import nodemailer from 'nodemailer';
import { mailConfig } from '../config/mail';
import { logger } from '../config/logger';

export class MailService {
  private transporter: nodemailer.Transporter;

  constructor() {
    this.transporter = nodemailer.createTransport({
      host: mailConfig.host,
      port: mailConfig.port,
      auth:
        mailConfig.user && mailConfig.pass
          ? {
              user: mailConfig.user,
              pass: mailConfig.pass,
            }
          : undefined,
    });
  }

  async sendVerificationEmail(email: string, token: string): Promise<void> {
    const verificationUrl = `${process.env.APP_URL || 'http://localhost:5000'}/api/v1/auth/verify-email?token=${token}`;
    const html = `
      <div style="font-family: Arial, sans-serif; padding: 20px;">
        <h2>Verify your email</h2>
        <p>Thank you for registering for Cloud Music Storage. Click the link below to verify your email address:</p>
        <a href="${verificationUrl}" style="background-color: #6366f1; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Verify Email</a>
      </div>
    `;

    await this.sendMail(email, 'Verify your Cloud Music Storage Email', html);
  }

  async sendPasswordResetEmail(email: string, token: string): Promise<void> {
    const resetUrl = `${process.env.APP_URL || 'http://localhost:5000'}/reset-password?token=${token}`;
    const html = `
      <div style="font-family: Arial, sans-serif; padding: 20px;">
        <h2>Reset Password</h2>
        <p>You requested a password reset. Click the link below to reset your password:</p>
        <a href="${resetUrl}" style="background-color: #ef4444; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Reset Password</a>
      </div>
    `;

    await this.sendMail(email, 'Password Reset Request', html);
  }

  private async sendMail(to: string, subject: string, html: string): Promise<void> {
    try {
      await this.transporter.sendMail({
        from: mailConfig.from,
        to,
        subject,
        html,
      });
      logger.info({ to, subject }, 'Email sent successfully');
    } catch (error) {
      logger.error({ error, to, subject }, 'Failed to send email');
    }
  }
}

export const mailService = new MailService();
