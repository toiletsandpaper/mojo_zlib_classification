from tools.distance import euclidean
from algorithm.sort import sort

struct NearestNeighborClassificator[type: DType]:
    var features_train: DynamicVector[Tensor[type]]
    var target_train: Tensor[DType.uint8]

    
    fn __init__(inout self, features_train: DynamicVector[Tensor[type]], target_train: Tensor[DType.uint8]):
        self.features_train = features_train
        self.target_train = target_train
        print('Model fitted from init')

    fn predict(self, new_features: DynamicVector[Tensor[type]]) raises -> Tensor[DType.uint8]:
        print('Calculating predictions')
        var predictions = Tensor[DType.uint8]()
        var new_features_count = len(new_features)

        var preds_count = 0
        var prev_percentage: Float64 = 0
        for new_tensor in new_features:
            var new_percentage = preds_count / new_features_count * 100
            #if new_percentage - prev_percentage > 2:
            print(str(new_percentage) + '% predicted             \r')
            prev_percentage = new_percentage
            
            var distances = DynamicVector[Int32]()
            for train_tensor in self.features_train:
                distances.append(euclidean[type](new_tensor[], train_tensor[]))
            var best_index = 0
            for i in range(len(distances)):
                if distances[i] < distances[best_index]:
                    best_index = i
            predictions[preds_count] = distances[best_index].cast[DType.uint8]()
            preds_count = preds_count + 1
        return predictions