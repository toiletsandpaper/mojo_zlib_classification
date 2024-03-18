#!/usr/bin/env mojo
from tools.gzip_python import compress
from classifiers.classifier import Classifier
from datasets.yahoo_gzip import load_dataset

@always_inline
fn main() raises:
    var data_train = load_dataset('datasets/train.csv')
    var data_test = load_dataset('datasets/test.csv')

    var classifier = Classifier()
    classifier.train(data_train, 20)

    # print(
    #     classifier.classify(compress('I am a good'))
    # )

    var preds = classifier.classify_bulk(data_test)

    var hits =  0
    for i in range(len(preds)):
        if not preds[i].label.value() or not data_test[i].label.value():
            raise Error('Invalid label for index: ' + str(i))
        if preds[i].label.value() == data_test[i].label.value():
            hits = hits + 1
    print('Total accuracy:', str(hits/len(preds) * 100) + '%')
