#!/usr/bin/env bash
set -euo pipefail

IDENTITY_NAME="SpeedProof Local"
KEYCHAIN_PATH="$HOME/Library/Keychains/SpeedProof.keychain-db"
SUPPORT_DIR="$HOME/Library/Application Support/SpeedProof"
PASSWORD_FILE="$SUPPORT_DIR/signing-keychain-password"
WORK_DIR="$(mktemp -d -t speedproof-signing)"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

mkdir -p "$SUPPORT_DIR"
if [[ ! -f "$PASSWORD_FILE" ]]; then
  umask 077
  openssl rand -hex 24 >"$PASSWORD_FILE"
fi
keychain_password="$(cat "$PASSWORD_FILE")"

if [[ ! -f "$KEYCHAIN_PATH" ]]; then
  security create-keychain -p "$keychain_password" "$KEYCHAIN_PATH"
fi
security unlock-keychain -p "$keychain_password" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"

keychains=()
while IFS= read -r keychain; do
  keychain="${keychain#*\"}"
  keychain="${keychain%\"*}"
  [[ -n "$keychain" ]] && keychains+=("$keychain")
done < <(security list-keychains -d user)
if [[ " ${keychains[*]} " != *" $KEYCHAIN_PATH "* ]]; then
  security list-keychains -d user -s "${keychains[@]}" "$KEYCHAIN_PATH"
fi

existing_identity="$(
  security find-identity -v -p codesigning "$KEYCHAIN_PATH" |
    awk -v name="\"$IDENTITY_NAME\"" '$0 ~ name { print $2; exit }'
)"
if [[ -n "$existing_identity" ]]; then
  echo "$IDENTITY_NAME is already available."
  exit 0
fi

certificate_path="$WORK_DIR/SpeedProofLocal.cer"
if security find-certificate -c "$IDENTITY_NAME" -p "$KEYCHAIN_PATH" >"$certificate_path" 2>/dev/null; then
  :
else
  private_key_path="$WORK_DIR/SpeedProofLocal.key"
  bundle_path="$WORK_DIR/SpeedProofLocal.p12"
  bundle_password="$(openssl rand -hex 24)"

  openssl req \
    -new \
    -newkey rsa:2048 \
    -x509 \
    -sha256 \
    -days 3650 \
    -nodes \
    -subj "/CN=$IDENTITY_NAME/O=SpeedProof Development" \
    -addext "keyUsage=critical,digitalSignature" \
    -addext "extendedKeyUsage=codeSigning" \
    -keyout "$private_key_path" \
    -out "$certificate_path"

  openssl pkcs12 \
    -export \
    -legacy \
    -name "$IDENTITY_NAME" \
    -inkey "$private_key_path" \
    -in "$certificate_path" \
    -out "$bundle_path" \
    -passout "pass:$bundle_password"

  security import "$bundle_path" \
    -k "$KEYCHAIN_PATH" \
    -P "$bundle_password" \
    -T /usr/bin/codesign \
    -T /usr/bin/security

  security set-key-partition-list \
    -S apple-tool:,apple:,codesign: \
    -s \
    -k "$keychain_password" \
    "$KEYCHAIN_PATH" >/dev/null
fi

identity_hash="$(
  security find-identity -v -p codesigning "$KEYCHAIN_PATH" |
    awk -v name="\"$IDENTITY_NAME\"" '$0 ~ name { print $2; exit }'
)"
if [[ -z "$identity_hash" ]]; then
  identity_hash="$(
    security find-certificate -c "$IDENTITY_NAME" -Z "$KEYCHAIN_PATH" |
      awk '/SHA-1 hash:/{ print $3; exit }'
  )"
fi
if [[ -z "$identity_hash" ]]; then
  echo "Couldn't find $IDENTITY_NAME after importing it." >&2
  exit 1
fi

echo "$IDENTITY_NAME is ready: $identity_hash"
