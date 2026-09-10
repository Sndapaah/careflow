import re
from typing import List, Dict


EMERGENCY_SYMPTOMS = {
    "difficulty breathing",
    "severe difficulty breathing",
    "chest pain",
    "severe chest pain",
    "loss of consciousness",
    "unconsciousness",
    "seizure",
    "convulsion",
    "severe bleeding",
    "vomiting blood",
    "coughing blood",
    "blood in vomit",
    "sudden weakness",
    "sudden paralysis",
    "severe confusion",
    "confusion",
    "blue lips",
    "blue skin",
}


URGENT_SYMPTOMS = {
    "persistent vomiting",
    "severe dehydration",
    "very high fever",
    "severe headache",
    "neck stiffness",
    "fainting",
    "blood in stool",
    "severe abdominal pain",
}


def normalize(text: str) -> str:
    text = text.strip().lower()
    text = re.sub(r"\s+", " ", text)
    return text

def evaluate_safety(symptoms: List[str]) -> Dict:

    normalized_symptoms = {
        normalize(symptom)
        for symptom in symptoms
    }

    allergy_emergency = any(
        any(term in symptom for term in (
            "anaphylaxis", "anaphylactic", "severe allergic", "allergic reaction",
            "swelling of lips", "swelling of tongue", "throat swelling",
        ))
        for symptom in normalized_symptoms
    )

    emergency_matches = sorted(
        normalized_symptoms.intersection(EMERGENCY_SYMPTOMS)
    )

    urgent_matches = sorted(
        normalized_symptoms.intersection(URGENT_SYMPTOMS)
    )

    if emergency_matches or allergy_emergency:

        return {
            "urgency": "emergency",
            "hospital_recommended": True,
            "reason": "Potential emergency warning signs were identified.",
            "matched_red_flags": sorted(set(emergency_matches + (["allergic reaction"] if allergy_emergency else [])))
        }

    if urgent_matches:

        return {
            "urgency": "urgent",
            "hospital_recommended": True,
            "reason": "Symptoms may require prompt medical assessment.",
            "matched_red_flags": urgent_matches
        }

    return {
        "urgency": "routine",
        "hospital_recommended": False,
        "reason": None,
        "matched_red_flags": []
    }
# def evaluate_safety(symptoms: List[Dict]) -> Dict:

#     emergency_matches = []
#     urgent_matches = []

#     for symptom in symptoms:

#         name = normalize(
#             symptom.get("name", "")
#         )

#         severity = normalize(
#             symptom.get("severity", "")
#             or ""
#         )

#         # -----------------------------------------
#         # Emergency symptom matching
#         # -----------------------------------------

#         if name in EMERGENCY_SYMPTOMS:
#             emergency_matches.append(name)

#         # Severe version of an emergency symptom
#         elif (
#             severity == "severe"
#             and name in {
#                 "chest pain",
#                 "difficulty breathing",
#                 "abdominal pain",
#                 "headache",
#             }
#         ):
#             emergency_matches.append(
#                 f"severe {name}"
#             )

#         # -----------------------------------------
#         # Urgent symptoms
#         # -----------------------------------------

#         if name in URGENT_SYMPTOMS:
#             urgent_matches.append(name)

#     emergency_matches = sorted(
#         set(emergency_matches)
#     )

#     urgent_matches = sorted(
#         set(urgent_matches)
#     )

#     if emergency_matches:

#         return {
#             "urgency": "emergency",
#             "hospital_recommended": True,
#             "reason": (
#                 "Potential emergency warning signs "
#                 "were identified."
#             ),
#             "matched_red_flags": emergency_matches
#         }

#     if urgent_matches:

#         return {
#             "urgency": "urgent",
#             "hospital_recommended": True,
#             "reason": (
#                 "Symptoms may require prompt "
#                 "medical assessment."
#             ),
#             "matched_red_flags": urgent_matches
#         }

#     return {
#         "urgency": "routine",
#         "hospital_recommended": False,
#         "reason": None,
#         "matched_red_flags": []
#     }





























# from typing import List, Dict


# # These are initial safety rules.
# # We will expand and validate them later.

# EMERGENCY_SYMPTOMS = {
#     "difficulty breathing",
#     "severe difficulty breathing",
#     "chest pain",
#     "severe chest pain",
#     "loss of consciousness",
#     "unconsciousness",
#     "seizure",
#     "convulsion",
#     "severe bleeding",
#     "vomiting blood",
#     "coughing blood",
#     "blood in vomit",
#     "sudden weakness",
#     "sudden paralysis",
#     "severe confusion",
#     "confusion",
#     "blue lips",
#     "blue skin",
# }


# URGENT_SYMPTOMS = {
#     "persistent vomiting",
#     "severe dehydration",
#     "very high fever",
#     "severe headache",
#     "neck stiffness",
#     "fainting",
#     "blood in stool",
#     "severe abdominal pain",
# }


# def normalize(text: str) -> str:
#     return text.strip().lower()


# def evaluate_safety(symptoms: List[str]) -> Dict:

#     normalized_symptoms = {
#         normalize(symptom)
#         for symptom in symptoms
#     }

#     emergency_matches = sorted(
#         normalized_symptoms.intersection(EMERGENCY_SYMPTOMS)
#     )

#     urgent_matches = sorted(
#         normalized_symptoms.intersection(URGENT_SYMPTOMS)
#     )

#     if emergency_matches:

#         return {
#             "urgency": "emergency",
#             "hospital_recommended": True,
#             "reason": "Potential emergency warning signs were identified.",
#             "matched_red_flags": emergency_matches
#         }

#     if urgent_matches:

#         return {
#             "urgency": "urgent",
#             "hospital_recommended": True,
#             "reason": "Symptoms may require prompt medical assessment.",
#             "matched_red_flags": urgent_matches
#         }

#     return {
#         "urgency": "routine",
#         "hospital_recommended": False,
#         "reason": None,
#         "matched_red_flags": []
#     }
