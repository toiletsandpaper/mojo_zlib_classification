from python import PythonObject, Python

alias PyBytes = PythonObject
alias text: StringLiteral = "test teeeeeeeeeeext"


fn decompress(text: StringLiteral) raises -> PyBytes:
    var zlib: PythonObject = Python.import_module("zlib")
    var builtins: PythonObject = Python.import_module("builtins")
    var py_bytes: PyBytes = builtins.str(text).encode("utf-8")
    return zlib.compress(py_bytes)


fn uncompress(data: PyBytes) raises -> String:
    var zlib: PythonObject = Python.import_module("zlib")
    var builtins: PythonObject = Python.import_module("builtins")

    return String(zlib.decompress(data).decode("utf-8"))


fn main() raises:
    # var text = 'test teeeeeeeeeeext'

    var data = decompress(text)
    print(String(data))

    var un_text = uncompress(data)
    print(un_text)
