#!/usr/bin/env mojo
from python import Python
from collections.vector import InlinedFixedVector
from collections.optional import Optional
from tensor import Tensor, TensorSpec
from utils.index import Index

from tools.zlib import compress, uncompress, ZlibResultType, uLong, Bytef
#from tools.distance import euclidian
from tools.knn import NearestNeighborClassificator
from datasets.yahoo import YahooDataset, YahooRecord, load_dataset


fn main() raises:
    var yahoo_dataset_train = load_dataset('datasets/yahoo_test.csv')
    var yahoo_dataset_test = load_dataset('datasets/yahoo_test.csv')

    # var spec = TensorSpec(DType.float32, len(yahoo_dataset_train), 2048, 3)
    # #var gray_scale_image = Tensor[DType.float32](spec)

    # var X_train = Tensor[DType.int8](spec)
    # var y_train = Tensor[DType.uint8](len(yahoo_dataset_train))
    # var X_test = Tensor[DType.int8](len(yahoo_dataset_test), 2048)
    # var y_test = Tensor[DType.uint8](len(yahoo_dataset_test))

    var X_train = DynamicVector[Tensor[DType.int16]]()
    var y_train = Tensor[DType.uint8](len(yahoo_dataset_train))
    var X_test = DynamicVector[Tensor[DType.int16]]()
    var y_test = Tensor[DType.uint8](len(yahoo_dataset_test))
  
    print('Converting data to tensors')
    for i in range(len(yahoo_dataset_train)):
        X_train.append(yahoo_dataset_train[i].compressed_all_text)
        y_train[i] = yahoo_dataset_train[i].topic
    for i in range(len(yahoo_dataset_test)):
        X_test.append(yahoo_dataset_test[i].compressed_all_text)
        y_test[i] = yahoo_dataset_test[i].topic
    print('Done converting to tensor')
    var knn = NearestNeighborClassificator[DType.int16](X_train, y_train)
    var y_pred = knn.predict(X_train)
    print('Predictions are made')

    var hits_tensor = y_test - y_pred
    var hits = 0
    for i in range(hits_tensor.num_elements()):
        if hits_tensor[i] == 0:
            hits = hits + 1

    print('Total accuracy:', str(hits/y_pred.num_elements() * 100) + '%')


    # var data_tensor = 
    # for rec in range(10):
    #     print(yahoo_dataset[rec], len(yahoo_dataset[rec].compressed_all_text))
    #     print(
    #         'Distance between', rec, 'and', rec+1, 'is', 
    #         euclidian(yahoo_dataset[rec].compressed_all_text, yahoo_dataset[rec+1].compressed_all_text)
    #     )
