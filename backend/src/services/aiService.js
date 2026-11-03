// TODO(service ai): Implement Gemini Vision OCR to extract food name and expiry date from label image
class AiService {
  async scanLabel(imageBuffer, mimeType) {
    // TODO: Send image to Google Gemini Vision API (Multimodal 1.5/2.0)
    // Prompt Gemini to extract:
    // { "foodName": "...", "expirationDate": "YYYY-MM-DD", "suggestedCategory": "...", "confidence": 0.95 }
    throw new Error('Not implemented');
  }
}

module.exports = new AiService();

