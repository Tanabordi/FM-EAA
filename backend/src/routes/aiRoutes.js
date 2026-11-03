const express = require('express');
const multer = require('multer');
const router = express.Router();

const upload = multer({
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
});

// TODO(route ai): POST /api/ai/scan-label - Analyze food label photo using Google Gemini Vision API
router.post('/scan-label', upload.single('image'), (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: 'POST /api/ai/scan-label' });
});

module.exports = router;

