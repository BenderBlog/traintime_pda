/*
Comprehensive Hall UI of the Xidian Directory.
Copyright (C) 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

*/

import 'package:flutter/material.dart';
import 'package:watermeter/repository/xidian_directory/xidian_directory_session.dart';
import 'package:watermeter/model/xidian_directory/shop_information.dart';
import 'package:watermeter/page/widget.dart';

class ComprehensiveWindow extends StatefulWidget {
  const ComprehensiveWindow({Key? key}) : super(key: key);

  @override
  State<ComprehensiveWindow> createState() => _ComprehensiveWindowState();
}

class _ComprehensiveWindowState extends State<ComprehensiveWindow>
    with AutomaticKeepAliveClientMixin {
  String categoryToSent = "所有";
  TextEditingController text =
      TextEditingController.fromValue(const TextEditingValue(text: ""));
  bool isSearch = false;
  late Future<ShopInformationEntity> data;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _get(true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _get(true),
        child: FutureBuilder<ShopInformationEntity>(
          future: data,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(child: Text("坏事: ${snapshot.error}"));
              } else {
                return dataList<ShopInformationResults, ShopCard>(
                    snapshot.data.results, (toUse) => ShopCard(toUse: toUse));
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          isSearch = !isSearch;
        }),
        elevation: 5,
        child: const Icon(Icons.search),
      ),
      bottomSheet: isSearch
          ? BottomAppBar(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextField(
                        controller: text,
                        decoration: const InputDecoration(
                          hintText: "在此搜索",
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (String text) {
                          setState(() {
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
            )
          : null,
    );
  }

  Future<void> _get(bool isForceUpdate) async {
    data = getShopData(
      category: categoryToSent,
      toFind: text.text,
      isForceUpdate: isForceUpdate,
    );
  }
}

class ShopCard extends StatelessWidget {
  final ShopInformationResults toUse;

  const ShopCard({Key? key, required this.toUse}) : super(key: key);

  IconData _iconForTarget() {
    switch (toUse.category) {
      case '饮食':
        return Icons.restaurant;
      case '生活':
        return Icons.nightlife;
      case '打印':
        return Icons.print;
      case '学习':
        return Icons.book;
      case '快递':
        return Icons.local_shipping;
      case '超市':
        return Icons.store;
      case '饮用水':
        return Icons.water_drop;
      default:
        return Icons.lightbulb;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      toUse.name,
                      textScaleFactor: 1.1,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    TagsBoxes(
                      text: toUse.status ? "开放" : "关闭",
                      backgroundColor: toUse.status ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.transparent,
                  height: 2.5,
                ),
                Row(
                  children: [
                    Icon(
                      _iconForTarget(),
                      size: 14,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const SizedBox(width: 5),
                    Wrap(
                      spacing: 5,
                      children: [
                        for (var i in toUse.tags) TagsBoxes(text: i),
                      ],
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.transparent,
                  height: 2.5,
                ),
                informationWithIcon(
                  Icons.description,
                  toUse.description ?? "没有描述",
                  context,
                ),
                informationWithIcon(
                  Icons.update,
                  toUse.updatedAt.toLocal().toString().substring(0, 19),
                  context,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
