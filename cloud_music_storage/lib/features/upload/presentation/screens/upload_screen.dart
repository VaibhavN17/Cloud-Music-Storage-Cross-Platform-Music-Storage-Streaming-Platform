/// Upload screen.
///
/// Production Upload Pipeline UI: native file picking via FilePicker, runtime permission check,
/// R2 private/public visibility switch, rich state machine progress badges, step-aware error banner,
/// retry action button, and first-upload celebration dialog.
library;

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/tracks_provider.dart';
import '../../../../shared/repositories/track_repository.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../widgets/first_upload_dialog.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  File? _selectedFile;
  String _fileName = '';
  int _fileSizeBytes = 0;
  String _format = '';
  bool _isPublic = false;

  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    final hasPermission = await PermissionService.requestAudioStoragePermission();
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage/Audio permission is required to select audio files.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'flac', 'wav', 'm4a', 'ogg', 'aac'],
    );

    if (result != null && result.files.single.path != null) {
      final platformFile = result.files.single;
      final file = File(platformFile.path!);

      final rawName = platformFile.name;
      final nameWithoutExt = rawName.contains('.')
          ? rawName.substring(0, rawName.lastIndexOf('.'))
          : rawName;
      final ext = platformFile.extension?.toUpperCase() ?? 'MP3';

      setState(() {
        _selectedFile = file;
        _fileName = rawName;
        _fileSizeBytes = platformFile.size;
        _format = ext;
        _titleController.text = nameWithoutExt;
        _artistController.text = 'Unknown Artist';
      });
    }
  }

  Future<void> _startUpload() async {
    if (_selectedFile == null) return;

    setState(() => _isUploading = true);

    final isFirstUpload = ref.read(tracksProvider).tracks.isEmpty;

    final uploadedTrack = await ref.read(tracksProvider.notifier).uploadTrack(
      file: _selectedFile!,
      title: _titleController.text.trim(),
      artist: _artistController.text.trim(),
      isPublic: _isPublic,
    );

    if (!mounted) return;

    setState(() => _isUploading = false);

    final progressState = ref.read(tracksProvider).uploadProgress;
    if (uploadedTrack != null && progressState?.status == UploadStatus.ready) {
      if (isFirstUpload) {
        context.pop();
        FirstUploadSuccessDialog.show(
          context,
          trackTitle: uploadedTrack.title,
          onPlayPressed: () {
            ref.read(playerProvider.notifier).playTrack(uploadedTrack);
          },
        );
      } else {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Uploaded "${uploadedTrack.title}" successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracksState = ref.watch(tracksProvider);
    final uploadProgress = tracksState.uploadProgress;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Upload Music',
          style: AppTypography.h2(color: context.appColors.textPrimary),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // Drop / File Selector Zone
                GestureDetector(
                  onTap: _isUploading ? null : _pickAudioFile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxl,
                      horizontal: AppSpacing.xl,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedFile != null
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.3),
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                      borderRadius: AppRadius.sheetRadius,
                      color: _selectedFile != null
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.primary.withValues(alpha: 0.05),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            _selectedFile != null ? Iconsax.music : Iconsax.arrow_up_2,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _selectedFile != null ? _fileName : 'Select your audio file',
                          style: AppTypography.h3(
                            color: context.appColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _selectedFile != null
                              ? 'Format: $_format • ${(_fileSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB'
                              : 'MP3, FLAC, WAV, M4A, OGG, AAC • Max 500 MB',
                          style: AppTypography.caption(
                            color: context.appColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        OutlinedButton.icon(
                          onPressed: _isUploading ? null : _pickAudioFile,
                          icon: const Icon(Iconsax.folder_open, size: 18),
                          label: Text(_selectedFile != null ? 'Change File' : 'Browse Files'),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_selectedFile != null) ...[
                  const SizedBox(height: AppSpacing.xl),

                  // Metadata & Visibility Form
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: context.appColors.surfaceVariant,
                      borderRadius: AppRadius.cardRadius,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Track Details',
                          style: AppTypography.bodySemiBold(
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _titleController,
                          enabled: !_isUploading,
                          decoration: const InputDecoration(
                            labelText: 'Song Title',
                            prefixIcon: Icon(Iconsax.musicnote, size: 20),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _artistController,
                          enabled: !_isUploading,
                          decoration: const InputDecoration(
                            labelText: 'Artist',
                            prefixIcon: Icon(Iconsax.user, size: 20),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Public Visibility',
                            style: AppTypography.bodySmall(color: context.appColors.textPrimary),
                          ),
                          subtitle: Text(
                            _isPublic
                                ? 'Uploads to audio-public/ (Shareable)'
                                : 'Uploads to audio-private/ (Private)',
                            style: AppTypography.caption(color: context.appColors.textSecondary),
                          ),
                          value: _isPublic,
                          activeTrackColor: AppColors.primary,
                          onChanged: _isUploading ? null : (val) => setState(() => _isPublic = val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Error Banner & Retry System
                  if (uploadProgress?.status == UploadStatus.failed) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: AppRadius.cardRadius,
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.error),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              uploadProgress?.errorMessage ?? 'Upload interrupted. Tap Retry to resume.',
                              style: AppTypography.caption(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _startUpload,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry Upload'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Upload Progress Indicator
                  if (_isUploading && uploadProgress != null && uploadProgress.status != UploadStatus.failed) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getStatusLabel(uploadProgress.status),
                              style: AppTypography.caption(
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '${(uploadProgress.progress * 100).toInt()}%',
                              style: AppTypography.caption(
                                color: context.appColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: uploadProgress.progress,
                            backgroundColor: context.appColors.border,
                            color: AppColors.primary,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ],

                  // Start Upload Action Button
                  if (uploadProgress?.status != UploadStatus.failed)
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: _isUploading ? 'Uploading...' : 'Upload Music',
                        onPressed: _isUploading ? null : _startUpload,
                        isLoading: _isUploading,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(UploadStatus status) {
    switch (status) {
      case UploadStatus.pending:
        return 'Queued for upload...';
      case UploadStatus.preparing:
        return 'Preparing audio file & validating...';
      case UploadStatus.uploading:
        return 'Uploading to Cloudflare R2 bucket...';
      case UploadStatus.uploadedToR2:
        return 'Uploaded to R2. Finalizing database record...';
      case UploadStatus.processing:
        return 'Processing metadata & stream token...';
      case UploadStatus.ready:
        return 'Upload Complete & Ready!';
      case UploadStatus.failed:
        return 'Upload Interrupted';
    }
  }
}
