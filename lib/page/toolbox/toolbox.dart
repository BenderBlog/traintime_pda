import 'package:flutter/material.dart';
import 'package:watermeter/page/toolbox/toolbox_addresses.dart';
import 'package:watermeter/page/toolbox/webview.dart';
import 'package:watermeter/page/toolbox/creative_job/creative_job.dart';

class ToolBox extends StatelessWidget {
  const ToolBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("更多功能"),
      ),
      body: ListView.separated(
        itemCount: ToolBoxAddresses.values.length + 1,
        itemBuilder: (context, index) {
          if (index < ToolBoxAddresses.values.length) {
            return ListTile(
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
            );
          } else {
            return ListTile(
              leading: const Icon(Icons.star),
              title: const Text("双创竞赛"),
              subtitle: const Text("拉队友来看看"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreativeJobView(),
                  ),
                );
              },
            );
          }
        },
        separatorBuilder: (BuildContext context, int index) =>
            const Divider(height: 0),
      ),
    );
  }
}
