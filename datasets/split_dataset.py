import pandas as pd
from sklearn.model_selection import train_test_split

def split_dataset(dataset: pd.DataFrame, test_size: float = 0.5) -> tuple:
    """Split the dataset into training and testing sets."""
    train, test = train_test_split(dataset, test_size=test_size)
    return train, test

if __name__ == '__main__':
    data = pd.read_csv('yahoo_test.csv', header=None)
    train, test = split_dataset(data)
    train.head(500).to_csv('train.csv', index=False, header=False)
    test.head(10).to_csv('test.csv', index=False, header=False)