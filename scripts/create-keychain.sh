#!/bin/sh
set -v
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/certs/dist.cer.enc -d -a -out scripts/certs/dist.cer
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/certs/dist.p12.enc -d -a -out scripts/certs/dist.p12
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/certs/mac-dev.p12.enc -d -a -out scripts/certs/mac-dev.p12
security create-keychain -p github-actions ios-build.keychain
security import ./scripts/certs/apple.cer -k ~/Library/Keychains/ios-build.keychain -A
security import ./scripts/certs/dist.cer -k ~/Library/Keychains/ios-build.keychain -A
security import ./scripts/certs/dist.p12 -k ~/Library/Keychains/ios-build.keychain -P $KEY_SECRET -A
security import ./scripts/certs/mac-dev.p12 -k ~/Library/Keychains/ios-build.keychain -P $KEY_SECRET -A
rm -f ./scripts/certs/dist.cer
rm -f ./scripts/certs/dist.p12
rm -f ./scripts/certs/mac-dev.p12
security set-key-partition-list -S apple-tool:,apple: -s -k github-actions ios-build.keychain