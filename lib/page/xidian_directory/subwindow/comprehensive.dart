/*
Comprehensive Hall UI of the Xidian Directory.
Copyright (C) 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:watermeter/repository/xidian_directory/xidian_directory_session.dart';
import 'package:watermeter/model/xidian_directory/shop_information_entity.dart';
import 'package:watermeter/page/weight.dart';

class ComprehensiveWindow extends StatefulWidget {
  const ComprehensiveWindow({Key? key}) : super(key: key);

  @override
  State<ComprehensiveWindow> createState() => _ComprehensiveWindowState();
}

class _ComprehensiveWindowState extends State<ComprehensiveWindow> {
  String categoryToSent = "所有";
  String toSearch = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: 0.1,
                color: Colors.black.withOpacity(0.2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "在此搜索",
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (String text) {
                      setState(() {
                        toSearch = text;
                        _get(false);
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: DropdownButton(
                  value: categoryToSent,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                  ),
                  underline: Container(
                    height: 2,
                  ),
                  items: [
                    for (var i in categories)
                      DropdownMenuItem(value: i, child: Text(i))
                  ],
                  onChanged: (String? value) {
                    setState(
                      () {
                        categoryToSent = value!;
                        _get(false);
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _get(true),
            child: FutureBuilder<ShopInformationEntity>(
              future: _get(false),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(child: Text("坏事: ${snapshot.error}"));
                  } else {
                    return ListView(
                      children: [
                        for (var i in snapshot.data.results) ShopCard(toUse: i),
                      ],
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<ShopInformationEntity> _get(bool isForceUpdate) async => getShopData(
      category: categoryToSent, toFind: toSearch, isForceUpdate: isForceUpdate);
}

class ShopCard extends StatelessWidget {
  final ShopInformationResults toUse;

  const ShopCard({Key? key, required this.toUse}) : super(key: key);

  Icon _iconForTarget() {
    switch (toUse.category) {
      case '饮食':
        return const Icon(Icons.restaurant);
      case '生活':
        return const Icon(Icons.nightlife);
      case '打印':
        return const Icon(Icons.print);
      case '学习':
        return const Icon(Icons.book);
      case '快递':
        return const Icon(Icons.local_shipping);
      case '超市':
        return const Icon(Icons.store);
      case '饮用水':
        return const Icon(Icons.water_drop);
      default:
        return const Icon(Icons.lightbulb);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShadowBox(
        child: Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                toUse.name,
                textAlign: TextAlign.left,
                textScaleFactor: 1.5,
              ),
              TagsBoxes(
                text: toUse.status ? "开放" : "关闭",
                backgroundColor: toUse.status ? Colors.green : Colors.red,
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _iconForTarget(),
              const SizedBox(width: 5),
              for (var i in toUse.tags)
                Row(
                  children: [
                    TagsBoxes(
                      text: i,
                    ),
                    const SizedBox(width: 4)
                  ],
                )
            ],
          ),
          const Divider(height: 15.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              toUse.description == null ? "没有描述" : toUse.description!,
              textScaleFactor: 1.10,
            ),
          ),
          const Divider(height: 15.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                // To be implemented.
                onPressed: () {},
                child: const Text("纠正"),
              ),
              Text(
                  "上次更新在 ${toUse.updatedAt.toLocal().toString().substring(0, 19)}"),
            ],
          ),
        ],
      ),
    ));
  }
}
