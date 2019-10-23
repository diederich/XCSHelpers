#!/bin/sh
# Script to run on Xcode server for notarizing the exported application bundle
# Requires:
# AC_PRIMARY_BUNDLE_ID - the primary bundle identifier e.g. "maccatalyst.com.company.productname"
# AC_ISSUER_ID - the issuer ID of the AppStore connect API key, e.g. "12asd12e-aa34-a231-a122-5bas1231a4d1"
# AC_KEY_ID - they key ID of the AppStore Connect API Key, e.g. "NAS12AF33"

if [ -z "$AC_KEY_ID" ] || [ -z "$AC_ISSUER_ID" ] || [ -z "$AC_PRIMARY_BUNDLE_ID" ]; then
  echo "Environment variables missing. Make sure to set: AC_PRIMARY_BUNDLE_ID, AC_ISSUER_ID and AC_KEY_ID."
  exit 1
fi

# Requirements from Xcode Server:
# $XCS_PRODUCT
if [ -z "$XCS_PRODUCT" ]; then
  echo "\$XCS_PRODUCT is empty. Did Xcode server export the archive?"
  exit 1
fi

# Derive some variables
PRODUCT_FOLDER="$XCS_PRODUCT"
PRODUCT_FILENAME=$(basename -- "$PRODUCT_FOLDER")
PRODUCT_NAME="${PRODUCT_FILENAME%.*}"
EXPORT_PATH="$TMPDIR/Notarize"
ZIP_PATH="$EXPORT_PATH/$PRODUCT_NAME.zip"

# Create a ZIP archive suitable for altool.
echo "Zipping '$PRODUCT_FOLDER' to '$ZIP_PATH'"
/usr/bin/ditto -c -k --keepParent "$PRODUCT_FOLDER" "$ZIP_PATH"

echo "Running altool with file '$ZIP_PATH'"
xcrun altool --notarize-app\
             --primary-bundle-id "$AC_PRIMARY_BUNDLE_ID"\
             --apiKey "$AC_KEY_ID"\
             --apiIssuer "$AC_ISSUER_ID"\
             --file "$ZIP_PATH"

