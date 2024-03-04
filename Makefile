target:
	cd zlib && sh ./configure && make all
	mv ./zlib/libz.dylib .
	cd zlib && make clean
