// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

// Live camera scanner for the aircon QR code. Pops with the IMEI it found.
//
// Frames go through the same decoding as picked photos rather than through
// flutter_zxing's ReaderWidget, which cannot read the aircon stickers reliably
// (see aircon_qr_decoder.dart). Tapping focuses there, zooming refocuses on
// the middle, and a while without a result refocuses again.
//
// Far away and zoomed in, the stream holds too little detail to read the
// sticker. The system camera app does much better there, so the page also
// offers to take a photo with it.

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/aircon_qr_decoder.dart';

class AirconQrScannerPage extends StatefulWidget {
  const AirconQrScannerPage({super.key});

  @override
  State<AirconQrScannerPage> createState() => _AirconQrScannerPageState();
}

class _AirconQrScannerPageState extends State<AirconQrScannerPage>
    with WidgetsBindingObserver {
  /// Frames decoded at the same time, each on its own isolate.
  static const _maxDecoding = 2;

  /// How long scanning may go without focusing before focusing again.
  static const _refocusInterval = Duration(seconds: 3);

  CameraController? _controller;
  Object? _error;

  /// Whether the camera should be running. A camera still opening checks it
  /// after each step, as stopping cannot reach it before it is assigned.
  bool _wantCamera = false;
  Future<void>? _starting;
  Future<void>? _releasing;

  int _decoding = 0;
  bool _finished = false;
  int _frameIndex = 0;
  DateTime? _lastInvalidToast;

  double _zoom = 1, _minZoom = 1, _maxZoom = 1, _zoomAtScaleStart = 1;
  bool _torch = false;
  bool _decodingPhoto = false;

  Timer? _refocusTimer;
  DateTime _lastFocus = DateTime.now();
  Offset _focusPoint = const Offset(0.5, 0.5);
  Offset? _focusIndicator;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera(rebuild: false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_controller == null) _startCamera();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _stopCamera();
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _startCamera() {
    _wantCamera = true;
    if (_finished) return Future.value();
    return _starting ??= _openCamera().whenComplete(() => _starting = null);
  }

  Future<void> _openCamera() async {
    CameraController? controller;
    bool cancelled() => !mounted || !_wantCamera;
    try {
      // The camera may refuse to open while the last controller still holds it.
      await _releasing;
      if (cancelled()) return;
      final cameras = await availableCameras();
      if (cancelled()) return;
      if (cameras.isEmpty) throw CameraException('noCamera', null);
      controller = CameraController(
        cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        ),
        // The default 720p leaves too few pixels per module on a small
        // sticker, and looks blurry once zoomed in.
        ResolutionPreset.veryHigh,
        enableAudio: false,
        // Both put luminance, or something cheap to turn into it, in the
        // first plane.
        imageFormatGroup: Platform.isIOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      if (cancelled()) return;

      // Not every device supports these; scanning works without them.
      try {
        _minZoom = await controller.getMinZoomLevel();
        _maxZoom = await controller.getMaxZoomLevel();
        _zoom = _zoom.clamp(_minZoom, _maxZoom);
        await controller.setZoomLevel(_zoom);
      } catch (_) {
        _minZoom = _maxZoom = _zoom = 1;
      }
      try {
        await controller.setFocusMode(FocusMode.auto);
      } catch (_) {}
      if (cancelled()) return;
      await controller.startImageStream(_onFrame);
      if (cancelled()) return;

      // Continuous autofocus alone often settles soft when zoomed in, while
      // starting a focus run every so often reliably sharpens the code.
      _refocusTimer = Timer.periodic(_refocusInterval, (_) {
        if (DateTime.now().difference(_lastFocus) >= _refocusInterval) {
          _focus(_focusPoint);
        }
      });
      setState(() {
        _controller = controller;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (controller != null && !identical(_controller, controller)) {
        await _release(controller);
      }
    }
  }

  /// Stops the camera, completing once it is released, including one that was
  /// still opening.
  Future<void> _stopCamera({bool rebuild = true}) async {
    _wantCamera = false;
    _refocusTimer?.cancel();
    _refocusTimer = null;
    final controller = _controller;
    _controller = null;
    _torch = false;
    if (controller != null) {
      if (rebuild && mounted) setState(() {});
      _release(controller);
    }
    await _starting;
    await _releasing;
  }

  Future<void> _release(CameraController controller) =>
      _releasing = controller.dispose().catchError((Object _) {});

  void _onFrame(CameraImage image) {
    if (_decoding >= _maxDecoding || _finished) return;
    _decoding++;

    final plane = image.planes.first;
    final frame = AirconQrFrame(
      bytes: plane.bytes,
      width: image.width,
      height: image.height,
      bytesPerRow: plane.bytesPerRow,
      isBgra: image.format.group == ImageFormatGroup.bgra8888,
    );
    decodeAirconImeiFromCameraFrame(
      frame,
      _frameIndex++,
    ).then(_onResult).catchError((_) {}).whenComplete(() => _decoding--);
  }

  void _onResult(AirconQrResult result) {
    if (!mounted || _finished) return;

    final imei = result.imei;
    if (imei != null) {
      _finished = true;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(imei);
      return;
    }

    if (!result.foundOtherCode) return;
    // Frames arrive quickly, so do not stack up a toast for each.
    final now = DateTime.now();
    if (_lastInvalidToast != null &&
        now.difference(_lastInvalidToast!) < const Duration(seconds: 3)) {
      return;
    }
    _lastInvalidToast = now;
    showToast(context: context, msg: context.t.setting.airconImeiInvalid);
  }

  /// Focuses at [point], given as a fraction of the preview.
  ///
  /// Only the focus point is set: on Android each metering call starts its own
  /// focus run, and a second one for exposure cancelled the first. Exposure
  /// stays automatic.
  Future<void> _focus(Offset point) async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        !controller.value.focusPointSupported) {
      return;
    }
    _lastFocus = DateTime.now();
    _focusPoint = point;
    try {
      await controller.setFocusPoint(point);
    } catch (_) {
      // Some devices reject metering points; continuous autofocus still runs.
    }
  }

  Future<void> _takePhoto() async {
    try {
      // Let the camera app have the camera.
      await _stopCamera();
      final photo = await ImagePicker().pickImage(
        source: ImageSource.camera,
        requestFullMetadata: false,
      );
      if (photo == null || !mounted) return;

      setState(() => _decodingPhoto = true);
      final imei = await decodeAirconImeiFromImageFile(photo.path);
      if (!mounted) return;
      if (imei != null) {
        _onResult((imei: imei, foundOtherCode: false));
        return;
      }
      showToast(context: context, msg: context.t.setting.airconImeiInvalid);
    } catch (_) {
      if (mounted) {
        showToast(context: context, msg: context.t.setting.airconImeiInvalid);
      }
    } finally {
      if (mounted) {
        setState(() => _decodingPhoto = false);
        if (_controller == null) _startCamera();
      }
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.setFlashMode(_torch ? FlashMode.off : FlashMode.torch);
      setState(() => _torch = !_torch);
    } catch (_) {}
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final controller = _controller;
    if (controller == null || details.pointerCount < 2) return;
    final zoom = (_zoomAtScaleStart * details.scale).clamp(_minZoom, _maxZoom);
    if (zoom == _zoom) return;
    setState(() => _zoom = zoom);
    controller.setZoomLevel(zoom).catchError((_) {});
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_zoom == _zoomAtScaleStart) return;
    // Autofocus does not always follow a zoom change, which left the picture
    // blurry until the camera was moved. The code is usually in the middle.
    _focus(const Offset(0.5, 0.5));
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(context.t.setting.scanAirconQr),
        actions: [
          if (controller != null)
            IconButton(
              onPressed: _toggleTorch,
              icon: Icon(_torch ? Icons.flash_on : Icons.flash_off),
            ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  context.t.setting.airconCameraError(error: _error.toString()),
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : controller == null || _decodingPhoto
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) =>
                  _buildPreview(controller, constraints.biggest),
            ),
    );
  }

  Widget _buildPreview(CameraController controller, Size viewport) {
    // The preview size is reported in the sensor's landscape orientation.
    final previewSize = controller.value.previewSize ?? viewport;
    final portrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    final preview = portrait
        ? Size(previewSize.height, previewSize.width)
        : previewSize;

    // Fill the screen; work out where the cropped preview lands so a tap can
    // be turned into a point on it.
    final scale = max(
      viewport.width / preview.width,
      viewport.height / preview.height,
    );
    final shown = preview * scale;
    final origin = Offset(
      (viewport.width - shown.width) / 2,
      (viewport.height - shown.height) / 2,
    );

    // The part of the frame that is decoded, see [airconQrScanArea].
    final frameSide = min(
      shown.shortestSide * airconQrScanArea,
      viewport.shortestSide - 32,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        final local = details.localPosition - origin;
        final point = Offset(
          (local.dx / shown.width).clamp(0.0, 1.0),
          (local.dy / shown.height).clamp(0.0, 1.0),
        );
        final indicator = details.localPosition;
        setState(() => _focusIndicator = indicator);
        // Keep the ring up until the camera has finished focusing.
        Future.wait([
          _focus(point),
          Future.delayed(const Duration(milliseconds: 600)),
        ]).whenComplete(() {
          if (mounted && _focusIndicator == indicator) {
            setState(() => _focusIndicator = null);
          }
        });
      },
      onScaleStart: (_) => _zoomAtScaleStart = _zoom,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: SizedBox(
                width: shown.width,
                height: shown.height,
                child: CameraPreview(controller),
              ),
            ),
          ),
          Center(
            child: Container(
              width: frameSide,
              height: frameSide,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          if (_focusIndicator != null)
            Positioned(
              left: _focusIndicator!.dx - 32,
              top: _focusIndicator!.dy - 32,
              child: IgnorePointer(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber, width: 2),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24 + MediaQuery.paddingOf(context).bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_maxZoom > _minZoom)
                  Text(
                    "${_zoom.toStringAsFixed(1)}x",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  context.t.setting.airconScanHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(context.t.setting.airconTakePhoto),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
