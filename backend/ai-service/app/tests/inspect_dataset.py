from pathlib import Path
import pandas as pd


DATASET_PATH = (
    Path(__file__).resolve().parent.parent
    / "data"
    / "disease_dataset.csv"
)


print(f"Loading dataset from:\n{DATASET_PATH}\n")

df = pd.read_csv(DATASET_PATH)


print("=" * 60)
print("DATASET SHAPE")
print("=" * 60)

print(f"Rows: {df.shape[0]}")
print(f"Columns: {df.shape[1]}")


print("\n" + "=" * 60)
print("COLUMNS")
print("=" * 60)

for column in df.columns:
    print(column)


print("\n" + "=" * 60)
print("FIRST 5 RECORDS")
print("=" * 60)

print(df.head().to_string())


print("\n" + "=" * 60)
print("DATA TYPES")
print("=" * 60)

print(df.dtypes)


print("\n" + "=" * 60)
print("MISSING VALUES")
print("=" * 60)

print(df.isnull().sum())


print("\n" + "=" * 60)
print("UNIQUE VALUES")
print("=" * 60)

for column in df.columns:
    if df[column].nunique() < 100:
        print(f"\n{column}:")
        print(df[column].unique())


print("\n" + "=" * 60)
print("DATASET INSPECTION COMPLETE")
print("=" * 60)