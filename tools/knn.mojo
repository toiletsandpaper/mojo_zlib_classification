from tools.distance import euclidian

struct NearestNeighborClassificator:
    # var X_train: Tensor[DType.int8]
    # var y_train: Tensor[DType.int8]
    var features_train: DynamicVector[DynamicVector[Int8]]
    var target_train: DynamicVector[UInt8]

    fn __init__(inout self, features_train: DynamicVector[DynamicVector[Int8]], target_train: DynamicVector[UInt8]):
        self.features_train = features_train
        self.target_train = target_train
        print('Model fitted from init')

    fn fit(inout self, features_train: DynamicVector[DynamicVector[Int8]], target_train: DynamicVector[UInt8]):
        self.features_train = features_train
        self.target_train = target_train
        print('Model fitted from fit')
        # for i in range(len(features_train)):
        #     self.X_train.data().store(i, features_train[i])
        #     self.y_train.data().store(i, target_train[i])

    fn predict(self, new_features: DynamicVector[DynamicVector[Int8]]) -> DynamicVector[UInt8]:
        print('Calculating predictions')
        var predictions = DynamicVector[UInt8]()
        var new_features_count = len(new_features)
        for new_i in range(new_features_count):
            print(str(new_i / new_features_count * 100) + '% of new features calcutalted                \r')
            var distances = DynamicVector[Float64]()
            for i in range(len(self.features_train)):
                var vector = self.features_train[i]
                distances.append(euclidian(new_features[new_i], vector))
            # best_index = np.array(distances).argmin()
            var best_index = 0
            for i in range(len(distances)):
                if distances[i] < distances[best_index]:
                    best_index = i
            predictions.append(self.target_train[best_index])
        return predictions