import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/preference.dart' as user_perference;
import 'package:watermeter/generated/translations.g.dart';

class SportPasswordDialog extends StatefulWidget {
  const SportPasswordDialog({super.key});

  @override
  State<SportPasswordDialog> createState() => _SportPasswordDialogState();
}

class _SportPasswordDialogState extends State<SportPasswordDialog> {
  /// Sport Password Text Editing Controller
  final TextEditingController _sportPasswordController =
      TextEditingController();

  bool _couldView = true;

  // 用于标识是否通过返回按钮关闭
  // bool _wasDismissedViaBackButton = false;

  @override
  void initState() {
    super.initState();
    String initialText = user_perference.getString(
      user_perference.Preference.sportPassword,
    );
    _sportPasswordController.text = initialText;
    _sportPasswordController.selection = TextSelection.fromPosition(
      TextPosition(offset: initialText.length),
    );
  }

  @override
  void dispose() {
    _sportPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: AlertDialog(
        title: Text(
          context.t.setting.changeSportTitle,
        ),
        content: TextField(
          autofocus: true,
          controller: _sportPasswordController,
          obscureText: _couldView,
          decoration: InputDecoration(
            hintText: context.t.setting.changePasswordDialog.inputHint,
            suffixIcon: IconButton(
              icon: Icon(_couldView ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _couldView = !_couldView;
                });
              },
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(context.t.common.cancel),
            onPressed: () {
              Navigator.of(context).pop<bool>(false); // 返回 false
            },
          ),
          TextButton(
            child: Text(context.t.common.confirm),
            onPressed: () async {
              if (_sportPasswordController.text.isNotEmpty) {
                await user_perference.setString(
                  user_perference.Preference.sportPassword,
                  _sportPasswordController.text,
                );
                if (context.mounted) {
                  Navigator.of(context).pop<bool>(true); // 返回 true
                }
              } else {
                showToast(
                  context: context,
                  msg: context.t.setting.changePasswordDialog.blankInput,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
