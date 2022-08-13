import 'package:flutter/material.dart';

class ClassTable extends StatelessWidget {
  const ClassTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("课表 第x周"),
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
