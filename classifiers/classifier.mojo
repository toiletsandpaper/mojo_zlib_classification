from collections.optional import Optional
from collections.vector import InlinedFixedVector
from sys.info import num_performance_cores
from algorithm import parallelize, sync_parallelize, async_parallelize

from classifiers.base import BaseClassifier
from tools.utils import get_most_common, quicksort, merge_sort
from tools.gzip_python import compress, CompressedText

struct Classifier:
    var training_data: Optional[DynamicVector[CompressedText[]]]
    var k: Int

    fn __init__(
        inout self, 
        training_data: Optional[DynamicVector[CompressedText[]]] = None,
        k: Int = 1,
    ) raises -> None:
        if training_data:
            self.training_data = quicksort(training_data.value())
            print('Model trained')
        else:
            self.training_data = None
        self.k = k
    
    fn train(inout self, texts: DynamicVector[CompressedText[]], k: Int = 1) raises -> None:
        self.training_data = quicksort(texts)
        self.k = k
        print('Model trained')
        

    fn classify(self, text: CompressedText[], k: Optional[Int] = None) raises -> CompressedText:
        if not self.training_data:
            raise Error("Classifier has not been trained")
        #print('Sorting candidates')
        var candidates = quicksort(self.training_data.value(), text)
        #print('Candidates sorted')
        var most_common = get_most_common(candidates, k.or_else(self.k).value())
        #print('Got most common' + str(most_common))
        return most_common

    @always_inline
    fn classify_bulk(self, texts: DynamicVector[CompressedText[]], k: Optional[Int] = None) raises -> DynamicVector[CompressedText[]]:
        var results = DynamicVector[CompressedText[]]()
        var placeholder = compress('error')
        placeholder.label = str(-1)
        #results.resize(len(texts), placeholder)

        @parameter
        fn _classify(i: Int):
            try:
                #results[i] = self.classify(texts[i], k)
                results.append(self.classify(texts[i], k))
            except:
                #results[i] = placeholder
                results.append(placeholder)

        parallelize[_classify](len(texts))
        print()
        return results
