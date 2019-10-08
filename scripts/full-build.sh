#!/bin/sh
set -v

openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/certs/dev.cer.enc -d -a -out scripts/certs/dev.cer
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/certs/dev.p12.enc -d -a -out scripts/certs/dev.p12
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/certs/mac-dev.p12.enc -d -a -out scripts/certs/mac-dev.p12

security create-keychain -p github-actions ios-build.keychain
security import ./scripts/certs/apple.cer -k ~/Library/Keychains/ios-build.keychain -A
security import ./scripts/certs/dev.cer -k ~/Library/Keychains/ios-build.keychain -A
security import ./scripts/certs/dev.p12 -k ~/Library/Keychains/ios-build.keychain -P $KEY_SECRET -A
security import ./scripts/certs/mac-dev.p12 -k ~/Library/Keychains/ios-build.keychain -P $KEY_SECRET -A

rm -f ./scripts/certs/dev.cer
rm -f ./scripts/certs/dev.p12
rm -f ./scripts/certs/mac-dev.p12

security default-keychain -s ios-build.keychain
security set-key-partition-list -S apple-tool:,apple: -s -k github-actions ios-build.keychain

xcodebuild -scheme 'Feed Compass' -configuration Release -allowProvisioningUpdates -showBuildTimingSummary

security delete-keychain ios-build.keychain