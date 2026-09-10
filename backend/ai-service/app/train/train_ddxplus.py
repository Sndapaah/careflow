import ast
import json
from pathlib import Path

import joblib
import numpy as np
import pandas as pd
from scipy.sparse import lil_matrix, csr_matrix, hstack
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, top_k_accuracy_score
from sklearn.preprocessing import LabelEncoder


BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data" / "ddxplus"
MODEL_DIR = BASE_DIR / "models"

MODEL_DIR.mkdir(exist_ok=True)

TRAIN_FILE = DATA_DIR / "train" / "release_train_patients"
VALIDATE_FILE = DATA_DIR / "validate" / "release_validate_patients"
TEST_FILE = DATA_DIR / "test" / "release_test_patients"


# ============================================================
# LOAD DATA
# ============================================================

print("Loading DDXPlus dataset...")

train_df = pd.read_csv(TRAIN_FILE)
validate_df = pd.read_csv(VALIDATE_FILE)
test_df = pd.read_csv(TEST_FILE)

print(f"Train: {train_df.shape}")
print(f"Validate: {validate_df.shape}")
print(f"Test: {test_df.shape}")


# ============================================================
# EVIDENCE PARSER
# ============================================================

def parse_evidences(value):
    if not isinstance(value, str):
        return []

    try:
        return ast.literal_eval(value)
    except Exception:
        return []


def normalize_evidence(evidence):
    """
    Converts:

        E_91

    into:

        E_91

    and:

        E_54_@_V_161

    into:

        E_54__V_161
    """

    if "_@_" in evidence:
        evidence_name, evidence_value = evidence.split("_@_", 1)
        return f"{evidence_name}__{evidence_value}"

    return evidence


# ============================================================
# BUILD VOCABULARY
# ============================================================

print("\nBuilding evidence vocabulary...")

evidence_features = set()

for value in train_df["EVIDENCES"]:
    for evidence in parse_evidences(value):
        evidence_features.add(
            normalize_evidence(evidence)
        )

evidence_features = sorted(evidence_features)

print(f"Evidence features: {len(evidence_features)}")


# ============================================================
# FEATURE INDEX
# ============================================================

feature_names = [
    "AGE",
    "SEX_M",
    "SEX_F",
] + evidence_features

feature_index = {
    name: index
    for index, name in enumerate(feature_names)
}

print(f"Total features: {len(feature_names)}")


# ============================================================
# SPARSE FEATURE ENCODING
# ============================================================

def transform_dataframe(df, batch_size=50_000):

    number_of_rows = len(df)
    number_of_features = len(feature_names)

    batches = []

    for start in range(0, number_of_rows, batch_size):

        end = min(
            start + batch_size,
            number_of_rows
        )

        batch = df.iloc[start:end]

        matrix = lil_matrix(
            (len(batch), number_of_features),
            dtype=np.float32
        )

        # --------------------------------------------
        # AGE
        # --------------------------------------------

        ages = pd.to_numeric(
            batch["AGE"],
            errors="coerce"
        ).fillna(0).to_numpy()

        matrix[:, feature_index["AGE"]] = ages.reshape(-1, 1)


        # --------------------------------------------
        # SEX
        # --------------------------------------------

        for row, sex in enumerate(batch["SEX"].values):

            sex = str(sex).upper()

            if sex == "M":
                matrix[
                    row,
                    feature_index["SEX_M"]
                ] = 1

            elif sex == "F":
                matrix[
                    row,
                    feature_index["SEX_F"]
                ] = 1


        # --------------------------------------------
        # EVIDENCES
        # --------------------------------------------

        for row, value in enumerate(
            batch["EVIDENCES"].values
        ):

            for evidence in parse_evidences(value):

                feature = normalize_evidence(evidence)

                index = feature_index.get(feature)

                if index is not None:
                    matrix[row, index] = 1


        batches.append(
            matrix.tocsr()
        )

        print(
            f"Encoded {end:,} / "
            f"{number_of_rows:,} records"
        )

    return csr_matrix(
        __import__("scipy").sparse.vstack(batches)
    )


# ============================================================
# ENCODE
# ============================================================

print("\nEncoding training data...")

X_train = transform_dataframe(train_df)

print(
    "Training matrix:",
    X_train.shape,
    "non-zero:",
    X_train.nnz
)


print("\nEncoding validation data...")

X_validate = transform_dataframe(validate_df)

print(
    "Validation matrix:",
    X_validate.shape,
    "non-zero:",
    X_validate.nnz
)


print("\nEncoding test data...")

X_test = transform_dataframe(test_df)

print(
    "Test matrix:",
    X_test.shape,
    "non-zero:",
    X_test.nnz
)


# ============================================================
# TARGET ENCODING
# ============================================================

print("\nEncoding disease labels...")

label_encoder = LabelEncoder()

y_train = label_encoder.fit_transform(
    train_df["PATHOLOGY"]
)

y_validate = label_encoder.transform(
    validate_df["PATHOLOGY"]
)

y_test = label_encoder.transform(
    test_df["PATHOLOGY"]
)

print(
    "Number of diseases:",
    len(label_encoder.classes_)
)


# ============================================================
# TRAIN RANDOM FOREST
# ============================================================

print("\nTraining Random Forest...")

model = RandomForestClassifier(
    n_estimators=200,
    max_depth=None,
    min_samples_leaf=2,
    class_weight="balanced_subsample",
    n_jobs=-1,
    random_state=42
)

model.fit(
    X_train,
    y_train
)


# ============================================================
# VALIDATION
# ============================================================

print("\nEvaluating validation set...")

validation_predictions = model.predict(
    X_validate
)

validation_accuracy = accuracy_score(
    y_validate,
    validation_predictions
)

print(
    f"Validation Accuracy: "
    f"{validation_accuracy:.4f}"
)


# ============================================================
# TEST
# ============================================================

print("\nEvaluating test set...")

test_predictions = model.predict(
    X_test
)

test_accuracy = accuracy_score(
    y_test,
    test_predictions
)

print(
    f"Test Accuracy: "
    f"{test_accuracy:.4f}"
)


# ============================================================
# TOP-5
# ============================================================

print("\nCalculating Top-5 accuracy...")

test_probabilities = model.predict_proba(
    X_test
)

top5_accuracy = top_k_accuracy_score(
    y_test,
    test_probabilities,
    k=5,
    labels=np.arange(
        len(label_encoder.classes_)
    )
)

print(
    f"Top-5 Test Accuracy: "
    f"{top5_accuracy:.4f}"
)


# ============================================================
# CLASSIFICATION REPORT
# ============================================================

print("\nClassification Report:")

print(
    classification_report(
        y_test,
        test_predictions,
        target_names=label_encoder.classes_,
        zero_division=0
    )
)


# ============================================================
# SAVE
# ============================================================

model_path = (
    MODEL_DIR /
    "ddxplus_disease_model.joblib"
)

print("\nSaving model...")

joblib.dump(
    {
        "model": model,
        "label_encoder": label_encoder,
        "feature_names": feature_names,
        "feature_index": feature_index,
    },
    model_path
)

print("\nModel saved to:")
print(model_path)

print("\nTraining complete.")







































# import ast
# import json
# from pathlib import Path

# import pandas as pd
# from sklearn.ensemble import RandomForestClassifier
# from sklearn.metrics import accuracy_score, classification_report, top_k_accuracy_score
# from sklearn.preprocessing import LabelEncoder
# import joblib


# BASE_DIR = Path(__file__).resolve().parent.parent

# DATA_DIR = BASE_DIR / "data" / "ddxplus"
# MODEL_DIR = BASE_DIR / "models"

# MODEL_DIR.mkdir(exist_ok=True)


# TRAIN_FILE = DATA_DIR / "train" / "release_train_patients"
# VALIDATE_FILE = DATA_DIR / "validate" / "release_validate_patients"
# TEST_FILE = DATA_DIR / "test" / "release_test_patients"


# # ============================================================
# # LOAD DATA
# # ============================================================

# print("Loading DDXPlus dataset...")

# train_df = pd.read_csv(TRAIN_FILE)
# validate_df = pd.read_csv(VALIDATE_FILE)
# test_df = pd.read_csv(TEST_FILE)

# print("Train:", train_df.shape)
# print("Validate:", validate_df.shape)
# print("Test:", test_df.shape)


# # ============================================================
# # LOAD EVIDENCE DEFINITIONS
# # ============================================================

# with open(
#     DATA_DIR / "release_evidences.json",
#     "r",
#     encoding="utf-8"
# ) as f:
#     evidences = json.load(f)

# print("Evidence definitions:", len(evidences))


# # ============================================================
# # CREATE EVIDENCE FEATURE LIST
# # ============================================================

# evidence_features = set()


# def extract_evidence_features(value):
#     """
#     Convert:

#         E_91

#     or:

#         E_54_@_V_161

#     into a feature name.
#     """

#     if not isinstance(value, str):
#         return []

#     try:
#         items = ast.literal_eval(value)
#     except Exception:
#         return []

#     features = []

#     for item in items:

#         if "_@_" in item:

#             evidence, evidence_value = item.split("_@_", 1)

#             # Keep value-specific evidence as its own feature.
#             features.append(f"{evidence}__{evidence_value}")

#         else:

#             features.append(item)

#     return features


# # Collect all possible features from training data

# print("Building evidence vocabulary...")

# for value in train_df["EVIDENCES"]:

#     features = extract_evidence_features(value)

#     evidence_features.update(features)


# evidence_features = sorted(evidence_features)

# print("Evidence features:", len(evidence_features))


# # ============================================================
# # FEATURE ENCODING
# # ============================================================

# feature_names = [
#     "AGE",
#     "SEX_M",
#     "SEX_F",
# ] + evidence_features


# def transform_dataframe(df):

#     X = pd.DataFrame(
#         0,
#         index=range(len(df)),
#         columns=feature_names,
#         dtype="float32"
#     )

#     # Age
#     X["AGE"] = pd.to_numeric(
#         df["AGE"],
#         errors="coerce"
#     ).fillna(0)

#     # Sex
#     X.loc[df["SEX"].values == "M", "SEX_M"] = 1
#     X.loc[df["SEX"].values == "F", "SEX_F"] = 1

#     # Evidence
#     for row_index, value in enumerate(df["EVIDENCES"]):

#         features = extract_evidence_features(value)

#         for feature in features:

#             if feature in X.columns:
#                 X.loc[row_index, feature] = 1

#     return X


# print("Encoding training data...")

# X_train = transform_dataframe(train_df)

# print("Encoding validation data...")

# X_validate = transform_dataframe(validate_df)

# print("Encoding test data...")

# X_test = transform_dataframe(test_df)


# # ============================================================
# # TARGET
# # ============================================================

# label_encoder = LabelEncoder()

# y_train = label_encoder.fit_transform(
#     train_df["PATHOLOGY"]
# )

# y_validate = label_encoder.transform(
#     validate_df["PATHOLOGY"]
# )

# y_test = label_encoder.transform(
#     test_df["PATHOLOGY"]
# )


# print("Number of diseases:", len(label_encoder.classes_))


# # ============================================================
# # TRAIN
# # ============================================================

# print("\nTraining Random Forest...")

# model = RandomForestClassifier(
#     n_estimators=300,
#     max_depth=None,
#     min_samples_leaf=2,
#     class_weight="balanced",
#     n_jobs=-1,
#     random_state=42
# )

# model.fit(X_train, y_train)


# # ============================================================
# # VALIDATION
# # ============================================================

# print("\nEvaluating validation set...")

# validation_predictions = model.predict(X_validate)

# validation_accuracy = accuracy_score(
#     y_validate,
#     validation_predictions
# )

# print(
#     f"Validation Accuracy: "
#     f"{validation_accuracy:.4f}"
# )


# # ============================================================
# # TEST
# # ============================================================

# print("\nEvaluating test set...")

# test_predictions = model.predict(X_test)

# test_accuracy = accuracy_score(
#     y_test,
#     test_predictions
# )

# print(
#     f"Test Accuracy: "
#     f"{test_accuracy:.4f}"
# )


# # ============================================================
# # TOP-5 ACCURACY
# # ============================================================

# test_probabilities = model.predict_proba(X_test)

# top5_accuracy = top_k_accuracy_score(
#     y_test,
#     test_probabilities,
#     k=5,
#     labels=range(len(label_encoder.classes_))
# )

# print(
#     f"Top-5 Test Accuracy: "
#     f"{top5_accuracy:.4f}"
# )


# # ============================================================
# # CLASSIFICATION REPORT
# # ============================================================

# print("\nClassification Report:")

# print(
#     classification_report(
#         y_test,
#         test_predictions,
#         target_names=label_encoder.classes_,
#         zero_division=0
#     )
# )


# # ============================================================
# # SAVE MODEL
# # ============================================================

# model_path = MODEL_DIR / "ddxplus_disease_model.joblib"

# joblib.dump(
#     {
#         "model": model,
#         "label_encoder": label_encoder,
#         "feature_names": feature_names,
#     },
#     model_path
# )


# print("\nModel saved to:")
# print(model_path)

# print("\nTraining complete.")