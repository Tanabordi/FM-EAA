process.env.NODE_ENV = 'test';
const storageService = require('../src/services/storageService');
const emailService = require('../src/services/emailService');
const config = require('../src/config/env');

describe('Storage & Email Services Unit Tests', () => {
  describe('StorageService', () => {
    const originalFetch = global.fetch;
    const originalPar = process.env.OCI_PAR_URL;
    const originalConfigPar = config.oci ? config.oci.parUrl : null;

    afterEach(() => {
      global.fetch = originalFetch;
      process.env.OCI_PAR_URL = originalPar;
      if (config.oci) config.oci.parUrl = originalConfigPar;
    });

    it('uploadAvatar throws if OCI_PAR_URL is missing', async () => {
      delete process.env.OCI_PAR_URL;
      if (config.oci) config.oci.parUrl = '';

      await expect(
        storageService.uploadAvatar('u1', Buffer.from('abc'))
      ).rejects.toThrow('OCI_PAR_URL is not configured');
    });

    it('uploadAvatar uploads successfully via PUT with normalized URL', async () => {
      process.env.OCI_PAR_URL =
        'https://objectstorage.ap-singapore-1.oraclecloud.com/p/test/n/bucket/b/bucket/o/';
      global.fetch = jest.fn().mockResolvedValue({
        ok: true,
        status: 200,
      });

      const url = await storageService.uploadAvatar(
        'u123',
        Buffer.from('fake_image'),
        'image/png',
        'photo.png'
      );
      expect(url).toContain('avatars/u123.png');
      expect(url).toContain('?v=');
      expect(global.fetch).toHaveBeenCalledWith(
        expect.stringContaining('avatars/u123.png'),
        expect.objectContaining({
          method: 'PUT',
          headers: { 'Content-Type': 'image/png' },
        })
      );
    });

    it('uploadAvatar throws on failed OCI response', async () => {
      process.env.OCI_PAR_URL = 'https://oci.com/p/test';
      global.fetch = jest.fn().mockResolvedValue({
        ok: false,
        status: 403,
        statusText: 'Forbidden',
        text: jest.fn().mockResolvedValue('Access Denied to Bucket'),
      });

      await expect(
        storageService.uploadAvatar('u123', Buffer.from('fake_image'))
      ).rejects.toThrow('Failed to upload to Oracle Object Storage (403)');
    });

    it('uploadItemImage returns null if OCI_PAR_URL is missing', async () => {
      delete process.env.OCI_PAR_URL;
      if (config.oci) config.oci.parUrl = '';

      const res = await storageService.uploadItemImage(Buffer.from('fake_image'));
      expect(res).toBeNull();
    });

    it('uploadItemImage uploads food photo successfully via PUT', async () => {
      process.env.OCI_PAR_URL = 'https://oci.com/p/test';
      global.fetch = jest.fn().mockResolvedValue({
        ok: true,
        status: 200,
      });

      const url = await storageService.uploadItemImage(
        Buffer.from('food'),
        'image/jpeg',
        'salmon.jpg'
      );
      expect(url).toContain('items/');
      expect(url).toContain('.jpg');
    });

    it('uploadItemImage throws on failed OCI response', async () => {
      process.env.OCI_PAR_URL = 'https://oci.com/p/test';
      global.fetch = jest.fn().mockResolvedValue({
        ok: false,
        status: 500,
        statusText: 'Internal Error',
        text: jest.fn().mockResolvedValue('OCI Service Unavailable'),
      });

      await expect(
        storageService.uploadItemImage(Buffer.from('food'))
      ).rejects.toThrow('Failed to upload item to Oracle Object Storage (500)');
    });
  });

  describe('EmailService', () => {
    const originalBrevo = process.env.BREVO_API_KEY;
    const originalResend = emailService.resendClient;
    const originalTransporter = emailService.transporter;
    const originalEmailUser = process.env.EMAIL_USER;

    afterEach(() => {
      process.env.BREVO_API_KEY = originalBrevo;
      emailService.resendClient = originalResend;
      emailService.transporter = originalTransporter;
      process.env.EMAIL_USER = originalEmailUser;
    });

    it('sendPasswordResetOtp returns unconfigured when no provider is active', async () => {
      delete process.env.BREVO_API_KEY;
      emailService.resendClient = null;
      emailService.transporter = null;

      const res = await emailService.sendPasswordResetOtp('test@example.com', '123456');
      expect(res.sent).toBe(false);
      expect(res.reason).toBe('unconfigured');
    });

    it('sendPasswordResetOtp handles Resend provider success and failure', async () => {
      delete process.env.BREVO_API_KEY;
      emailService.resendClient = {
        emails: {
          send: jest.fn().mockResolvedValue({
            data: { id: 'resend_msg_123' },
            error: null,
          }),
        },
      };

      const res = await emailService.sendPasswordResetOtp('test@resend.com', '654321');
      expect(res.sent).toBe(true);
      expect(res.provider).toBe('resend');
      expect(res.id).toBe('resend_msg_123');

      // Failure test
      emailService.resendClient.emails.send.mockRejectedValue(
        new Error('Resend network fail')
      );
      const failRes = await emailService.sendPasswordResetOtp('test@resend.com', '654321');
      expect(failRes.sent).toBe(false);
    });

    it('sendPasswordResetOtp handles Nodemailer SMTP provider success', async () => {
      delete process.env.BREVO_API_KEY;
      emailService.resendClient = null;
      process.env.EMAIL_USER = 'support@fmeaa.com';
      emailService.transporter = {
        sendMail: jest.fn().mockResolvedValue({ messageId: 'smtp_msg_456' }),
      };

      const res = await emailService.sendPasswordResetOtp('test@smtp.com', '112233');
      expect(res.sent).toBe(true);
      expect(res.provider).toBe('smtp');
      expect(res.messageId).toBe('smtp_msg_456');
    });
  });

  describe('AuthService OTP & Edge Cases', () => {
    const authService = require('../src/services/authService');

    beforeEach(() => {
      authService.passwordResetStore.clear();
    });

    it('verifyOtp validates required email and otp', () => {
      expect(() => authService.verifyOtp('', '123456')).toThrow('Email and OTP code are required');
      expect(() => authService.verifyOtp('test@example.com', '')).toThrow('Email and OTP code are required');
    });

    it('verifyOtp throws 400 when no reset record exists', () => {
      expect(() => authService.verifyOtp('notfound@example.com', '123456')).toThrow('No password reset requested');
    });

    it('verifyOtp throws 400 when OTP has expired', () => {
      authService.passwordResetStore.set('expired@example.com', {
        otp: '123456',
        expiresAt: Date.now() - 1000,
        attempts: 0,
        verified: false,
      });

      expect(() => authService.verifyOtp('expired@example.com', '123456')).toThrow('expired');
      expect(authService.passwordResetStore.has('expired@example.com')).toBe(false);
    });

    it('verifyOtp throws 429 when max attempts (5) reached', () => {
      authService.passwordResetStore.set('lockout@example.com', {
        otp: '123456',
        expiresAt: Date.now() + 60000,
        attempts: 5,
        verified: false,
      });

      expect(() => authService.verifyOtp('lockout@example.com', '123456')).toThrow('Too many failed attempts');
      expect(authService.passwordResetStore.has('lockout@example.com')).toBe(false);
    });

    it('verifyOtp increments attempt counter on wrong OTP', () => {
      authService.passwordResetStore.set('wrong@example.com', {
        otp: '123456',
        expiresAt: Date.now() + 60000,
        attempts: 0,
        verified: false,
      });

      expect(() => authService.verifyOtp('wrong@example.com', '999999')).toThrow('Invalid verification code');
      expect(authService.passwordResetStore.get('wrong@example.com').attempts).toBe(1);
    });

    it('verifyOtp marks record verified on correct OTP', () => {
      authService.passwordResetStore.set('valid@example.com', {
        otp: '123456',
        expiresAt: Date.now() + 60000,
        attempts: 1,
        verified: false,
      });

      const res = authService.verifyOtp('valid@example.com', '123456');
      expect(res.success).toBe(true);
      expect(authService.passwordResetStore.get('valid@example.com').verified).toBe(true);
    });

    it('resetPassword validates inputs and complex password requirements', async () => {
      await expect(authService.resetPassword('', '123456', 'Pass123!')).rejects.toThrow('required');
      await expect(authService.resetPassword('test@example.com', '', 'Pass123!')).rejects.toThrow('required');
      await expect(authService.resetPassword('test@example.com', '123456', '')).rejects.toThrow('required');

      authService.passwordResetStore.set('user@example.com', {
        otp: '123456',
        expiresAt: Date.now() + 60000,
        attempts: 0,
        verified: false,
      });

      // Wrong OTP
      await expect(authService.resetPassword('user@example.com', '000000', 'NewPass123!')).rejects.toThrow('Invalid verification code');

      // Password too short
      await expect(authService.resetPassword('user@example.com', '123456', 'Short1!')).rejects.toThrow('at least 8 characters');

      // Password too long (> 64)
      await expect(authService.resetPassword('user@example.com', '123456', 'A'.repeat(65) + '1')).rejects.toThrow('must not exceed 64 characters');

      // Password no letters
      await expect(authService.resetPassword('user@example.com', '123456', '1234567890')).rejects.toThrow('contain both letters and numbers');

      // Password no numbers
      await expect(authService.resetPassword('user@example.com', '123456', 'LettersOnlyHere')).rejects.toThrow('contain both letters and numbers');
    });

    it('loginWithGoogle validates missing credentials', async () => {
      await expect(authService.loginWithGoogle({})).rejects.toThrow('Invalid Google payload');
    });
  });
});
