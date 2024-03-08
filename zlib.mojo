from sys import ffi, external_call
from memory import memset_zero, memset
from memory.anypointer import AnyPointer

alias ZLibPath: String = "libz.dylib"

# Z_OK            0
# Z_STREAM_END    1
# Z_NEED_DICT     2
# Z_ERRNO        (-1)
# Z_STREAM_ERROR (-2)
# Z_DATA_ERROR   (-3)
# Z_MEM_ERROR    (-4)
# Z_BUF_ERROR    (-5)
# Z_VERSION_ERROR (-6)

alias Bytef = Scalar[DType.int8]
alias uLong = UInt64
alias zlib_type = fn (
    _out: Pointer[Bytef], _out_len: Pointer[uLong], _in: Pointer[Bytef], _in_len: uLong
) -> Int
alias ZlibResultType = Tuple[Pointer[Bytef], Pointer[uLong]]


fn log_zlib_result(Z_RES: Int, compressing: Bool = True) raises -> NoneType:
    var prefix: String = ""
    if not compressing:
        prefix = "un"

    if Z_RES == 0:
        print(
            "OK "
            + prefix.upper()
            + "COMPRESSING: Everything "
            + prefix
            + "compressed fine"
        )
    elif Z_RES == -4:
        raise Error("ERROR " + prefix.upper() + "COMPRESSING: Not enought memory")
    elif Z_RES == -5:
        raise Error(
            "ERROR " + prefix.upper() + "COMPRESSING: Buffer have not enough memory"
        )
    else:
        raise Error("ERROR " + prefix.upper() + "COMPRESSING: Unhandled exception")


fn compress(text: StringLiteral) raises -> ZlibResultType:
    var data_memory_amount: Int = 1024
    var handle = ffi.DLHandle(ZLibPath)
    var zlib_compress = handle.get_function[zlib_type]("compress")

    var compressed = Pointer[Bytef].alloc(data_memory_amount)
    var compressed_len = Pointer[uLong].alloc(1)
    memset_zero(compressed, data_memory_amount)
    memset_zero(compressed_len, 1)
    compressed_len[0] = data_memory_amount

    var Z_RES = zlib_compress(
        compressed,
        compressed_len,
        text.data()._as_scalar_pointer(),
        len(text) + 1,
    )
    log_zlib_result(Z_RES)
    handle.close()
    return Tuple(compressed, compressed_len)


fn uncompress(data: DynamicVector[Int8]) raises -> String:
    var data_memory_amount: Int = 2048
    var handle = ffi.DLHandle(ZLibPath)
    var zlib_uncompress = handle.get_function[zlib_type]("uncompress")

    var uncompressed = Pointer[Bytef].alloc(data_memory_amount)
    var compressed = Pointer[Bytef].alloc(len(data))
    var uncompressed_len = Pointer[uLong].alloc(1)
    memset_zero(uncompressed, data_memory_amount)
    memset_zero(uncompressed_len, 1)
    uncompressed_len[0] = data_memory_amount
    for i in range(len(data)):
        compressed.store(i, data[i])

    var Z_RES = zlib_uncompress(
        uncompressed,
        uncompressed_len,
        compressed,
        len(data),
    )
    log_zlib_result(Z_RES, compressing=False)
    var res: String = ""
    for i in range(uncompressed_len[0]):
        res = res + chr(uncompressed[i].to_int())
    handle.close()
    return res


fn main() raises:
    var text = "test teeeeeeeeeeext"
    var res = compress(text)
    var res_data_pointer = res.get[0, Pointer[Bytef]]()
    var res_len = res.get[1, Pointer[uLong]]().load(0)
    var res_data = DynamicVector[Bytef]()
    print_no_newline("compressed data is ")
    for i in range(res_len):
        res_data.append(res_data_pointer.load(i))
        print_no_newline(hex(res_data[i]))
    print("\ncompressed lenght is " + String(res_len) + "\n")

    var uncompressed = uncompress(res_data)
    print("uncompressed string: " + uncompressed)
