import 'package:hive/hive.dart';

part 'Model.g.dart';

@HiveType(typeId: 0)
class Anime {
  @HiveField(0)
  String id;
  @HiveField(1)
  String session;
  @HiveField(2)
  String? aniId;
  @HiveField(3)
  String? poster;
  @HiveField(4)
  String? trailer;
  @HiveField(5)
  String? desc;
  @HiveField(6)
  String? romaji;
  @HiveField(7)
  String? title;
  @HiveField(8)
  String? status;
  @HiveField(9)
  String? type;
  @HiveField(10)
  String? year;
  @HiveField(11)
  String? score;
  @HiveField(12)
  String? totalEpisodes;
  @HiveField(13)
  List<String>? tags;
  @HiveField(14)
  List<Episode>? episodes;
  @HiveField(15)
  List<Anime>? recommendation;
  @HiveField(16)
  List<Anime>? relations;

  Anime({
    required this.id,
    required this.session,
    this.aniId,
    this.poster,
    this.trailer,
    this.desc,
    this.romaji,
    this.title,
    this.status,
    this.type,
    this.year,
    this.totalEpisodes,
    this.tags,
    this.episodes,
    this.score,
    this.recommendation,
    this.relations,
  });
}

@HiveType(typeId: 1)
class Episode {
  @HiveField(0)
  String? id;
  @HiveField(1)
  int? animeId;
  @HiveField(2)
  String episode;
  @HiveField(3)
  String? title;
  @HiveField(4)
  String? image;
  @HiveField(5)
  String? disc;
  @HiveField(6)
  String? type;
  @HiveField(7)
  String? duration;
  @HiveField(8)
  String? createdAt;

  Episode({
    this.id,
    this.animeId,
    required this.episode,
    this.title,
    this.image,
    this.disc,
    this.type,
    this.duration,
    this.createdAt,
  });
}
