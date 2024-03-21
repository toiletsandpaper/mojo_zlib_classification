from python import Python
from algorithm import parallelize, sync_parallelize

struct PyObjContainer(CollectionElement):
    var obj: PythonObject

    fn __init__(inout self, obj: PythonObject):
        self.obj = obj

    fn __copyinit__(inout self, other: Self):
        self.obj = other.obj

    fn __moveinit__(inout self, owned other: Self):
        self.obj = other.obj


fn do_something_python(text: String,uuid: PythonObject) raises -> String:
    return text + '\t' + str(uuid.uuid4())


fn main() raises:
    var texts = DynamicVector[String]()
    var uuids = DynamicVector[PyObjContainer]()
    texts.append("Hello, World!")
    texts.append("This is a test.")
    texts.append("Hello, World!")
    texts.append("This is a test.")
    texts.append("Hello, World!")
    texts.append("This is a test.")
    texts.append("Hello, World!")
    texts.append("This is a test.")
    texts.append("Hello, World!")
    texts.append("This is a test.")

    for i in range(len(texts)):
        var _uuid = Python.import_module('uuid')
        uuids.append(_uuid)

    #var uuid = Python.import_module('uuid')
    #var uuid_ref = Reference[PythonObject](uuid)
    # for i in range(len(texts)):
    #     print(do_something_python(texts[i], uuid_ref))

    
    @parameter
    fn _do(i: Int):
        try:
            print(do_something_python(texts[i], uuids[i].obj))
        except:
            print('Error')

    #parallelize[_do](1)  # returns only UUID4, but not text... why?
    parallelize[_do](len(texts), 1)