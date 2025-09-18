// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Electricity account dialog.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/logger.dart';

enum InputMode { generator, manual }

enum CampusLocation { south, north }

enum YardLocation { south, north }

enum ApartmentLocation { south, north }

/// A dialog used to input electricity account.
/// Saving logic have implemented, if success, return true, else return false.
class ElectricityAccountDialog extends StatefulWidget {
  final Future<String> Function()? onFetchFromNetwork;
  final Future<void> Function(String) onSaveAccount;
  final String? initialAccountNumber;

  const ElectricityAccountDialog({
    super.key,
    this.onFetchFromNetwork,
    required this.onSaveAccount,
    this.initialAccountNumber,
  });

  @override
  State<ElectricityAccountDialog> createState() =>
      _ElectricityAccountDialogState();
}

class _ElectricityAccountDialogState extends State<ElectricityAccountDialog> {
  final _generatorFormKey = GlobalKey<FormState>();
  final _manualFormKey = GlobalKey<FormState>();

  final _buildingController = TextEditingController();
  final _roomController = TextEditingController();
  final _unitOrZoneController = TextEditingController();
  final _floorController = TextEditingController();
  final _manualInputController = TextEditingController();

  CampusLocation _selectedCampus = CampusLocation.south;
  String _generatedAccountPreview = '';
  InputMode _currentMode = InputMode.manual;
  bool _isConfirming = false;
  bool _isFetching = false;

  String _unitOrZoneLabel = 'setting.change_electricity_account.unitOrZone';
  bool _showUnitOrZoneInput = false;
  bool _showFloorInput = false;
  bool _showYardSelector = false;
  YardLocation? _selectedYard;
  bool _showBuildingPartSelector = false;
  ApartmentLocation? _selectedBuildingPart;

  @override
  void initState() {
    super.initState();
    if (widget.initialAccountNumber != null &&
        widget.initialAccountNumber!.isNotEmpty) {
      _manualInputController.text = widget.initialAccountNumber!;
      //_currentMode = InputMode.manual;
    }
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _roomController.dispose();
    _unitOrZoneController.dispose();
    _floorController.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  Future<void> _handleFetchFromNetwork() async {
    if (widget.onFetchFromNetwork == null) return;

    setState(() => _isFetching = true);

    try {
      final String accountNumber = await widget.onFetchFromNetwork!();
      _manualInputController.text = accountNumber;
      if (mounted) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            "setting.change_electricity_account.successful_fetch",
            translationParams: {"accountNumber": accountNumber},
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            "setting.change_electricity_account.failed_fetch",
            translationParams: {"e": e.toString()},
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFetching = false);
      }
    }
  }

  void _updateGeneratorFormFields() {
    setState(() {
      _isConfirming = false;
      _generatedAccountPreview = '';
    });
    final building = int.tryParse(_buildingController.text);
    setState(() {
      _showUnitOrZoneInput = false;
      _showFloorInput = false;
      _showYardSelector = false;
      _selectedYard = null;
      _showBuildingPartSelector = false;
      _selectedBuildingPart = null;
      _unitOrZoneController.clear();
      _floorController.clear();

      if (building == null) return;
      if (_selectedCampus == CampusLocation.north) {
        if ([4, 11, 24, 47, 48, 49, 51, 52, 53, 55].contains(building)) {
          _showYardSelector = true;
        }
        if ([21, 24, 28, 47, 48, 49, 51, 52, 53, 55].contains(building)) {
          _unitOrZoneLabel = 'setting.change_electricity_account.unitCode';
          _showUnitOrZoneInput = true;
        } else if ([4, 94, 95, 96, 97, 98].contains(building)) {
          _unitOrZoneLabel = 'setting.change_electricity_account.levelCode';
          _showUnitOrZoneInput = true;
        } else {
          _unitOrZoneLabel = 'setting.change_electricity_account.unitCode';
          _showUnitOrZoneInput = true;
        }
      } else {
        if ([1, 2, 3, 4].contains(building)) {
          _unitOrZoneLabel = 'setting.change_electricity_account.zoneCode';
          _showUnitOrZoneInput = true;
          _showFloorInput = true;
        } else if ([5, 8, 9, 10, 11, 12, 14].contains(building)) {
          _unitOrZoneLabel = 'setting.change_electricity_account.zoneCode';
          _showUnitOrZoneInput = true;
        } else if ([19, 20, 21, 22].contains(building)) {
          _showFloorInput = true;
        } else if (building == 18) {
          _showBuildingPartSelector = true;
          _showFloorInput = true;
        }
      }
    });
  }

  void _processAccount() {
    if (_currentMode == InputMode.manual) {
      if (_manualFormKey.currentState!.validate()) {
        _saveAccount(_manualInputController.text);
      }
      return;
    }

    if (_isConfirming) {
      _saveAccount(_generatedAccountPreview);
    } else {
      if (_generatorFormKey.currentState!.validate()) {
        String? accountNumber = _generateAccountNumber();
        if (accountNumber != null) {
          setState(() {
            _generatedAccountPreview = accountNumber;
            _isConfirming = true;
          });
        }
      }
    }
  }

  Future<void> _saveAccount(String accountNumber) async {
    log.info("[ElectricityAccountDialog] Final account: $accountNumber");
    await widget.onSaveAccount(accountNumber);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _quitWithoutSave() {
    log.info("[ElectricityAccountDialog] User aborted.");
    Navigator.of(context).pop<bool>(false);
  }

  String? _generateAccountNumber() {
    try {
      final building = int.parse(_buildingController.text);
      final roomText = _roomController.text;
      final unitOrZoneText = _unitOrZoneController.text;
      final floorText = _floorController.text;
      String accountA, accountB, accountC, accountD, accountE = "";
      if (_selectedCampus == CampusLocation.south) {
        accountA = "2";
        accountB = building.toString().padLeft(3, "0");
        if ([1, 2, 3, 4].contains(building)) {
          accountC = unitOrZoneText + floorText;
          accountD = roomText.padLeft(4, "0");
        } else if ([5, 8, 9, 10, 11, 12, 14].contains(building)) {
          accountC = unitOrZoneText.padLeft(2, "0");
          accountD = roomText.padLeft(4, unitOrZoneText);
        } else if ([6, 7].contains(building)) {
          accountC = "00";
          accountD = roomText.padLeft(4, "0");
        } else if ([13, 15].contains(building)) {
          accountC = "01";
          accountD = roomText.padLeft(4, "1");
        } else if ([19, 20, 21, 22].contains(building)) {
          accountC = "01";
          accountD = roomText.padLeft(4, floorText);
        } else if (building == 18) {
          accountC = (_selectedBuildingPart == ApartmentLocation.south)
              ? "10"
              : "20";
          accountD = roomText.padLeft(4, floorText);
        } else {
          throw UnknownRoleException;
        }
      } else {
        accountA = "1";
        accountB = building.toString().padLeft(3, "0");
        if ([4, 24, 47, 48, 49, 51, 52, 53, 55].contains(building)) {
          accountE = (_selectedYard == YardLocation.south) ? "1" : "2";
        } else if (building == 11) {
          accountE = (_selectedYard == YardLocation.south) ? "2" : "1";
        }
        if ([21, 24, 28, 47, 48, 49, 51, 52, 53, 55].contains(building)) {
          accountC = unitOrZoneText.padLeft(2, "0");
          accountD = roomText.padLeft(4, "0");
        } else if ([4, 94, 95, 96, 97, 98].contains(building)) {
          accountC = unitOrZoneText.padLeft(2, "0");
          accountD = roomText.padLeft(4, "0");
        } else {
          accountC = unitOrZoneText.padLeft(2, "0");
          accountD = roomText.padLeft(4, "0");
        }
        final int room = int.parse(roomText);
        if ([4, 24, 49, 51, 55].contains(building)) {
          if (![
            101,
            102,
            203,
            204,
            305,
            306,
            407,
            48,
            509,
            510,
          ].contains(room)) {
            accountE = "";
          }
        }
        if ([47, 48, 52, 53].contains(building)) {
          if (![101, 102, 103, 104].contains(room)) {
            accountE = "";
          }
        }
        if (![4, 11, 24, 47, 48, 49, 51, 52, 53, 55].contains(building)) {
          accountE = "";
        }
      }
      return "$accountA$accountB$accountC$accountD$accountE";
    } catch (e) {
      showToast(
        context: context,
        msg: FlutterI18n.translate(
          context,
          "setting.change_electricity_account.failed_generate",
          translationParams: {"e": e.toString().replaceAll("Exception: ", "")},
        ),
      );
      return null;
    }
  }

  Widget _buildGeneratorForm() {
    return Form(
      key: _generatorFormKey,
      child: IgnorePointer(
        ignoring: _isConfirming,
        child: Opacity(
          opacity: _isConfirming ? 0.5 : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<CampusLocation>(
                decoration: InputDecoration(
                  labelText: FlutterI18n.translate(
                    context,
                    "setting.change_electricity_account.campus",
                  ),
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: CampusLocation.values
                    .map(
                      (CampusLocation v) => DropdownMenuItem<CampusLocation>(
                        value: v,
                        child: Text(
                          FlutterI18n.translate(
                            context,
                            "setting.change_electricity_account.${v == CampusLocation.north ? "north" : "south"}Campus",
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedCampus = v!;
                  _buildingController.clear();
                  _roomController.clear();
                  _updateGeneratorFormFields();
                }),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _buildingController,
                decoration: InputDecoration(
                  labelText: FlutterI18n.translate(
                    context,
                    "setting.change_electricity_account.building_number",
                  ),
                  hintText: FlutterI18n.translate(
                    context,
                    "setting.change_electricity_account.building_number_hint",
                  ),
                  prefixIcon: Icon(Icons.domain),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => (v == null || v.isEmpty)
                    ? FlutterI18n.translate(
                        context,
                        "setting.change_electricity_account.building_number_query",
                      )
                    : null,
                onChanged: (v) => _updateGeneratorFormFields(),
              ),
              if (_showYardSelector) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<YardLocation>(
                  hint: Text(
                    FlutterI18n.translate(
                      context,
                      "setting.change_electricity_account.yard_hint",
                    ),
                  ),
                  decoration: InputDecoration(
                    labelText: FlutterI18n.translate(
                      context,
                      "setting.change_electricity_account.yard",
                    ),
                    prefixIcon: Icon(Icons.holiday_village),
                  ),
                  items: YardLocation.values
                      .map(
                        (YardLocation v) => DropdownMenuItem<YardLocation>(
                          value: v,
                          child: Text(
                            FlutterI18n.translate(
                              context,
                              "setting.change_electricity_account.${v == YardLocation.north ? "north" : "south"}Yard",
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedYard = v),
                  validator: (v) => (v == null)
                      ? FlutterI18n.translate(
                          context,
                          "setting.change_electricity_account.yard_query",
                        )
                      : null,
                ),
              ],
              if (_showBuildingPartSelector) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<ApartmentLocation>(
                  hint: Text(
                    FlutterI18n.translate(
                      context,
                      "setting.change_electricity_account.apartment_hint",
                    ),
                  ),
                  decoration: InputDecoration(
                    labelText: FlutterI18n.translate(
                      context,
                      "setting.change_electricity_account.apartment",
                    ),
                    prefixIcon: Icon(Icons.apartment),
                  ),
                  items: ApartmentLocation.values
                      .map(
                        (
                          ApartmentLocation v,
                        ) => DropdownMenuItem<ApartmentLocation>(
                          value: v,
                          child: Text(
                            FlutterI18n.translate(
                              context,
                              "setting.change_electricity_account.${v == ApartmentLocation.north ? "north" : "south"}Apartment",
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedBuildingPart = v),
                  validator: (v) => (v == null)
                      ? "setting.change_electricity_account.apartment_query"
                      : null,
                ),
              ],
              if (_showUnitOrZoneInput) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _unitOrZoneController,
                  decoration: InputDecoration(
                    labelText: FlutterI18n.translate(context, _unitOrZoneLabel),
                    prefixIcon: const Icon(Icons.map_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => (v == null || v.isEmpty)
                      ? FlutterI18n.translate(
                          context,
                          "setting.change_electricity_account.pleaseInput",
                          translationParams: {
                            "unitOrZoneCode": FlutterI18n.translate(
                              context,
                              _unitOrZoneLabel,
                            ),
                          },
                        )
                      : null,
                ),
              ],
              if (_showFloorInput) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _floorController,
                  decoration: InputDecoration(
                    labelText: FlutterI18n.translate(
                      context,
                      "setting.change_electricity_account.levelCode",
                    ),
                    prefixIcon: Icon(Icons.layers),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => (v == null || v.isEmpty)
                      ? FlutterI18n.translate(
                          context,
                          "setting.change_electricity_account.levelCode_query",
                        )
                      : null,
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomController,
                decoration: InputDecoration(
                  labelText: FlutterI18n.translate(
                    context,
                    "setting.change_electricity_account.roomCode",
                  ),
                  hintText: FlutterI18n.translate(
                    context,
                    "setting.change_electricity_account.roomCode_hint",
                  ),
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => (v == null || v.isEmpty)
                    ? FlutterI18n.translate(
                        context,
                        "setting.change_electricity_account.roomCode_query",
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualInputForm() {
    return Form(
      key: _manualFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _manualInputController,
            decoration: InputDecoration(
              labelText: FlutterI18n.translate(
                context,
                "setting.change_electricity_account.account",
              ),
              hintText: FlutterI18n.translate(
                context,
                "setting.change_electricity_account.account_hint",
              ),
              prefixIcon: Icon(Icons.pin_outlined),
            ),
            keyboardType: TextInputType.number,
            readOnly: _isFetching,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return FlutterI18n.translate(
                  context,
                  "setting.change_electricity_account.account_query",
                );
              }
              if (value.length < 10) {
                return FlutterI18n.translate(
                  context,
                  "setting.change_electricity_account.account_length",
                );
              }
              return null;
            },
          ),
          if (widget.onFetchFromNetwork != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isFetching ? null : _handleFetchFromNetwork,
              icon: _isFetching
                  ? Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.sync_rounded, color: Colors.white),
              label: Text(
                FlutterI18n.translate(
                  context,
                  "setting.change_electricity_account.${_isFetching ? 'fetching' : 'fetch_from_internet'}",
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (_currentMode == InputMode.manual) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.save_alt_rounded),
        label: Text(
          FlutterI18n.translate(
            context,
            "setting.change_electricity_account.save_account",
          ),
        ),
        onPressed: _processAccount,
      );
    }

    if (_isConfirming) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        label: Text(
          FlutterI18n.translate(
            context,
            "setting.change_electricity_account.confirm_saving",
          ),
        ),
        onPressed: _processAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
        ),
      );
    } else {
      return ElevatedButton.icon(
        icon: const Icon(Icons.smart_toy_outlined),
        label: Text(
          FlutterI18n.translate(
            context,
            "setting.change_electricity_account.calculate_account",
          ),
        ),
        onPressed: _processAccount,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        FlutterI18n.translate(
          context,
          "setting.change_electricity_account.title",
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<InputMode>(
              segments: <ButtonSegment<InputMode>>[
                ButtonSegment<InputMode>(
                  value: InputMode.manual,
                  icon: Icon(Icons.edit_outlined),
                  label: Text(
                    FlutterI18n.translate(
                      context,
                      "setting.change_electricity_account.input",
                    ),
                  ),
                ),
                ButtonSegment<InputMode>(
                  value: InputMode.generator,
                  icon: Icon(Icons.smart_toy_outlined),
                  label: Text(
                    FlutterI18n.translate(
                      context,
                      "setting.change_electricity_account.calculate",
                    ),
                  ),
                ),
              ],
              selected: <InputMode>{_currentMode},
              onSelectionChanged: (Set<InputMode> newSelection) {
                setState(() {
                  _currentMode = newSelection.first;
                  _isConfirming = false;
                  _generatedAccountPreview = '';
                });
              },
            ),
            const SizedBox(height: 20),

            if (_isConfirming && _generatedAccountPreview.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.indigo),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.indigo),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FlutterI18n.translate(
                              context,
                              "setting.change_electricity_account.confirm_account",
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          SelectableText(
                            _generatedAccountPreview,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      child: Text(
                        FlutterI18n.translate(
                          context,
                          "setting.change_electricity_account.change",
                        ),
                      ),
                      onPressed: () => setState(() {
                        _isConfirming = false;
                        _generatedAccountPreview = '';
                      }),
                    ),
                  ],
                ),
              ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _currentMode == InputMode.generator
                  ? _buildGeneratorForm()
                  : _buildManualInputForm(),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            FlutterI18n.translate(
              context,
              "setting.change_electricity_account.cancel",
            ),
          ),
          onPressed: () => _quitWithoutSave(),
        ),
        _buildActionButton(),
      ],
    );
  }
}

class UnknownRoleException implements Exception {}
