const router = require('express').Router();
const multer = require('multer');
const authenticateToken = require('../middleware/auth');
const { scanLabel, suggestRecipes, getRecipeQuota } = require('../services/aiService');

const ALLOWED_MIME = ['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif'];

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (!ALLOWED_MIME.includes(file.mimetype)) {
      const err = new Error('Invalid file type. Only JPEG, PNG, WebP, and HEIC are supported.');
      err.statusCode = 400;
      return cb(err, false);
    }
    cb(null, true);
  },
});

const handleUpload = (req, res, next) => {
  upload.single('image')(req, res, (err) => {
    if (err instanceof multer.MulterError) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(413).json({ error: 'File size exceeded (Max: 5MB)' });
      }
      return res.status(400).json({ error: err.message });
    }
    if (err) {
      return res.status(err.statusCode || 400).json({ error: err.message });
    }
    next();
  });
};

router.post('/scan-label', authenticateToken, handleUpload, async (req, res, next) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'image is required' });
    const language = req.query.language || req.body?.language || 'en';
    const mode = req.query.mode || req.body?.mode || 'full';
    const result = await scanLabel(req.file.buffer, req.file.mimetype, language, mode);

    let imageUrl = null;
    if (mode !== 'expiry_only') {
      try {
        const storageService = require('../services/storageService');
        imageUrl = await storageService.uploadItemImage(
          req.file.buffer,
          req.file.mimetype,
          req.file.originalname || 'scan.jpg'
        );
      } catch (uploadErr) {
        console.warn('[AI Scan] OCI image upload skipped or failed:', uploadErr.message);
      }
    }

    res.json({
      ...result,
      imageUrl: imageUrl || null,
    });
  } catch (err) {
    next(err);
  }
});

router.get('/recipes/quota', authenticateToken, (req, res) => {
  const userId = req.user?.userId || 'anonymous';
  const quota = getRecipeQuota(userId, req.query.mainIngredient || req.query.ingredient || '');
  res.json(quota);
});

router.post('/recipes', authenticateToken, async (req, res, next) => {
  try {
    const { mainIngredient, category, language, offset } = req.body;
    if (!mainIngredient || typeof mainIngredient !== 'string' || mainIngredient.trim().length === 0) {
      return res.status(400).json({ error: 'mainIngredient is required' });
    }

    const userId = req.user?.userId || 'anonymous';
    const result = await suggestRecipes({
      userId,
      mainIngredient: mainIngredient.trim(),
      category: category || req.query.category,
      language: language || 'en',
      offset: typeof offset === 'number' ? offset : 0,
    });

    res.json(result);
  } catch (err) {
    if (err.statusCode === 429) {
      return res.status(429).json({
        error: err.message,
        usedDailyQuota: err.usedQuota || 3,
        remainingDailyQuota: err.remainingQuota ?? 0,
        maxDailyQuota: 3,
      });
    }
    next(err);
  }
});

module.exports = router;
