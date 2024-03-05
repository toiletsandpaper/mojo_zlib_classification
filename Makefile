all: zlib_dylib yahoo_answers_dataset build

zlib_dylib:
	cd zlib && sh ./configure && make all
	mv ./zlib/libz.dylib .
	cd zlib && make clean

yahoo_answers_dataset:
	echo "TODO"

build:
	mkdir build
	cd build && mojo build ../main.mojo

clean:
	rm -rf build

