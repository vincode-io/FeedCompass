#!/bin/sh
set -v

openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/certs/dist.cer.enc -d -a -out scripts/certs/dist.cer
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/certs/dist.p12.enc -d -a -out scripts/certs/dist.p12

security create-keychain -p github-actions github-build.keychain
security import ./scripts/certs/apple.cer -k ~/Library/Keychains/github-build.keychain -A
security import ./scripts/certs/dist.cer -k ~/Library/Keychains/github-build.keychain -A
security import ./scripts/certs/dist.p12 -k ~/Library/Keychains/github-build.keychain -P $KEY_SECRET -A

rm -f ./scripts/certs/dist.cer
rm -f ./scripts/certs/dist.p12

security default-keychain -s github-build.keychain
#security set-key-partition-list -S apple-tool:,apple: -s -k github-actions github-build.keychain