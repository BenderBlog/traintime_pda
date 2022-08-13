import 'package:flutter/material.dart';
import 'package:watermeter/ui/tool/sport/sportWindow.dart';

class ToolWindow extends StatelessWidget {
  ToolWindow({Key? key, required this.contextFromPage}) : super(key: key);
  BuildContext contextFromPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("工具箱"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Show Snackbar',
          onPressed: () {
            Navigator.pop(context);
            //ScaffoldMessenger.of(context).showSnackBar(
            //    const SnackBar(content: Text('Should back to the main menu.')));
          },
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          MaterialButton(
            child: Text("体育查询"),
            onPressed: () {
              Navigator.of(contextFromPage).push(
                MaterialPageRoute(builder: (context) {
                  return SportWindow();
                }),
              );
            },
          )
        ]
      )
    );
  }
}
