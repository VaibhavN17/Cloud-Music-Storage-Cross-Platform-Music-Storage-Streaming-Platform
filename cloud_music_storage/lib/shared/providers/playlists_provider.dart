/// Playlists Riverpod State Notifier & Provider.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/playlist_model.dart';
import '../models/track_model.dart';

class PlaylistsState {
  const PlaylistsState({
    this.playlists = const [],
    this.isLoading = false,
  });

  final List<PlaylistModel> playlists;
  final bool isLoading;

  PlaylistsState copyWith({
    List<PlaylistModel>? playlists,
    bool? isLoading,
  }) {
    return PlaylistsState(
      playlists: playlists ?? this.playlists,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final playlistsProvider = StateNotifierProvider<PlaylistsNotifier, PlaylistsState>((ref) {
  return PlaylistsNotifier();
});

class PlaylistsNotifier extends StateNotifier<PlaylistsState> {
  PlaylistsNotifier() : super(const PlaylistsState());

  void createPlaylist(String title, {String? description}) {
    final newPlaylist = PlaylistModel(
      id: 'pl_${DateTime.now().millisecondsSinceEpoch}',
      ownerId: 'me',
      name: title,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(playlists: [newPlaylist, ...state.playlists]);
  }

  void addTrackToPlaylist(String playlistId, TrackModel track) {
    final index = state.playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = state.playlists[index];
      if (!playlist.tracks.any((t) => t.id == track.id)) {
        final updatedTracks = [...playlist.tracks, track];
        final updatedPlaylist = playlist.copyWith(
          tracks: updatedTracks,
          trackCount: updatedTracks.length,
        );
        final updatedList = List<PlaylistModel>.from(state.playlists);
        updatedList[index] = updatedPlaylist;
        state = state.copyWith(playlists: updatedList);
      }
    }
  }

  void removeTrackFromPlaylist(String playlistId, String trackId) {
    final index = state.playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = state.playlists[index];
      final updatedTracks = playlist.tracks.where((t) => t.id != trackId).toList();
      final updatedPlaylist = playlist.copyWith(
        tracks: updatedTracks,
        trackCount: updatedTracks.length,
      );
      final updatedList = List<PlaylistModel>.from(state.playlists);
      updatedList[index] = updatedPlaylist;
      state = state.copyWith(playlists: updatedList);
    }
  }

  void deletePlaylist(String playlistId) {
    state = state.copyWith(
      playlists: state.playlists.where((p) => p.id != playlistId).toList(),
    );
  }
}
