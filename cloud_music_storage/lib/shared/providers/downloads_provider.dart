/// Dedicated Downloads Riverpod Provider.
///
/// Manages offline downloaded audio files independently from cloud library.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/track_model.dart';

final downloadsProvider = StateNotifierProvider<DownloadsNotifier, List<TrackModel>>((ref) {
  return DownloadsNotifier();
});

class DownloadsNotifier extends StateNotifier<List<TrackModel>> {
  DownloadsNotifier() : super(const []);

  void addDownloadedTrack(TrackModel track) {
    if (!state.any((t) => t.id == track.id)) {
      final downloadedTrack = track.copyWith(isDownloaded: true);
      state = [downloadedTrack, ...state];
    }
  }

  void removeDownloadedTrack(String trackId) {
    state = state.where((t) => t.id != trackId).toList();
  }
}
