#!/usr/bin/env mojo
from sys import ffi
from tools.zlib import zlib_type_compress
from classifiers.classifier import Classifier
from datasets.yahoo_gzip import load_dataset


fn main() raises:
    var handle = ffi.DLHandle('libz.dylib')
    var zlib_compress = handle.get_function[zlib_type_compress]("compress")

    var data_train = load_dataset('datasets/yahoo_train.csv', zlib_compress)
    var data_test = load_dataset('datasets/yahoo_test.csv', zlib_compress)

    var classifier = Classifier(zlib_compress)
    classifier.train(data_train)
    
    # print(
    #     classifier.classify(compress('I am a good'))
    # )

    var preds = classifier.classify_bulk(data_test, k=1)

    handle.close()

    var hits =  0
    for i in range(len(preds)):
        if not preds[i].label.value() or not data_test[i].label.value():
            raise Error('Invalid label for index: ' + str(i))
        if preds[i].label.value() == data_test[i].label.value():
            hits = hits + 1
    print('Total accuracy:', str(hits/len(preds) * 100) + '%')
