import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

import '../models/Model.dart';

class AnimepaheFetcher {
  final String baseurl = "https://animepahe.ru";
  final Map<String, String> header = {
    'Referer': 'https://animepahe.ru/',
    'Cookie': '__ddg1=;__ddg2_=;__ddgid_=; __ddgmark_=;SERVERID=',
  };

  Future<List<Episode>> fetchRecent({String page = "1"}) async {
    var r = await (await Dio().get(
            "https://animepahe.ru/api?m=airing&page=$page",
            options: Options(headers: header)))
        .data;
    return r["data"]
        .map(
          (e) => Episode(
            id: '/play/${e["anime_session"]}/${e["session"]}',
            episode: e["episode"].toString(),
            duration: e["duration"],
            animeId: e["anime_id"],
            createdAt: e["created_at"],
            title: e["anime_title"],
            disc: e["disc"],
            image: e["snapshot"],
            type: e["audio"],
          ),
        )
        .toList()
        .cast<Episode>();
  }

  Future<List<Anime>> search(String q) async {
    try {
      var r = await (await Dio().get("https://animepahe.ru/api?m=search&q=$q",
              options: Options(headers: header)))
          .data;
      return r["data"]
          .map((e) => Anime(
              id: e["id"].toString(),
              session: e["session"],
              title: e["title"],
              type: e["type"],
              totalEpisodes: e["episodes"].toString(),
              status: e["status"],
              year: e["year"].toString(),
              score: e["score"].toString(),
              poster: e["poster"]))
          .toList()
          .cast<Anime>();
    } catch (e) {
      return [];
    }
  }

  Future<Anime> fetchInfo(String id) async {
    final response = await http.get(Uri.parse("https://animepahe.ru/anime/$id"),
        headers: header);
    final document = parse(response.body);

    Anime info = Anime(id: id, session: id);
    info.title = document
        .querySelector('.title-wrapper')!
        .querySelector('h1 > span')!
        .text;
    info.poster = document
        .querySelector('.anime-poster')!
        .querySelector('a')!
        .attributes['href'];
    info.desc = document
        .querySelector('.anime-content > div > .anime-summary')!
        .text
        .replaceAll('\n', '')
        .trim();
    info.romaji = document
        .querySelectorAll('.anime-info > p')
        .firstWhere((e) => e.querySelector("strong")!.text.contains("Japanese"))
        .text
        .split(':')
        .last
        .trim();
    info.totalEpisodes = document
        .querySelectorAll('.anime-info > p')
        .firstWhere((e) => e.querySelector("strong")!.text.contains("Episode"))
        .text
        .split(':')
        .last
        .trim();
    info.status = document
        .querySelectorAll('.anime-info > p')
        .firstWhere((e) => e.querySelector("strong")!.text.contains("Status"))
        .text
        .split(':')
        .last
        .trim();

    info.tags = document
        .querySelectorAll('.anime-info .anime-genre ul li')
        .map((e) => e.text.trim())
        .toList();

    info.recommendation = document
        .querySelectorAll('.anime-recommendation > div > .row')
        .map((e) {
      return Anime(
        session: e.children.first
                .querySelector('a')!
                .attributes['href']
                ?.split('/')
                .last ??
            "",
        id: e.children.first
                .querySelector('a')!
                .attributes['href']
                ?.split('/')
                .last ??
            "",
        title: e.children.first.querySelector('a')!.attributes['title'],
        poster:
            e.children.first.querySelector('a > img')!.attributes['data-src'],
        type: e.children.last.querySelector('strong')!.text,
        totalEpisodes:
            e.children.last.text.split('-').last.split('Episodes').first.trim(),
        status: e.children.last.text.split('(').last.split(')').first.trim(),
        year: e.children.last.children.last.text,
      );
    }).toList();
    info.relations = document
        .querySelectorAll('.anime-relation > .col-12 > .row .col-12 > .row')
        .map((e) {
      return Anime(
        session: e.children.first
                .querySelector('a')!
                .attributes['href']
                ?.split('/')
                .last ??
            "",
        id: e.children.first
                .querySelector('a')!
                .attributes['href']
                ?.split('/')
                .last ??
            "",
        title: e.children.first.querySelector('a')!.attributes['title'],
        poster:
            e.children.first.querySelector('a > img')!.attributes['data-src'],
        type: e.children.last.querySelector('strong')!.text,
        totalEpisodes:
            e.children.last.text.split('-').last.split('Episode').first.trim(),
        status: e.children.last.text.split('(').last.split(')').first.trim(),
        year: e.children.last.children.last.text,
      );
    }).toList();
    info.episodes = await fetchEpisodes(id);
    return info;
  }

  Future<List<Episode>> fetchEpisodes(String id, {String? page}) async {
    try {
      final response = await (await Dio().get(
              "https://animepahe.ru/api?m=release&id=$id&sort=episode_desc&page=$page",
              options: Options(headers: header)))
          .data;
      final data = response;
      final List<dynamic> r = data['data'];

      var episodes = <Episode>[];
      for (var e in r) {
        episodes.add(
          Episode(
            id: '/play/$id/${e["session"]}',
            episode: e["episode"].toString(),
            duration: e["duration"],
            animeId: e["anime_id"],
            createdAt: e["created_at"],
            title: e["title"] != "" ? e["title"] : "Episode ${e["episode"]}",
            disc: e["disc"],
            image: e["snapshot"],
            type: e["audio"],
          ),
        );
      }
      return episodes;
    } catch (e) {
      return [Episode(id: 'No Episodes found!', episode: "")];
    }
  }

  Future<dynamic> fetchm3u8(String id) async {
    var api = "https://valerien-api.vercel.app/anime/watch?id=";
    final resp =
        await (await Dio().get(api + id, options: Options(headers: header)))
            .data;
    return resp;
  }
}
