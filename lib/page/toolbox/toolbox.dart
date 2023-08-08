import 'package:flutter/material.dart';
import 'package:watermeter/page/toolbox/toolbox_addresses.dart';
import 'package:watermeter/page/toolbox/webview.dart';

class ToolBox extends StatelessWidget {
  const ToolBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("更多功能"),
      ),
      body: ListView.separated(
        itemCount: ToolBoxAddresses.values.length,
        itemBuilder: (context, index) => ListTile(
          leading: Icon(ToolBoxAddresses.values[index].iconData),
          title: Text(ToolBoxAddresses.values[index].name),
          subtitle: Text(ToolBoxAddresses.values[index].description),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WebView(
                  name: ToolBoxAddresses.values[index].name,
                  cookieDomainList: const [
                    "http://ids.xidian.edu.cn/authserver/"
                  ],
                  domain: ToolBoxAddresses.values[index].url,
                ),
              ),
            );
          },
        ),
        separatorBuilder: (BuildContext context, int index) =>
            const Divider(height: 0),
      ),
    );
  }
}
