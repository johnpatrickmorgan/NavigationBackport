#!/bin/sh

xcodebuild \
  -project NavigationBackportApp.xcodeproj \
  -scheme "NavigationBackportApp (iOS)" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 12,OS=14.5' \
  test && \
xcodebuild \
  -project NavigationBackportApp.xcodeproj \
  -scheme "NavigationBackportApp (iOS)" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 13,OS=15.5' \
  test && \
xcodebuild \
  -project NavigationBackportApp.xcodeproj \
  -scheme "NavigationBackportApp (iOS)" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.2' \
  test