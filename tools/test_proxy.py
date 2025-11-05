#!/usr/bin/env python3
"""Test script to verify the Groq proxy is working correctly."""

import requests
import json

# Test 1: Health check
print("Test 1: Health check...")
try:
    r = requests.get('http://127.0.0.1:5000/health', timeout=5)
    print(f"✓ Health check: {r.status_code} - {r.text}")
except Exception as e:
    print(f"✗ Health check failed: {e}")

# Test 2: Generate with 'input' format
print("\nTest 2: Generate with 'input' format...")
try:
    r = requests.post(
        'http://127.0.0.1:5000/generate',
        json={'input': 'Say hello in one sentence'},
        headers={'Content-Type': 'application/json'},
        timeout=15
    )
    print(f"Status: {r.status_code}")
    if r.status_code == 200:
        data = r.json()
        print(f"✓ Response: {json.dumps(data, indent=2)[:500]}")
    else:
        print(f"✗ Error response: {r.text}")
except Exception as e:
    print(f"✗ Generate failed: {e}")

print("\nDone!")
