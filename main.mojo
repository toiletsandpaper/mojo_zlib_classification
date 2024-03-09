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
    # var all_text: String
    var compressed_all_text: DynamicVector[Bytef]

    fn __init__(inout self):
        # self.id = id
        # self.topic = topic.replace('"', '')
        # self.question_title = question_title.replace('"', '')
        # self.question_content = question_content.replace('"', '')
        # self.best_answer = best_answer.replace('"', '')
        # self.all_text = String('\n').join(question_title, question_content, best_answer)
        self.id = 0
        self.topic = 0
        self.question_title = ""
        self.question_content = ""
        self.best_answer = ""
        # self.all_text = ""
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
        
        return (
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
            # + ', all_text='
            # + self.all_text
            # + ', compressed=['
            # + String(',').join(self.compressed_all_text)
            # + ']'
            + ")"
        )


fn main() raises:
    var yahoo_dataset = DynamicVector[YahooRecord]()
    with open("yahoo_test.csv", "r") as file:
        for line in file.read().split("\n"):
            var col = line[].split(",")

            var id = col[0]
            var topic = col[1]
            var question_title = col[2]
            var question_content = col[3]
            var best_answer = col[4]

            # mojo 24.1 doesnt allow to instantiate from dynamic values :(
            try:
                var record = YahooRecord()
                record.id = atol(id)
                record.topic = atol(topic)            
                record.question_title = question_title.replace('"', '')
                record.question_content = question_content.replace('"', '')
                record.best_answer = best_answer.replace('"', '')
                var compres_res =  compress(
                    String(' ').join(question_title, question_content, best_answer),
                    logging=False
                )
                var compressed_len: uLong = compres_res.get[1, Pointer[uLong]]().load(0)
                var compressed_data_ptr: Pointer[Bytef] = compres_res.get[0, Pointer[Bytef]]()
                for j in range(compressed_len):
                    record.compressed_all_text.append(compressed_data_ptr.load(j))

                # Sometimes one of this works, sometimes nothing works at all
                # idk what causing this, maybe unclosed `file` when error raised? 
                # record.all_text = question_title + ' ' + question_content + ' ' + best_answer
                # record.all_text = question_title + question_content + best_answer
                # record.all_text = String(' ').join(question_title, question_content, best_answer)
                yahoo_dataset.append(record)
            except err:
                print('Error ' + str(err) + '; skiping unparsable line: ' + line[])
        for i in range(10):
            print(yahoo_dataset[i])
            # var compressed_len: uLong = yahoo_dataset[i].compressed_all_text.value().get[1, Pointer[uLong]]().load(0)
            # var compressed_data_ptr: Pointer[Bytef] = yahoo_dataset[i].compressed_all_text.value().get[0, Pointer[Bytef]]()
            # for j in range(compressed_len):
            #     print_no_newline(hex(compressed_data_ptr.load(j)))
            print()
