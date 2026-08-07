import '../../../../shared/models/track_model.dart';

class SyncedContactUser {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final String? phoneNumber;

  SyncedContactUser({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.phoneNumber,
  });

  factory SyncedContactUser.fromJson(Map<String, dynamic> json) {
    return SyncedContactUser(
      id: json['id'] as String,
      displayName: json['displayName'] as String? ?? 'User',
      avatarUrl: json['avatarUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }
}

class SyncedContact {
  final String phone;
  final bool isRegisteredOnApp;
  final SyncedContactUser? user;

  SyncedContact({
    required this.phone,
    required this.isRegisteredOnApp,
    this.user,
  });

  factory SyncedContact.fromJson(Map<String, dynamic> json) {
    return SyncedContact(
      phone: json['phone'] as String,
      isRegisteredOnApp: json['isRegisteredOnApp'] as bool? ?? false,
      user: json['user'] != null
          ? SyncedContactUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CollaborationSessionModel {
  final String id;
  final String hostId;
  final String guestId;
  final String status;
  final String? currentTrackId;
  final SyncedContactUser? host;
  final SyncedContactUser? guest;
  final DateTime? createdAt;

  CollaborationSessionModel({
    required this.id,
    required this.hostId,
    required this.guestId,
    required this.status,
    this.currentTrackId,
    this.host,
    this.guest,
    this.createdAt,
  });

  factory CollaborationSessionModel.fromJson(Map<String, dynamic> json) {
    return CollaborationSessionModel(
      id: json['id'] as String,
      hostId: json['hostId'] as String,
      guestId: json['guestId'] as String,
      status: json['status'] as String? ?? 'PENDING',
      currentTrackId: json['currentTrackId'] as String?,
      host: json['host'] != null
          ? SyncedContactUser.fromJson(json['host'] as Map<String, dynamic>)
          : null,
      guest: json['guest'] != null
          ? SyncedContactUser.fromJson(json['guest'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

class CombinedSessionTracks {
  final String sessionId;
  final String hostId;
  final String guestId;
  final int totalTracks;
  final List<TrackModel> tracks;

  CombinedSessionTracks({
    required this.sessionId,
    required this.hostId,
    required this.guestId,
    required this.totalTracks,
    required this.tracks,
  });

  factory CombinedSessionTracks.fromJson(Map<String, dynamic> json) {
    final rawTracks = json['tracks'] as List<dynamic>? ?? [];
    return CombinedSessionTracks(
      sessionId: json['sessionId'] as String? ?? '',
      hostId: json['hostId'] as String? ?? '',
      guestId: json['guestId'] as String? ?? '',
      totalTracks: json['totalTracks'] as int? ?? 0,
      tracks: rawTracks
          .map((t) => TrackModel.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}
