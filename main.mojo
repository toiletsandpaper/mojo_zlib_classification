#!/usr/bin/env mojo
from python import Python
from collections.vector import InlinedFixedVector
from collections.optional import Optional

from zlib import compress, uncompress, ZlibResultType, uLong, Bytef


struct YahooRecord(CollectionElement, Stringable):
    var id: UInt64
    var topic: UInt8
    var question_title: String
    var question_content: String
    var best_answer: String
    var compressed_all_text: DynamicVector[Bytef]

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


fn main() raises:
    var yahoo_dataset = DynamicVector[YahooRecord]()
    with open("yahoo_test.csv", "r") as file:
        for line in file.read().split("\n"):
            try:
                if line[] == '':
                    raise Error('blank line')
                var col = line[].split(",")

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
            except err:
                print('Error ' + str(err) + '; skiping unparsable line: ' + line[])
        for i in range(10):
            print(yahoo_dataset[i])
            print()
