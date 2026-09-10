from pathlib import Path
import ast
import joblib
import numpy as np
from scipy.sparse import lil_matrix


BASE_DIR = Path(__file__).resolve().parent.parent
MODEL_PATH = BASE_DIR / "models" / "ddxplus_disease_model.joblib"


class DDXPlusPredictor:

    def __init__(self):
        print(f"Loading DDXPlus model from: {MODEL_PATH}")

        bundle = joblib.load(MODEL_PATH)

        self.model = bundle["model"]
        self.label_encoder = bundle["label_encoder"]
        self.feature_names = bundle["feature_names"]
        self.feature_index = bundle["feature_index"]

        print("DDXPlus model loaded successfully.")
        print(f"Features: {len(self.feature_names)}")
        print(f"Diseases: {len(self.label_encoder.classes_)}")

    # --------------------------------------------------------
    # EVIDENCE NORMALIZATION
    # --------------------------------------------------------

    def normalize_evidence(self, evidence):
        if "_@_" in evidence:
            evidence_name, evidence_value = evidence.split(
                "_@_", 1
            )

            return f"{evidence_name}__{evidence_value}"

        return evidence

    # --------------------------------------------------------
    # BUILD FEATURE MATRIX
    # --------------------------------------------------------

    def encode_patient(
        self,
        age,
        sex,
        evidences
    ):

        matrix = lil_matrix(
            (1, len(self.feature_names)),
            dtype=np.float32
        )

        # AGE
        age_index = self.feature_index.get("AGE")

        if age_index is not None:
            matrix[0, age_index] = float(age)

        # SEX
        sex = str(sex).upper()

        if sex == "M":
            index = self.feature_index.get("SEX_M")

            if index is not None:
                matrix[0, index] = 1

        elif sex == "F":
            index = self.feature_index.get("SEX_F")

            if index is not None:
                matrix[0, index] = 1

        # EVIDENCES
        for evidence in evidences:

            feature = self.normalize_evidence(evidence)

            index = self.feature_index.get(feature)

            if index is not None:
                matrix[0, index] = 1

        return matrix.tocsr()

    # --------------------------------------------------------
    # PREDICT
    # --------------------------------------------------------

    def predict(
        self,
        age,
        sex,
        evidences,
        top_k=5
    ):

        X = self.encode_patient(
            age=age,
            sex=sex,
            evidences=evidences
        )

        probabilities = self.model.predict_proba(X)[0]

        top_indices = np.argsort(
            probabilities
        )[::-1][:top_k]

        predictions = []

        for index in top_indices:

            disease_id = self.model.classes_[index]

            disease_name = self.label_encoder.inverse_transform(
                [disease_id]
            )[0]

            severity = "Low"

            if probabilities[index] >= 0.70:
                severity = "High"
            elif probabilities[index] >= 0.40:
                severity = "Moderate"

            predictions.append({
                "disease": disease_name,
                "probability": round(float(probabilities[index]), 4),
                "confidence": round(float(probabilities[index]) * 100, 1),
                "severity": severity
            })

        predictions.sort(
            key=lambda x: x["confidence"],
            reverse=True
        )
        
        return predictions
        