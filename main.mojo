#!/usr/bin/env mojo
from python import Python

from zlib import compress, uncompress

fn main() raises:
    var datasets = Python.import_module('datasets')
    var yahoo_dataset = datasets.load_dataset('yahoo_answers_topics')
    _ = yahoo_dataset.to_csv('yahoo.csv')
    #yahoo_dataset
    print('Done')