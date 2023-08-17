import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/small_function_card.dart';
import 'package:watermeter/page/homepage/toolbox/toolbox_addresses.dart';
import 'package:watermeter/page/homepage/toolbox/webview.dart';
import 'package:watermeter/page/creative_job/creative_job.dart';
import 'package:watermeter/page/sliver_grid_deligate_with_fixed_height.dart';
import 'package:watermeter/page/telebook/telebook_view.dart';
import 'package:watermeter/page/xdu_planet/xdu_planet_page.dart';

class ToolBoxView extends StatelessWidget {
  const ToolBoxView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("小工具"),
      ),
      body: GridView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedHeight(
          maxCrossAxisExtent: 160,
          height: 84,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        children: List.generate(
          ToolBoxAddresses.values.length + 3,
          (index) {
            if (index == 0) {
              return GestureDetector(
                onTap: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreativeJobView(),
                    ),
                  );
                },
                child: const SmallFunctionCard(
                  icon: Icons.star,
                  name: "双创竞赛",
                  description: "拉队友来看看",
                ),
              );
            } else if (index == 1) {
              return GestureDetector(
                onTap: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const XDUPlanetPage(),
                    ),
                  );
                },
                child: const SmallFunctionCard(
                  icon: Icons.rss_feed,
                  name: "博客星球",
                  description: "学习先辈经验",
                ),
              );
            } else if (index == 2) {
              return GestureDetector(
                onTap: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TeleBookWindow(),
                    ),
                  );
                },
                child: const SmallFunctionCard(
                  icon: Icons.contacts_rounded,
                  name: "电话本",
                  description: "校园服务电话",
                ),
              );
            } else {
              return GestureDetector(
                onTap: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WebView(
                        name: ToolBoxAddresses.values[index - 3].name,
                        cookieDomainList: const [
                          "http://ids.xidian.edu.cn/authserver/"
                        ],
                        domain: ToolBoxAddresses.values[index - 3].url,
                      ),
                    ),
                  );
                },
                child: SmallFunctionCard(
                  icon: ToolBoxAddresses.values[index - 3].iconData,
                  name: ToolBoxAddresses.values[index - 3].name,
                  description: ToolBoxAddresses.values[index - 3].description,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
