import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../player/presentation/providers/player_provider.dart';
import '../providers/collaboration_provider.dart';

class CollaborationScreen extends ConsumerStatefulWidget {
  const CollaborationScreen({super.key});

  @override
  ConsumerState<CollaborationScreen> createState() => _CollaborationScreenState();
}

class _CollaborationScreenState extends ConsumerState<CollaborationScreen> {
  final TextEditingController _phoneInputController = TextEditingController();
  final TextEditingController _profilePhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(collaborationProvider.notifier).loadSessionAndInvites();
    });
  }

  @override
  void dispose() {
    _phoneInputController.dispose();
    _profilePhoneController.dispose();
    super.dispose();
  }

  void _showSetPhoneDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Set Your Phone Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your contact phone number so your friends can find and invite you on the app.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _profilePhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+1234567890',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(dialogContext);
                final phone = _profilePhoneController.text.trim();
                if (phone.isNotEmpty) {
                  final success = await ref
                      .read(collaborationProvider.notifier)
                      .setPhoneNumber(phone);
                  if (success) {
                    nav.pop();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Phone number updated successfully!')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _onManualLookup() {
    final text = _phoneInputController.text.trim();
    if (text.isEmpty) return;

    // Parse comma-separated or space-separated numbers
    final numbers = text
        .split(RegExp(r'[,\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    ref.read(collaborationProvider.notifier).syncContacts(numbers);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(collaborationStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listen Together'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(collaborationProvider.notifier).loadSessionAndInvites(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.phonelink_setup),
            onPressed: _showSetPhoneDialog,
            tooltip: 'Set My Phone Number',
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(collaborationProvider.notifier).loadSessionAndInvites(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error Banner
                    if (state.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: theme.colorScheme.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: TextStyle(color: theme.colorScheme.onErrorContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 1. Active Session Section
                    if (state.activeSession != null) ...[
                      _buildActiveSessionCard(context, state),
                      const SizedBox(height: 24),
                    ],

                    // 2. Incoming & Outgoing Invites
                    if (state.incomingInvites.isNotEmpty ||
                        state.outgoingInvites.isNotEmpty) ...[
                      _buildInvitesSection(context, state),
                      const SizedBox(height: 24),
                    ],

                    // 3. Contact Lookup & Invite Section
                    _buildContactLookupSection(context, state),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildActiveSessionCard(BuildContext context, CollaborationState state) {
    final session = state.activeSession!;
    final theme = Theme.of(context);
    final hostName = session.host?.displayName ?? 'Host';
    final guestName = session.guest?.displayName ?? 'Guest';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  avatar: const Icon(Icons.graphic_eq, size: 18),
                  label: const Text('Active Room'),
                  backgroundColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('End Session?'),
                        content: const Text('This will end the shared listening session for both participants.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('End Session')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      ref.read(collaborationProvider.notifier).endSession();
                    }
                  },
                  icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                  label: const Text('Leave', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Participant avatars & names
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUserAvatar(hostName, 'Host', theme),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(Icons.swap_horizontal_circle, size: 32, color: theme.colorScheme.primary),
                ),
                _buildUserAvatar(guestName, 'Guest', theme),
              ],
            ),
            const SizedBox(height: 20),

            // Shared Library stats
            Center(
              child: Text(
                'Combined Library: ${state.combinedTracks.length} tracks available',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // PRIMARY ACTION BUTTON: PLAY RANDOM SONG FROM BOTH USERS
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 6,
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final track = await ref.read(collaborationProvider.notifier).playRandomTrack();
                  if (track != null) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Now Playing (Random Choice): ${track.title} - ${track.artist ?? "Unknown"}'),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.shuffle_rounded, size: 28),
                label: const Text(
                  'PLAY RANDOM SONG (BOTH USERS)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Combined Tracks List preview
            const Text(
              'Shared Tracks',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            state.combinedTracks.isEmpty
                ? const Text('No tracks uploaded yet by either user.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.combinedTracks.length > 5 ? 5 : state.combinedTracks.length,
                    itemBuilder: (context, index) {
                      final track = state.combinedTracks[index];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(track.title, overflow: TextOverflow.ellipsis),
                        subtitle: Text(track.artist ?? 'Unknown Artist'),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_circle_fill),
                          onPressed: () {
                            ref.read(playerProvider.notifier).playTrack(
                                  track,
                                  queue: state.combinedTracks,
                                );
                          },
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(String name, String role, ThemeData theme) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary),
          ),
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(role, style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
      ],
    );
  }

  Widget _buildInvitesSection(BuildContext context, CollaborationState state) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invitations', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (state.incomingInvites.isNotEmpty) ...[
              const Text('Incoming Invites', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ...state.incomingInvites.map((invite) {
                final senderName = invite.host?.displayName ?? 'A user';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.person_add)),
                  title: Text('$senderName invited you to Listen Together'),
                  subtitle: Text(invite.host?.phoneNumber ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                        onPressed: () => ref
                            .read(collaborationProvider.notifier)
                            .respondInvite(invite.id, true),
                        tooltip: 'Accept',
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
                        onPressed: () => ref
                            .read(collaborationProvider.notifier)
                            .respondInvite(invite.id, false),
                        tooltip: 'Decline',
                      ),
                    ],
                  ),
                );
              }),
            ],
            if (state.outgoingInvites.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Pending Outgoing Invites', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              ...state.outgoingInvites.map((invite) {
                final recipientName = invite.guest?.displayName ?? invite.guest?.phoneNumber ?? 'Contact';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.hourglass_top)),
                  title: Text('Invite sent to $recipientName'),
                  subtitle: const Text('Waiting for acceptance...'),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactLookupSection(BuildContext context, CollaborationState state) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.contacts),
                const SizedBox(width: 8),
                Text('Invite Friends from Contacts', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Enter contact phone numbers to check if they are available on the app:'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneInputController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'e.g. +1234567890, +9876543210',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: state.isSyncingContacts ? null : _onManualLookup,
                  child: state.isSyncingContacts
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Lookup'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Synced contacts results
            if (state.syncedContacts.isNotEmpty) ...[
              Text('Found Contacts (${state.syncedContacts.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.syncedContacts.length,
                itemBuilder: (context, index) {
                  final contact = state.syncedContacts[index];
                  final isRegistered = contact.isRegisteredOnApp;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isRegistered ? Colors.green.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isRegistered ? Colors.green : Colors.grey.shade400,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isRegistered ? Colors.green : Colors.grey,
                          child: Icon(
                            isRegistered ? Icons.person_add_alt_1 : Icons.person_off,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.user?.displayName ?? contact.phone,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                contact.phone,
                                style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                              ),
                              const SizedBox(height: 2),
                              Chip(
                                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: isRegistered ? Colors.green.shade100 : Colors.grey.shade300,
                                label: Text(
                                  isRegistered ? 'Available on App' : 'Not on App',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isRegistered ? Colors.green.shade900 : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isRegistered)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.send, size: 16),
                            label: const Text('Invite'),
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final success = await ref
                                  .read(collaborationProvider.notifier)
                                  .sendInvite(guestId: contact.user?.id, phoneNumber: contact.phone);
                              if (success) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text('Invite sent to ${contact.user?.displayName ?? contact.phone}!')),
                                );
                              }
                            },
                          )
                        else
                          OutlinedButton.icon(
                            icon: const Icon(Icons.share, size: 16),
                            label: const Text('Share App'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('App invite link copied to clipboard!')),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Provider typedef helper
final collaborationStateProvider = Provider<CollaborationState>((ref) {
  return ref.watch(collaborationProvider);
});
