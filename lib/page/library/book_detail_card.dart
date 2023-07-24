import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/library/book_place_card.dart';
import 'package:watermeter/page/widget.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class BookDetailCard extends StatefulWidget {
  final BookInfo toUse;

  const BookDetailCard({
    super.key,
    required this.toUse,
  });

  @override
  State<BookDetailCard> createState() => _BookDetailCardState();
}

class _BookDetailCardState extends State<BookDetailCard> {
  late Future<List<BookLocation>> future;

  @override
  void initState() {
    super.initState();
    future = LibrarySession().getBookLocation(widget.toUse);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(
            widget.toUse.bookName,
            style: TextStyle(
              fontSize: 20.0,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "作者：${widget.toUse.author}\n"
                      "出版社：${widget.toUse.publisherHouse}\n"
                      "ISBN: ${widget.toUse.isbn}\n"
                      "发行时间: ${widget.toUse.publicationDate}\n"
                      "索书号: ${widget.toUse.searchCode}",
                    ),
                  ],
                ),
              ),
              CachedNetworkImage(
                imageUrl: LibrarySession.bookCover(widget.toUse.isbn ?? ""),
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                    Image.asset("assets/Empty-Cover.jpg"),
                width: 90,
                height: 120,
              ),
            ],
          ),
          Text(widget.toUse.description ?? "这本书没有提供描述"),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const InfoDetailBox(
                      child: Center(child: Text("正在获取")));
                } else if (snapshot.hasError) {
                  return const InfoDetailBox(
                      child: Center(child: Text("获取信息出错")));
                } else {
                  return Column(
                    children: List.generate(
                      snapshot.data!.length,
                      (index) => BookPlaceCard(
                        toUse: snapshot.data![index],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
