import { PrismaClient, Role, Visibility } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed...');

  // 1. Create Admin User
  const adminPasswordHash = await bcrypt.hash('AdminSecurePassword123!', 10);
  const admin = await prisma.user.upsert({
    where: { email: 'admin@cloudmusic.app' },
    update: {},
    create: {
      email: 'admin@cloudmusic.app',
      passwordHash: adminPasswordHash,
      displayName: 'System Admin',
      role: Role.ADMIN,
      emailVerified: true,
      bio: 'Cloud Music Storage Platform Administrator',
      settings: {
        create: {
          emailNotifications: true,
          pushNotifications: true,
          autoPlayNext: true,
          audioQuality: 'high',
          theme: 'dark',
        },
      },
    },
  });
  console.log(`✅ Admin created: ${admin.email}`);

  // 2. Create Demo Artist User
  const artistPasswordHash = await bcrypt.hash('ArtistSecurePassword123!', 10);
  const artist = await prisma.user.upsert({
    where: { email: 'artist@cloudmusic.app' },
    update: {},
    create: {
      email: 'artist@cloudmusic.app',
      passwordHash: artistPasswordHash,
      displayName: 'Aura Soundscape',
      role: Role.ARTIST,
      emailVerified: true,
      bio: 'Ambient electronic music producer.',
      settings: {
        create: {},
      },
    },
  });
  console.log(`✅ Artist created: ${artist.email}`);

  // 3. Create Demo Standard User
  const userPasswordHash = await bcrypt.hash('UserSecurePassword123!', 10);
  const user = await prisma.user.upsert({
    where: { email: 'user@cloudmusic.app' },
    update: {},
    create: {
      email: 'user@cloudmusic.app',
      passwordHash: userPasswordHash,
      displayName: 'Demo Listener',
      role: Role.USER,
      emailVerified: true,
      bio: 'Music enthusiast and collector.',
      settings: {
        create: {},
      },
    },
  });
  console.log(`✅ Standard user created: ${user.email}`);

  // 4. Create Root Folders for User
  const rootFolder = await prisma.folder.create({
    data: {
      ownerId: user.id,
      name: 'My Favorites & Demos',
    },
  });

  const subFolder = await prisma.folder.create({
    data: {
      ownerId: user.id,
      parentId: rootFolder.id,
      name: 'Unreleased Instrumental Tracks',
    },
  });
  console.log(`✅ Folders created: ${rootFolder.name} -> ${subFolder.name}`);

  // 5. Create Sample Tracks
  const track1 = await prisma.track.create({
    data: {
      ownerId: artist.id,
      title: 'Midnight Echoes',
      artist: 'Aura Soundscape',
      album: 'Nocturnal Waves',
      genre: 'Ambient',
      durationMs: 245000,
      fileKey: `tracks/${artist.id}/midnight_echoes.mp3`,
      fileSizeBytes: BigInt(8745120),
      format: 'mp3',
      visibility: Visibility.PUBLIC,
      ownershipAttestedAt: new Date(),
      playCount: 142,
      likeCount: 28,
    },
  });

  const track2 = await prisma.track.create({
    data: {
      ownerId: user.id,
      folderId: subFolder.id,
      title: 'Starlight Breeze',
      artist: 'Demo Listener',
      album: 'Personal Recordings',
      genre: 'Lo-Fi',
      durationMs: 182000,
      fileKey: `tracks/${user.id}/starlight_breeze.flac`,
      fileSizeBytes: BigInt(18940000),
      format: 'flac',
      visibility: Visibility.PRIVATE,
      playCount: 15,
      likeCount: 2,
    },
  });
  console.log(`✅ Sample tracks created: ${track1.title}, ${track2.title}`);

  // 6. Create Demo Playlist
  const playlist = await prisma.playlist.create({
    data: {
      ownerId: user.id,
      name: 'Chill Evening Chillout',
      description: 'Relaxing tunes for late night coding sessions',
      visibility: Visibility.PUBLIC,
      tracks: {
        create: [
          { trackId: track1.id, position: 0 },
          { trackId: track2.id, position: 1 },
        ],
      },
    },
  });
  console.log(`✅ Playlist created: ${playlist.name}`);

  console.log('🚀 Database seeding completed successfully.');
}

main()
  .catch((e) => {
    console.error('❌ Seeding error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
