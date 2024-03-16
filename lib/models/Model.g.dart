// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimeAdapter extends TypeAdapter<Anime> {
  @override
  final int typeId = 0;

  @override
  Anime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Anime(
      id: fields[0] as String,
      session: fields[1] as String,
      aniId: fields[2] as String?,
      poster: fields[3] as String?,
      trailer: fields[4] as String?,
      desc: fields[5] as String?,
      romaji: fields[6] as String?,
      title: fields[7] as String?,
      status: fields[8] as String?,
      type: fields[9] as String?,
      year: fields[10] as String?,
      totalEpisodes: fields[12] as String?,
      tags: (fields[13] as List?)?.cast<String>(),
      episodes: (fields[14] as List?)?.cast<Episode>(),
      score: fields[11] as String?,
      recommendation: (fields[15] as List?)?.cast<Anime>(),
      relations: (fields[16] as List?)?.cast<Anime>(),
    );
  }

  @override
  void write(BinaryWriter writer, Anime obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.session)
      ..writeByte(2)
      ..write(obj.aniId)
      ..writeByte(3)
      ..write(obj.poster)
      ..writeByte(4)
      ..write(obj.trailer)
      ..writeByte(5)
      ..write(obj.desc)
      ..writeByte(6)
      ..write(obj.romaji)
      ..writeByte(7)
      ..write(obj.title)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.type)
      ..writeByte(10)
      ..write(obj.year)
      ..writeByte(11)
      ..write(obj.score)
      ..writeByte(12)
      ..write(obj.totalEpisodes)
      ..writeByte(13)
      ..write(obj.tags)
      ..writeByte(14)
      ..write(obj.episodes)
      ..writeByte(15)
      ..write(obj.recommendation)
      ..writeByte(16)
      ..write(obj.relations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EpisodeAdapter extends TypeAdapter<Episode> {
  @override
  final int typeId = 1;

  @override
  Episode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Episode(
      id: fields[0] as String?,
      animeId: fields[1] as int?,
      episode: fields[2] as String,
      title: fields[3] as String?,
      image: fields[4] as String?,
      disc: fields[5] as String?,
      type: fields[6] as String?,
      duration: fields[7] as String?,
      createdAt: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Episode obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.animeId)
      ..writeByte(2)
      ..write(obj.episode)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.image)
      ..writeByte(5)
      ..write(obj.disc)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
