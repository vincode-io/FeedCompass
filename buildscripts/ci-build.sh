#!/bin/sh
set -v
set -e

# Unencrypt our provisioning profile, certificate, and private key
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in buildscripts/profile/FeedCompass.provisionprofile.enc -d -a -out buildscripts/profile/FeedCompass.provisionprofile
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in buildscripts/certs/dev.cer.enc -d -a -out buildscripts/certs/dev.cer
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in buildscripts/certs/dev.p12.enc -d -a -out buildscripts/certs/dev.p12

# Put the certificates and private key in the Keychain, set ACL permissions, and make default
security create-keychain -p github-actions github-build.keychain
security import buildscripts/certs/apple.cer -k ~/Library/Keychains/github-build.keychain -A
security import buildscripts/certs/dev.cer -k ~/Library/Keychains/github-build.keychain -A
security import buildscripts/certs/dev.p12 -k ~/Library/Keychains/github-build.keychain -P $KEY_SECRET -A
security set-key-partition-list -S apple-tool:,apple: -s -k github-actions github-build.keychain
security default-keychain -s github-build.keychain

# Copy the provisioning profile
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp buildscripts/profile/FeedCompass.provisionprofile ~/Library/MobileDevice/Provisioning\ Profiles/

# Delete the decrypted files
rm -f buildscripts/profile/FeedCompass.provisionprofile
rm -f buildscripts/certs/dev.cer
rm -f buildscripts/certs/dev.p12

# Do the build
xcodebuild -scheme 'Feed Compass' -configuration Release -allowProvisioningUpdates -showBuildTimingSummary

# Delete the keychain and the provisioningi profile
security delete-keychain github-build.keychain
rm -f ~/Library/MobileDevice/Provisioning\ Profiles/FeedCompass.provisionprofile