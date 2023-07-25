/*
Cafeteria UI of the Xidian Directory.
Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

*/

import 'package:flutter/material.dart';
import 'package:watermeter/page/sliver_grid_deligate_with_fixed_height.dart';
import 'package:watermeter/repository/xidian_directory/xidian_directory_session.dart';
import 'package:watermeter/model/xidian_directory/cafeteria_window_item.dart';
import 'package:watermeter/page/widget.dart';

class DiningHallWindow extends StatefulWidget {
  const DiningHallWindow({Key? key}) : super(key: key);

  @override
  State<DiningHallWindow> createState() => _DiningHallWindowState();
}

class _DiningHallWindowState extends State<DiningHallWindow>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  TextEditingController text =
      TextEditingController.fromValue(const TextEditingValue(text: ""));
  String goToWhere = "竹园一楼";
  bool isSearch = false;
  late Future<List<WindowInformation>> data;

  @override
  void initState() {
    super.initState();
    _get(true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: [
          Row(
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
                  value: goToWhere,
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
                        goToWhere = value!;
                        _get(false);
                      },
                    );
                  },
                ),
              )
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _get(true),
              child: FutureBuilder<List<WindowInformation>>(
                future: data,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(
                          child:
                              Text("坏事: ${snapshot.error} + ${snapshot.data}"));
                    } else {
                      return dataList<WindowInformation, CafeteriaCard>(
                          snapshot.data,
                          (toUse) => CafeteriaCard(toUse: toUse));
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _get(bool isForceUpdate) async {
    data = getCafeteriaData(
      toFind: text.text,
      where: goToWhere,
      isForceUpdate: isForceUpdate,
    );
  }
}

class CafeteriaCard extends StatelessWidget {
  final WindowInformation toUse;

  const CafeteriaCard({Key? key, required this.toUse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (toUse.number != null)
                        Row(
                          children: [
                            TagsBoxes(
                              text: toUse.number.toString(),
                              backgroundColor: Colors.grey,
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          toUse.name,
                          textAlign: TextAlign.left,
                          textScaleFactor: 1.25,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      TagsBoxes(
                          text: toUse.places,
                          backgroundColor: Colors.deepPurple),
                      const SizedBox(width: 5),
                      TagsBoxes(
                        text: toUse.state() ? "开放" : "关门",
                        backgroundColor:
                            toUse.state() ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
              if (toUse.commit != null) const SizedBox(height: 10),
              if (toUse.commit != null)
                Row(
                  children: [
                    const SizedBox(height: 5),
                    Flexible(
                      child: Text("${toUse.commit}"),
                    )
                  ],
                ),
              const Divider(height: 28.0),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedHeight(
                  maxCrossAxisExtent: 375,
                  height: 60,
                  mainAxisSpacing: 15.0,
                  crossAxisSpacing: 15.0,
                ),
                itemCount: toUse.items.length,
                shrinkWrap: true,
                itemBuilder: (context, index) =>
                    ItemBox(toUse: toUse.items.elementAt(index)),
              ),
            ],
          ),
        ));
  }
}

class ItemBox extends StatelessWidget {
  final WindowItemsGroup toUse;
  const ItemBox({Key? key, required this.toUse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoDetailBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              toUse.commit == null
                  ? toUse.name
                  : "${toUse.name}\n${toUse.commit!}",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                decoration: !toUse.status
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          Row(
            children: [
              Text(
                "${toUse.price.join(" 或 ")} 元每${toUse.unit}",
                style: TextStyle(
                  decoration: !toUse.status
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
