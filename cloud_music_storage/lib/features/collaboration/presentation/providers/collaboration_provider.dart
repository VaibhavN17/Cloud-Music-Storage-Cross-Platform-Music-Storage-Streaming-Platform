import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/track_model.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../data/models/collaboration_models.dart';
import '../../data/repositories/collaboration_repository.dart';

class CollaborationState {
  final bool isLoading;
  final bool isSyncingContacts;
  final String? errorMessage;
  final String? userPhoneNumber;
  final CollaborationSessionModel? activeSession;
  final List<CollaborationSessionModel> incomingInvites;
  final List<CollaborationSessionModel> outgoingInvites;
  final List<SyncedContact> syncedContacts;
  final List<TrackModel> combinedTracks;
  final TrackModel? sessionCurrentTrack;

  CollaborationState({
    this.isLoading = false,
    this.isSyncingContacts = false,
    this.errorMessage,
    this.userPhoneNumber,
    this.activeSession,
    this.incomingInvites = const [],
    this.outgoingInvites = const [],
    this.syncedContacts = const [],
    this.combinedTracks = const [],
    this.sessionCurrentTrack,
  });

  CollaborationState copyWith({
    bool? isLoading,
    bool? isSyncingContacts,
    String? errorMessage,
    String? userPhoneNumber,
    CollaborationSessionModel? activeSession,
    bool clearActiveSession = false,
    List<CollaborationSessionModel>? incomingInvites,
    List<CollaborationSessionModel>? outgoingInvites,
    List<SyncedContact>? syncedContacts,
    List<TrackModel>? combinedTracks,
    TrackModel? sessionCurrentTrack,
  }) {
    return CollaborationState(
      isLoading: isLoading ?? this.isLoading,
      isSyncingContacts: isSyncingContacts ?? this.isSyncingContacts,
      errorMessage: errorMessage,
      userPhoneNumber: userPhoneNumber ?? this.userPhoneNumber,
      activeSession: clearActiveSession ? null : (activeSession ?? this.activeSession),
      incomingInvites: incomingInvites ?? this.incomingInvites,
      outgoingInvites: outgoingInvites ?? this.outgoingInvites,
      syncedContacts: syncedContacts ?? this.syncedContacts,
      combinedTracks: combinedTracks ?? this.combinedTracks,
      sessionCurrentTrack: sessionCurrentTrack ?? this.sessionCurrentTrack,
    );
  }
}

class CollaborationNotifier extends StateNotifier<CollaborationState> {
  final CollaborationRepository _repository;
  final Ref _ref;

  CollaborationNotifier(this._repository, this._ref) : super(CollaborationState());

  /// Load session and invites data
  Future<void> loadSessionAndInvites() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _repository.getSessionAndInvites();
      state = state.copyWith(
        isLoading: false,
        activeSession: res.activeSession,
        clearActiveSession: res.activeSession == null,
        incomingInvites: res.incomingInvites,
        outgoingInvites: res.outgoingInvites,
      );

      if (res.activeSession != null) {
        await fetchCombinedTracks(res.activeSession!.id);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Update user phone number
  Future<bool> setPhoneNumber(String phone) async {
    try {
      await _repository.updatePhoneNumber(phone);
      state = state.copyWith(userPhoneNumber: phone);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update phone number: $e');
      return false;
    }
  }

  /// Sync device contact list or inputted numbers against backend
  Future<void> syncContacts(List<String> phoneNumbers) async {
    if (phoneNumbers.isEmpty) return;
    state = state.copyWith(isSyncingContacts: true, errorMessage: null);
    try {
      final contacts = await _repository.syncContacts(phoneNumbers);
      state = state.copyWith(
        isSyncingContacts: false,
        syncedContacts: contacts,
      );
    } catch (e) {
      state = state.copyWith(
        isSyncingContacts: false,
        errorMessage: 'Failed to lookup contacts: $e',
      );
    }
  }

  /// Send invite to contact / phone number
  Future<bool> sendInvite({String? phoneNumber, String? guestId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.sendInvite(phoneNumber: phoneNumber, guestId: guestId);
      await loadSessionAndInvites();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Respond to pending invitation
  Future<bool> respondInvite(String sessionId, bool accept) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.respondInvite(sessionId, accept);
      await loadSessionAndInvites();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Fetch combined tracks of host and guest
  Future<void> fetchCombinedTracks(String sessionId) async {
    try {
      final res = await _repository.getCombinedTracks(sessionId);
      state = state.copyWith(combinedTracks: res.tracks);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to load shared tracks: $e');
    }
  }

  /// Play a random song from the combined track pool
  Future<TrackModel?> playRandomTrack() async {
    if (state.activeSession == null) return null;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final track = await _repository.playRandomSong(state.activeSession!.id);
      state = state.copyWith(
        isLoading: false,
        sessionCurrentTrack: track,
      );

      // Trigger global audio player to play the selected track!
      final playerNotifier = _ref.read(playerProvider.notifier);
      await playerNotifier.playTrack(track, queue: state.combinedTracks);

      return track;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to pick random song: $e',
      );
      return null;
    }
  }

  /// End current session
  Future<void> endSession() async {
    if (state.activeSession == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.endSession(state.activeSession!.id);
      state = state.copyWith(
        isLoading: false,
        clearActiveSession: true,
        combinedTracks: [],
        sessionCurrentTrack: null,
      );
      await loadSessionAndInvites();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to end session: $e',
      );
    }
  }
}

final collaborationProvider = StateNotifierProvider<CollaborationNotifier, CollaborationState>((ref) {
  final repo = ref.watch(collaborationRepositoryProvider);
  return CollaborationNotifier(repo, ref);
});
