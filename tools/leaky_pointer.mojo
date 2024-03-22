@value
@register_passable
struct WrappedPointer[T: AnyRegType, id: String]:
    var ptr: Pointer[T]

    fn __init__(inout self, ptr: AnyPointer[T], size: Int):
        self.ptr = Pointer[T](size)
        ptr.move_into(self.ptr.address)
        #memset_zero(self.ptr, size)

    fn __init__(inout self, size: Int):
        self.ptr = Pointer[T].alloc(size)
        memset_zero(self.ptr, size)

    fn free(owned self) raises:
        self.ptr.free()
        self.ptr = Pointer[T]()

    fn __del__(owned self):
        if self.ptr:
            print(Self.id, "not freed before delete")

    fn __getitem__(self, index: Int) -> T:
        return self.ptr[index]

    fn __setitem__(inout self, index: Int, value: T):
        self.ptr[index] = value

    fn load(self) -> T:
        return self.ptr.load()

    fn store(inout self, value: T):
        self.ptr.store(value)

    # any other Pointer methods needed

fn leaking_fn():
    var ptr = WrappedPointer[Int, "leaking"](10)
    ptr[0] = 1


fn freed_fn() raises:
    var ptr = WrappedPointer[Int, "freed"](10)
    ptr[0] = 2
    ptr.free()



fn main() raises:
    leaking_fn()
    freed_fn()