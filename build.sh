# Build script for the Embla iOS app
# Only used for Travis CI build tests.
#
# Builds an unsigned app binary in debug mode.
#
# xcodebuild output is fed through xcpretty to reduce build log
# verbosity and keep it within Travis log length limit.

xcodebuild  -parallelizeTargets \
            -workspace "ManDrake.xcworkspace" \
            -scheme "ManDrake" \
            -configuration "Debug" \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_ALLOWED=NO \
            CODE_SIGNING_REQUIRED=NO \
            clean build \
            | xcpretty -c && exit ${PIPESTATUS[0]}
