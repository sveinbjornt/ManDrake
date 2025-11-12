# Build script for the ManDrake macOS app
#
# Builds an unsigned app binary in debug mode.
#
# xcodebuild output is fed through xcpretty to reduce build log verbosity

xcodebuild  -parallelizeTargets \
            -project "ManDrake.xcodeproj" \
            -scheme "ManDrake" \
            -configuration "Debug" \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_ALLOWED=NO \
            CODE_SIGNING_REQUIRED=NO \
            clean build \
            | xcpretty -c && exit ${PIPESTATUS[0]}
