import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/small_function_card.dart';
import 'package:watermeter/page/telebook/telebook_view.dart';

class TeleBookCard extends StatelessWidget {
  const TeleBookCard({super.key});

  @override
  Widget build(BuildContext context) {
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
  }
}
