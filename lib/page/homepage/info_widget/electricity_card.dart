import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/repository/electricity/electricity_session.dart';

class ElectricityCard extends StatelessWidget {
  const ElectricityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("电费帐号：${electricityAccount()}\n长按可以重新加载"),
        ));
      },
      onLongPress: () async => await update(),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(
                  Icons.electric_meter_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 14,
                ),
                const SizedBox(width: 7.5),
                Text(
                  "电量信息",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ]),
              const SizedBox(width: 15),
              Expanded(
                child: Center(
                  child: Obx(
                    () => Text(
                      electricityInfo.value,
                      textScaleFactor: 1.15,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
