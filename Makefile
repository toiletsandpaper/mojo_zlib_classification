all: zlib_dylib build

zlib_dylib:
	cd zlib && sh ./configure && make all
	mv ./zlib/libz.dylib .
	cd zlib && make clean

build:
	@echo Building
	mkdir build
	mojo build main.mojo -o build/mojo_zlib_classifier

clean:
	rm -rf build

love:
	@echo not war
