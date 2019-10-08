#!/bin/sh
set -v
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/certs/dev.cer.enc -d -a -out scripts/certs/dev.cer
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/certs/dev.p12.enc -d -a -out scripts/certs/dev.p12
security create-keychain -p github-actions ios-build.keychain
security import ./scripts/certs/apple.cer -k ~/Library/Keychains/ios-build.keychain -A
security import ./scripts/certs/dev.cer -k ~/Library/Keychains/ios-build.keychain -A
security import ./scripts/certs/dev.p12 -k ~/Library/Keychains/ios-build.keychain -P $KEY_SECRET -A
rm -f ./scripts/certs/dev.cer
rm -f ./scripts/certs/dev.p12
security set-key-partition-list -S apple-tool:,apple: -s -k github-actions ios-build.keychain