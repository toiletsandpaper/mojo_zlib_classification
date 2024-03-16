from collections.optional import Optional

from classifiers.base import BaseClassifier
from tools.utils import get_most_common, quicksort
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
        else:
            self.training_data = None
        self.k = k
    
    fn train(inout self, texts: DynamicVector[CompressedText[]], k: Int = 1) raises -> None:
        self.training_data = quicksort(texts)
        self.k = k
        

    fn classify(self, text: CompressedText[], k: Optional[Int] = None) raises -> CompressedText:
        if not self.training_data:
            raise Error("Classifier has not been trained")
        var candidates = quicksort(self.training_data.value(), text)
        var most_common = get_most_common(candidates, k.or_else(self.k).value())
        return most_common

    fn classify_bulk(self, texts: DynamicVector[CompressedText[]], k: Optional[Int] = None) raises -> DynamicVector[CompressedText[]]:
        var results = DynamicVector[CompressedText[]]()
        var counter = 0
        for text in texts:
            print_no_newline(str(counter / len(texts) * 100) + "%               \r")
            results.append(self.classify(text[], k))
            counter = counter + 1
        return results
