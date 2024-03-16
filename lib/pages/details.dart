import 'package:animepahe/models/Model.dart';
import 'package:animepahe/pages/media.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import '../main.dart';
import '../settings.dart';

class DetailsPage extends StatefulWidget {
  final Anime item;
  const DetailsPage(this.item, {super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Anime item;
  int page = 2;
  bool isDataReady = false;
  bool episodeLock = false;
  bool play = false;
  final laterBox = WatchList.hive;
  static Map<String, Anime> tempData = {};
  bool issaved = false;

  getData() async {
    scraper.fetchInfo(widget.item.session).then((value) {
      item = value;
      isDataReady = true;
      tempData[widget.item.id] = value;
      if (laterBox.containsKey(widget.item.session)) {
        laterBox.put(widget.item.session, value);
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    issaved = laterBox.containsKey(widget.item.session);
    print(widget.item.id.split("/").last);
    print(issaved);
    print(laterBox.keys.toList());
    super.initState();
    getData();

    if (tempData.containsKey(widget.item.session)) {
      item = tempData[widget.item.session]!;
      isDataReady = true;
      setState(() {});
    } else {
      getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels ==
                notification.metrics.maxScrollExtent &&
            isDataReady &&
            item.episodes!.isNotEmpty &&
            !episodeLock) {
          episodeLock = !episodeLock;
          print("fetching $page");
          setState(() {
            scraper
                .fetchEpisodes(widget.item.session, page: page.toString())
                .then((value) {
              print(value.first.episode);
              if (value.first.episode != "") {
                item.episodes!.addAll(value);
                episodeLock = !episodeLock;
              }
              page++;
            });
          });
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(widget.item.title!),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    if (issaved) {
                      laterBox.delete(widget.item.session);
                      Toast.show("Removed",
                          backgroundColor:
                              const Color.fromARGB(225, 31, 33, 35),
                          textStyle: const TextStyle(color: Colors.red));
                    } else {
                      laterBox.put(widget.item.session, item);
                      Toast.show("Added",
                          backgroundColor:
                              const Color.fromARGB(225, 31, 33, 35),
                          textStyle: const TextStyle(color: Colors.green));
                    }
                    issaved = !issaved;
                  });
                },
                icon: Icon(issaved ? Icons.bookmark : Icons.bookmark_border))
          ],
        ),
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: ListView(shrinkWrap: true, children: [
            Container(
              width: screen.width,
              height: screen.height * 0.3,
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  shape: BoxShape.rectangle,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6)
                  ],
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    opacity: 0.4,
                    colorFilter: const ColorFilter.srgbToLinearGamma(),
                    scale: 1.5,
                    image: NetworkImage(widget.item.poster!),
                    onError: (exception, stackTrace) {
                      Container(
                          color: Colors.amber,
                          alignment: Alignment.center,
                          child: const Text(
                            'Whoops!',
                            style: TextStyle(fontSize: 20),
                          ));
                    },
                  )),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8, bottom: 8),
                    child: SizedBox(
                      width: screen.width * 0.35,
                      height: 200,
                      child: InkWell(
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 6)
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              isDataReady ? item.poster! : widget.item.poster!,
                              fit: BoxFit.cover,
                              height: 400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: screen.width * 0.55,
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      widget.item.title!,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
            ),
            isDataReady
                ? ListView(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white38)),
                                child: Text("Episodes ${item.totalEpisodes!}"),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                width: 2,
                                height: 20,
                                color: Colors.grey,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white38)),
                                child: Text(item.status!),
                              )
                            ]),
                      ),
                      item.tags!.isNotEmpty
                          ? SizedBox(
                              width: screen.width,
                              child: ListTile(
                                title: const Text(
                                  "Genres :",
                                  style: TextStyle(color: Colors.greenAccent),
                                ),
                                subtitle: Text(
                                  item.tags!.join(", "),
                                ),
                              ),
                            )
                          : const Center(),
                      SizedBox(
                        width: screen.width,
                        child: ListTile(
                          title: const Text(
                            "Description :",
                            style: TextStyle(color: Colors.greenAccent),
                          ),
                          subtitle: Text(
                            item.desc!,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      item.relations!.isNotEmpty
                          ? myGrid(item.relations!, context, "Relations :")
                          : const Center(),
                      item.recommendation!.isNotEmpty
                          ? myGrid(
                              item.recommendation!, context, "Recommendation :")
                          : const Center(),
                      Padding(
                        padding: const EdgeInsets.only(left: 18),
                        child: SizedBox(
                          width: screen.width,
                          child: const Text(
                            "Episodes: ",
                            style: TextStyle(
                                color: Colors.greenAccent, fontSize: 16),
                          ),
                        ),
                      ),
                      item.episodes!.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: item.episodes!.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MediaPlayer(
                                                episode:
                                                    item.episodes![index])));
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 100,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        shape: BoxShape.rectangle,
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                                item.episodes![index].image!))),
                                    child: Text(
                                      item.episodes![index].title!,
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              margin: const EdgeInsets.only(top: 30),
                              child: const Center(
                                child: Text(
                                  "~~ No Data Yet ~~",
                                  style: TextStyle(
                                      color: Colors.indigoAccent, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  )
                : const Padding(
                    padding: EdgeInsets.all(50),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

myGrid(List<Anime> data, BuildContext context, String text) {
  return SizedBox(
    width: MediaQuery.of(context).size.width,
    child: ListTile(
        title: Text(
          text,
          style: const TextStyle(color: Colors.greenAccent),
        ),
        subtitle: SizedBox(
          height: 150,
          child: ListView(
            padding: const EdgeInsets.only(top: 10),
            shrinkWrap: true,
            controller: ScrollController(),
            scrollDirection: Axis.horizontal,
            children:
                data.map((e) => cards(context, e)).toList().cast<Widget>(),
          ),
        )),
  );
}

cards(BuildContext context, Anime item) {
  return InkWell(
    onTap: () => Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => DetailsPage(item))),
    child: Container(
      width: MediaQuery.of(context).size.width * 0.3,
      padding: const EdgeInsets.only(right: 10),
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(item.poster!),
                fit: BoxFit.cover,
              )),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          alignment: Alignment.bottomCenter,
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(16, 0, 0, 0),
                    Color.fromARGB(189, 0, 0, 0),
                  ])),
          child: Text(
            item.title!,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
      ]),
    ),
  );
}
