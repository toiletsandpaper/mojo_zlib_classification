import multiprocessing
import datasets

yahoo = datasets.load_dataset('yahoo_answers_topics')
splits = yahoo.keys()

def save_split(split_name: str) -> None:
    yahoo[split_name].to_csv(f'yahoo_{split_name}.csv')

if __name__ == '__main__':
    with multiprocessing.Pool(len(splits)) as pool:
        print(f'Starting {len(splits)} processes to save dataset into csv files')
        pool.map(save_split, splits)