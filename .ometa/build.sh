#!/usr/bin/env bash
# Jailbreak .debs, plus the rootless build injected into a decrypted TikTok IPA with cyan
# (which also bundles the Cephei frameworks and ElleKit the tweak needs).
source "$PIPELINE/lib/helpers.sh"
setup_theos 16.5
install_cyan

log "Cephei SDK"
TMP=$(mktemp -d)
gh release download 2.0 -R hbang/libcephei -p 'cephei_sdk_2.0.zip' -D "$TMP"
unzip -q "$TMP/cephei_sdk_2.0.zip" -d "$TMP"
for d in "$THEOS/lib" "$THEOS/lib/iphone/rootless"; do
  mkdir -p "$d"; cp -R "$TMP"/cephei_sdk_2.0/*.framework "$d/"
done

VERSION=$(awk '/^Version:/ {print $2}' control)
FLAGS=(FINALPACKAGE=1 ARCHS="arm64 arm64e" TARGET="iphone:clang:16.5:14.0")

log "Rootless .deb"; make clean package "${FLAGS[@]}" THEOS_PACKAGE_SCHEME=rootless
ROOTLESS=$(ls packages/*_iphoneos-arm64.deb)
cp "$ROOTLESS" "$OUT/"
log "Rootful .deb";  make clean package "${FLAGS[@]}"
cp packages/*_iphoneos-arm.deb "$OUT/"

log "IPA (TikTok $BASE_VERSION)"
cyan -i "$BASE_IPA" -o "$OUT/BHTikTok_${BASE_VERSION}_v$VERSION.ipa" -uwf "$OUT/$(basename "$ROOTLESS")"
