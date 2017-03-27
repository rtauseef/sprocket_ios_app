FRAMEWORKS_PATH="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
LINK_READER_FRAMEWORK_NAME="LinkReaderKit.framework"
LINK_READER_FRAMEWORK="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/${LINK_READER_FRAMEWORK_NAME}"
LINK_READER_BINARY="${LINK_READER_FRAMEWORK}/LinkReaderKit"
archs=$(lipo -info "$LINK_READER_BINARY" | rev | cut -d ':' -f1 | rev)

find "$LINK_READER_FRAMEWORK" -name '*.framework' -type d | while read -r FRAMEWORK
do

FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"

for arch in $archs; do
if [[ "$VALID_ARCHS" != *"$arch"* ]]; then
lipo -remove "$arch" -output "$FRAMEWORK_EXECUTABLE_PATH" "$FRAMEWORK_EXECUTABLE_PATH" || exit 1
echo "Removed $arch from $FRAMEWORK_EXECUTABLE_PATH"
fi
done

done;



find "$LINK_READER_FRAMEWORK" -name '*.framework' -type d | while read -r FRAMEWORK
do
echo "Signing $FRAMEWORK"
/usr/bin/codesign -s "$EXPANDED_CODE_SIGN_IDENTITY_NAME" --force "${FRAMEWORK}"
FRAMEWORK_NAME=$(basename "$FRAMEWORK")
if [[ "$FRAMEWORK_NAME" != "$LINK_READER_FRAMEWORK_NAME" ]]; then
echo "Moving $FRAMEWORK to ${FRAMEWORKS_PATH}/${FRAMEWORK_NAME}"
rm -rf "${FRAMEWORKS_PATH}/${FRAMEWORK_NAME}"
mv "$FRAMEWORK" "${FRAMEWORKS_PATH}/${FRAMEWORK_NAME}"
fi
done;

echo "Signing $LINK_READER_FRAMEWORK"
/usr/bin/codesign -s "$EXPANDED_CODE_SIGN_IDENTITY_NAME" --force "${LINK_READER_FRAMEWORK}"

rm -rf "$LINK_READER_FRAMEWORK/Frameworks"
rm -f "$LINK_READER_FRAMEWORK/strip-framework.sh"
