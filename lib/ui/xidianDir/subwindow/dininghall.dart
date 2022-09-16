/*
Cafeteria UI of the Xidian Directory.
Copyright (C) 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:watermeter/communicate/xidianDir/xidianDirSession.dart';
import 'package:watermeter/dataStruct/xidianDir/cafeteria_window_item_entity.dart';
import 'package:watermeter/ui/weight.dart';

class DiningHallWindow extends StatefulWidget {
  const DiningHallWindow({Key? key}) : super(key: key);

  @override
  State<DiningHallWindow> createState() => _DiningHallWindowState();
}

/// TODO: Add a random button and a general report button.
/// TODO: Add a button, which could hide the details of the window.
class _DiningHallWindowState extends State<DiningHallWindow> {
  String toSearch = "";
  String goToWhere = "竹园一楼";

  @override
  Widget build(BuildContext context) {
    return Column(children: [
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
      ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: () async => _get(true),
          child: FutureBuilder<List<WindowInformation>>(
            future: _get(false),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text("坏事: ${snapshot.error} + ${snapshot.data}"));
                } else {
                  return ListView(
                    children: [
                      for (var i in snapshot.data) CafeteriaCard(toUse: i),
                    ],
                  );
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      )
    ]);
  }

  Future<List<WindowInformation>> _get(bool isForceUpdate) async =>
      getCafeteriaData(
          toFind: toSearch, where: goToWhere, isForceUpdate: isForceUpdate);
}

class CafeteriaCard extends StatelessWidget {
  final WindowInformation toUse;

  const CafeteriaCard({Key? key, required this.toUse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShadowBox(
        child: Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
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
                    textScaleFactor: 1.5,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                )
              ]),
              Row(
                children: [
                  TagsBoxes(
                      text: toUse.places, backgroundColor: Colors.deepPurple),
                  const SizedBox(width: 5),
                  TagsBoxes(
                    text: toUse.state() ? "开放" : "关门",
                    backgroundColor: toUse.state() ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ],
          ),
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
          for (var i in toUse.items)
            Column(
              children: [
                ItemBox(toUse: i),
                const SizedBox(height: 10),
              ],
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 237, 242, 247),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  toUse.name,
                  textScaleFactor: 1.10,
                  style: TextStyle(
                    decoration: !toUse.status
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "${toUse.price.join(" 或 ")} 元每${toUse.unit}",
                      textScaleFactor: 1.10,
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
            if (toUse.commit != null)
              Row(children: [
                const SizedBox(height: 10),
                Flexible(
                  child: Text(toUse.commit!),
                )
              ])
          ],
        ),
      ),
    );
  }
}
