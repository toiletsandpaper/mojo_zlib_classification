from tools.distance import euclidean
from algorithm import argmin
from utils.index import Index
from collections.optional import Optional
from algorithm import parallelize

struct NearestNeighborClassificator[type: DType]:
    var features_train: Tensor[type]
    var target_train: Tensor[DType.uint8]

    
    fn __init__(inout self, features_train: Tensor[type], target_train: Tensor[DType.uint8]):
        self.features_train = features_train
        self.target_train = target_train
        print('Model fitted from init')


    fn predict(self, new_features: Tensor[type]) raises -> Tensor[DType.uint8]:
        
        print('Calculating predictions')
        var rows = new_features.shape()[0]
        var cols = new_features.shape()[1]
        var train_rows = self.features_train.shape()[0]
        var train_cols = self.features_train.shape()[1]
        var predictions = Tensor[DType.uint8](rows)

        var preds_count = 0
        var prev_percentage: Float64 = 0
        print('Total rows to predict =', rows)
        for new_row in range(rows):
            var new_percentage = (preds_count / rows) * 100
            if new_percentage - prev_percentage > 0.5:
                print_no_newline(str(new_percentage) + '% predicted                \r')
                prev_percentage = new_percentage

            var best_distance_idx: UInt8 = 0
            var best_distance: Optional[Int32] = None
            #var distances = Tensor[DType.int32](train_rows)
            var tensor = Tensor[type](cols)
            for col in range(cols):
                tensor[Index(col)] = new_features[Index(col, new_row)]
            
            for row in range(train_rows):
                var train_tensor = Tensor[type](train_cols)
                for col in range(train_cols):
                    train_tensor[col] = self.features_train[Index(col, row)]
                var distance = euclidean[type](tensor, train_tensor)
                if not best_distance or best_distance.value() > distance:
                    best_distance = distance
                    best_distance_idx = row
            if not best_distance:
                raise Error('best distance not found somehow; is data ok?')
            predictions[new_row] = self.target_train[Index(best_distance_idx)]
            preds_count = preds_count + 1
        return predictions