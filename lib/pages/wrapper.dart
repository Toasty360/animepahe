import 'dart:math';

import 'package:animepahe/models/Model.dart';
import 'package:animepahe/pages/media.dart';
import 'package:animepahe/settings.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toast/toast.dart';

import '../main.dart';
import 'details.dart';

class Wrapper extends StatefulWidget {
  final Future<List<Episode>> recent;

  const Wrapper({super.key, required this.recent});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  int pindex = 0;
  static List<Episode> recent = [];
  final laterBox = WatchList.hive;

  int page = 2;
  bool pageLock = false;
  @override
  void initState() {
    super.initState();
    widget.recent.then((value) {
      setState(() => recent = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    final screen = MediaQuery.of(context).size;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.maxScrollExtent ==
                notification.metrics.pixels &&
            recent.isNotEmpty &&
            !pageLock) {
          pageLock = !pageLock;
          scraper.fetchRecent(page: page.toString()).then((value) {
            setState(() {
              page++;
              recent.addAll(value);
              pageLock = !pageLock;
            });
          });
        }
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SizedBox(
            width: screen.width,
            height: screen.height,
            child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const ClampingScrollPhysics(),
                children: [
                  [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 25),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 12, 14, 17),
                          borderRadius: BorderRadius.circular(50)),
                      child: TextField(
                          onSubmitted: (value) {
                            mysnack(scraper.search(value), context);
                          },
                          decoration: const InputDecoration(
                              hintText: "Search",
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.search))),
                    ),
                    ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const ClampingScrollPhysics(),
                      children: recent
                          .map((e) => InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MediaPlayer(episode: e),
                                  )),
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color.fromARGB(225, 31, 33, 35),
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: screen.width,
                                      height: 150,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(e.image!))),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: const Color.fromARGB(
                                                225, 31, 33, 35),
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow,
                                            size: 30,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailsPage(Anime(
                                                          id: e.animeId
                                                              .toString(),
                                                          session: e.id!
                                                              .split("/")[2],
                                                          poster: e.image,
                                                          title: e.title)),
                                                ));
                                          },
                                          icon: const Icon(
                                            Icons.info_outline,
                                            color: Colors.white,
                                          )),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        alignment: Alignment.bottomLeft,
                                        width: screen.width,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: screen.width * 0.7,
                                              child: Text(
                                                e.title ?? "",
                                                maxLines: 1,
                                                style: const TextStyle(
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.black,
                                              ),
                                              child: Text(e.episode),
                                            )
                                          ],
                                        )),
                                  ],
                                ),
                              )))
                          .toList()
                          .cast<Widget>(),
                    )
                  ],
                  <Widget>[
                    header("Watchlist", null),
                    Center(
                      child: ValueListenableBuilder<Box<Anime>>(
                        valueListenable: laterBox.listenable(),
                        builder: (context, box, _) {
                          return box.isNotEmpty
                              ? GridView(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              max(2, screen.width ~/ 200),
                                          mainAxisSpacing: 15,
                                          mainAxisExtent: 250,
                                          crossAxisSpacing: 10),
                                  children: box.values
                                      .toList()
                                      .map((e) => cards(context, e))
                                      .toList()
                                      .cast<Widget>(),
                                )
                              : Container(
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "~ No Data Yet ~",
                                    style: TextStyle(color: Colors.blueGrey),
                                  ),
                                );
                        },
                      ),
                    ),
                  ]
                ][pindex]),
          ),
          bottomNavigationBar: NavigationBarTheme(
              data: const NavigationBarThemeData(
                  indicatorColor: Colors.blueGrey,
                  iconTheme: MaterialStatePropertyAll(
                      IconThemeData(color: Colors.white70)),
                  labelTextStyle: MaterialStatePropertyAll(
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
              child: NavigationBar(
                backgroundColor: Colors.black,
                height: 65,
                selectedIndex: pindex,
                onDestinationSelected: (value) {
                  setState(() {
                    pindex = value;
                  });
                },
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home), label: "Home"),
                  NavigationDestination(
                      icon: Icon(Icons.collections_bookmark),
                      label: "Watchlist"),
                ],
              )),
        ),
      ),
    );
  }
}

mysnack(Future<List<Anime>> fuData, BuildContext context) {
  Size screen = MediaQuery.of(context).size;
  return showModalBottomSheet(
    elevation: 0,
    isScrollControlled: true,
    backgroundColor: Colors.black,
    enableDrag: true,
    isDismissible: true,
    useSafeArea: true,
    barrierColor: Colors.transparent,
    showDragHandle: true,
    shape: const BeveledRectangleBorder(),
    context: context,
    builder: (context) => FutureBuilder(
      future: fuData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            Navigator.pop(context);
          }
          List<Anime> data = snapshot.data!;
          print("search data ${data.length}");
          return ListView.builder(
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) => InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsPage(data[index]),
                        )),
                    child: Container(
                      width: screen.width,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      height: 180,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color.fromARGB(225, 31, 33, 35)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            height: 150,
                            width: 120,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(data[index].poster!))),
                          ),
                          Container(
                            width: screen.width * 0.5,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    data[index].title!,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 18,
                                          color: Colors.yellow,
                                        ),
                                        Text(
                                          data[index].score!,
                                          textAlign: TextAlign.center,
                                        ),
                                        const Spacer(),
                                        Text(
                                          data[index].type!,
                                          textAlign: TextAlign.center,
                                        ),
                                        const Spacer(),
                                        Text(
                                          data[index].status!.split(" ").first,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  )
                                ]),
                          )
                        ],
                      ),
                    ),
                  ));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    ),
  );
}

header(String text, Widget? clear) {
  return Container(
    margin: const EdgeInsets.only(left: 20, top: 20),
    alignment: Alignment.centerLeft,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          color: Colors.red,
          width: 5,
          height: 20,
        ),
        Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color.fromARGB(255, 229, 223, 223))),
        const Spacer(),
        clear ?? const Center()
      ],
    ),
  );
}
