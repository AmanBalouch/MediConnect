#!/bin/bash

# WiFi Device Connection Helper Script
# Usage: bash connect_wifi.sh

echo "======================================"
echo "📱 WiFi Device Connection Helper"
echo "======================================"
echo ""

# Step 1: Check if device is connected via USB
echo "Step 1️⃣ : Checking USB connection..."
devices=$(adb devices | grep -v "List" | grep "device$" | wc -l)

if [ $devices -eq 0 ]; then
    echo "❌ No USB connected devices found!"
    echo "Please connect your device via USB and enable USB Debugging"
    echo "Settings → About Phone → Build Number (tap 7 times) → Developer Options → USB Debugging"
    exit 1
fi

echo "✅ Device found via USB"
adb devices
echo ""

# Step 2: Enable TCP/IP mode
echo "Step 2️⃣ : Enabling TCP/IP mode..."
adb tcpip 5555
sleep 2
echo ""

# Step 3: Get device IP
echo "Step 3️⃣ : Getting device IP address..."
device_ip=$(adb shell ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d'/' -f1)

if [ -z "$device_ip" ]; then
    echo "❌ Could not get device IP!"
    echo "Make sure WiFi is connected on your device"
    exit 1
fi

echo "✅ Device IP: $device_ip"
echo ""

# Step 4: Disconnect USB
echo "Step 4️⃣ : Please disconnect USB cable from device"
read -p "Press Enter when USB is disconnected..."
echo ""

# Step 5: Connect via WiFi
echo "Step 5️⃣ : Connecting via WiFi..."
adb connect $device_ip:5555
sleep 2
echo ""

# Step 6: Verify connection
echo "Step 6️⃣ : Verifying WiFi connection..."
adb devices
echo ""

# Check if WiFi connection was successful
wifi_devices=$(adb devices | grep ":5555" | wc -l)

if [ $wifi_devices -eq 0 ]; then
    echo "❌ WiFi connection failed!"
    echo "Troubleshooting:"
    echo "1. Make sure device and computer are on same WiFi"
    echo "2. Check firewall settings"
    echo "3. Try: adb kill-server && adb start-server"
    exit 1
fi

echo "✅ WiFi connection successful!"
echo ""
echo "======================================"
echo "🎉 Ready to use!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Run: flutter run"
echo "2. Or:  flutter run -d $device_ip:5555"
echo ""
echo "Connected device: $device_ip:5555"
echo "======================================"

