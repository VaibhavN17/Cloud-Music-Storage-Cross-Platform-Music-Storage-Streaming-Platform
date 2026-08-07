/// Tracks Riverpod State Notifier & Provider.
///
/// Coordinates library state between UI and TrackRepository.
/// Implements optimistic UI updates with server synchronization and rollback handling.
library;

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/view_state.dart';
import '../models/track_model.dart';
import '../repositories/track_repository.dart';

class TracksState {
  const TracksState({
    this.tracks = const [],
    this.viewState = ViewState.empty,
    this.uploadProgress,
    this.errorMessage,
  });

  final List<TrackModel> tracks;
  final ViewState viewState;
  final UploadProgressState? uploadProgress;
  final String? errorMessage;

  TracksState copyWith({
    List<TrackModel>? tracks,
    ViewState? viewState,
    UploadProgressState? uploadProgress,
    String? errorMessage,
  }) {
    return TracksState(
      tracks: tracks ?? this.tracks,
      viewState: viewState ?? this.viewState,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: errorMessage,
    );
  }
}

final tracksProvider = StateNotifierProvider<TracksNotifier, TracksState>((ref) {
  final repository = ref.watch(trackRepositoryProvider);
  return TracksNotifier(repository);
});

final favoritesProvider = Provider<List<TrackModel>>((ref) {
  final state = ref.watch(tracksProvider);
  return state.tracks.where((t) => t.isFavorite).toList();
});

final recentTracksProvider = Provider<List<TrackModel>>((ref) {
  final state = ref.watch(tracksProvider);
  final list = List<TrackModel>.from(state.tracks);
  list.sort((a, b) {
    final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return bDate.compareTo(aDate);
  });
  return list;
});

final mostPlayedProvider = Provider<List<TrackModel>>((ref) {
  final state = ref.watch(tracksProvider);
  final list = List<TrackModel>.from(state.tracks);
  list.sort((a, b) => b.playCount.compareTo(a.playCount));
  return list;
});

class TracksNotifier extends StateNotifier<TracksState> {
  TracksNotifier(this._repository) : super(const TracksState()) {
    fetchLibrary();
  }

  final TrackRepository _repository;

  /// Fetches library from backend and updates state.
  Future<void> fetchLibrary() async {
    state = state.copyWith(viewState: ViewState.loading);
    try {
      final tracks = await _repository.getTracks();
      state = state.copyWith(
        tracks: tracks,
        viewState: tracks.isEmpty ? ViewState.empty : ViewState.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        viewState: state.tracks.isEmpty ? ViewState.error : ViewState.loaded,
        errorMessage: e.toString(),
      );
    }
  }

  /// Uploads audio file, emits UploadProgressState, and updates library ONLY when status is UploadStatus.ready.
  Future<TrackModel?> uploadTrack({
    required File file,
    required String title,
    required String artist,
    bool isPublic = false,
  }) async {
    final uploadedTrack = await _repository.uploadTrack(
      file: file,
      title: title,
      artist: artist,
      isPublic: isPublic,
      onProgress: (progressState) {
        state = state.copyWith(uploadProgress: progressState);
      },
    );

    if (uploadedTrack != null && state.uploadProgress?.status == UploadStatus.ready) {
      final updatedList = [uploadedTrack, ...state.tracks];
      state = state.copyWith(
        tracks: updatedList,
        viewState: ViewState.loaded,
      );
      return uploadedTrack;
    }

    return uploadedTrack;
  }

  /// Optimistically toggles favorite status for a track.
  Future<void> toggleFavorite(String trackId) async {
    final previousTracks = List<TrackModel>.from(state.tracks);
    final index = state.tracks.indexWhere((t) => t.id == trackId);
    if (index == -1) return;

    final targetTrack = state.tracks[index];
    final updatedTrack = targetTrack.copyWith(isFavorite: !targetTrack.isFavorite);

    final updatedList = List<TrackModel>.from(state.tracks);
    updatedList[index] = updatedTrack;

    // Optimistic UI update
    state = state.copyWith(tracks: updatedList);

    // Backend sync
    final success = await _repository.toggleFavorite(trackId);
    if (!success) {
      // Rollback on failure
      state = state.copyWith(tracks: previousTracks);
    }
  }

  /// Optimistically deletes a track from user library.
  Future<void> deleteTrack(String trackId) async {
    final previousTracks = List<TrackModel>.from(state.tracks);
    final updatedList = state.tracks.where((t) => t.id != trackId).toList();

    // Optimistic UI update
    state = state.copyWith(
      tracks: updatedList,
      viewState: updatedList.isEmpty ? ViewState.empty : ViewState.loaded,
    );

    // Backend sync
    final success = await _repository.deleteTrack(trackId);
    if (!success) {
      // Rollback on failure
      state = state.copyWith(
        tracks: previousTracks,
        viewState: previousTracks.isEmpty ? ViewState.empty : ViewState.loaded,
      );
    }
  }

  /// Records play count locally and sends background ping to backend.
  void recordPlay(String trackId) {
    final index = state.tracks.indexWhere((t) => t.id == trackId);
    if (index != -1) {
      final targetTrack = state.tracks[index];
      final updatedTrack = targetTrack.copyWith(playCount: targetTrack.playCount + 1);
      final updatedList = List<TrackModel>.from(state.tracks);
      updatedList[index] = updatedTrack;
      state = state.copyWith(tracks: updatedList);
    }
    _repository.recordPlay(trackId);
  }
}
