all: zlib_dylib yahoo_download build

zlib_dylib:
ifeq ($(wildcard *.dylib *.so),)
	@ echo $(wildcard *.dylib *.so)
	cd zlib && sh ./configure && make all
	mv ./zlib/libz.dylib .
	cd zlib && make clean
else
	@true && echo "$(wildcard *.dylib *.so) found, skipping building zlib"
endif

yahoo_download:
ifeq ($(wildcard *_train.csv), $(wildcard *_test.csv))
	python3 download_dataset.py
else
	@true && echo "$(wildcard *_train.csv) and $(wildcard *_test.csv) found, skip downloading again"
endif

build:
	@echo Building binary
	mkdir build
	mojo build main.mojo -o build/mojo_zlib_classifier

clean:
	rm -rf build
	rm -f *.dylib *.so
	rm -f *.csv

love:
	@echo not war
