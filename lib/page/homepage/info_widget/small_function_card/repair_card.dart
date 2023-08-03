import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/small_function_card.dart';
import 'package:watermeter/page/toolbox/toolbox.dart';

class ToolCard extends StatelessWidget {
  const ToolCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ToolBox(),
          ),
        );
      },
      child: const SmallFunctionCard(
        icon: Icons.assistant_outlined,
        name: "小工具箱",
        description: "其他更多功能",
      ),
    );
  }
}
