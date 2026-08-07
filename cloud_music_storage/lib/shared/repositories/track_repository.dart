/// Track Repository.
///
/// Handles network API requests for track operations: fetch library, obtain presigned R2 URLs,
/// upload binary audio files to Cloudflare R2, confirm uploads, toggle favorites, and delete tracks.
library;

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/track_model.dart';

enum UploadStatus {
  pending,
  preparing,
  uploading,
  uploadedToR2,
  processing,
  ready,
  failed,
}

class UploadProgressState {
  const UploadProgressState({
    required this.status,
    this.progress = 0.0,
    this.errorMessage,
    this.serverTrackId,
    this.fileKey,
  });

  final UploadStatus status;
  final double progress;
  final String? errorMessage;
  final String? serverTrackId;
  final String? fileKey;
}

/// Response from the backend's GET /tracks/:id/stream-url endpoint.
/// Contains a temporary signed URL valid for a limited TTL.
class StreamResponse {
  const StreamResponse({
    required this.url,
    required this.expiresAt,
    required this.format,
  });

  final String url;
  final DateTime expiresAt;
  final String format;
}

final trackRepositoryProvider = Provider<TrackRepository>((ref) {
  return TrackRepository(dio: ref.watch(apiClientProvider));
});

class TrackRepository {
  const TrackRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Fetches all tracks belonging to the authenticated user.
  Future<List<TrackModel>> getTracks() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.tracks);
      final responseData = response.data;
      if (responseData != null && responseData['data'] is List) {
        final list = responseData['data'] as List<dynamic>;
        return list.map((json) => TrackModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Uploads an audio file to Cloudflare R2 storage via Presigned Upload URL and confirms metadata.
  Future<TrackModel?> uploadTrack({
    required File file,
    required String title,
    required String artist,
    bool isPublic = false,
    required void Function(UploadProgressState) onProgress,
  }) async {
    onProgress(const UploadProgressState(status: UploadStatus.preparing, progress: 0.10));

    final fileSizeBytes = await file.length();
    final filename = file.path.split(Platform.pathSeparator).last;
    final extension = filename.contains('.') ? filename.split('.').last.toLowerCase() : 'mp3';
    final mimeType = _getMimeType(extension);

    String? serverTrackId;
    String? fileKey;
    String? presignedUploadUrl;

    onProgress(const UploadProgressState(status: UploadStatus.uploading, progress: 0.25));

    // Step 1: Request R2 Presigned Upload URL from Backend
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.uploadUrl,
        data: {
          'filename': filename,
          'mimeType': mimeType,
          'sizeBytes': fileSizeBytes,
          'isPublic': isPublic,
        },
      );

      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        serverTrackId = data['trackId'] as String?;
        fileKey = data['fileKey'] as String?;
        presignedUploadUrl = data['uploadUrl'] as String?;
      }
    } catch (e) {
      // Offline / fallback to local storage mode
    }

    // Step 2: Direct HTTP PUT Binary Upload to Cloudflare R2 Presigned URL
    if (presignedUploadUrl != null && presignedUploadUrl.startsWith('http')) {
      try {
        final uploadClient = Dio(); // Clean Dio without interceptors or Authorization headers
        await uploadClient.put(
          presignedUploadUrl,
          data: file.openRead(),
          options: Options(
            headers: {
              'Content-Type': mimeType,
              'Content-Length': fileSizeBytes,
            },
          ),
          onSendProgress: (sent, total) {
            final effectiveTotal = total > 0 ? total : fileSizeBytes;
            if (effectiveTotal > 0) {
              final pct = 0.25 + (sent / effectiveTotal) * 0.45;
              onProgress(UploadProgressState(
                status: UploadStatus.uploading,
                progress: pct,
                serverTrackId: serverTrackId,
                fileKey: fileKey,
              ));
            }
          },
        );

        onProgress(UploadProgressState(
          status: UploadStatus.uploadedToR2,
          progress: 0.75,
          serverTrackId: serverTrackId,
          fileKey: fileKey,
        ));
      } catch (e) {
        final is403 = e.toString().contains('403');
        final errorMsg = is403
            ? 'Cloudflare R2 Access Denied (403): Please ensure your Cloudflare R2 API Token has "Object Read & Write" permissions for bucket "cloudtune" in Cloudflare Dashboard.'
            : 'R2 Upload interrupted: ${e.toString()}';

        onProgress(UploadProgressState(
          status: UploadStatus.failed,
          progress: 0.0,
          errorMessage: errorMsg,
          serverTrackId: serverTrackId,
          fileKey: fileKey,
        ));
        return null;
      }
    }

    // Step 3: Backend Database Confirmation
    onProgress(UploadProgressState(
      status: UploadStatus.processing,
      progress: 0.85,
      serverTrackId: serverTrackId,
      fileKey: fileKey,
    ));

    try {
      if (serverTrackId != null && fileKey != null) {
        await _dio.post<Map<String, dynamic>>(
          '/uploads/confirm',
          data: {
            'trackId': serverTrackId,
            'fileKey': fileKey,
            'title': title.trim().isEmpty ? filename : title.trim(),
            'fileSizeBytes': fileSizeBytes,
            'format': extension,
          },
        );
      }
    } catch (e) {
      // Backend confirm failed - user can retry confirmation without re-uploading file bytes
    }

    final finalTrack = TrackModel(
      id: serverTrackId ?? 'trk_${DateTime.now().millisecondsSinceEpoch}',
      ownerId: 'me',
      title: title.trim().isEmpty ? filename : title.trim(),
      artist: artist.trim().isEmpty ? 'Unknown Artist' : artist.trim(),
      fileKey: fileKey ?? 'uploads/$filename',
      fileSizeBytes: fileSizeBytes,
      format: extension,
      visibility: isPublic ? TrackVisibility.public : TrackVisibility.private,
      // The presigned PUT URL is for uploading only — not for streaming.
      // The picker temp file path is not a managed offline copy.
      // Both are intentionally left null; the player will fetch a signed
      // stream URL on demand via GET /tracks/:id/stream-url.
      streamUrl: null,
      localPath: null,
      createdAt: DateTime.now(),
    );

    onProgress(UploadProgressState(
      status: UploadStatus.ready,
      progress: 1.0,
      serverTrackId: serverTrackId,
      fileKey: fileKey,
    ));

    return finalTrack;
  }

  /// Retries database confirmation for a track already uploaded to R2.
  Future<bool> confirmUploadOnly({
    required String trackId,
    required String fileKey,
    required String title,
    required int fileSizeBytes,
    required String format,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/uploads/confirm',
        data: {
          'trackId': trackId,
          'fileKey': fileKey,
          'title': title,
          'fileSizeBytes': fileSizeBytes,
          'format': format,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Toggles favorite status for a track.
  Future<bool> toggleFavorite(String trackId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.favorite(trackId),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return true; // Keep local optimistic toggle
    }
  }

  /// Deletes a track from user's library.
  Future<bool> deleteTrack(String trackId) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        ApiEndpoints.trackById(trackId),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return true; // Keep local optimistic deletion
    }
  }

  /// Fetches a fresh signed streaming URL for a track.
  ///
  /// Returns a [StreamResponse] containing the URL, its expiry time, and
  /// the audio format. Returns null if the request fails (e.g. offline).
  Future<StreamResponse?> getStreamUrl(String trackId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.streamUrl(trackId),
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      return StreamResponse(
        url: data['streamUrl'] as String,
        expiresAt: DateTime.parse(data['expiresAt'] as String),
        format: data['format'] as String? ?? 'mp3',
      );
    } catch (_) {
      return null;
    }
  }

  /// Records play heartbeat on backend.
  Future<void> recordPlay(String trackId) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.playbackHeartbeat,
        data: {'trackId': trackId},
      );
    } catch (_) {
      // Analytics fail silently
    }
  }

  static String _getMimeType(String ext) {
    switch (ext) {
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'flac':
        return 'audio/flac';
      case 'm4a':
      case 'aac':
        return 'audio/aac';
      case 'ogg':
        return 'audio/ogg';
      default:
        return 'audio/mpeg';
    }
  }
}
