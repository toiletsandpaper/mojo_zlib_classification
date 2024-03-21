#from tools.gzip_python import compress, decompress, 
from tools.gzip_python import CompressedText
from tools.zlib import compress, zlib_type_compress
from algorithm.sort import sort
from collections.optional import Optional
from collections.dict import Dict

from tools.stringbuilder import StringBuilder

struct IntKey(KeyElement, Intable):
    var value: Int

    fn __init__(inout self, owned value: Int):
        self.value = value

    fn __eq__(self, other: IntKey) -> Bool:
        return self.value == other.value

    fn __hash__(self) -> Int:
        return hash(self.value)

    fn __copyinit__(inout self, other: IntKey):
        self.value = other.value

    fn __moveinit__(inout self, owned other: IntKey):
        self.value = other.value

    fn __int__(self) -> Int:
        return self.value

fn calc_distance(text1: CompressedText, text2: CompressedText, compressor: zlib_type_compress) raises -> Float64:
    var combined_text = StringBuilder()
    combined_text.append(text1.text) 
    combined_text.append(' ') 
    combined_text.append(text2.text)
    var combined = compress(str(combined_text), zlib_compress=compressor)
    # var combined_text: String = text1.text + ' ' + text2.text
    # var combined = compress(combined_text)
    var res = (len(combined) - math.min(len(text1), len(text2))) / math.max(len(text1), len(text2))
    return res

fn quicksort(array: DynamicVector[CompressedText[]], compressor: zlib_type_compress, by_distance: Optional[CompressedText[]] = None,) raises -> DynamicVector[CompressedText[]]:
    if len(array) <= 1:
        #print('array 1')#, array[0])
        return array
    var left = DynamicVector[CompressedText[]]()
    var middle = DynamicVector[CompressedText[]]()
    var right = DynamicVector[CompressedText[]]()
        
    if not by_distance:
        var pivot = array[len(array) // 2]
        for x in array:
            if len(x[]) < len(pivot):
                left.append(x[])
            elif len(x[]) == len(pivot):
                middle.append(x[])
            else:
                right.append(x[])
        left = quicksort(left, compressor)
        left.extend(middle)
        left.extend(quicksort(right, compressor))
        #right = quicksort(right)
        return left
    else:
        var pivot = calc_distance(array[len(array) // 2], by_distance.value(), compressor=compressor)
        for x in array:
            var distance = calc_distance(x[], by_distance.value(), compressor=compressor)
            if distance < pivot:
                left.append(x[])
            elif distance == pivot:
                middle.append(x[])
            else:
                right.append(x[])
        left = quicksort(left, compressor, by_distance.value())
        left.extend(middle)
        left.extend(quicksort(right, compressor, by_distance.value()))
        # print(len(left))
        return left

# fn merge(left: DynamicVector[CompressedText[]], right: DynamicVector[CompressedText[]], by_distance: Optional[CompressedText[]] = None) raises -> DynamicVector[CompressedText[]]:
#     var result = DynamicVector[CompressedText[]]()
#     var i = 0
#     var j = 0
#     while i < len(left) and j < len(right):
#         if not by_distance:
#             if len(left[i]) < len(right[j]):
#                 result.append(left[i])
#                 i += 1
#             else:
#                 result.append(right[j])
#                 j += 1
#         else:
#             if calc_distance(left[i], by_distance.value()) < calc_distance(right[j], by_distance.value()):
#                 result.append(left[i])
#                 i += 1
#             else:
#                 result.append(right[j])
#                 j += 1
#     while i < len(left):
#         result.append(left[i])
#         i += 1
#     while j < len(right):
#         result.append(right[j])
#         j += 1
#     return result

# fn merge_sort(array: DynamicVector[CompressedText[]], by_distance: Optional[CompressedText[]] = None) raises -> DynamicVector[CompressedText[]]:
#     if len(array) <= 1:
#         return array
#     var middle = len(array) // 2
#     var left = DynamicVector[CompressedText[]]()
#     var right = DynamicVector[CompressedText[]]()
#     for i in range(middle):
#         left.append(array[i])
#     for i in range(middle, len(array)):
#         right.append(array[i])
#     left = merge_sort(left, by_distance)
#     right = merge_sort(right, by_distance)
#     return merge(left, right, by_distance)
    

fn get_most_common(sorted_array: DynamicVector[CompressedText[]], top_k: Int = 10) raises -> CompressedText:    
    var k = math.min(top_k, len(sorted_array))
    var dict = Dict[CompressedText[], Int]()
    for i in range(k):
        if dict.find(sorted_array[i]):
            dict[sorted_array[i]] += 1
        else:
            dict[sorted_array[i]] = 1
    var max_item: Optional[CompressedText[]] = None
    var max_count = 0
    for item in dict:
        if dict[item[]] > max_count:
            max_count = dict[item[]]
            max_item = item[]
    return max_item.value()

    
    # var k = math.min(top_k, len(sorted_array))
    # var max_item: Optional[CompressedText[]] = None
    # var max_count = 0
    # for i in range(k):
    #     print('i', i)
    #     var count = 0
    #     for j in range(k):
    #         print('j', j)
    #         if sorted_array[i] == sorted_array[j]:
    #             print('count')
    #             count += 1
    #     if count > max_count:
    #         max_count = count
    #         max_item = sorted_array[i]
    # return max_item.value()
    

fn main() raises:
    var text1 = "Hello, world!"
    var text2 = "Hello"
    var text3 = 'agdgkkdgkdgfgk'

    var array = DynamicVector[CompressedText[]]()
    _ = array.append(compress(text1))
    _ = array.append(compress(text3))
    _ = array.append(compress(text2))
    _ = array.append(compress(text3))
    _ = array.append(compress(text3))
    _ = array.append(compress(text1))
    _ = array.append(compress(text1))
    _ = array.append(compress(text1))

    # print(
    #     calc_distance(compress(text1), compress(text3)),
    # )

    var text = compress('bye')

    # print(
    #     get_most_common(quicksort(array, text))
    # )

    # var sorted = merge_sort(array, text)
    # for item in sorted:
    #     print(item[].text, len(item[]), calc_distance(item[], text))

    # print(get_most_common(sorted))