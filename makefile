FLUTTER=flutter

run:
	$(FLUTTER) run -vv --no-sound-null-safety

gen-models:
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

bluid:
	$(FLUTTER) build apk