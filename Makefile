.PHONY: test

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

screen-record:
	xcrun simctl io booted recordVideo ~/Desktop/simulator.mov

record-2-gif:
	ffmpeg -i ~/Desktop/simulator.mov -vf scale=320:-1 -r 6 -f gif -y ./img/spiramentum2.gif