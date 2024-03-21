all: build

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
	python3 datasets/download_dataset.py
else
	@echo "$(wildcard datasets/*_train.csv) and $(wildcard datasets/*_test.csv) found, skip downloading again"
endif

yahoo_split: yahoo_download
ifeq ($(wildcard datasets/train.csv), $(wildcard datasets/test.csv))
	python3 datasets/split_dataset.py
else
	@echo "$(wildcard datasets/train.csv) and $(wildcard datasets/test.csv) found, skip downloading again"
endif

stringbuilder:
ifeq ($(wildcard tools/stringbuilder.mojo),)
	cp mojo_stringbuilder/stringbuilder/builder.mojo tools/stringbuilder.mojo
	mojo format tools/stringbuilder.mojo
	cd tools && sed -i '' -e 's/ let / var /g' -e 's/: StringBuilder/: Self/g' stringbuilder.mojo
else
	@echo "$(wildcard tools/stringbuilder.mojo) found, skipping building stringbuilder"
endif

build: stringbuilder zlib_dylib yahoo_split
	mkdir build
	mojo build main.mojo -o build/mojo_zlib_classifier

clean:
	rm -rf build
	rm -f *.dylib *.so
	rm -f datasets/*.csv

love:
	@echo not war
