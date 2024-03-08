#!/usr/bin/env mojo
from python import Python
from collections.vector import InlinedFixedVector
from collections.optional import Optional

from zlib import compress, uncompress, ZlibResultType


struct YahooRecord(CollectionElement, Stringable):
    var id: UInt64
    var topic: UInt8
    var question_title: String
    var question_content: String
    var best_answer: String
    # var all_text: String
    var compressed_all_text: Optional[ZlibResultType]

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
        self.compressed_all_text = None
        

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
                # FIXME: doesnt work, some weird error when casting String to StringLiteral
                var a = StringLiteral.__init__(question_title)
                record.compressed_all_text = compress(
                    StringLiteral(question_title))
                )

                # Sometimes one of this works, sometimes nothing works at all
                # idk what causing this, maybe unclosed `file` when error raised? 
                # record.all_text = question_title + ' ' + question_content + ' ' + best_answer
                # record.all_text = question_title + question_content + best_answer
                # record.all_text = String(' ').join(question_title, question_content, best_answer)
                yahoo_dataset.append(record)
            except:
                print('skiping unparsable line: ' + line[])
        for i in range(10):
            print(yahoo_dataset[i])
