// TODO(service auth): Implement user registration with bcrypt hash, login with JWT, Google token verification, and password reset email
class AuthService {
  async register(username, email, password) {
    // TODO: Hash password with bcrypt, save to Oracle users table, return user and JWT token
    throw new Error('Not implemented');
  }

  async login(identifier, password) {
    // TODO: Verify password_hash against username or email, return JWT token
    throw new Error('Not implemented');
  }

  async googleAuth(idToken) {
    // TODO: Verify Google ID token via google-auth-library, link or create user
    throw new Error('Not implemented');
  }

  async sendPasswordResetLink(email) {
    // TODO: Generate reset token, send email with reset link
    throw new Error('Not implemented');
  }

  async resetPassword(token, newPassword) {
    // TODO: Verify reset token, update password_hash
    throw new Error('Not implemented');
  }
}

module.exports = new AuthService();

