/// Network connectivity monitoring service.
library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream provider for connectivity status.
final connectivityProvider = StreamProvider<bool>((ref) {
  return ConnectivityService().isConnected;
});

/// Simple connectivity provider (current state).
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.valueOrNull ?? true;
});

class ConnectivityService {
  final _connectivity = Connectivity();

  /// Stream that emits true when connected, false when disconnected.
  Stream<bool> get isConnected {
    return _connectivity.onConnectivityChanged.map((results) {
      return results.any(
        (result) => result != ConnectivityResult.none,
      );
    });
  }

  /// Check current connectivity status.
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }
}
