#!/usr/bin/env mojo
from python import Python
from collections.vector import InlinedFixedVector
from collections.optional import Optional

from tools.zlib import compress, uncompress, ZlibResultType, uLong, Bytef
from datasets.yahoo import YahooDataset, YahooRecord, load_dataset


fn main() raises:
    var yahoo_dataset = load_dataset('datasets/yahoo_train.csv')
    #var data_tensor = 
    for rec in range(10):
        print(yahoo_dataset[rec], len(yahoo_dataset[rec].compressed_all_text))