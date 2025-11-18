#!/bin/bash
set -e

echo "🏗️  Building Numina iOS Release..."

# Check for fastlane
if ! command -v fastlane &> /dev/null; then
    echo "❌ Fastlane not found. Install with: gem install fastlane"
    exit 1
fi

# Run tests
echo "🧪 Running tests..."
fastlane test

# Build and upload to TestFlight
echo "📦 Building and uploading to TestFlight..."
fastlane beta

echo "✅ Build complete and uploaded to TestFlight!"
