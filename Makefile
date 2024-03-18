all: zlib_dylib yahoo_download build

zlib_dylib:
ifeq ($(wildcard *.dylib *.so),)
	cd zlib && sh ./configure && make all
	mv $(wildcard zlib/*.dylib zlib/*.so) .
	cd zlib && make clean
else
	@echo "$(wildcard *.dylib *.so) found, skipping building zlib"
endif

yahoo_download:
ifeq ($(wildcard datasets/*_train.csv), $(wildcard datasets/*_test.csv))
	cd datasets && python3 download_dataset.py && python3 split_dataset.py
else
	@echo "$(wildcard datasets/*_train.csv) and $(wildcard datasets/*_test.csv) found, skip downloading again"
endif

build:
	@echo Building binary
	mkdir build
	mojo build main.mojo -o build/mojo_zlib_classifier

clean:
	rm -rf build
	rm -f *.dylib *.so
	rm -f datasets/*.csv

love:
	@echo not war
