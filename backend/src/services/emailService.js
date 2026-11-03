const nodemailer = require('nodemailer');

class EmailService {
  constructor() {
    this.transporter = null;
    this._initTransporter();
  }

  _initTransporter() {
    const user = process.env.EMAIL_USER;
    const pass = process.env.EMAIL_PASS;

    if (user && pass) {
      this.transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: user.trim(),
          pass: pass.replace(/\s+/g, ''), // Strip spaces from Google App Password
        },
      });
    }
  }

  /**
   * Send a 6-digit OTP code to user's email for password reset
   * @param {string} toEmail 
   * @param {string} otp 
   */
  async sendPasswordResetOtp(toEmail, otp) {
    if (!this.transporter) {
      this._initTransporter();
    }

    if (!this.transporter) {
      console.warn('[EmailService] EMAIL_USER or EMAIL_PASS not configured. Skipping real email send.');
      return { sent: false, reason: 'unconfigured' };
    }

    const mailOptions = {
      from: `"FM-EAA Support" <${process.env.EMAIL_USER.trim()}>`,
      to: toEmail.trim(),
      subject: `[FM-EAA] รหัสยืนยันการตั้งรหัสผ่านใหม่ (OTP: ${otp})`,
      html: `
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
      `,
    };

    try {
      const info = await this.transporter.sendMail(mailOptions);
      console.log(`[EmailService] OTP email successfully sent to ${toEmail} (MessageId: ${info.messageId})`);
      return { sent: true, messageId: info.messageId };
    } catch (err) {
      console.error(`[EmailService] Failed to send email to ${toEmail}:`, err.message);
      return { sent: false, error: err.message };
    }
  }
}

module.exports = new EmailService();
