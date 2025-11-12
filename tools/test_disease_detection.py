"""
Test script for Disease Detection API
Sends images to the prediction endpoint and displays results
"""

import requests
import json
import os
from pathlib import Path

# API endpoint
API_ENDPOINT = "http://127.0.0.1:10000/predict"

def predict_disease(image_path):
    """
    Send an image to the disease detection API and get prediction results
    
    Args:
        image_path: Path to the image file
        
    Returns:
        dict: Response from the API containing prediction results
    """
    try:
        # Check if file exists
        if not os.path.exists(image_path):
            print(f"❌ Error: File not found - {image_path}")
            return None
        
        # Open and send the image
        with open(image_path, 'rb') as image_file:
            files = {'file': image_file}
            
            print(f"📤 Sending image: {os.path.basename(image_path)}")
            print(f"🔗 Endpoint: {API_ENDPOINT}")
            
            response = requests.post(API_ENDPOINT, files=files)
            
            # Check response status
            if response.status_code == 200:
                result = response.json()
                print("\n✅ Success! Prediction Results:")
                print(f"{'='*60}")
                print(f"Prediction: {result.get('prediction', 'Unknown')}")
                print(f"Confidence: {result.get('confidence', 0):.2%}")
                print(f"{'='*60}\n")
                return result
            else:
                print(f"❌ Error: Server returned status code {response.status_code}")
                print(f"Response: {response.text}")
                return None
                
    except requests.exceptions.ConnectionError:
        print(f"❌ Error: Could not connect to {API_ENDPOINT}")
        print("   Make sure the server is running on port 10000")
        return None
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return None

def test_multiple_images(image_folder):
    """
    Test multiple images from a folder
    
    Args:
        image_folder: Path to folder containing test images
    """
    if not os.path.exists(image_folder):
        print(f"❌ Error: Folder not found - {image_folder}")
        return
    
    # Supported image extensions
    image_extensions = {'.jpg', '.jpeg', '.png', '.bmp', '.gif'}
    
    # Get all image files
    image_files = [
        f for f in os.listdir(image_folder)
        if Path(f).suffix.lower() in image_extensions
    ]
    
    if not image_files:
        print(f"❌ No image files found in {image_folder}")
        return
    
    print(f"\n🔍 Found {len(image_files)} images to test\n")
    
    results = []
    for image_file in image_files:
        image_path = os.path.join(image_folder, image_file)
        result = predict_disease(image_path)
        if result:
            results.append({
                'filename': image_file,
                'result': result
            })
        print()  # Empty line between results
    
    # Summary
    if results:
        print(f"\n📊 Summary: Successfully processed {len(results)}/{len(image_files)} images")

def main():
    """
    Main function - handles command line usage
    """
    import sys
    
    print("🍇 Grape Disease Detection API Test Tool")
    print("=" * 60)
    
    if len(sys.argv) < 2:
        print("\n📖 Usage:")
        print("  Test single image:")
        print("    python test_disease_detection.py <image_path>")
        print("\n  Test multiple images:")
        print("    python test_disease_detection.py --folder <folder_path>")
        print("\n  Example:")
        print("    python test_disease_detection.py test_leaf.jpg")
        print("    python test_disease_detection.py --folder ./test_images/")
        sys.exit(1)
    
    if sys.argv[1] == '--folder' and len(sys.argv) > 2:
        test_multiple_images(sys.argv[2])
    else:
        predict_disease(sys.argv[1])

if __name__ == "__main__":
    main()
