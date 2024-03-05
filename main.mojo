#!/usr/bin/env mojo
from python import Python

from zlib import compress, uncompress

fn main() raises:
    var datasets = Python.import_module('datasets')
    _ = datasets.load_dataset('yahoo_answers_topics')
    print('Main')