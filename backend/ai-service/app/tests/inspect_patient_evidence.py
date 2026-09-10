import ast
import json
from pathlib import Path

import pandas as pd


BASE_DIR = Path(__file__).resolve().parent.parent

DATA_DIR = (
    BASE_DIR
    / "data"
    / "ddxplus"
)

TRAIN_FILE = (
    DATA_DIR
    / "train"
    / "release_train_patients"
)

EVIDENCE_FILE = (
    DATA_DIR
    / "release_evidences.json"
)


print("Loading evidence definitions...")

with open(
    EVIDENCE_FILE,
    "r",
    encoding="utf-8"
) as f:

    evidences = json.load(f)


print(
    f"Loaded {len(evidences)} evidence definitions."
)


print("\nLoading training data...")

df = pd.read_csv(TRAIN_FILE)

print(
    f"Loaded {len(df):,} patient records."
)


# ============================================================
# PRINT RELEVANT EVIDENCE DEFINITIONS
# ============================================================

TARGETS = [
    "E_53",
    "E_54",
    "E_55",
    "E_56",
    "E_57",
    "E_58",
    "E_59",
    "E_66",
]


print("\n")
print("=" * 70)
print("RELEVANT EVIDENCE DEFINITIONS")
print("=" * 70)


for key in TARGETS:

    evidence = evidences.get(key)

    if not evidence:
        continue

    print(f"\n{key}")
    print(
        "Question:",
        evidence.get("question_en")
    )

    print(
        "Data type:",
        evidence.get("data_type")
    )

    values = evidence.get(
        "value_meaning",
        {}
    )

    if values:

        print("Values:")

        for value_id, meaning in values.items():

            print(
                f"  {value_id}: "
                f"{meaning.get('en')}"
            )


# ============================================================
# FIND VALUES USED WITH THESE EVIDENCES
# ============================================================

print("\n")
print("=" * 70)
print("VALUES ACTUALLY USED IN TRAINING DATA")
print("=" * 70)


counts = {}

for value in df["EVIDENCES"]:

    try:
        evidences_list = ast.literal_eval(
            value
        )
    except Exception:
        continue

    for evidence in evidences_list:

        for target in TARGETS:

            if evidence.startswith(
                target + "_@_"
            ):

                counts[evidence] = (
                    counts.get(
                        evidence,
                        0
                    ) + 1
                )


for evidence, count in sorted(
    counts.items(),
    key=lambda x: -x[1]
):

    print(
        f"{evidence:<25} "
        f"{count:,}"
    )