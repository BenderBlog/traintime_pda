import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/preference.dart' as user_perference;

class SportPasswordDialog extends StatefulWidget {
  const SportPasswordDialog({super.key});

  @override
  State<SportPasswordDialog> createState() => _SportPasswordDialogState();
}

class _SportPasswordDialogState extends State<SportPasswordDialog> {
  /// Sport Password Text Editing Controller
  final TextEditingController _sportPasswordController = TextEditingController();

  bool _couldView = true;

  // 用于标识是否通过返回按钮关闭
  // bool _wasDismissedViaBackButton = false;

  @override
  void initState() {
    super.initState();
    String initialText =
        user_perference.getString(user_perference.Preference.sportPassword);
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
      onPopInvoked: (popInvokedCallback) {
        // _wasDismissedViaBackButton = true;
        popInvokedCallback; // 允许导航器继续处理返回操作
      },
      child: AlertDialog(
        title: const Text('修改体育系统密码'),
        content: TextField(
          autofocus: true,
          controller: _sportPasswordController,
          obscureText: _couldView,
          decoration: InputDecoration(
            hintText: "请在此输入密码",
            border: const OutlineInputBorder(),
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
            child: const Text('取消'),
            onPressed: () {
              Navigator.of(context).pop<bool>(false); // 返回 false
            },
          ),
          TextButton(
            child: const Text('提交'),
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
                showToast(context: context, msg: "输入空白!");
              }
            },
          ),
        ],
      ),
    );
  }
}
