#!/bin/bash
set -e

echo "📸 Taking App Store screenshots..."

fastlane screenshots

echo "✅ Screenshots saved to fastlane/screenshots/"
