from pathlib import Path
from tools.gzip_python import compress, CompressedText

fn load_dataset(yahoo_path: Path) raises -> DynamicVector[CompressedText[]]:
    var yahoo_dataset = DynamicVector[CompressedText[]]()
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
                    print_no_newline(str((readed_percentage).cast[DType.int8]()) + '% of file preprocessed      \r')
                if lines[i] == '':
                    raise Error('blank line')
                var col = lines[i].split(",")
                var id = col[0]
                var topic = col[1]
                var question_title = col[2]
                var question_content = col[3]
                var best_answer = col[4]
                
                var text = String(' ').join(topic, question_title, question_content, best_answer)
                
                var compressed_text = compress(text)
                compressed_text.label = topic

                yahoo_dataset.append(compressed_text)
            except err: 
                print('\nSkipping line; Error:', str(err))
    return yahoo_dataset