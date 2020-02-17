all:
	flutter build ios

clean:
	flutter clean

run:
	flutter run

test:
	flutter test

sim:
	open -a Simulator

catalina:
	sudo xattr -d com.apple.quarantine ~/bin/flutter/bin/cache/artifacts/libimobiledevice/idevice_id 
	sudo xattr -d com.apple.quarantine ~/bin/flutter/bin/cache/artifacts/libimobiledevice/ideviceinfo
	sudo xattr -d com.apple.quarantine ~/bin/flutter/bin/cache/artifacts/usbmuxd/iproxy  