#!/usr/bin/env python3
"""
Setup script for Gemini PDF test dependencies
Run this to install required packages
"""

import subprocess
import sys

def install_package(package):
    """Install a package using pip"""
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])
        print(f"✅ Installed {package}")
        return True
    except subprocess.CalledProcessError:
        print(f"❌ Failed to install {package}")
        return False

def main():
    """Install required packages for Gemini PDF test"""
    print("=== Installing Gemini PDF Test Dependencies ===")
    
    packages = [
        "requests",
        "PyPDF2"
    ]
    
    success_count = 0
    for package in packages:
        if install_package(package):
            success_count += 1
    
    print(f"\n--- Setup Complete ---")
    print(f"Installed {success_count}/{len(packages)} packages")
    
    if success_count == len(packages):
        print("✅ All packages installed successfully!")
        print("\nNext steps:")
        print("1. Edit tests/test_gemini_pdf.py and add your Gemini API key")
        print("2. Run: python tests/test_gemini_pdf.py")
        print("3. Run: python tests/compare_results.py")
        print("4. Delete the test files when done")
    else:
        print("❌ Some packages failed to install")
        print("Try running manually:")
        for package in packages:
            print(f"  pip install {package}")

if __name__ == "__main__":
    main() 