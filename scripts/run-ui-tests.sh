#!/bin/bash
set -e

echo "🧪 Running Numina iOS UI Tests..."

# Run UI tests
xcodebuild test \
  -project Numina.xcodeproj \
  -scheme Numina \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -testPlan NuminaUITests

echo "✅ Tests complete!"
