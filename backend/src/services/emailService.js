let Resend;
try {
  Resend = require('resend').Resend;
} catch (_) {}

let nodemailer;
try {
  nodemailer = require('nodemailer');
} catch (_) {}

class EmailService {
  constructor() {
    this.resendClient = null;
    this.transporter = null;
    this._initClients();
  }

  _initClients() {
    const resendKey = process.env.RESEND_API_KEY;
    if (resendKey && Resend) {
      this.resendClient = new Resend(resendKey.trim());
    }

    const user = process.env.EMAIL_USER;
    const pass = process.env.EMAIL_PASS;
    if (user && pass && nodemailer) {
      this.transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: user.trim(),
          pass: pass.replace(/\s+/g, ''),
        },
        connectionTimeout: 5000, // 5 seconds timeout
        greetingTimeout: 5000,
        socketTimeout: 5000,
      });
    }
  }

  /**
   * Send a 6-digit OTP code to user's email for password reset
   * @param {string} toEmail 
   * @param {string} otp 
   */
  async sendPasswordResetOtp(toEmail, otp) {
    if (!this.resendClient && !this.transporter) {
      this._initClients();
    }

    const htmlContent = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #F8F9FA; margin: 0; padding: 24px; }
          .container { max-width: 500px; margin: 0 auto; background: #FFFFFF; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.06); }
          .header { background: linear-gradient(135deg, #2E7D32, #1B5E20); padding: 32px 24px; text-align: center; color: #FFFFFF; }
          .header h1 { margin: 0; font-size: 24px; font-weight: 700; letter-spacing: -0.5px; }
          .content { padding: 32px 24px; text-align: center; color: #333333; }
          .greeting { font-size: 16px; margin-bottom: 16px; color: #555555; }
          .desc { font-size: 14px; line-height: 1.6; color: #666666; margin-bottom: 24px; }
          .otp-box { background: #E8F5E9; border: 2px dashed #4CAF50; border-radius: 12px; padding: 18px 24px; display: inline-block; margin-bottom: 24px; }
          .otp-code { font-size: 36px; font-weight: 800; letter-spacing: 6px; color: #1B5E20; margin: 0; }
          .warning { font-size: 13px; color: #E53935; margin-bottom: 20px; font-weight: 500; }
          .footer { background: #F1F3F4; padding: 20px; text-align: center; font-size: 12px; color: #888888; border-top: 1px solid #E0E0E0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>FM-EAA</h1>
            <p style="margin: 4px 0 0 0; opacity: 0.9; font-size: 14px;">Food Management & Expiry Alert Assistant</p>
          </div>
          <div class="content">
            <div class="greeting">สวัสดีครับ,</div>
            <div class="desc">
              เราได้รับคำขอรีเซ็ตรหัสผ่านสำหรับบัญชี <b>${toEmail}</b> ในแอปพลิเคชัน FM-EAA<br>
              กรุณาใช้รหัส OTP ด้านล่างนี้เพื่อดำเนินการตั้งรหัสผ่านใหม่:
            </div>
            <div class="otp-box">
              <div class="otp-code">${otp}</div>
            </div>
            <div class="warning">
              ⏱️ รหัสยืนยันนี้มีอายุการใช้งาน 10 นาที<br>
              หากคุณไม่ได้ส่งคำขอนี้ สามารถเพิกเฉยต่ออีเมลฉบับนี้ได้ รหัสผ่านของคุณจะไม่มีการเปลี่ยนแปลง
            </div>
          </div>
          <div class="footer">
            อีเมลฉบับนี้ส่งโดยระบบอัตโนมัติ กรุณาอย่าตอบกลับ<br>
            &copy; 2026 FM-EAA Team. All rights reserved.
          </div>
        </div>
      </body>
      </html>
    `;

    // 1. Try Brevo HTTP API (Recommended: sends to ANY email without custom domain, uses HTTPS port 443)
    const brevoKey = process.env.BREVO_API_KEY;
    if (brevoKey) {
      try {
        const senderEmail = process.env.BREVO_SENDER_EMAIL || '4ajanbanat8@gmail.com';
        const senderName = process.env.BREVO_SENDER_NAME || 'FM-EAA Support';
        const resp = await fetch('https://api.brevo.com/v3/smtp/email', {
          method: 'POST',
          headers: {
            'accept': 'application/json',
            'api-key': brevoKey.trim(),
            'content-type': 'application/json',
          },
          body: JSON.stringify({
            sender: { name: senderName, email: senderEmail },
            to: [{ email: toEmail.trim() }],
            subject: `[FM-EAA] รหัสยืนยันการตั้งรหัสผ่านใหม่ (OTP: ${otp})`,
            htmlContent: htmlContent,
          }),
        });

        const resData = await resp.json();
        if (resp.ok && resData.messageId) {
          console.log(`[EmailService] OTP email sent via Brevo to ${toEmail} (MessageId: ${resData.messageId})`);
          return { sent: true, provider: 'brevo', messageId: resData.messageId };
        } else {
          console.error(`[EmailService] Brevo dispatch rejected for ${toEmail}:`, resData.message || resData);
        }
      } catch (err) {
        console.error(`[EmailService] Brevo dispatch failed for ${toEmail}:`, err.message);
      }
    }

    // 2. Try Resend HTTP API (uses HTTPS port 443)
    if (this.resendClient) {
      try {
        const fromEmail = process.env.RESEND_FROM_EMAIL || 'FM-EAA Support <onboarding@resend.dev>';
        const response = await this.resendClient.emails.send({
          from: fromEmail,
          to: toEmail.trim(),
          subject: `[FM-EAA] รหัสยืนยันการตั้งรหัสผ่านใหม่ (OTP: ${otp})`,
          html: htmlContent,
        });

        if (response && response.error) {
          console.error(`[EmailService] Resend dispatch rejected for ${toEmail}:`, response.error.message || response.error);
        } else if (response && response.data?.id) {
          console.log(`[EmailService] OTP email sent via Resend to ${toEmail} (ID: ${response.data.id})`);
          return { sent: true, provider: 'resend', id: response.data.id };
        }
      } catch (err) {
        console.error(`[EmailService] Resend dispatch failed for ${toEmail}:`, err.message);
      }
    }

    // 2. Fallback to Nodemailer SMTP
    if (this.transporter && process.env.EMAIL_USER) {
      try {
        const info = await this.transporter.sendMail({
          from: `"FM-EAA Support" <${process.env.EMAIL_USER.trim()}>`,
          to: toEmail.trim(),
          subject: `[FM-EAA] รหัสยืนยันการตั้งรหัสผ่านใหม่ (OTP: ${otp})`,
          html: htmlContent,
        });
        console.log(`[EmailService] OTP email sent via SMTP to ${toEmail} (MessageId: ${info.messageId})`);
        return { sent: true, provider: 'smtp', messageId: info.messageId };
      } catch (err) {
        console.error(`[EmailService] SMTP dispatch failed for ${toEmail}:`, err.message);
      }
    }

    console.warn(`[EmailService] No active email provider configured. (OTP for ${toEmail} is ${otp})`);
    return { sent: false, reason: 'unconfigured' };
  }
}

module.exports = new EmailService();
