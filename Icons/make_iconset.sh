mkdir ManDrakeAppIcon.iconset
sips -z 16 16     ManDrakeAppIcon1024.png --out ManDrakeAppIcon.iconset/icon_16x16.png
sips -z 32 32     ManDrakeAppIcon1024.png --out ManDrakeAppIcon.iconset/icon_16x16@2x.png
sips -z 32 32     ManDrakeAppIcon1024.png --out ManDrakeAppIcon.iconset/icon_32x32.png
sips -z 64 64     ManDrakeAppIcon1024.png --out ManDrakeAppIcon.iconset/icon_32x32@2x.png
sips -z 128 128   ManDrakeAppIcon1024.png --out ManDrakeAppIcon.iconset/icon_128x128.png
sips -z 256 256   ManDrakeAppIcon1024.png --out ManDrakeAppIcon.iconset/icon_128x128@2x.png
sips -z 256 256   ManDrakeAppIcon1024.png --out ManDrakeAppIcon.iconset/icon_256x256.png
sips -z 512 512   ManDrakeAppIcon1024.png --out ManDrakeAppIcon.iconset/icon_256x256@2x.png
sips -z 512 512   ManDrakeAppIcon1024.png --out ManDrakeAppIcon.iconset/icon_512x512.png
cp ManDrakeAppIcon1024.png ManDrakeAppIcon.iconset/icon_512x512@2x.png


