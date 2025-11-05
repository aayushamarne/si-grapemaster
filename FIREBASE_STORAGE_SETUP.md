# Firebase Storage Setup for GrapeMaster

## 📦 Enable Firebase Storage

Follow these steps to enable Firebase Storage for crop images:

### Step 1: Go to Firebase Console
1. Open: https://console.firebase.google.com/
2. Select: **grapemaster-cf8ce**

### Step 2: Navigate to Storage
```
Left Sidebar:
├─ 🏠 Project Overview
├─ 📦 Build
│  ├─ 🔐 Authentication (already enabled ✅)
│  ├─ 🗄️ Firestore Database (already enabled ✅)
│  ├─ 💾 Storage ← Click this!
│  └─ ...
```

### Step 3: Enable Storage
1. Click **"Get Started"** button
2. **Important**: Choose **Test mode** for now
3. Click **"Next"**
4. Select **Storage Location**: Choose the same region as your Firestore
   - Recommended: `us-central1` or your nearest region
5. Click **"Done"**

### Step 4: Configure Security Rules

After enabling, update the Storage rules:

1. In Storage page, click the **"Rules"** tab
2. Replace the rules with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload images
    match /crops/{userId}/{cropId}/{imageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                   request.auth.uid == userId &&
                   request.resource.size < 5 * 1024 * 1024 && // Max 5MB
                   request.resource.contentType.matches('image/.*');
    }
    
    // Fallback rule for other paths
    match /{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

3. Click **"Publish"**

### Explanation of Rules:
- ✅ Only authenticated users can upload/download
- ✅ Users can only upload to their own folder (userId must match)
- ✅ Files must be images (image/jpeg, image/png, etc.)
- ✅ Maximum file size: 5MB
- ✅ Organized by: `/crops/{userId}/{cropId}/{timestamp}.jpg`

### Step 5: Verify Setup

1. Go to **Storage → Files** tab
2. You should see an empty bucket
3. After you upload a crop image in the app, you'll see:
   ```
   crops/
     {your-user-id}/
       {crop-id}/
         1699000000000.jpg
   ```

## 🔒 Production Rules (Use Later)

For production, use stricter rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /crops/{userId}/{cropId}/{imageId} {
      // Read: authenticated users
      allow read: if request.auth != null;
      
      // Write: owner only, image files, max 5MB
      allow write: if request.auth != null && 
                   request.auth.uid == userId &&
                   request.resource.size < 5 * 1024 * 1024 &&
                   request.resource.contentType.matches('image/.*');
      
      // Delete: owner only
      allow delete: if request.auth != null && 
                    request.auth.uid == userId;
    }
    
    // Deny all other paths
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

## 📊 Storage Usage

### Free Tier Limits (Spark Plan):
- **Storage**: 5 GB
- **Downloads**: 1 GB/day
- **Uploads**: 50K/day

### Pricing (Blaze Plan):
- **Storage**: $0.026/GB/month
- **Downloads**: $0.12/GB
- **Uploads**: Free

For a small app, free tier is sufficient!

## 🧪 Testing Storage

After setup, test in your app:

1. **Sign in** to the app
2. Go to **"Your crops"** tab
3. Tap **+ button** → Add Crop
4. Fill form and **add image** (camera or gallery)
5. Tap **"Save Crop"**
6. Check terminal for logs:
   ```
   🔵 Uploading image for crop {cropId}...
   ✅ Image uploaded successfully: https://firebasestorage...
   ✅ Image URL added to crop document
   ```
7. Go to Firebase Console → Storage → Files
8. You should see your uploaded image!

## ❓ Troubleshooting

### Error: "Firebase Storage is not enabled"
- Make sure you clicked "Get Started" in Storage section
- Wait 1-2 minutes for propagation

### Error: "Permission denied"
- Check Storage rules are published
- Make sure you're signed in to the app
- Verify `request.auth != null` in rules

### Error: "Image too large"
- Images are auto-compressed to 80% quality
- Max dimensions: 1920x1080
- If still too large, adjust `maxWidth` in `add_crop_screen.dart`

### Images not appearing in app
- Check internet connection
- Verify image URL in Firestore document
- Check browser console for CORS errors (web only)

## 🔄 Migration from Old Data

If you have crops without images:
1. Old crops will still appear in list
2. They'll show placeholder icon instead of image
3. You can edit them later to add images

---

**Next Step**: Once Storage is enabled, test uploading a crop image! 🎉
