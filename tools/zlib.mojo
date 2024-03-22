from sys import ffi, external_call
from memory import memset_zero, memset
from memory.anypointer import AnyPointer
from collections.optional import Optional

from tools.gzip_python import CompressedText

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
alias zlib_type_compress = fn (
    _out: Pointer[Bytef], _out_len: Pointer[uLong], _in: AnyPointer[Bytef], _in_len: uLong
) -> Int
alias zlib_type_uncompress = fn (
    _out: Pointer[Bytef], _out_len: Pointer[uLong], _in: Pointer[Bytef], _in_len: uLong
) -> Int
alias ZlibResultType = Tuple[Pointer[Bytef], Pointer[uLong]]


fn log_zlib_result(Z_RES: Int, compressing: Bool = True, log_ok: Bool = True) raises -> NoneType:
    var prefix: String = ""
    if not compressing:
        prefix = "un"

    if Z_RES == 0:
        if log_ok:
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
        raise Error("ERROR " + prefix.upper() + "COMPRESSING: Unhandled exception. Return code:" + str(Z_RES))


fn compress(text: String, logging: Bool) raises -> ZlibResultType:
    var data_memory_amount: Int = len(text) * 3
    var handle = ffi.DLHandle(ZLibPath)
    var zlib_compress = handle.get_function[zlib_type_compress]("compress")

    var compressed = Pointer[Bytef].alloc(data_memory_amount)
    var compressed_len = Pointer[uLong].alloc(1)
    memset_zero(compressed, data_memory_amount)
    memset_zero(compressed_len, 1)
    compressed_len[0] = data_memory_amount

    var text_bytes = text.as_bytes()

    var Z_RES = zlib_compress(
        compressed,
        compressed_len,
        text_bytes.steal_data(),
        len(text) + 1,
    )
    log_zlib_result(Z_RES, log_ok=logging)
    handle.close()
    return Tuple(compressed, compressed_len)

fn compress[tensor_len: Int = 2048](text: String) raises -> CompressedText:
    var data_memory_amount: Int = len(text) * 3
    var handle = ffi.DLHandle(ZLibPath)
    var zlib_compress = handle.get_function[zlib_type_compress]("compress")

    var compressed = Pointer[Bytef].alloc(data_memory_amount)
    var compressed_len = Pointer[uLong].alloc(1)
    memset_zero(compressed, data_memory_amount)
    memset_zero(compressed_len, 1)
    compressed_len[0] = data_memory_amount

    var text_bytes = text.as_bytes()

    var Z_RES = zlib_compress(
        compressed,
        compressed_len,
        text_bytes.steal_data(),
        len(text) + 1,
    )
    handle.close()

    # var compressed_tensor = Tensor[DType.int16](tensor_len)
    # for i in range(compressed_len.load(0).to_int()):
    #     compressed_tensor[i] = compressed[i].to_int()
    # var res = CompressedText[DType.int16](text, compressed_tensor, compressed_len.load(0).to_int())
    var res = CompressedText[DType.int16](text, compressed_len.load(0).to_int())
    compressed.free()
    compressed_len.free()
    return res

fn compress[tensor_len: Int = 2048](text: String, zlib_compress: zlib_type_compress) raises -> CompressedText:
    var data_memory_amount: Int = len(text) * 3

    var compressed = Pointer[Bytef].alloc(data_memory_amount)
    var compressed_len = Pointer[uLong].alloc(1)
    memset_zero(compressed, data_memory_amount)
    memset_zero(compressed_len, 1)
    compressed_len[0] = data_memory_amount

    var text_bytes = text.as_bytes()

    var Z_RES = zlib_compress(
        compressed,
        compressed_len,
        text_bytes.steal_data(),
        len(text) + 1,
    )

    # if compressed_len.load(0).to_int() > tensor_len:
    #     raise Error("Compressed data is too big for provided tensor")

    # var compressed_tensor = Tensor[DType.int16](tensor_len)
    # for i in range(compressed_len.load(0).to_int()):
    #     compressed_tensor[i] = compressed[i].to_int()
    # var res = CompressedText[DType.int16](text, compressed_tensor, compressed_len.load(0).to_int())
    var res = CompressedText[DType.int16](text, compressed_len.load(0).to_int())
    compressed.free()
    compressed_len.free()
    return res


fn uncompress(data: DynamicVector[Int8], logging: Bool = False) raises -> String:
    var data_memory_amount: Int = len(data) * 3
    var handle = ffi.DLHandle(ZLibPath)
    var zlib_uncompress = handle.get_function[zlib_type_uncompress]("uncompress")

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
    log_zlib_result(Z_RES, compressing=False, log_ok=logging)
    var res: String = ""
    for i in range(uncompressed_len[0]):
        res = res + chr(uncompressed[i].to_int())
    handle.close()
    return res


fn main() raises:
    var text = "test teeeeeeeeeeext"
    var res: CompressedText = compress[50](text)
    print(res)

    # var res_data_pointer = res.get[0, Pointer[Bytef]]()
    # var res_len = res.get[1, Pointer[uLong]]().load(0)
    # var res_data = DynamicVector[Bytef]()
    # print_no_newline("compressed data is ")
    # for i in range(res_len):
    #     res_data.append(res_data_pointer.load(i))
    #     print_no_newline(hex(res_data[i]))
    # print("\ncompressed lenght is " + String(res_len) + "\n")

    # var uncompressed = uncompress(res_data)
    # print("uncompressed string: " + uncompressed)
