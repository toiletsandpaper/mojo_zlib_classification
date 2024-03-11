from tools.zlib import uLong, Bytef, compress, uncompress
from pathlib import Path

alias YahooDataset = DynamicVector[YahooRecord]

@value
struct YahooRecord(CollectionElement, Stringable):
    var id: UInt64
    var topic: UInt8
    var question_title: String
    var question_content: String
    var best_answer: String
    var compressed_all_text: DynamicVector[Bytef]
    # TODO: var fixed_data_len: SIMD[DType.int8, 2048]

    fn __init__(inout self):
        self.id = 0
        self.topic = 0
        self.question_title = ""
        self.question_content = ""
        self.best_answer = ""
        self.compressed_all_text = DynamicVector[Bytef]()
        

    fn __copyinit__(inout self: Self, borrowed other: Self):
        self.id = other.id
        self.topic = other.topic
        self.question_title = other.question_title
        self.question_content = other.question_content
        self.best_answer = other.best_answer
        self.compressed_all_text = other.compressed_all_text

    fn __moveinit__(inout self: Self, owned other: Self):
        self.id = other.id
        self.topic = other.topic
        self.question_title = other.question_title
        self.question_content = other.question_content
        self.best_answer = other.best_answer
        self.compressed_all_text = other.compressed_all_text

    fn __str__(self) -> String:

        var first_part: String = (
            "YahooRecord(id="
            + String(self.id)
            + ", topic="
            + String(self.topic)
            + ", question_title="
            + self.question_title
            + ", question_content="
            + self.question_content
            + ", best_answer="
            + self.best_answer
        )

        var second_part: String = ', compressed=['
        for el in self.compressed_all_text:
            second_part = second_part + String(el[]) + ', '
        second_part = second_part[:-2] + ']'

        var last_part: String = ')'
        return (
            first_part + second_part + last_part
        )

fn load_dataset(yahoo_path: Path) raises -> YahooDataset:
    var yahoo_dataset = YahooDataset()
    var max_vector_length: UInt32 = 0
    with open(yahoo_path, "r") as file:
        print('Started loading', yahoo_path, 'file')
        var lines = file.read().split("\n")
        print('File', yahoo_path, 'loaded and splitted in lines')
        var readed = 0
        var last_readed: Float64 = 0.0
        for i in range(len(lines)):
            try:
                var readed_percentage = readed / len(lines) * 100
                if readed_percentage - last_readed > 2:
                    last_readed = readed_percentage
                    print_no_newline(str(readed / len(lines) * 100) + '% of file preprocessed      \r')
                if lines[i] == '':
                    raise Error('blank line')
                var col = lines[i].split(",")

                var id = col[0]
                var topic = col[1]
                var question_title = col[2]
                var question_content = col[3]
                var best_answer = col[4]

                # mojo 24.1 doesnt allow to instantiate from dynamic values :(
                var record = YahooRecord()
                record.id = atol(id)
                record.topic = atol(topic)            
                record.question_title = question_title.replace('"', '')
                record.question_content = question_content.replace('"', '')
                record.best_answer = best_answer.replace('"', '')
                var all: String = String(' ').join(question_title, question_content, best_answer)
                var compres_res =  compress(
                    all,
                    logging=False
                )
                var compressed_len: uLong = compres_res.get[1, Pointer[uLong]]().load(0)
                var compressed_data_ptr: Pointer[Bytef] = compres_res.get[0, Pointer[Bytef]]()
                for j in range(compressed_len):
                    record.compressed_all_text.append(compressed_data_ptr.load(j))
                yahoo_dataset.append(record)
                max_vector_length = math.max(max_vector_length, len(record.compressed_all_text))
            except err:
                print()
                print('Error ' + str(err) + '; skiping unparsable line: ' + lines[i])
            readed = readed + 1
    for row in yahoo_dataset:
        var row_len = len(row[].compressed_all_text)
        if UInt32(row_len) < max_vector_length:
            for i in range(max_vector_length - row_len):
                row[].compressed_all_text.append(0)
        elif UInt32(row_len) > max_vector_length:
            raise Error('vector of row is larger than related var somehow')
    return yahoo_dataset