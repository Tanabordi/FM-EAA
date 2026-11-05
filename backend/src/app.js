const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const fridgeRoutes = require('./routes/fridgeRoutes');
const itemRoutes = require('./routes/itemRoutes');
const historyRoutes = require('./routes/historyRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const inviteRoutes = require('./routes/inviteRoutes');
const syncRoutes = require('./routes/syncRoutes');
const aiRoutes = require('./routes/aiRoutes');

const errorHandler = require('./middleware/errorHandler');

const app = express();

// Middlewares
app.use(cors());
app.use((req, res, next) => {
  console.log(`[HTTP] ${req.method} ${req.originalUrl}`);
  next();
});
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Root Endpoint
app.get('/', (req, res) => {
  res.status(200).json({
    name: 'FM-EAA Backend API',
    status: 'running',
    version: '1.0.1',
    deployCheck: 'auto-deploy-active',
    message: 'Backend API is running. Access the Flutter frontend at http://localhost:8080',
    health: '/health',
  });
});

// Health Check Endpoint (Required 200 OK)
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    version: '1.0.1',
    deployCheck: 'auto-deploy-active',
    timestamp: new Date().toISOString(),
  });
});

// Mount API Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/fridges', fridgeRoutes);
app.use('/api/fridges/:id/items', itemRoutes);
app.use('/api/items', itemRoutes);
app.use('/api/fridges/:id/history', historyRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/invites', inviteRoutes);
app.use('/api/sync', syncRoutes);
app.use('/api/ai', aiRoutes);

// Compatibility fallback for clients with duplicate /api baseUrl
app.use('/api/api/fridges', fridgeRoutes);
app.use('/api/api/invites', inviteRoutes);
app.use('/api/api/notifications', notificationRoutes);


// Error Handling Middleware
app.use(errorHandler);

module.exports = app;

