from python import PythonObject, Python
from collections.optional import Optional

alias PyBytes = PythonObject

struct CompressedText[type: DType = DType.int16](Stringable, Copyable, Movable, CollectionElement, Sized, KeyElement):
    var text: String
    #var tensor: Tensor[type]
    var compressed_len: Int
    var label: Optional[String]

    #fn __init__(inout self, text: String, tensor: Tensor[type], compressed_len: Int, label: Optional[String] = None):
    fn __init__(inout self, text: String, compressed_len: Int, label: Optional[String] = None):
        self.text = text
        #self.tensor = tensor
        self.compressed_len = compressed_len
        self.label = label

    fn __len__(self) -> Int:
        return self.compressed_len

    fn __eq__(self, other: Self) -> Bool:
        return (
            self.text == other.text and 
        #    self.tensor == other.tensor and 
            self.compressed_len == other.compressed_len 
        )

    fn __hash__(self) -> Int:
        var ptr = self.text._buffer.data.value
        return hash(DTypePointer[DType.int8](ptr), len(self.text))

    fn __copyinit__(inout self, other: Self):
        self.text = other.text
       # self.tensor = other.tensor
        self.compressed_len = other.compressed_len
        self.label = other.label
    
    fn __moveinit__(inout self, owned other: Self):
        self.text = other.text
       # self.tensor = other.tensor
        self.compressed_len = other.compressed_len
        self.label = other.label

    fn __str__(self) -> String:
        var out: String = "CompressedText(text='" + self.text + "', tensor=[0"
        # for i in range(self.tensor.num_elements()):
        #     out = out + str(self.tensor[i]) + ','
        out = out[:-1] + '], compressed_len=' + str(self.compressed_len) 
        out = out + ', label=' + self.label.or_else('None').value() + ')'
        return out

# fn compress[tensor_len: Int64 = 2048](owned text: String) raises -> CompressedText:
#     text = text.lower()
#     var out_tensor = Tensor[DType.int16](tensor_len.to_int())
#     var gzip = Python.import_module('gzip')
#     var builtins: PythonObject = Python.import_module("builtins")
#     var py_bytes: PyBytes = gzip.compress(builtins.str(text).encode("utf-8"))
#     # _ = builtins.print(py_bytes)
#     # _ = builtins.print(builtins.list(builtins.map(builtins.int, py_bytes)))
#     var compressed_len: Int = len(py_bytes)
#     for i in range(len(py_bytes)):
#         out_tensor[i] = int(builtins.int(py_bytes[i]))
#     var result = CompressedText(text, out_tensor, compressed_len)
#     return result

# fn decompress(text: CompressedText) raises -> String:
#     var gzip = Python.import_module('gzip')
#     var builtins: PythonObject = Python.import_module("builtins")
#     var py_list: PythonObject = builtins.list()
#     #print(py_bytes)
#     for i in range(text.compressed_len):
#         #print(text.tensor[i], builtins.bytes(builtins.chr(text.tensor[i])))
#         _ = py_list.append(text.tensor[i].to_int())
#     #print(py_bytes)
#     return str(gzip.decompress(builtins.bytes(py_list)).decode("utf-8"))


# fn main() raises:
    # var text = 'heADSlloooooooo'
    # var out = compress[50](text)
    # print(out)
    
    # var decompressed = decompress(out)
    # print(decompressed)