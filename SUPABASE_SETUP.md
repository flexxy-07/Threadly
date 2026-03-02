# 🚀 Supabase Setup Guide

This guide will help you set up Supabase for your Threadly app with email/password authentication.

---

## 📋 Prerequisites

- A Supabase account (free tier is fine)
- Your app is now using **email/password authentication** (Google Sign-In has been removed)

---

## 🔧 Step 1: Create a Supabase Project

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Click **"New Project"**
3. Fill in:
   - **Name**: `Threadly` (or any name you prefer)
   - **Database Password**: Create a strong password (save it somewhere!)
   - **Region**: Choose the closest to your users
4. Click **"Create new project"**
5. Wait for the project to be set up (takes ~2 minutes)

---

## 🔑 Step 2: Get Your Supabase Credentials

1. Once your project is ready, go to **Settings** (⚙️ icon in sidebar)
2. Click on **API** in the settings menu
3. You'll see two important values:
   - **Project URL**: Looks like `https://xxxxx.supabase.co`
   - **Anon/Public Key**: A long string starting with `eyJ...`

4. Copy these values and update your `.env` file:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

⚠️ **IMPORTANT**: Never commit your `.env` file to Git!

---

## 📧 Step 3: Configure Email Authentication

1. In your Supabase Dashboard, go to **Authentication** → **Providers**
2. Make sure **Email** is enabled (it should be by default)
3. **Optional**: Configure email templates:
   - Go to **Authentication** → **Email Templates**
   - Customize the confirmation email, password reset email, etc.

### Email Confirmation Settings

By default, Supabase requires users to confirm their email. You have two options:

#### Option A: Disable Email Confirmation (for development)
1. Go to **Authentication** → **Providers** → **Email**
2. Toggle **OFF** "Confirm email"
3. Click **Save**

✅ **Best for**: Quick development and testing

#### Option B: Enable Email Confirmation (for production)
1. Keep "Confirm email" enabled
2. Users will receive a confirmation email after signing up
3. They must click the link before they can sign in

✅ **Best for**: Production apps with better security

---

## 🗄️ Step 4: Create the Users Table

Your app needs a `users` table to store user profiles. Run this SQL in Supabase:

1. Go to **SQL Editor** in the sidebar
2. Click **"New query"**
3. Paste this SQL:

```sql
-- Create users table
CREATE TABLE IF NOT EXISTS users (
  uid UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  profile_pic TEXT DEFAULT 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
  banner TEXT DEFAULT 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809',
  is_authenticated BOOLEAN DEFAULT TRUE,
  karma INTEGER DEFAULT 0,
  awards TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read all profiles
CREATE POLICY "Users can view all profiles"
  ON users FOR SELECT
  USING (true);

-- Policy: Users can insert their own profile
CREATE POLICY "Users can insert their own profile"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = uid);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update their own profile"
  ON users FOR UPDATE
  USING (auth.uid() = uid);

-- Create an index for faster queries
CREATE INDEX IF NOT EXISTS users_email_idx ON users(email);
```

4. Click **"Run"** (or press Ctrl+Enter)
5. You should see: "Success. No rows returned"

---

## 🪣 Step 5: Set Up Storage (Optional)

If your app uses file uploads (profile pictures, post images, etc.):

1. Go to **Storage** in the sidebar
2. Click **"Create a new bucket"**
3. Create these buckets:
   - **Name**: `community-images`
   - **Public**: ✅ Check this box
   - Click **"Create bucket"**

4. Repeat for other buckets you need (e.g., `profile-images`, `post-images`)

### Storage Policies

For each bucket, set up policies:

1. Click on the bucket name
2. Go to **Policies** tab
3. Click **"Add policy"** and select **"For full customization"**
4. Add these policies:

**Allow authenticated users to upload:**
```sql
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'community-images');
```

**Allow public to view:**
```sql
CREATE POLICY "Public can view"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'community-images');
```

---

## ✅ Step 6: Test Your Setup

1. Make sure your `.env` file has the correct values
2. Run your app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
3. Try signing up with a test email:
   - Email: `test@example.com`
   - Password: `test123` (or any password 6+ characters)
   - Name: `Test User`

4. Check your Supabase Dashboard:
   - Go to **Authentication** → **Users**
   - You should see your test user
   - Go to **Table Editor** → **users**
   - You should see the user profile

---

## 🐛 Troubleshooting

### "User not found" error
- The user was created in `auth.users` but not in your `users` table
- Check if the SQL script in Step 4 ran successfully
- Try signing up again with a new email

### "Invalid API key" error
- Double-check your `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `.env`
- Make sure there are no extra spaces or quotes
- Restart your app after changing `.env`

### Email confirmation required but not receiving emails
- Check your spam folder
- In development, disable email confirmation (see Step 3)
- Or check Supabase logs: **Logs** → **Auth Logs**

### "Row Level Security policy violation"
- The SQL policies in Step 4 might not have been created
- Go to **SQL Editor** and re-run the policy creation commands

---

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)

---

## 🎉 You're All Set!

Your app is now using Supabase for:
- ✅ Email/Password Authentication
- ✅ User Profile Storage
- ✅ File Storage (if configured)

No more OAuth complexity! 🚀
