# Crop Management Feature Guide

## 🎉 What's New

Your GrapeMaster app now has complete crop management with image capture/upload!

## ✨ Features Added

### 1. **Crop Model** (`lib/src/models/crop_model.dart`)
- Structured data model for crops
- Fields: name, variety, area, status, images, timestamps
- Firestore integration

### 2. **Crop Service** (`lib/src/services/crop_service.dart`)
- Add crops to Firestore
- Upload images to Firebase Storage
- Retrieve crops for current user
- Update and delete crops
- Full CRUD operations with error handling

### 3. **Add Crop Screen** (Enhanced)
- Modern card-based UI
- Form validation
- **📸 Camera capture** - Take photos directly
- **🖼️ Gallery picker** - Select multiple images
- Image preview with remove option
- Upload progress indicators
- Success/error feedback

### 4. **Crops List Screen** (`lib/src/screens/crops_list_screen.dart`)
- Beautiful grid/list view of all your crops
- Real-time updates via Firestore streams
- Status indicators (Healthy/Diseased/Unknown)
- Image thumbnails
- Empty state with add prompt
- Tap to view details

### 5. **Crop Detail Screen**
- Full-screen image gallery
- All crop information displayed
- Edit and delete options
- Multiple images grid view

## 📱 How to Use

### Adding a Crop:

1. **Open the app** → Go to "Your crops" tab (first tab with 🌱 icon)
2. **Tap the + button** (floating action button or top-right)
3. **Fill in the form:**
   - Crop Name (required) - e.g., "Grapes"
   - Variety (optional) - e.g., "Thompson Seedless"
   - Area in acres (required) - e.g., "2.5"
4. **Add Images:**
   - Tap "Add Images" button
   - Choose "Take Photo" 📸 or "Choose from Gallery" 🖼️
   - Add multiple images (you can add more after taking/selecting)
   - Remove unwanted images by tapping the ❌ on the image
5. **Tap "Save Crop"** ✅
6. Wait for upload (you'll see progress messages)
7. Done! Your crop is saved with all images

### Viewing Crops:

- **List View**: All crops appear in "Your crops" tab
- **Tap any crop card** to see full details
- **Swipe through images** in detail view
- **See crop status** (color-coded badges)

### Editing/Deleting:

- Open crop detail screen
- Tap **Edit** icon (✏️) to modify (coming soon)
- Tap **Delete** icon (🗑️) to remove
- Confirm deletion in dialog

## 🔧 Technical Details

### Packages Added:
- `image_picker: ^1.1.2` - Camera and gallery access
- `permission_handler: ^11.3.1` - Runtime permissions

### Permissions (Android):
- ✅ Camera access
- ✅ Read/Write storage (for older Android)
- ✅ Read media images (Android 13+)

### Firebase Setup Required:
1. **Authentication**: Email/Password enabled ✅
2. **Firestore**: Database created
3. **Storage**: Firebase Storage bucket enabled
   - Go to Firebase Console → Storage → Get Started
   - Use test mode rules for now:
   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

### Firestore Security Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /crops/{cropId} {
      // Allow read if authenticated
      allow read: if request.auth != null;
      
      // Allow create if authenticated and farmerId matches user
      allow create: if request.auth != null && 
                    request.resource.data.farmerId == request.auth.uid;
      
      // Allow update/delete if you own the crop
      allow update, delete: if request.auth != null && 
                            resource.data.farmerId == request.auth.uid;
    }
  }
}
```

## 📊 Database Structure

### Crops Collection:
```
crops/
  {cropId}/
    - farmerId: string (user UID)
    - name: string
    - variety: string
    - area: number (acres)
    - status: string ('healthy', 'diseased', 'unknown')
    - imageUrls: array of strings
    - createdAt: timestamp
    - updatedAt: timestamp
```

### Storage Structure:
```
crops/
  {userId}/
    {cropId}/
      {timestamp}.jpg
      {timestamp}.jpg
      ...
```

## 🎨 UI Features

- **Modern Cards**: Clean, Plantix-inspired design
- **Image Thumbnails**: Quick preview in list
- **Status Badges**: Color-coded health indicators
  - 🟢 Green = Healthy
  - 🔴 Red = Diseased
  - ⚪ Grey = Unknown
- **Empty States**: Helpful prompts when no data
- **Loading States**: Progress indicators during uploads
- **Error Handling**: Clear error messages

## 🚀 Future Enhancements (Coming Soon)

- [ ] Edit crop details
- [ ] AI disease detection from images
- [ ] Crop health timeline
- [ ] Weather integration per crop
- [ ] Harvest predictions
- [ ] Crop recommendations
- [ ] Offline support
- [ ] Share crops with community

## 🐛 Troubleshooting

### Camera not working?
- Check permissions in phone Settings → Apps → GrapeMaster → Permissions
- Enable Camera and Storage permissions

### Images not uploading?
- Check internet connection
- Verify Firebase Storage is enabled in console
- Check storage rules allow authenticated writes

### Can't see crops?
- Make sure you're signed in
- Check Firestore rules allow reads
- Verify crops collection exists in Firestore

## 📝 Notes

- **Image Quality**: Automatically compressed to 80% quality, max 1920x1080
- **Multiple Images**: No limit on number of images per crop
- **Real-time Updates**: List updates automatically when crops are added/modified
- **User Isolation**: Users only see their own crops (filtered by farmerId)

---

**Built with ❤️ for GrapeMaster**
