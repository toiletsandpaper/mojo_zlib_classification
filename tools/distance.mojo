from collections.optional import Optional
from tensor import Tensor
from complex import ComplexSIMD

fn euclidian(
    vec1: DynamicVector[Int8], 
    vec2: DynamicVector[Int8], 
    dim: Optional[Int] = None
) -> Float64:
    # XXX: why does this is still a Optional after `or_else`?
    # var _dim = dim.or_else(
    #     math.min(len(vec1), len(vec2))
    # )
    var out_sum: Float64 = 0
    for i in range(dim.or_else(math.min(len(vec1), len(vec2))).value()):
        print('Int1:', vec1[i], '\nFloat1:',  vec1[i].cast[DType.float64]())
        out_sum = out_sum + (vec1[i].cast[DType.float64]() - vec2[i].cast[DType.float64]())**2
    return math.sqrt(out_sum)
    
fn main():
    var a = DynamicVector[Int8]()
    var b = DynamicVector[Int8]()
    for i in range(1, 4):
        a.append(i)
        b.append(i+3)
    print(euclidian(a, b))
