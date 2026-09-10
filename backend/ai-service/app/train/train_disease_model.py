from pathlib import Path

import joblib
import pandas as pd

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report


# --------------------------------------------------
# PATHS
# --------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent.parent

DATASET_PATH = BASE_DIR / "data" / "disease_dataset.csv"
MODEL_DIR = BASE_DIR / "models"

MODEL_DIR.mkdir(exist_ok=True)

MODEL_PATH = MODEL_DIR / "disease_classifier.joblib"


# --------------------------------------------------
# LOAD DATASET
# --------------------------------------------------

print("Loading dataset...")

df = pd.read_csv(DATASET_PATH)

print(f"Dataset shape: {df.shape}")


# --------------------------------------------------
# CHECK DISEASE DISTRIBUTION
# --------------------------------------------------

disease_counts = df["disease"].value_counts()

rare_diseases = disease_counts[disease_counts < 2]

if len(rare_diseases) > 0:

    print("\nWARNING: Diseases with fewer than 2 records:")

    for disease, count in rare_diseases.items():
        print(f"  {disease}: {count}")

    print("\nRemoving these diseases for this training run...")

    df = df[
        ~df["disease"].isin(rare_diseases.index)
    ].copy()


print(f"\nDataset after filtering: {df.shape}")


# --------------------------------------------------
# FEATURES / TARGET
# --------------------------------------------------

X = df.drop(columns=["disease"])
y = df["disease"]


print(f"Features: {X.shape[1]}")
print(f"Diseases: {y.nunique()}")


# --------------------------------------------------
# TRAIN / TEST SPLIT
# --------------------------------------------------

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.20,
    random_state=42,
    stratify=y
)


print(f"Training records: {len(X_train)}")
print(f"Testing records: {len(X_test)}")


# --------------------------------------------------
# MODEL
# --------------------------------------------------

print("\nTraining Random Forest...")

model = RandomForestClassifier(
    n_estimators=300,
    max_depth=None,
    min_samples_split=2,
    random_state=42,
    n_jobs=-1,
    class_weight="balanced"
)

model.fit(X_train, y_train)


# --------------------------------------------------
# EVALUATION
# --------------------------------------------------

print("\nEvaluating model...")

predictions = model.predict(X_test)

accuracy = accuracy_score(
    y_test,
    predictions
)

print(f"\nAccuracy: {accuracy:.4f}")

print("\nClassification Report:")

print(
    classification_report(
        y_test,
        predictions,
        zero_division=0
    )
)


# --------------------------------------------------
# SAVE MODEL
# --------------------------------------------------

print("\nSaving model...")

joblib.dump(
    {
        "model": model,
        "features": list(X.columns),
        "classes": list(model.classes_)
    },
    MODEL_PATH
)


print(f"\nModel saved to:")
print(MODEL_PATH)

print("\nTraining complete.")