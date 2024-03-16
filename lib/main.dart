import 'package:animepahe/models/Model.dart';
import 'package:animepahe/pages/wrapper.dart';
import 'package:animepahe/settings.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  Future<List<Episode>> recent = scraper.fetchRecent();
  Hive.registerAdapter(EpisodeAdapter());
  Hive.registerAdapter(AnimeAdapter());

  await WatchList.initializeHive();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Animpahe",
    darkTheme: ThemeData.dark(useMaterial3: true),
    theme: ThemeData(
        fontFamily: 'Open_Sans',
        brightness: Brightness.dark,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF17203A))),
    home: Wrapper(recent: recent),
  ));
}

class WatchList {
  static late Box<Anime> _hive;

  static Future<void> initializeHive() async {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    _hive = await Hive.openBox<Anime>('Later', path: appDocumentDirectory.path);
  }

  static Box<Anime> get hive => _hive;
}
