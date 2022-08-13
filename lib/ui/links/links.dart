import 'package:flutter/material.dart';

class LinksWindow extends StatelessWidget {
  const LinksWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("有用的链接"),
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
