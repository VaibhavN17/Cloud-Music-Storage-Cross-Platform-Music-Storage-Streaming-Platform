import { Playlist, Visibility } from '@prisma/client';
import { playlistRepository, PlaylistRepository } from '../repositories/playlist.repository';
import { ApiError } from '../utils/ApiError';

export class PlaylistService {
  constructor(private repo: PlaylistRepository = playlistRepository) {}

  async listPlaylists(ownerId: string): Promise<Playlist[]> {
    return this.repo.listUserPlaylists(ownerId);
  }

  async getPlaylist(id: string, userId: string): Promise<Playlist> {
    const playlist = await this.repo.findById(id, userId);
    if (!playlist) {
      throw ApiError.notFound('Playlist not found');
    }
    return playlist;
  }

  async createPlaylist(ownerId: string, name: string, description?: string, visibility = Visibility.PRIVATE): Promise<Playlist> {
    return this.repo.create({
      name,
      description,
      visibility,
      owner: { connect: { id: ownerId } },
    });
  }

  async updatePlaylist(
    id: string,
    ownerId: string,
    data: { name?: string; description?: string; coverUrl?: string; visibility?: Visibility }
  ): Promise<Playlist> {
    await this.getPlaylist(id, ownerId);
    return this.repo.update(id, ownerId, data);
  }

  async deletePlaylist(id: string, ownerId: string): Promise<Playlist> {
    await this.getPlaylist(id, ownerId);
    return this.repo.delete(id, ownerId);
  }

  async addTrackToPlaylist(playlistId: string, ownerId: string, trackId: string): Promise<void> {
    await this.getPlaylist(playlistId, ownerId);
    await this.repo.addTrack(playlistId, trackId);
  }

  async removeTrackFromPlaylist(playlistId: string, ownerId: string, trackId: string): Promise<void> {
    await this.getPlaylist(playlistId, ownerId);
    await this.repo.removeTrack(playlistId, trackId);
  }

  async reorderPlaylistTracks(
    playlistId: string,
    ownerId: string,
    trackOrder: { trackId: string; position: number }[]
  ): Promise<void> {
    await this.getPlaylist(playlistId, ownerId);
    await this.repo.reorderTracks(playlistId, trackOrder);
  }
}

export const playlistService = new PlaylistService();
