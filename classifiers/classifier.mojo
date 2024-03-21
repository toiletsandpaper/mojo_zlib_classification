from collections.optional import Optional
from collections.dict import Dict

from classifiers.base import BaseClassifier
from tools.utils import get_most_common, quicksort
# from tools.gzip_python import compress, 
from tools.gzip_python import CompressedText
from tools.zlib import compress, zlib_type_compress
from tools.stringbuilder import StringBuilder

struct Classifier:
    var training_data: Optional[DynamicVector[CompressedText[]]]
    var k: Int
    var compressor: zlib_type_compress

    fn __init__(
        inout self, 
        owned compressor: zlib_type_compress,
        training_data: Optional[DynamicVector[CompressedText[]]] = None,
        k: Int = 1,
    ) raises -> None:
        if training_data:
            self.training_data = quicksort(training_data.value(), compressor)
            print('Model trained')
        else:
            self.training_data = None
        self.k = k
        self.compressor = compressor
    
    fn train(inout self, texts: DynamicVector[CompressedText[]], k: Int = 1) raises -> None:
        self.training_data = quicksort(texts, self.compressor)
        self.k = k
        print('Model trained')


    fn classify(self, text: CompressedText[], k: Optional[Int] = None) raises -> CompressedText:
        if not self.training_data:
            raise Error("Classifier has not been trained")
        #print('Sorting candidates')
        var candidates = quicksort(self.training_data.value(), self.compressor, text)
        #print('Candidates sorted')
        var most_common = get_most_common(candidates, k.or_else(self.k).value())
        #print('Got most common' + str(most_common))
        return most_common

    fn classify_bulk(self, texts: DynamicVector[CompressedText[]], k: Optional[Int] = None) raises -> DynamicVector[CompressedText[]]:
        var results = DynamicVector[CompressedText[]]()
        var counter = 0
        for text in texts:
            print_no_newline(str(counter / len(texts) * 100) + "%               \r")
            results.append(self.classify(text[], k))
            counter = counter + 1
        print('100% All text classified')
        print()
        return results
