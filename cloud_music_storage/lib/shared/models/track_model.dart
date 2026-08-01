/// Track data model.
///
/// Matches the Prisma Track model from Backend Schemas §2.
library;

enum TrackVisibility { private, public }

class TrackModel {
  const TrackModel({
    required this.id,
    required this.ownerId,
    this.folderId,
    required this.title,
    this.artist,
    this.album,
    this.genre,
    this.durationMs,
    required this.fileKey,
    this.artworkKey,
    this.artworkUrl,
    this.streamUrl,
    required this.fileSizeBytes,
    required this.format,
    this.visibility = TrackVisibility.private,
    this.ownershipAttestedAt,
    this.playCount = 0,
    this.likeCount = 0,
    this.isFavorite = false,
    this.isDownloaded = false,
    this.localPath,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String? folderId;
  final String title;
  final String? artist;
  final String? album;
  final String? genre;
  final int? durationMs;
  final String fileKey;
  final String? artworkKey;
  final String? artworkUrl;
  final String? streamUrl;
  final int fileSizeBytes;
  final String format;
  final TrackVisibility visibility;
  final DateTime? ownershipAttestedAt;
  final int playCount;
  final int likeCount;
  final bool isFavorite;
  final bool isDownloaded;
  final String? localPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayArtist => (artist == null || artist!.isEmpty) ? 'Unknown Artist' : artist!;
  String get displayAlbum => (album == null || album!.isEmpty) ? 'Unknown Album' : album!;

  String get formattedDuration {
    if (durationMs == null || durationMs! <= 0) return '--:--';
    final duration = Duration(milliseconds: durationMs!);
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String? ?? '',
      folderId: json['folderId'] as String?,
      title: json['title'] as String,
      artist: json['artist'] as String?,
      album: json['album'] as String?,
      genre: json['genre'] as String?,
      durationMs: json['durationMs'] as int?,
      fileKey: json['fileKey'] as String? ?? '',
      artworkKey: json['artworkKey'] as String?,
      artworkUrl: json['artworkUrl'] as String?,
      streamUrl: json['streamUrl'] as String?,
      fileSizeBytes: _parseInt(json['fileSizeBytes']),
      format: json['format'] as String? ?? 'mp3',
      visibility: (json['visibility'] as String?)?.toUpperCase() == 'PUBLIC'
          ? TrackVisibility.public
          : TrackVisibility.private,
      ownershipAttestedAt: json['ownershipAttestedAt'] != null
          ? DateTime.tryParse(json['ownershipAttestedAt'] as String)
          : null,
      playCount: json['playCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      localPath: json['localPath'] as String?,
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
      'folderId': folderId,
      'title': title,
      'artist': artist,
      'album': album,
      'genre': genre,
      'durationMs': durationMs,
      'fileKey': fileKey,
      'artworkKey': artworkKey,
      'artworkUrl': artworkUrl,
      'streamUrl': streamUrl,
      'fileSizeBytes': fileSizeBytes,
      'format': format,
      'visibility': visibility.name.toUpperCase(),
      'ownershipAttestedAt': ownershipAttestedAt?.toIso8601String(),
      'playCount': playCount,
      'likeCount': likeCount,
      'isFavorite': isFavorite,
      'isDownloaded': isDownloaded,
      'localPath': localPath,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  TrackModel copyWith({
    String? id,
    String? ownerId,
    String? folderId,
    String? title,
    String? artist,
    String? album,
    String? genre,
    int? durationMs,
    String? fileKey,
    String? artworkKey,
    String? artworkUrl,
    String? streamUrl,
    int? fileSizeBytes,
    String? format,
    TrackVisibility? visibility,
    DateTime? ownershipAttestedAt,
    int? playCount,
    int? likeCount,
    bool? isFavorite,
    bool? isDownloaded,
    String? localPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrackModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      folderId: folderId ?? this.folderId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      genre: genre ?? this.genre,
      durationMs: durationMs ?? this.durationMs,
      fileKey: fileKey ?? this.fileKey,
      artworkKey: artworkKey ?? this.artworkKey,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      format: format ?? this.format,
      visibility: visibility ?? this.visibility,
      ownershipAttestedAt: ownershipAttestedAt ?? this.ownershipAttestedAt,
      playCount: playCount ?? this.playCount,
      likeCount: likeCount ?? this.likeCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
