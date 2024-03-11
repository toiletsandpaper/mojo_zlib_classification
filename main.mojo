#!/usr/bin/env mojo
from python import Python
from collections.vector import InlinedFixedVector
from collections.optional import Optional

from tools.zlib import compress, uncompress, ZlibResultType, uLong, Bytef
from tools.distance import euclidian
from tools.knn import NearestNeighborClassificator
from datasets.yahoo import YahooDataset, YahooRecord, load_dataset


fn main() raises:
    var yahoo_dataset_train = load_dataset('datasets/yahoo_train.csv')
    var yahoo_dataset_test = load_dataset('datasets/yahoo_test.csv')
    var X_train = DynamicVector[DynamicVector[Int8]]()
    var y_train = DynamicVector[UInt8]()
    var X_test = DynamicVector[DynamicVector[Int8]]()
    var y_test = DynamicVector[UInt8]()
    for row in yahoo_dataset_train:
        X_train.append(row[].compressed_all_text)
        y_train.append(row[].topic)
    for row in yahoo_dataset_test:
        X_test.append(row[].compressed_all_text)
        y_test.append(row[].topic)
    var knn = NearestNeighborClassificator(X_train, y_train)
    var y_pred = knn.predict(X_train)

    var hits = 0
    for i in range(len(y_pred)):
        if y_pred[i] == y_test[i]:
            hits += 1

    print('Total accuracy:', str(hits/len(y_pred) * 100) + '%')


    # var data_tensor = 
    # for rec in range(10):
    #     print(yahoo_dataset[rec], len(yahoo_dataset[rec].compressed_all_text))
    #     print(
    #         'Distance between', rec, 'and', rec+1, 'is', 
    #         euclidian(yahoo_dataset[rec].compressed_all_text, yahoo_dataset[rec+1].compressed_all_text)
    #     )
