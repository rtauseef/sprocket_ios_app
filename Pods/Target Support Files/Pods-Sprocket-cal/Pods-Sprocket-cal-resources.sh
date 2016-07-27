#!/bin/sh
set -e

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

case "${TARGETED_DEVICE_FAMILY}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

realpath() {
  DIRECTORY="$(cd "${1%/*}" && pwd)"
  FILENAME="${1##*/}"
  echo "$DIRECTORY/$FILENAME"
}

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}"
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}"
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\""
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\""
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\""
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE=$(realpath "$RESOURCE_PATH")
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH"
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "HPPhotoProvider/Pod/Assets/HPPRBack@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFacebookNoPhotoAlbum@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFilterButtonLeftOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFilterButtonLeftOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFilterButtonRightOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFilterButtonRightOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRGridViewOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRGridViewOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRListViewOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRListViewOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRMyFeedOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRMyFeedOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRRetry@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRSearch@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/Loading_Image@2x.png"
  install_resource "HPPhotoProvider/Pod/Classes/HPPRAlertStripView.xib"
  install_resource "HPPhotoProvider/Pod/Classes/HPPRNoInternetConnectionMessageView.xib"
  install_resource "HPPhotoProvider/Pod/Classes/HPPRNoInternetConnectionRetryView.xib"
  install_resource "HPPhotoProvider/Pod/Classes/HPPRSegmentedControlView.xib"
  install_resource "HPPhotoProvider/Pod/Classes/HPPR.storyboard"
  install_resource "HPPhotoProvider/Pod/HPPhotoProviderLocalizable.bundle"
  install_resource "MobilePrintSDK/Pod/Assets/MPActiveCircle@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPArrow@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPCheck@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPDoNoEnter.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPDoNoEnter@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPDownload@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPGear@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPInactiveCircle@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMagnify@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMeasurementArrowDown@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMeasurementArrowLeft@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMeasurementArrowRight@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMeasurementArrowUp@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMultipageWire.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPPrint@2x~ipad.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPPrint@2x~iphone.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPPrintLater@2x~ipad.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPPrintLater@2x~iphone.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPSelected@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPSelected@3x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPUnselected@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPUnselected@3x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPX@2x.png"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPBTProgressView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPMultiPageView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPPageRangeView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPPageView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPPrintJobsActionView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPRuleView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/MP.storyboard"
  install_resource "MobilePrintSDK/Pod/MobilePrintSDKLocalizable.bundle"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "HPPhotoProvider/Pod/Assets/HPPRBack@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFacebookNoPhotoAlbum@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFilterButtonLeftOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFilterButtonLeftOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFilterButtonRightOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFilterButtonRightOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRGridViewOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRGridViewOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRListViewOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRListViewOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRMyFeedOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRMyFeedOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRRetry@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRSearch@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/Loading_Image@2x.png"
  install_resource "HPPhotoProvider/Pod/Classes/HPPRAlertStripView.xib"
  install_resource "HPPhotoProvider/Pod/Classes/HPPRNoInternetConnectionMessageView.xib"
  install_resource "HPPhotoProvider/Pod/Classes/HPPRNoInternetConnectionRetryView.xib"
  install_resource "HPPhotoProvider/Pod/Classes/HPPRSegmentedControlView.xib"
  install_resource "HPPhotoProvider/Pod/Classes/HPPR.storyboard"
  install_resource "HPPhotoProvider/Pod/HPPhotoProviderLocalizable.bundle"
  install_resource "MobilePrintSDK/Pod/Assets/MPActiveCircle@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPArrow@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPCheck@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPDoNoEnter.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPDoNoEnter@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPDownload@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPGear@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPInactiveCircle@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMagnify@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMeasurementArrowDown@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMeasurementArrowLeft@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMeasurementArrowRight@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMeasurementArrowUp@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMultipageWire.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPPrint@2x~ipad.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPPrint@2x~iphone.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPPrintLater@2x~ipad.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPPrintLater@2x~iphone.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPSelected@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPSelected@3x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPUnselected@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPUnselected@3x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPX@2x.png"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPBTProgressView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPMultiPageView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPPageRangeView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPPageView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPPrintJobsActionView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPRuleView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/MP.storyboard"
  install_resource "MobilePrintSDK/Pod/MobilePrintSDKLocalizable.bundle"
fi
if [[ "$CONFIGURATION" == "TestFlight" ]]; then
  install_resource "HPPhotoProvider/Pod/Assets/HPPRBack@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFacebookNoPhotoAlbum@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFilterButtonLeftOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFilterButtonLeftOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFilterButtonRightOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFilterButtonRightOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRGridViewOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRGridViewOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRListViewOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRListViewOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRMyFeedOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRMyFeedOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRRetry@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRSearch@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/Loading_Image@2x.png"
  install_resource "HPPhotoProvider/Pod/Classes/HPPRAlertStripView.xib"
  install_resource "HPPhotoProvider/Pod/Classes/HPPRNoInternetConnectionMessageView.xib"
  install_resource "HPPhotoProvider/Pod/Classes/HPPRNoInternetConnectionRetryView.xib"
  install_resource "HPPhotoProvider/Pod/Classes/HPPRSegmentedControlView.xib"
  install_resource "HPPhotoProvider/Pod/Classes/HPPR.storyboard"
  install_resource "HPPhotoProvider/Pod/HPPhotoProviderLocalizable.bundle"
  install_resource "MobilePrintSDK/Pod/Assets/MPActiveCircle@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPArrow@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPCheck@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPDoNoEnter.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPDoNoEnter@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPDownload@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPGear@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPInactiveCircle@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMagnify@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMeasurementArrowDown@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMeasurementArrowLeft@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMeasurementArrowRight@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMeasurementArrowUp@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMultipageWire.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPPrint@2x~ipad.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPPrint@2x~iphone.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPPrintLater@2x~ipad.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPPrintLater@2x~iphone.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPSelected@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPSelected@3x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPUnselected@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPUnselected@3x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPX@2x.png"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPBTProgressView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPMultiPageView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPPageRangeView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPPageView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPPrintJobsActionView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPRuleView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/MP.storyboard"
  install_resource "MobilePrintSDK/Pod/MobilePrintSDKLocalizable.bundle"
fi
if [[ "$CONFIGURATION" == "AppStore" ]]; then
  install_resource "HPPhotoProvider/Pod/Assets/HPPRBack@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFacebookNoPhotoAlbum@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFilterButtonLeftOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFilterButtonLeftOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFilterButtonRightOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRFilterButtonRightOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRGridViewOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRGridViewOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRListViewOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRListViewOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRMyFeedOff@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRMyFeedOn@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRRetry@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/HPPRSearch@2x.png"
  install_resource "HPPhotoProvider/Pod/Assets/Loading_Image@2x.png"
  install_resource "HPPhotoProvider/Pod/Classes/HPPRAlertStripView.xib"
  install_resource "HPPhotoProvider/Pod/Classes/HPPRNoInternetConnectionMessageView.xib"
  install_resource "HPPhotoProvider/Pod/Classes/HPPRNoInternetConnectionRetryView.xib"
  install_resource "HPPhotoProvider/Pod/Classes/HPPRSegmentedControlView.xib"
  install_resource "HPPhotoProvider/Pod/Classes/HPPR.storyboard"
  install_resource "HPPhotoProvider/Pod/HPPhotoProviderLocalizable.bundle"
  install_resource "MobilePrintSDK/Pod/Assets/MPActiveCircle@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPArrow@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPCheck@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPDoNoEnter.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPDoNoEnter@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPDownload@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPGear@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPInactiveCircle@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMagnify@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMeasurementArrowDown@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMeasurementArrowLeft@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMeasurementArrowRight@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMeasurementArrowUp@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPMultipageWire.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPPrint@2x~ipad.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPPrint@2x~iphone.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPPrintLater@2x~ipad.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPPrintLater@2x~iphone.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPSelected@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPSelected@3x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPUnselected@2x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPUnselected@3x.png"
  install_resource "MobilePrintSDK/Pod/Assets/MPX@2x.png"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPBTProgressView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPMultiPageView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPPageRangeView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPPageView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPPrintJobsActionView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/Private/MPRuleView.xib"
  install_resource "MobilePrintSDK/Pod/Classes/MP.storyboard"
  install_resource "MobilePrintSDK/Pod/MobilePrintSDKLocalizable.bundle"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "`realpath $PODS_ROOT`*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi