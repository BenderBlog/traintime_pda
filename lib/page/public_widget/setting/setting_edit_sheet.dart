// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

Future<T?> showSettingSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showM3EModalBottomSheet<T>(
    context: context,
    builder: builder,
    isScrollControlled: true,
    useRootNavigator: true,
    constraints: BoxConstraints(maxWidth: sheetMaxWidth),
  );
}

class SettingSheet extends StatelessWidget {
  const SettingSheet({
    super.key,
    required this.title,
    required this.child,
    this.style,
  });

  final String title;
  final Widget child;
  final M3EBottomSheetStyle? style;

  @override
  Widget build(BuildContext context) {
    // Modal sheets do not avoid the keyboard by themselves, lift the sheet
    // above the input method so focused fields stay visible.
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: M3EBottomSheet(title: Text(title), style: style, child: child),
    );
  }
}

/// Keeps edits local until validation and persistence both succeed.
class SettingTextEditSheet extends StatefulWidget {
  const SettingTextEditSheet({
    super.key,
    required this.title,
    required this.initialValue,
    required this.label,
    required this.saveLabel,
    required this.cancelLabel,
    required this.failureMessage,
    required this.validator,
    required this.onSave,
    this.description,
    this.suffixText,
    this.keyboardType,
    this.inputFormatters,
    this.isPassword = false,
    this.visibilityLabel,
    this.signToggleLabel,
  });

  final String title;
  final String initialValue;
  final String label;
  final String saveLabel;
  final String cancelLabel;
  final String failureMessage;
  final String? description;
  final String? suffixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isPassword;
  final String? visibilityLabel;
  final String? signToggleLabel;
  final String? Function(String value) validator;
  final Future<void> Function(String value) onSave;

  @override
  State<SettingTextEditSheet> createState() => _SettingTextEditSheetState();
}

class _SettingTextEditSheetState extends State<SettingTextEditSheet> {
  late final _controller = TextEditingController(text: widget.initialValue);
  late bool _obscured = widget.isPassword;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final value = _controller.text;
    final error = widget.validator(value);
    setState(() {
      _error = error;
    });
    if (error != null) return;
    setState(() {
      _saving = true;
    });
    try {
      await widget.onSave(value);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = widget.failureMessage;
          _saving = false;
        });
      }
    }
  }

  void _toggleSign() {
    final text = _controller.text;
    final value = text.startsWith('-') ? text.substring(1) : '-$text';
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: SettingSheet(
        title: widget.title,
        style: const M3EBottomSheetStyle(
          dragHandlePadding: EdgeInsets.symmetric(vertical: 12),
          padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.description != null) ...[
                Text(
                  widget.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                autofocus: true,
                controller: _controller,
                enabled: !_saving,
                obscureText: _obscured,
                autocorrect: !widget.isPassword,
                enableSuggestions: !widget.isPassword,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                onChanged: (_) {
                  if (_error != null) {
                    setState(() {
                      _error = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: widget.label,
                  suffixText: widget.suffixText,
                  errorText: _error,
                  errorMaxLines: 3,
                  border: const OutlineInputBorder(),
                  suffixIcon: widget.isPassword
                      ? IconButton(
                          tooltip: widget.visibilityLabel,
                          onPressed: _saving
                              ? null
                              : () => setState(() {
                                  _obscured = !_obscured;
                                }),
                          icon: Icon(
                            _obscured ? Icons.visibility : Icons.visibility_off,
                          ),
                        )
                      : widget.signToggleLabel != null
                      ? IconButton(
                          tooltip: widget.signToggleLabel,
                          onPressed: _saving ? null : _toggleSign,
                          icon: const Icon(Icons.exposure),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 8,
                overflowSpacing: 8,
                children: [
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.pop(context, false),
                    child: Text(widget.cancelLabel),
                  ),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.saveLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
