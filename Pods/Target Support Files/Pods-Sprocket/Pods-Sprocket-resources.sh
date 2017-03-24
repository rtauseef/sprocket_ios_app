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
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH"
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "../../hp_photo_provider/Pod/Assets/Album_Placeholder@1x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Album_Placeholder@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Album_Placeholder@3x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check@3x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check_Inactive1.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check_Inactive1@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check_Inactive1@3x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRBack@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRCameraCell.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRCameraCell@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRCameraCell@3x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRFacebookNoPhotoAlbum@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRMyFeedOff@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRMyFeedOn@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRRetry@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRSearch@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Loading_Image@2x.png"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPRAlertStripView.xib"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPRNoInternetConnectionMessageView.xib"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPRNoInternetConnectionRetryView.xib"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPRSegmentedControlView.xib"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPR.storyboard"
  install_resource "../../hp_photo_provider/Pod/HPPhotoProviderLocalizable.bundle"
  install_resource "../../hp_photo_provider/Pod/TencentOpenApi_IOS_Bundle.bundle"
  install_resource "../../ios-print-sdk/Pod/Assets/MPActiveCircle@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPArrow@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPCheck@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPDoNoEnter.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPDoNoEnter@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPDownload@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPGear@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPInactiveCircle@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMagnify@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMeasurementArrowDown@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMeasurementArrowLeft@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMeasurementArrowRight@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMeasurementArrowUp@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMultipageWire.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPPrint@2x~ipad.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPPrint@2x~iphone.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPPrintLater@2x~ipad.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPPrintLater@2x~iphone.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPSelected@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPSelected@3x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPUnselected@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPUnselected@3x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPWaste@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPX@2x.png"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/Manta/MPBTProgressView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPMultiPageView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPPageRangeView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPPageView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPPrintJobsActionView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPRuleView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/MP.storyboard"
  install_resource "../../ios-print-sdk/Pod/MobilePrintSDKLocalizable.bundle"
  install_resource "$PODS_CONFIGURATION_BUILD_DIR/UrbanAirship-iOS-SDK-Pods-Sprocket/AirshipResources.bundle"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "../../hp_photo_provider/Pod/Assets/Album_Placeholder@1x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Album_Placeholder@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Album_Placeholder@3x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check@3x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check_Inactive1.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check_Inactive1@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check_Inactive1@3x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRBack@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRCameraCell.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRCameraCell@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRCameraCell@3x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRFacebookNoPhotoAlbum@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRMyFeedOff@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRMyFeedOn@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRRetry@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRSearch@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Loading_Image@2x.png"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPRAlertStripView.xib"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPRNoInternetConnectionMessageView.xib"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPRNoInternetConnectionRetryView.xib"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPRSegmentedControlView.xib"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPR.storyboard"
  install_resource "../../hp_photo_provider/Pod/HPPhotoProviderLocalizable.bundle"
  install_resource "../../hp_photo_provider/Pod/TencentOpenApi_IOS_Bundle.bundle"
  install_resource "../../ios-print-sdk/Pod/Assets/MPActiveCircle@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPArrow@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPCheck@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPDoNoEnter.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPDoNoEnter@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPDownload@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPGear@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPInactiveCircle@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMagnify@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMeasurementArrowDown@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMeasurementArrowLeft@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMeasurementArrowRight@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMeasurementArrowUp@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMultipageWire.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPPrint@2x~ipad.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPPrint@2x~iphone.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPPrintLater@2x~ipad.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPPrintLater@2x~iphone.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPSelected@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPSelected@3x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPUnselected@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPUnselected@3x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPWaste@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPX@2x.png"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/Manta/MPBTProgressView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPMultiPageView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPPageRangeView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPPageView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPPrintJobsActionView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPRuleView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/MP.storyboard"
  install_resource "../../ios-print-sdk/Pod/MobilePrintSDKLocalizable.bundle"
  install_resource "$PODS_CONFIGURATION_BUILD_DIR/UrbanAirship-iOS-SDK-Pods-Sprocket/AirshipResources.bundle"
fi
if [[ "$CONFIGURATION" == "TestFlight" ]]; then
  install_resource "../../hp_photo_provider/Pod/Assets/Album_Placeholder@1x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Album_Placeholder@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Album_Placeholder@3x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check@3x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check_Inactive1.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check_Inactive1@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check_Inactive1@3x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRBack@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRCameraCell.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRCameraCell@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRCameraCell@3x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRFacebookNoPhotoAlbum@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRMyFeedOff@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRMyFeedOn@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRRetry@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRSearch@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Loading_Image@2x.png"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPRAlertStripView.xib"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPRNoInternetConnectionMessageView.xib"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPRNoInternetConnectionRetryView.xib"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPRSegmentedControlView.xib"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPR.storyboard"
  install_resource "../../hp_photo_provider/Pod/HPPhotoProviderLocalizable.bundle"
  install_resource "../../hp_photo_provider/Pod/TencentOpenApi_IOS_Bundle.bundle"
  install_resource "../../ios-print-sdk/Pod/Assets/MPActiveCircle@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPArrow@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPCheck@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPDoNoEnter.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPDoNoEnter@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPDownload@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPGear@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPInactiveCircle@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMagnify@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMeasurementArrowDown@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMeasurementArrowLeft@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMeasurementArrowRight@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMeasurementArrowUp@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMultipageWire.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPPrint@2x~ipad.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPPrint@2x~iphone.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPPrintLater@2x~ipad.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPPrintLater@2x~iphone.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPSelected@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPSelected@3x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPUnselected@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPUnselected@3x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPWaste@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPX@2x.png"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/Manta/MPBTProgressView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPMultiPageView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPPageRangeView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPPageView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPPrintJobsActionView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPRuleView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/MP.storyboard"
  install_resource "../../ios-print-sdk/Pod/MobilePrintSDKLocalizable.bundle"
  install_resource "$PODS_CONFIGURATION_BUILD_DIR/UrbanAirship-iOS-SDK-Pods-Sprocket/AirshipResources.bundle"
fi
if [[ "$CONFIGURATION" == "AppStore" ]]; then
  install_resource "../../hp_photo_provider/Pod/Assets/Album_Placeholder@1x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Album_Placeholder@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Album_Placeholder@3x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check@3x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check_Inactive1.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check_Inactive1@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Check_Inactive1@3x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRBack@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRCameraCell.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRCameraCell@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRCameraCell@3x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRFacebookNoPhotoAlbum@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRMyFeedOff@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRMyFeedOn@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRRetry@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/HPPRSearch@2x.png"
  install_resource "../../hp_photo_provider/Pod/Assets/Loading_Image@2x.png"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPRAlertStripView.xib"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPRNoInternetConnectionMessageView.xib"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPRNoInternetConnectionRetryView.xib"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPRSegmentedControlView.xib"
  install_resource "../../hp_photo_provider/Pod/Classes/HPPR.storyboard"
  install_resource "../../hp_photo_provider/Pod/HPPhotoProviderLocalizable.bundle"
  install_resource "../../hp_photo_provider/Pod/TencentOpenApi_IOS_Bundle.bundle"
  install_resource "../../ios-print-sdk/Pod/Assets/MPActiveCircle@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPArrow@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPCheck@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPDoNoEnter.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPDoNoEnter@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPDownload@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPGear@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPInactiveCircle@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMagnify@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMeasurementArrowDown@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMeasurementArrowLeft@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMeasurementArrowRight@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMeasurementArrowUp@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPMultipageWire.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPPrint@2x~ipad.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPPrint@2x~iphone.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPPrintLater@2x~ipad.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPPrintLater@2x~iphone.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPSelected@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPSelected@3x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPUnselected@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPUnselected@3x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPWaste@2x.png"
  install_resource "../../ios-print-sdk/Pod/Assets/MPX@2x.png"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/Manta/MPBTProgressView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPMultiPageView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPPageRangeView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPPageView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPPrintJobsActionView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/Private/MPRuleView.xib"
  install_resource "../../ios-print-sdk/Pod/Classes/MP.storyboard"
  install_resource "../../ios-print-sdk/Pod/MobilePrintSDKLocalizable.bundle"
  install_resource "$PODS_CONFIGURATION_BUILD_DIR/UrbanAirship-iOS-SDK-Pods-Sprocket/AirshipResources.bundle"
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
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
