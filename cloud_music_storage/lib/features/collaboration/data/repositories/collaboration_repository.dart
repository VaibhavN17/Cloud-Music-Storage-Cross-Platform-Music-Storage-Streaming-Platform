import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/track_model.dart';
import '../models/collaboration_models.dart';

class SessionAndInvitesResult {
  final CollaborationSessionModel? activeSession;
  final List<CollaborationSessionModel> incomingInvites;
  final List<CollaborationSessionModel> outgoingInvites;

  SessionAndInvitesResult({
    this.activeSession,
    required this.incomingInvites,
    required this.outgoingInvites,
  });
}

final collaborationRepositoryProvider = Provider<CollaborationRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return CollaborationRepository(dio);
});

class CollaborationRepository {
  final Dio _dio;

  CollaborationRepository(this._dio);

  /// Update user's phone number
  Future<void> updatePhoneNumber(String phoneNumber) async {
    await _dio.patch(
      ApiEndpoints.me,
      data: {'phoneNumber': phoneNumber},
    );
  }

  /// Sync/match array of phone numbers against registered users
  Future<List<SyncedContact>> syncContacts(List<String> phoneNumbers) async {
    final response = await _dio.post(
      ApiEndpoints.collaborationSyncContacts,
      data: {'phoneNumbers': phoneNumbers},
    );

    final dataList = response.data['data'] as List<dynamic>? ?? [];
    return dataList.map((item) => SyncedContact.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Send collaboration invite to a phone number or guestId
  Future<CollaborationSessionModel> sendInvite({String? phoneNumber, String? guestId}) async {
    final response = await _dio.post(
      ApiEndpoints.collaborationInvite,
      data: {
        if (phoneNumber != null) ...{'phoneNumber': phoneNumber},
        if (guestId != null) ...{'guestId': guestId},
      },
    );

    return CollaborationSessionModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Get active session and pending invites
  Future<SessionAndInvitesResult> getSessionAndInvites() async {
    final response = await _dio.get(ApiEndpoints.collaborationSession);
    final data = response.data['data'] as Map<String, dynamic>? ?? {};

    final activeRaw = data['activeSession'] as Map<String, dynamic>?;
    final activeSession = activeRaw != null ? CollaborationSessionModel.fromJson(activeRaw) : null;

    final incomingRaw = data['incomingInvites'] as List<dynamic>? ?? [];
    final incomingInvites = incomingRaw.map((item) => CollaborationSessionModel.fromJson(item as Map<String, dynamic>)).toList();

    final outgoingRaw = data['outgoingInvites'] as List<dynamic>? ?? [];
    final outgoingInvites = outgoingRaw.map((item) => CollaborationSessionModel.fromJson(item as Map<String, dynamic>)).toList();

    return SessionAndInvitesResult(
      activeSession: activeSession,
      incomingInvites: incomingInvites,
      outgoingInvites: outgoingInvites,
    );
  }

  /// Accept or decline an invitation
  Future<CollaborationSessionModel> respondInvite(String sessionId, bool accept) async {
    final response = await _dio.post(
      ApiEndpoints.collaborationRespondInvite(sessionId),
      data: {'accept': accept},
    );

    return CollaborationSessionModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Get combined track library of host + guest
  Future<CombinedSessionTracks> getCombinedTracks(String sessionId) async {
    final response = await _dio.get(ApiEndpoints.collaborationSessionTracks(sessionId));
    return CombinedSessionTracks.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Trigger random song selection from combined library
  Future<TrackModel> playRandomSong(String sessionId) async {
    final response = await _dio.post(ApiEndpoints.collaborationPlayRandom(sessionId));
    final data = response.data['data'] as Map<String, dynamic>;
    return TrackModel.fromJson(data['selectedTrack'] as Map<String, dynamic>);
  }

  /// End an active session
  Future<void> endSession(String sessionId) async {
    await _dio.post(ApiEndpoints.collaborationEndSession(sessionId));
  }
}
