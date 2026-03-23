// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'dart:convert' show base64Decode;
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/dorm_water_session.dart';
import 'package:watermeter/repository/preference.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

class DormWaterWindow extends StatefulWidget {
  const DormWaterWindow({super.key});

  @override
  State<DormWaterWindow> createState() => _DormWaterWindowState();
}

class _DormWaterWindowState extends State<DormWaterWindow> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _imageCodeController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  
  late DormWaterSession _session;
  
  // Login tab states
  String? _captchaImageBase64;
  bool _isCaptchaLoading = false;
  String? _captchaError;
  bool _isLoggingIn = false;
  bool _isLoggedIn = false;

  // Device list tab states
  List<DormWaterDevice> _devices = [];
  bool _isLoadingDevices = false;
  String? _devicesError;
  
  // Water control states
  DormWaterDevice? _currentDevice;
  bool _isWaterRunning = false;
  int _statusCheckCount = 0; // Counter for consecutive status checks (status == 99)

  @override
  void initState() {
    super.initState();
    _session = DormWaterSession();
    _checkLoginStatus();
    _loadCaptcha();
  }

  /// Check if user is already logged in (token exists)
  void _checkLoginStatus() {
    final token = getString(Preference.dormWaterToken);
    setState(() {
      _isLoggedIn = token.isNotEmpty;
    });
    if (_isLoggedIn) {
      _loadDevices();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _imageCodeController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  /// Load captcha image from API
  Future<void> _loadCaptcha() async {
    setState(() {
      _isCaptchaLoading = true;
      _captchaError = null;
    });

    try {
      final captchaData = await _session.getCaptcha();
      setState(() {
        _captchaImageBase64 = captchaData.imageBase64;
        _isCaptchaLoading = false;
      });
    } catch (e) {
      setState(() {
        _captchaError = e.toString();
        _isCaptchaLoading = false;
      });
    }
  }

  /// Refresh captcha by calling _loadCaptcha again
  void _refreshCaptcha() {
    _loadCaptcha();
    _imageCodeController.clear();
  }

  /// Send SMS code to user's phone
  Future<void> _sendSmsCode() async {
    final phone = _phoneController.text.trim();
    final imageCode = _imageCodeController.text.trim();

    if (phone.isEmpty) {
      if (!mounted) return;
      showToast(context: context, msg: FlutterI18n.translate(context, "dorm_water.phone_required"));
      return;
    }

    if (imageCode.isEmpty) {
      if (!mounted) return;
      showToast(context: context, msg: FlutterI18n.translate(context, "dorm_water.image_code_required"));
      return;
    }

    try {
      await _session.sendSmsCode(
        phoneNumber: phone,
        imageCode: imageCode,
      );
      if (!mounted) return;
      showToast(context: context, msg: FlutterI18n.translate(context, "dorm_water.sms_sent"));
    } catch (e) {
      if (!mounted) return;
      showToast(context: context, msg: "${FlutterI18n.translate(context, "dorm_water.sms_failed")}: $e");
      _loadCaptcha();
    }
  }

  /// Login with SMS code
  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final smsCode = _smsCodeController.text.trim();

    if (phone.isEmpty) {
      if (!mounted) return;
      showToast(context: context, msg: FlutterI18n.translate(context, "dorm_water.phone_required"));
      return;
    }

    if (smsCode.isEmpty) {
      if (!mounted) return;
      showToast(context: context, msg: FlutterI18n.translate(context, "dorm_water.sms_code_required"));
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    try {
      await _session.login(
        phoneNumber: phone,
        smsCode: smsCode,
      );
      if (!mounted) return;
      showToast(context: context, msg: FlutterI18n.translate(context, "dorm_water.login_success"));
      setState(() {
        _isLoggedIn = true;
      });
      _loadDevices();
    } catch (e) {
      if (!mounted) return;
      showToast(context: context, msg: "${FlutterI18n.translate(context, "dorm_water.login_failed")}: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  /// Logout and clear token
  Future<void> _logout() async {
    await remove(Preference.dormWaterToken);
    await remove(Preference.dormWaterUid);
    await remove(Preference.dormWaterEid);
    
    if (!mounted) return;
    setState(() {
      _isLoggedIn = false;
      _devices = [];
      _phoneController.clear();
      _imageCodeController.clear();
      _smsCodeController.clear();
    });
    _loadCaptcha();
    
    if (!mounted) return;
    showToast(context: context, msg: FlutterI18n.translate(context, "dorm_water.logout_success"));
  }

  /// Load device list
  Future<void> _loadDevices() async {
    setState(() {
      _isLoadingDevices = true;
      _devicesError = null;
    });

    try {
      final devices = await _session.getDeviceList();
      if (!mounted) return;
      setState(() {
        _devices = devices;
        _isLoadingDevices = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _devicesError = e.toString();
        _isLoadingDevices = false;
      });
      showToast(context: context, msg: "${FlutterI18n.translate(context, "dorm_water.fetch_devices_failed")}: $e");
    }
  }

  /// Start water dispensing
  Future<void> _startWater(DormWaterDevice device) async {
    setState(() {
      _currentDevice = device;
      _isWaterRunning = true;
      _statusCheckCount = 0; // Reset counter when starting water
    });

    try {
      await _session.startWater(deviceId: device.id);
      if (!mounted) return;
      showToast(context: context, msg: FlutterI18n.translate(context, "dorm_water.start_water_success"));
      // Start polling device status
      _pollDeviceStatus(device.id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isWaterRunning = false;
        _currentDevice = null;
      });
      showToast(context: context, msg: "${FlutterI18n.translate(context, "dorm_water.start_water_failed")}: $e");
    }
  }

  /// End water dispensing
  Future<void> _endWater(String deviceId) async {
    try {
      await _session.endWater(deviceId: deviceId);
      if (!mounted) return;
      showToast(context: context, msg: FlutterI18n.translate(context, "dorm_water.end_water_success"));
      setState(() {
        _isWaterRunning = false;
        _currentDevice = null;
        _statusCheckCount = 0; // Reset counter when ending water
      });
    } catch (e) {
      if (!mounted) return;
      showToast(context: context, msg: "${FlutterI18n.translate(context, "dorm_water.end_water_failed")}: $e");
    }
  }

  /// Poll device status until it reaches idle state (status == 99)
  /// Requires consecutive 3 detections of status == 99 to confirm device is truly stopped
  Future<void> _pollDeviceStatus(String deviceId) async {
    const maxAttempts = 60; // Max 60 attempts (60 seconds if polling every 1 second)
    const requiredIdleCount = 3; // Need to detect idle status 3 times consecutively
    int attempts = 0;

    while (attempts < maxAttempts && _isWaterRunning) {
      if (!mounted) return;

      try {
        await Future.delayed(const Duration(seconds: 1));
        final status = await _session.checkDeviceStatus(deviceId: deviceId);
        
        if (!mounted) return;

        // Status 99 means device is ready/idle
        if (status == 99) {
          _statusCheckCount++;
          
          // If we've detected idle state 3 times consecutively, confirm device is stopped
          if (_statusCheckCount >= requiredIdleCount) {
            setState(() {
              _isWaterRunning = false;
              _currentDevice = null;
              _statusCheckCount = 0;
            });
            if (mounted) {
              showToast(context: context, msg: FlutterI18n.translate(context, "dorm_water.device_status_ready"));
            }
            return;
          }
        } else {
          // If device is not idle, reset counter (network fluctuation or still dispensing)
          _statusCheckCount = 0;
        }
      } catch (e) {
        if (!mounted) return;
        // Reset counter on error to avoid false detection
        _statusCheckCount = 0;
        // Continue polling even if there's an error
      }

      attempts++;
    }

    // Timeout reached
    if (mounted) {
      setState(() {
        _isWaterRunning = false;
        _currentDevice = null;
        _statusCheckCount = 0;
      });
      showToast(context: context, msg: "Device status check timeout");
    }
  }



  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return _buildDeviceListPage(context);
    } else {
      return _buildLoginPage(context);
    }
  }

  /// Build login page
  Widget _buildLoginPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "dorm_water.title")),
      ),
      body: _buildLoginTab(context),
    );
  }

  /// Build device list page
  Widget _buildDeviceListPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "dorm_water.title")),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: FlutterI18n.translate(context, "dorm_water.logout"),
          ),
        ],
      ),
      body: _buildDeviceListTab(context),
    );
  }

  /// Build login tab
  Widget _buildLoginTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
          // Phone input
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: FlutterI18n.translate(context, "dorm_water.phone"),
            ),
          ),
          const SizedBox(height: 12),
          // Image code input with captcha image on the right
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _imageCodeController,
                  decoration: InputDecoration(
                    labelText: FlutterI18n.translate(context, "dorm_water.image_code"),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildCaptchaImage(context),
            ],
          ),
          const SizedBox(height: 12),
          // SMS code input
          TextField(
            controller: _smsCodeController,
            decoration: InputDecoration(
              labelText: FlutterI18n.translate(context, "dorm_water.sms_code"),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: _sendSmsCode,
                  child: Text(
                    FlutterI18n.translate(context, "dorm_water.send_sms"),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _isLoggingIn ? null : _login,
                  child: Text(
                    FlutterI18n.translate(context, "dorm_water.login"),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    /// Build device list tab
    Widget _buildDeviceListTab(BuildContext context) {
      if (_isLoadingDevices) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(FlutterI18n.translate(context, "dorm_water.loading_devices")),
            ],
          ),
        );
      }

      if (_devicesError != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                FlutterI18n.translate(context, "dorm_water.fetch_devices_failed"),
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadDevices,
                child: Text(FlutterI18n.translate(context, "dorm_water.retry_load_devices")),
              ),
            ],
          ),
        );
      }

      if (_devices.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(FlutterI18n.translate(context, "dorm_water.no_devices")),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadDevices,
                child: Text(FlutterI18n.translate(context, "dorm_water.select_device")),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          return Card(
            child: ListTile(
              title: Text(device.name),
              subtitle: Text("ID: ${device.id}"),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(MingCuteIcons.mgc_star_fill),
                      onPressed: () {
                        // TODO: Placeholder - Star device
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        (_isWaterRunning && _currentDevice?.id == device.id)
                            ? MingCuteIcons.mgc_stop_fill
                            : MingCuteIcons.mgc_play_fill,
                      ),
                      onPressed: () {
                        if (_isWaterRunning && _currentDevice?.id == device.id) {
                          _endWater(device.id);
                        } else {
                          _startWater(device);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    /// Build captcha image widget (clickable to refresh)
  Widget _buildCaptchaImage(BuildContext context) {
    // Loading state
    if (_isCaptchaLoading) {
      return Container(
        width: 140,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Error state
    if (_captchaError != null) {
      return GestureDetector(
        onTap: _refreshCaptcha,
        child: Container(
          width: 140,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              FlutterI18n.translate(context, "dorm_water.captcha_error"),
              style: const TextStyle(color: Colors.red, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Image loaded state
    if (_captchaImageBase64 != null) {
      return GestureDetector(
        onTap: _refreshCaptcha,
        child: Container(
          width: 140,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Image.memory(
            base64Decode(_captchaImageBase64!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Placeholder
    return Container(
      width: 140,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text("No image", style: TextStyle(fontSize: 10)),
      ),
    );
  }
}
