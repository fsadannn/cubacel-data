FLUTTER=flutter

run:
	$(FLUTTER) run -vv

gen-models:
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

build-apk:
	$(FLUTTER) build apk -vv --split-per-abi

install:
	$(FLUTTER) install

clean:
	$(flutter) clean