# Quiz App Backend - Render Deployment Guide

## Prerequisites

1. A Render account (sign up at https://render.com)
2. MongoDB Atlas account (for cloud MongoDB) at https://www.mongodb.com/cloud/atlas

## Step 1: Set Up MongoDB Atlas (If not already done)

1. Go to https://cloud.mongodb.com/
2. Create a free cluster (M0 tier is free)
3. Create a database user with username and password
4. Whitelist all IP addresses (0.0.0.0/0) for Render to connect
5. Get your connection string - it looks like:
   ```
   mongodb+srv://username:password@cluster.mongodb.net/?retryWrites=true&w=majority
   ```

## Step 2: Deploy to Render

### Option A: Deploy from GitHub (Recommended)

1. Push your code to GitHub repository
2. Go to https://dashboard.render.com/
3. Click "New +" → "Web Service"
4. Connect your GitHub repository
5. Configure the service:

   - **Name**: `quiz-app-backend` (or your preferred name)
   - **Region**: Choose closest to your users
   - **Branch**: `main` or `master`
   - **Root Directory**: `backend`
   - **Runtime**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - **Instance Type**: Free (or paid if needed)

6. Add Environment Variables:

   - Click "Advanced" → "Add Environment Variable"
   - Add `MONGODB_URL` with your MongoDB Atlas connection string
   - Add `MONGODB_DB_NAME` with value `quiz_app`

7. Click "Create Web Service"

### Option B: Manual Deploy

1. Go to https://dashboard.render.com/
2. Click "New +" → "Web Service"
3. Select "Public Git repository"
4. Paste your repository URL
5. Follow the same configuration as Option A above

## Step 3: Get Your Backend URL

After deployment completes (takes 2-3 minutes):

1. Render will provide you a URL like: `https://quiz-app-backend.onrender.com`
2. Test it by visiting: `https://quiz-app-backend.onrender.com/` (should show API running message)
3. Check API docs at: `https://quiz-app-backend.onrender.com/docs`

## Step 4: Update Flutter App

1. Copy your Render URL (e.g., `https://quiz-app-backend.onrender.com`)
2. Open `quiz_app/lib/api_config.dart`
3. Replace the ngrok URL with your Render URL:
   ```dart
   class ApiConfig {
     static const String baseUrl = 'https://quiz-app-backend.onrender.com';
   }
   ```

## Important Notes

### Free Tier Limitations

- Render free tier spins down after 15 minutes of inactivity
- First request after spin-down takes 30-60 seconds (cold start)
- Solution: Use a paid plan ($7/month) for always-on service, or ping your service periodically

### MongoDB Connection

- Make sure MongoDB Atlas is configured to allow connections from anywhere (0.0.0.0/0)
- Or add Render's IP addresses to whitelist (check Render docs for current IPs)

### CORS Configuration

- The backend is already configured to allow all origins (`CORS_ORIGINS = ["*"]`)
- For production, you should restrict this to your specific domains

## Troubleshooting

### Service won't start

- Check logs in Render dashboard
- Verify environment variables are set correctly
- Ensure MongoDB connection string is correct

### Connection timeouts

- Check MongoDB Atlas network access settings
- Verify connection string format

### 502 Bad Gateway

- Usually means service is still starting up
- Wait a minute and try again
- Check Render logs for errors

## Monitoring

- View logs: Render Dashboard → Your Service → Logs
- Check metrics: Render Dashboard → Your Service → Metrics
- Set up health checks and alerts in Render settings

## Cost Optimization

**Free Tier:**

- 750 hours/month free (enough for one always-on service)
- Automatically spins down after inactivity

**Paid Tier ($7/month):**

- Always-on
- No spin-down delays
- Better performance
- Custom domains

## Next Steps

1. Deploy the backend to Render
2. Update `api_config.dart` with Render URL
3. Test your Flutter app with production backend
4. Monitor logs and performance
5. Consider upgrading to paid tier for production use
