const config = require('../config/env');

class StorageService {
  /**
   * Upload an avatar buffer to Oracle Cloud Object Storage via Pre-Authenticated Request (PAR) URL
   * @param {string} userId
   * @param {Buffer} fileBuffer
   * @param {string} mimeType
   * @param {string} originalName
   * @returns {Promise<string>} The uploaded object URL
   */
  async uploadAvatar(userId, fileBuffer, mimeType = 'image/jpeg', originalName = 'avatar.jpg') {
    const parUrl = process.env.OCI_PAR_URL || (config.oci && config.oci.parUrl);
    if (!parUrl || !parUrl.trim()) {
      throw new Error('OCI_PAR_URL is not configured. Please add OCI_PAR_URL in backend/.env');
    }

    const extMatch = originalName.match(/\.([a-zA-Z0-9]+)$/);
    const ext = extMatch ? extMatch[1].toLowerCase() : (mimeType.includes('png') ? 'png' : 'jpg');
    // Use fixed object name per user so new uploads overwrite the existing file in the bucket
    const objectName = `avatars/${userId}.${ext}`;

    // Normalize base PAR URL (remove trailing slashes)
    const baseUrl = parUrl.trim().replace(/\/+$/, '');
    const uploadUrl = `${baseUrl}/${objectName}`;

    const res = await fetch(uploadUrl, {
      method: 'PUT',
      headers: {
        'Content-Type': mimeType,
      },
      body: fileBuffer,
    });

    if (!res.ok) {
      const errText = await res.text().catch(() => '');
      throw new Error(`Failed to upload to Oracle Object Storage (${res.status}): ${errText || res.statusText}`);
    }

    // Return with cache-buster query param so browsers and Flutter immediately load the fresh image
    return `${uploadUrl}?v=${Date.now()}`;
  }

  /**
   * Upload a food item image buffer to Oracle Cloud Object Storage via Pre-Authenticated Request (PAR) URL
   * @param {Buffer} fileBuffer
   * @param {string} [mimeType='image/jpeg']
   * @param {string} [originalName='item.jpg']
   * @returns {Promise<string|null>} The uploaded public PAR URL or null if OCI is not configured
   */
  async uploadItemImage(fileBuffer, mimeType = 'image/jpeg', originalName = 'item.jpg') {
    const parUrl = process.env.OCI_PAR_URL || (config.oci && config.oci.parUrl);
    if (!parUrl || !parUrl.trim()) {
      return null;
    }

    const extMatch = (originalName || '').match(/\.([a-zA-Z0-9]+)$/);
    const ext = extMatch ? extMatch[1].toLowerCase() : (mimeType && mimeType.includes('png') ? 'png' : 'jpg');
    const objectName = `items/${Date.now()}_${Math.random().toString(36).substring(2, 9)}.${ext}`;

    const baseUrl = parUrl.trim().replace(/\/+$/, '');
    const uploadUrl = `${baseUrl}/${objectName}`;

    const res = await fetch(uploadUrl, {
      method: 'PUT',
      headers: {
        'Content-Type': mimeType || 'image/jpeg',
      },
      body: fileBuffer,
    });

    if (!res.ok) {
      const errText = await res.text().catch(() => '');
      throw new Error(`Failed to upload item to Oracle Object Storage (${res.status}): ${errText || res.statusText}`);
    }

    return uploadUrl;
  }
}

module.exports = new StorageService();
