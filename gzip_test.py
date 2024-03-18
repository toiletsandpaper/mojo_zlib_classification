from gzip_classifier import Classifier
import pandas as pd
from tqdm import tqdm

# CompressedText: TypeAlias = str, bytes, str

# class Classifier:
#     training_data: list[CompressedText]

# train_data = pd.read_csv('datasets/train.csv', header=None, names=['id', 'category', 'question_title', 'question_content', 'best_answer'])
# train_data['encoded'] = train_data.agg(lambda x: f"{x['question_title']} {x['question_content']} {x['best_answer']}", axis=1)
# y = list(train_data['category'])

# test_data = pd.read_csv('datasets/test.csv', header=None, names=['id', 'category', 'question_title', 'question_content', 'best_answer'])
# test_data['encoded'] = test_data.agg(lambda x: f"{x['question_title']} {x['question_content']} {x['best_answer']}", axis=1)
# y_test = list(test_data['category'])

# classifier = Classifier()
# classifier.train(train_data['encoded'].to_list(), y_test)

# y_pred = classifier.classify_bulk(test_data['encoded'].to_list(), k=10)

# acc = [y_test == y_pred for y_test, y_pred in zip(y_test, y_pred)]
# print(len(acc) / len(y_test) * 100)