FLUTTER=flutter

run:
	$(FLUTTER) run -vv --no-sound-null-safety

gen-models:
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

build-apk:
	$(FLUTTER) build apk --split-per-abi

install:
	$(FLUTTER) install

clean:
	$(flutter) clean