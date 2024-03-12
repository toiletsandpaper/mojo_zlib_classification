from collections.optional import Optional
from tensor import Tensor, TensorSpec
from complex import ComplexSIMD
from algorithm.functional import vectorize
from algorithm import map, sum

fn reduce_power2_sum[type: DType](tensor: Tensor[type]) -> SIMD[type, 1]:
    alias simd_width = simdwidthof[type]()
    # a vector to hold intermediate results.  The 0 is splatted to all elements.
    var accumulator = SIMD[type, simd_width](0)

    @parameter
    fn reduce_power_and_sum[width: Int](i: Int):
        @parameter
        if width == simd_width:
            # accumulator and loaded SIMD vector match types with `simd_width`.
            accumulator += tensor.simd_load[simd_width](i) ** 2
        else:
            # Handle tail elements when the tensor size isn't a multiple of simd_width.
            accumulator[0] += tensor.simd_load[width](i).reduce_add() ** 2

    vectorize[reduce_power_and_sum, simd_width, 1](tensor.num_elements())
    # reduce the vector of sums to a scalar
    return accumulator.reduce_add()

fn euclidean[type: DType](vec1: Tensor[type], vec2: Tensor[type]) raises -> Int32:
    var out_vec: Tensor[type] = (vec1 - vec2)
    # var sum: Int32 = 0
    # for i in range(out_vec.num_elements()):
    #     sum = sum + out_vec[i].cast[DType.int32]() ** 2
    # var out = math.sqrt(sum)
    var out = math.sqrt(reduce_power2_sum[type](out_vec)).cast[DType.int32]()
    return out
        
            
fn main() raises:
    var tensor_length = 3
    var a = Tensor[DType.int16](tensor_length)
    var b = Tensor[DType.int16](tensor_length)


    for i in range(0, tensor_length):
        a[i] = i + 1
        b[i] = i + 4

    print(euclidean[DType.int16](a, b))