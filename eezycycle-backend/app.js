const express = require('express');
const cors = require('cors');
const { notFound, errorMiddleware } = require('./utils/error');
const healthRoutes = require('./routes/health_routes');
const authRoutes = require('./routes/auth_routes');
const meRoutes = require('./routes/me_routes');
const onboardingRoutes = require('./routes/onboarding_routes');
const cycleRoutes = require('./routes/cycle_routes');
const dailyLogRoutes = require('./routes/daily_log_routes');
const partnerRoutes = require('./routes/partner_routes');
const secretRoutes = require('./routes/secret_routes');
const postRoutes = require('./routes/post_routes');
const commentRoutes = require('./routes/comment_routes');
const articleRoutes = require('./routes/article_routes');

const app = express();

app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use('/uploads', express.static(require('path').join(__dirname, 'uploads')));

app.use('/api', healthRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/me', meRoutes);
app.use('/api/onboarding', onboardingRoutes);
app.use('/api/cycle', cycleRoutes);
app.use('/api/logs', dailyLogRoutes);
app.use('/api/partner', partnerRoutes);
app.use('/api/secret', secretRoutes);
app.use('/api/posts', postRoutes);
app.use('/api/comments', commentRoutes);
app.use('/api/articles', articleRoutes);

app.use(notFound);
app.use(errorMiddleware);

module.exports = app;
