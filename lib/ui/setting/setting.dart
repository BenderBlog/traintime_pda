import 'package:flutter/material.dart';

class SettingWindow extends StatelessWidget {
  const SettingWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("设置页"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            //ScaffoldMessenger.of(context).showSnackBar(
            //    const SnackBar(content: Text('Should back to the main menu.')));
          },
        ),
      ),
    );
  }
}
