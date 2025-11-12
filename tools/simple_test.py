"""
Simple example script to test the Disease Detection API
Run this to quickly test if the API is working
"""

import requests

# API endpoint
ENDPOINT = "http://127.0.0.1:10000/predict"

# Example: Test with a sample image
def quick_test(image_path):
    """Quick test with a single image"""
    
    print(f"🍇 Testing Disease Detection API")
    print(f"Endpoint: {ENDPOINT}")
    print(f"Image: {image_path}\n")
    
    try:
        # Open and send the image
        with open(image_path, 'rb') as img:
            files = {'file': img}
            response = requests.post(ENDPOINT, files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ SUCCESS!")
            print(f"\nPrediction: {result.get('prediction', 'Unknown')}")
            print(f"Confidence: {result.get('confidence', 0):.4f}")
            print(f"\nFull Response:")
            print(result)
        else:
            print(f"❌ Error: Status {response.status_code}")
            print(response.text)
            
    except FileNotFoundError:
        print(f"❌ Error: Image file not found - {image_path}")
    except requests.exceptions.ConnectionError:
        print(f"❌ Error: Cannot connect to {ENDPOINT}")
        print("Make sure the server is running!")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        # Use command line argument
        quick_test(sys.argv[1])
    else:
        # Example usage
        print("Usage: python simple_test.py <image_path>")
        print("\nExample:")
        print("  python simple_test.py grape_leaf.jpg")
