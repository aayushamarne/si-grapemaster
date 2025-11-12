"""
Network Configuration Helper for Disease Detection API
This script helps you find the correct IP address to use in your Flutter app
"""

import socket
import subprocess
import platform

def get_local_ip():
    """Get the local IP address of this computer"""
    try:
        # Create a socket to determine the local IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except Exception:
        return None

def get_all_ips():
    """Get all network interface IPs"""
    hostname = socket.gethostname()
    try:
        ips = socket.gethostbyname_ex(hostname)[2]
        return [ip for ip in ips if not ip.startswith("127.")]
    except Exception:
        return []

def main():
    print("=" * 70)
    print("🌐 Network Configuration Helper for Flutter App")
    print("=" * 70)
    
    print("\n📱 CHOOSE YOUR SETUP:\n")
    
    # For Android Emulator
    print("1️⃣  ANDROID EMULATOR:")
    print("   Use: http://10.0.2.2:10000/predict")
    print("   (10.0.2.2 is the special alias to access host machine from emulator)")
    
    # For Physical Device
    print("\n2️⃣  PHYSICAL ANDROID DEVICE (same WiFi as computer):")
    local_ip = get_local_ip()
    if local_ip:
        print(f"   Use: http://{local_ip}:10000/predict")
        print(f"   Your computer's IP: {local_ip}")
    else:
        print("   Could not detect IP automatically")
    
    all_ips = get_all_ips()
    if all_ips:
        print(f"   Available IPs: {', '.join(all_ips)}")
    
    # For iOS Simulator
    print("\n3️⃣  iOS SIMULATOR:")
    print("   Use: http://127.0.0.1:10000/predict")
    print("   (iOS simulator can access localhost directly)")
    
    # Current server status
    print("\n" + "=" * 70)
    print("📋 QUICK INSTRUCTIONS:")
    print("=" * 70)
    print("\n1. Make sure Flask server is running:")
    print("   cd grapeMasterBackend")
    print("   python app.py")
    
    print("\n2. Update disease_detection_screen.dart:")
    print("   Find: Uri.parse('http://...:10000/predict')")
    print("   Replace with the appropriate URL from above")
    
    print("\n3. Test with Python first:")
    print("   cd tools")
    print("   python simple_test.py path/to/image.jpg")
    
    print("\n4. If using physical device, ensure:")
    print("   - Computer and phone are on SAME WiFi network")
    print("   - Firewall allows port 10000")
    print("   - Flask is running with host='0.0.0.0' (allows external connections)")
    
    print("\n" + "=" * 70)
    
    # Firewall check for Windows
    if platform.system() == "Windows":
        print("\n🔥 WINDOWS FIREWALL TIP:")
        print("   If connection fails, allow port 10000 in Windows Firewall:")
        print("   netsh advfirewall firewall add rule name=\"Flask API\" dir=in action=allow protocol=TCP localport=10000")

if __name__ == "__main__":
    main()
