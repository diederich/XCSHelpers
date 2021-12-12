#!/bin/sh
# Script to run on Xcode server for notarizing the exported application bundle
# Requires:
# AC_ISSUER_ID - the issuer ID of the AppStore connect API key, e.g. "12asd12e-aa34-a231-a122-5bas1231a4d1"
# AC_KEY_ID - they key ID of the AppStore Connect API Key, e.g. "NAS12AF33"

if [ -z "$AC_KEY_ID" ] || [ -z "$AC_ISSUER_ID" ]; then
 echo "Environment variables missing. Make sure to set: AC_PRIMARY_BUNDLE_ID, AC_ISSUER_ID and AC_KEY_ID."
exit 1
fi

# Requirements from Xcode Server:
# $XCS_PRODUCT
if [ -z "$XCS_PRODUCT" ]; then
  echo "\$XCS_PRODUCT is empty. Did Xcode server export the archive?"
  exit 1
fi

PKG_PATH="$XCS_PRODUCT"

echo "Running altool with file '$PKG_PATH'"
xcrun altool --upload-app\
             --type osx\
             --apiKey "$AC_KEY_ID"\
             --apiIssuer "$AC_ISSUER_ID"\
             --file "$PKG_PATH"
