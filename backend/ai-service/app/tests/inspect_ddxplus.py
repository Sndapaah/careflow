from pathlib import Path
import json


BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data" / "ddxplus"

with open(DATA_DIR / "release_conditions.json", "r", encoding="utf-8") as f:
    conditions = json.load(f)

with open(DATA_DIR / "release_evidences.json", "r", encoding="utf-8") as f:
    evidences = json.load(f)


print("=" * 70)
print("DDXPLUS SUMMARY")
print("=" * 70)

print("Conditions:", len(conditions))
print("Evidences:", len(evidences))


train_file = next(
    f for f in (DATA_DIR / "train").iterdir()
    if f.is_file()
)

print("\nTraining file:")
print(train_file)

print("Size:", round(train_file.stat().st_size / (1024 ** 3), 2), "GB")


print("\n" + "=" * 70)
print("FIRST PATIENT RECORDS")
print("=" * 70)

with open(train_file, "r", encoding="utf-8") as f:

    for i in range(3):

        line = f.readline()

        print(f"\nRAW RECORD {i + 1}:")
        print(line[:5000])

        if not line:
            break
