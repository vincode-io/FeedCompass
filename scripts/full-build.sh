#!/bin/sh
set -v
set -e

openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/certs/dev.cer.enc -d -a -out scripts/certs/dev.cer
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/certs/dev.p12.enc -d -a -out scripts/certs/dev.p12

security create-keychain -p github-actions github-build.keychain
security import ./scripts/certs/apple.cer -k ~/Library/Keychains/github-build.keychain -A
security import ./scripts/certs/dev.cer -k ~/Library/Keychains/github-build.keychain -A
security import ./scripts/certs/dev.p12 -k ~/Library/Keychains/github-build.keychain -P $KEY_SECRET -A
security set-key-partition-list -S apple-tool:,apple: -s -k github-actions github-build.keychain
security default-keychain -s github-build.keychain

#security set-keychain-settings -t 3600 -l github-build.keychain
#security unlock-keychain -p github-actions github-build.keychain

rm -f ./scripts/certs/dev.cer
rm -f ./scripts/certs/dev.p12

xcodebuild -scheme 'Feed Compass' -configuration Release -allowProvisioningUpdates -showBuildTimingSummary

security delete-keychain github-build.keychain