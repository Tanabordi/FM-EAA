const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const fridgeRoutes = require('./routes/fridgeRoutes');
const itemRoutes = require('./routes/itemRoutes');
const historyRoutes = require('./routes/historyRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const syncRoutes = require('./routes/syncRoutes');
const aiRoutes = require('./routes/aiRoutes');

const errorHandler = require('./middleware/errorHandler');

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health Check Endpoint (Required 200 OK)
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Mount API Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/fridges', fridgeRoutes);
app.use('/api/fridges/:id/items', itemRoutes);
app.use('/api/items', itemRoutes);
app.use('/api/fridges/:id/history', historyRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/sync', syncRoutes);
app.use('/api/ai', aiRoutes);

// Error Handling Middleware
app.use(errorHandler);

module.exports = app;

