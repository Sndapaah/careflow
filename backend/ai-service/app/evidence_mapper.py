import json
import re
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
EVIDENCE_FILE = BASE_DIR / "data" / "ddxplus" / "release_evidences.json"


class EvidenceMapper:

    def __init__(self):
        print(f"Loading evidence definitions from: {EVIDENCE_FILE}")

        with open(EVIDENCE_FILE, "r", encoding="utf-8") as f:
            self.evidences = json.load(f)

        print(f"Loaded {len(self.evidences)} evidence definitions.")

        self.questions = {}

        for key, evidence in self.evidences.items():
            question = evidence.get("question_en")

            if question:
                self.questions[key] = question.lower()

    # ---------------------------------------------------------
    # NORMALIZE
    # ---------------------------------------------------------

    def normalize(self, text):

        text = text.lower()

        text = re.sub(r"[^\w\s]", " ", text)

        text = re.sub(r"\s+", " ", text)

        return text.strip()

    # ---------------------------------------------------------
    # BASIC SEARCH
    # ---------------------------------------------------------

    def search(self, text):

        text = self.normalize(text)

        results = []

        for key, question in self.questions.items():

            if text in question:

                results.append({
                    "evidence": key,
                    "question": question
                })

        return results

    # ---------------------------------------------------------
    # MAP TEXT
    # ---------------------------------------------------------

    def map_text(self, text):

        text = self.normalize(text)

        evidences = []

        # -----------------------------------------------------
        # SYNONYMS
        # -----------------------------------------------------

        synonyms = {

            "shortness of breath": [
                "difficulty breathing",
                "breathlessness",
                "cannot breathe",
                "can't breathe",
                "hard to breathe"
            ],

            "fever": [
                "high temperature",
                "temperature",
                "feverish"
            ],

            "headache": [
                "head pain",
                "pain in head",
                "migraine"
            ],

            "leg pain": [
                "calf pain",
                "pain in calf",
                "leg hurts",
                "aching leg"
            ],

            "chest pain": [
                "pain in chest",
                "tight chest",
                "chest hurts"
            ],

            "abdominal pain": [
                "stomach pain",
                "belly pain",
                "pain in stomach",
                "pain in abdomen"
            ]
        }

        for canonical, words in synonyms.items():

            for word in words:

                if word in text:
                    text += " " + canonical
                    break

        # -----------------------------------------------------
        # FEVER
        # -----------------------------------------------------

        if "fever" in text:
            evidences.append("E_91")

        # The DDXPlus evidence set models cough explicitly. Without this
        # mapping a request containing only "cough" produces no evidence and
        # the classifier falls back to an essentially unconditioned ranking.
        if "cough" in text:
            evidences.append("E_201")

        # -----------------------------------------------------
        # BREATHING
        # -----------------------------------------------------

        if "shortness of breath" in text:
            evidences.append("E_66")

        # -----------------------------------------------------
        # PAIN
        # -----------------------------------------------------

        pain_words = [

            "pain",
            "hurt",
            "hurts",
            "ache",
            "aching",
            "burning",
            "cramp",
            "cramping",
            "sharp",
            "stabbing",
            "throbbing",
            "pressure",
            "sore",
            "tender"

        ]

        has_pain = any(word in text for word in pain_words)

        if has_pain:

            pain_character = {

                "burning": "E_54_@_V_181",
                "sharp": "E_54_@_V_192",
                "cramping": "E_54_@_V_182",
                "cramp": "E_54_@_V_182",
                "heavy": "E_54_@_V_183",
                "pressure": "E_54_@_V_183",
                "tugging": "E_54_@_V_180",
                "throbbing": "E_54_@_V_180"

            }

            for word, evidence in pain_character.items():

                if word in text:
                    evidences.append(evidence)

            locations = {

                "left calf": "E_55_@_V_120",
                "right calf": "E_55_@_V_119",

                "calf": "E_55_@_V_120",
                "lower leg": "E_55_@_V_120",
                "leg": "E_55_@_V_120",

                "left foot": "E_55_@_V_73",
                "right foot": "E_55_@_V_72",
                "foot": "E_55_@_V_73",

                "left knee": "E_55_@_V_93",
                "right knee": "E_55_@_V_92",
                "knee": "E_55_@_V_93",

                "left shoulder": "E_55_@_V_195",
                "right shoulder": "E_55_@_V_194",
                "shoulder": "E_55_@_V_195",

                "left chest": "E_55_@_V_56",
                "right chest": "E_55_@_V_55",
                "chest": "E_55_@_V_29",

                "stomach": "E_55_@_V_187",
                "abdomen": "E_55_@_V_187",
                "belly": "E_55_@_V_187",

                "left hip": "E_55_@_V_100",
                "right hip": "E_55_@_V_99",

                "lower back": "E_55_@_V_40",
                "upper back": "E_55_@_V_39",

                "neck": "E_55_@_V_53",

                "head": "E_55_@_V_89"

            }

            for phrase, evidence in locations.items():

                if phrase in text:
                    evidences.append(evidence)

            evidences.append("E_53")

        # -----------------------------------------------------
        # FALLBACK SEARCH
        # -----------------------------------------------------

        if len(evidences) < 2:

            words = text.split()

            for key, question in self.questions.items():

                score = 0

                for word in words:

                    if len(word) > 3 and word in question:
                        score += 1

                if score >= 2:
                    evidences.append(key)

        return list(dict.fromkeys(evidences))

    # ---------------------------------------------------------
    # COMPATIBILITY
    # ---------------------------------------------------------

    def map_patient_text(self, text):

        return self.map_text(text)

    # ---------------------------------------------------------
    # MULTIPLE SYMPTOMS
    # ---------------------------------------------------------

    def map_symptoms(self, symptoms):

        all_evidences = []

        for symptom in symptoms:

            if isinstance(symptom, dict):
                text = symptom.get("name", "")

            elif hasattr(symptom, "name"):
                text = symptom.name

            else:
                text = str(symptom)

            if not text:
                continue

            all_evidences.extend(self.map_text(text))

        return list(dict.fromkeys(all_evidences))
