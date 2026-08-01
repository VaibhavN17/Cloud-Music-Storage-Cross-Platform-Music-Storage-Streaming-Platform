import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import jwt from 'jsonwebtoken';
import { User, Role } from '@prisma/client';
import { env } from '../config/env';
import { authRepository, AuthRepository } from '../repositories/auth.repository';
import { mailService } from './mail.service';
import { ApiError } from '../utils/ApiError';
import { JwtPayload } from '../interfaces/auth.interface';

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: string;
}

export class AuthService {
  constructor(private repo: AuthRepository = authRepository) {}

  private hashToken(token: string): string {
    return crypto.createHash('sha256').update(token).digest('hex');
  }

  private generateTokens(user: User): AuthTokens {
    const payload: JwtPayload = {
      userId: user.id,
      email: user.email,
      role: user.role,
    };

    const accessToken = jwt.sign(payload, env.JWT_ACCESS_SECRET, {
      expiresIn: env.JWT_ACCESS_EXPIRES_IN as jwt.SignOptions['expiresIn'],
    });

    const refreshToken = crypto.randomBytes(40).toString('hex');
    return {
      accessToken,
      refreshToken,
      expiresIn: env.JWT_ACCESS_EXPIRES_IN,
    };
  }

  async signup(email: string, passwordHashRaw: string, displayName: string): Promise<{ user: Partial<User>; tokens: AuthTokens }> {
    const existing = await this.repo.findUserByEmail(email);
    if (existing) {
      throw ApiError.badRequest('User with this email already exists');
    }

    const passwordHash = await bcrypt.hash(passwordHashRaw, 10);
    const user = await this.repo.createUser({
      email,
      passwordHash,
      displayName,
      role: Role.USER,
      settings: {
        create: {},
      },
    });

    const tokens = this.generateTokens(user);
    const hashedRefresh = this.hashToken(tokens.refreshToken);
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days

    await this.repo.saveRefreshToken(user.id, hashedRefresh, expiresAt);

    // Omit sensitive data
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { passwordHash: _, twoFactorSecret, ...userPublic } = user;

    return { user: userPublic, tokens };
  }

  async login(email: string, passwordRaw: string): Promise<{ user: Partial<User>; tokens: AuthTokens }> {
    const user = await this.repo.findUserByEmail(email);
    if (!user || !user.passwordHash) {
      throw ApiError.badRequest('Invalid email or password');
    }

    if (user.suspended) {
      throw ApiError.forbidden('Account is suspended. Please contact support.');
    }

    const isMatch = await bcrypt.compare(passwordRaw, user.passwordHash);
    if (!isMatch) {
      throw ApiError.badRequest('Invalid email or password');
    }

    const tokens = this.generateTokens(user);
    const hashedRefresh = this.hashToken(tokens.refreshToken);
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

    await this.repo.saveRefreshToken(user.id, hashedRefresh, expiresAt);

    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { passwordHash: _, twoFactorSecret, ...userPublic } = user;

    return { user: userPublic, tokens };
  }

  async refreshToken(refreshTokenRaw: string): Promise<AuthTokens> {
    const hashedRefresh = this.hashToken(refreshTokenRaw);
    const savedToken = await this.repo.findRefreshToken(hashedRefresh);

    if (!savedToken || savedToken.revoked || new Date() > savedToken.expiresAt) {
      throw ApiError.unauthorized('Invalid or expired refresh token');
    }

    // Revoke current refresh token (Rotation pattern)
    await this.repo.revokeRefreshToken(savedToken.id);

    const user = await this.repo.findUserById(savedToken.userId);
    if (!user || user.suspended) {
      throw ApiError.unauthorized('User account disabled or not found');
    }

    // Issue new pair
    const tokens = this.generateTokens(user);
    const newHashedRefresh = this.hashToken(tokens.refreshToken);
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

    await this.repo.saveRefreshToken(user.id, newHashedRefresh, expiresAt);

    return tokens;
  }

  async logout(refreshTokenRaw: string): Promise<void> {
    const hashedRefresh = this.hashToken(refreshTokenRaw);
    const savedToken = await this.repo.findRefreshToken(hashedRefresh);
    if (savedToken) {
      await this.repo.revokeRefreshToken(savedToken.id);
    }
  }

  async logoutAll(userId: string): Promise<void> {
    await this.repo.revokeAllUserRefreshTokens(userId);
  }

  async googleOAuth(idToken: string): Promise<{ user: Partial<User>; tokens: AuthTokens }> {
    const mockEmail = `google_user_${idToken.substring(0, 8)}@gmail.com`;
    let user = await this.repo.findUserByEmail(mockEmail);

    if (!user) {
      user = await this.repo.createUser({
        email: mockEmail,
        displayName: 'Google User',
        emailVerified: true,
        googleId: `google_${idToken.substring(0, 10)}`,
        settings: { create: {} },
      });
    }

    const tokens = this.generateTokens(user);
    const hashedRefresh = this.hashToken(tokens.refreshToken);
    await this.repo.saveRefreshToken(user.id, hashedRefresh, new Date(Date.now() + 30 * 24 * 3600 * 1000));

    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { passwordHash, twoFactorSecret, ...userPublic } = user;
    return { user: userPublic, tokens };
  }

  async appleOAuth(idToken: string): Promise<{ user: Partial<User>; tokens: AuthTokens }> {
    const mockEmail = `apple_user_${idToken.substring(0, 8)}@privaterelay.appleid.com`;
    let user = await this.repo.findUserByEmail(mockEmail);

    if (!user) {
      user = await this.repo.createUser({
        email: mockEmail,
        displayName: 'Apple User',
        emailVerified: true,
        appleId: `apple_${idToken.substring(0, 10)}`,
        settings: { create: {} },
      });
    }

    const tokens = this.generateTokens(user);
    const hashedRefresh = this.hashToken(tokens.refreshToken);
    await this.repo.saveRefreshToken(user.id, hashedRefresh, new Date(Date.now() + 30 * 24 * 3600 * 1000));

    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { passwordHash, twoFactorSecret, ...userPublic } = user;
    return { user: userPublic, tokens };
  }

  async forgotPassword(email: string): Promise<void> {
    const user = await this.repo.findUserByEmail(email);
    if (user) {
      const resetToken = crypto.randomBytes(32).toString('hex');
      // In production, store resetToken in Redis with 1 hour TTL
      await mailService.sendPasswordResetEmail(email, resetToken);
    }
  }

  async resetPassword(token: string, newPasswordRaw: string): Promise<void> {
    // In production, verify resetToken from Redis and extract userId
    if (!token) {
      throw ApiError.badRequest('Invalid or expired password reset token');
    }
    // Hash new password and update user passwordHash
    const passwordHash = await bcrypt.hash(newPasswordRaw, 10);
    // Dummy validation check
    if (passwordHash) {
      return;
    }
  }
}

export const authService = new AuthService();
