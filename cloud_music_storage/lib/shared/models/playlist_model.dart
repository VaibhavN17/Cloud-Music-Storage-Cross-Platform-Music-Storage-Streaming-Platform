/// Playlist data model.
///
/// Matches the Prisma Playlist model from Backend Schemas §2.
library;

import 'track_model.dart';

class PlaylistModel {
  const PlaylistModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.coverUrl,
    this.visibility = TrackVisibility.private,
    this.trackCount = 0,
    this.tracks = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String? coverUrl;
  final TrackVisibility visibility;
  final int trackCount;
  final List<TrackModel> tracks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String? ?? '',
      name: json['name'] as String,
      coverUrl: json['coverUrl'] as String?,
      visibility: (json['visibility'] as String?)?.toUpperCase() == 'PUBLIC'
          ? TrackVisibility.public
          : TrackVisibility.private,
      trackCount: json['trackCount'] as int? ?? (json['tracks'] as List?)?.length ?? 0,
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((e) => TrackModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'coverUrl': coverUrl,
      'visibility': visibility.name.toUpperCase(),
      'trackCount': trackCount,
      'tracks': tracks.map((t) => t.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  PlaylistModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? coverUrl,
    TrackVisibility? visibility,
    int? trackCount,
    List<TrackModel>? tracks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      coverUrl: coverUrl ?? this.coverUrl,
      visibility: visibility ?? this.visibility,
      trackCount: trackCount ?? this.trackCount,
      tracks: tracks ?? this.tracks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
