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
});
