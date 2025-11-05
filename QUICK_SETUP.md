# Quick Firebase Setup Checklist

## ⚠️ IMPORTANT: Do this NOW before testing

### 1. Firebase Storage (REQUIRED for images)
1. Go to: https://console.firebase.google.com/project/grapemaster-cf8ce/storage
2. Click **"Get Started"**
3. Choose **"Start in test mode"**
4. Click **"Next"** → **"Done"**

### 2. Verify Firestore Rules
1. Go to: https://console.firebase.google.com/project/grapemaster-cf8ce/firestore
2. Click **"Rules"** tab
3. Make sure it says:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
4. Click **"Publish"**

### 3. Check Authentication
- Go to: https://console.firebase.google.com/project/grapemaster-cf8ce/authentication
- Make sure **Email/Password** is enabled

## 🧪 Testing Steps

1. **Build and run the app:**
   ```powershell
   flutter run -d 10BE3J1DC500081
   ```

2. **Sign in to your account**

3. **Go to "Your crops" tab** (first tab)

4. **Tap + button**

5. **Fill the form and add image:**
   - Tap "Add Images"
   - Choose Camera or Gallery
   - App should ask for permission ✅
   - Grant permission
   - Select/capture image

6. **Save the crop**

7. **Check terminal logs for:**
   ```
   🔵 Requesting camera permission...
   ✅ Camera permission granted
   🔵 Opening camera...
   ✅ Photo captured
   🔵 Starting crop submission...
   🔵 Adding crop to Firestore...
   ✅ Crop added successfully with ID: xxx
   🔵 Uploading 1 image(s)...
   🔵 Uploading image for crop xxx...
   ✅ Image uploaded successfully
   🔵 Getting crops for user: xxx
   ✅ Received 1 crop(s) from Firestore
   ✅ Displaying 1 crops
   ```

## 🐛 If crops still not showing:

1. **Check if you're signed in:**
   - Go to "You" tab
   - Should show your name/email
   - If not, sign in first

2. **Check terminal for errors:**
   - Look for ❌ marks
   - Common issues:
     - "No user logged in" → Sign in first
     - "Permission denied" → Check Firebase rules
     - "Storage not enabled" → Enable Firebase Storage

3. **Verify in Firebase Console:**
   - Go to Firestore → Data tab
   - Look for "crops" collection
   - Should see your added crop
   - Go to Storage → Files
   - Should see uploaded images

4. **Force refresh:**
   - Close and reopen the app
   - Or tap retry button if shown

## 📱 Permission Issues?

If permissions are not asking:

1. **Uninstall the app completely** from phone
2. **Reinstall:**
   ```powershell
   flutter run -d 10BE3J1DC500081
   ```
3. Try again - it should ask for permissions on first use

Or manually enable in phone:
- Settings → Apps → GrapeMaster → Permissions
- Enable Camera and Photos/Storage
