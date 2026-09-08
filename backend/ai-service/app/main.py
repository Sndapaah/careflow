from fastapi import FastAPI
import json
from pydantic import BaseModel, Field
from typing import List, Optional

# from app.medical_model import ask_medgemma
from app.medical_model import ask_ai
from app.safety import evaluate_safety
from app.evidence_mapper import EvidenceMapper
from app.ddxplus_predictor import DDXPlusPredictor


app = FastAPI(
    title="CareFlow AI Service",
    description="AI-powered medical decision support service",
    version="1.0.0"
)


evidence_mapper = EvidenceMapper()
ddxplus_predictor = DDXPlusPredictor()


class Symptom(BaseModel):
    name: str
    severity: Optional[str] = None
    duration: Optional[str] = None


class PatientRequest(BaseModel):
    age: int
    sex: str

    latitude: float
    longitude: float

    symptoms: List[Symptom] = Field(default_factory=list)

    existing_conditions: List[str] = Field(default_factory=list)
    allergies: List[str] = Field(default_factory=list)
    medications: List[str] = Field(default_factory=list)

    additional_information: Optional[str] = None


@app.get("/")
def root():
    return {
        "message": "CareFlow AI Service is running",
        "status": "healthy"
    }


@app.post("/analyze")
def analyze_patient(patient: PatientRequest):

    symptoms_text = "\n".join(
        f"- {s.name}"
        f"{f' | severity: {s.severity}' if s.severity else ''}"
        f"{f' | duration: {s.duration}' if s.duration else ''}"
        for s in patient.symptoms
    )

    conditions_text = (
        ", ".join(patient.existing_conditions)
        if patient.existing_conditions
        else "None reported"
    )

    allergies_text = (
        ", ".join(patient.allergies)
        if patient.allergies
        else "None reported"
    )

    medications_text = (
        ", ".join(patient.medications)
        if patient.medications
        else "None reported"
    )

    additional_info = (
        patient.additional_information
        if patient.additional_information
        else "None provided"
    )

    symptom_names = [
        symptom.name
        for symptom in patient.symptoms
    ]


    ddxplus_evidences = evidence_mapper.map_symptoms(
        symptom_names
    )

    safety = evaluate_safety(symptom_names + [f"allergy: {allergy}" for allergy in patient.allergies])

    ddxplus_predictions = ddxplus_predictor.predict(
        age=patient.age,
        sex=patient.sex,
        evidences=ddxplus_evidences,
        top_k=5
    )

    prompt = f"""
        You are CareFlow AI.

        Return ONLY valid JSON.

        Patient Information:

        Age: {patient.age}
        Sex: {patient.sex}

        Symptoms:
        {symptoms_text}

        Existing Conditions:
        {conditions_text}

        Allergies:
        {allergies_text}

        Current Medications:
        {medications_text}

        Additional Information:
        {additional_info}

        DDXPlus Top Candidate Conditions:
        {json.dumps(ddxplus_predictions, indent=2)}

        These are machine-learning predictions generated from the patient's symptoms.

        They are NOT confirmed diagnoses.

        Use them only if they are clinically consistent with the patient's presentation.

        You may reject predictions that do not fit the symptoms.

        You may introduce better conditions if they better explain the patient's symptoms.
        If one of your possible conditions matches one of these diseases,
        reuse its probability instead of inventing one.

        Only invent a probability if the condition is NOT present in the ML predictions.

        Do not change the ML probabilities.
        
        Determine which medical specialties are most appropriate for the patient's presentation.

        Examples:
        - Chest pain → Cardiology, Emergency
        - Stroke symptoms → Neurology, Emergency
        - Fracture → Orthopedics
        - Pregnancy → Obstetrics & Gynecology
        - Skin rash → Dermatology
        - Eye problems → Ophthalmology

        Safety Assessment:
        {json.dumps(safety, indent=2)}

        Return EXACTLY this JSON:
        For every possible condition:

        - Use the DDXPlus probability whenever the disease exists in the ML predictions.
        - Otherwise estimate a probability based on the clinical presentation.
        - Sort conditions from highest probability to lowest.

        {{
        "possible_conditions":[
            {{
            "name":"",
            "probability":0,
            "severity":"",
            "reason":""
            }}
        ],
        "risk_score":0,
        "severity": {{
            "level": "",
            "reason": ""
        }},
        Always return this object.

        Never leave it empty.

        The level must be one of:

        Low
        Moderate
        High
        Critical
        
        "recommendations": [
            ""
        ]
        }}

        Rules:
        - Only JSON.
        - No markdown.
        - No explanations.
        - Never diagnose with certainty.
        - Never prescribe medication.
        Assign a risk_score from 0 to 100.

        Guide:

        0-20 = Very Low

        21-40 = Low

        41-60 = Moderate

        61-80 = High

        81-100 = Critical

        The score should consider:

        - symptoms
        - severity
        - duration
        - DDXPlus predictions
        - safety assessment
        - existing conditions
        - age
    """


    # --------------------------------------------------------
    # Gemini AI ANALYSIS
    # --------------------------------------------------------

    try:
        analysis = ask_ai(prompt)
    except Exception as error:
        # DDXPlus and the safety rules are local and remain useful when the
        # optional generative provider is unavailable or exceeds its timeout.
        print(f"Gemini analysis unavailable, using local fallback: {error}")
        analysis = {
            "possible_conditions": [
                {
                    "name": prediction["disease"],
                    "probability": prediction["probability"],
                    "severity": prediction.get("severity", "Unknown"),
                    "reason": "Matched by the local symptom model.",
                }
                for prediction in ddxplus_predictions
            ],
            "risk_score": round(
                max(
                    [prediction["probability"] for prediction in ddxplus_predictions]
                    or [0]
                )
                * 100
            ),
            "severity": {
                "level": "High" if safety["urgency"] == "emergency" else "Low",
                "reason": safety.get("reason") or "No emergency red flags matched.",
            },
            "recommendations": [
                "Seek medical assessment if symptoms persist or worsen."
            ],
        }

    if isinstance(analysis, str):

        try:
            analysis = json.loads(analysis)

        except Exception:

            analysis = None

    # Never present an empty or malformed diagnosis. The local DDXPlus model
    # is deterministic and provides a useful result when Gemini is unavailable
    # or returns a schema we cannot safely consume.
    if not isinstance(analysis, dict) or not isinstance(
        analysis.get("possible_conditions"), list
    ) or not analysis.get("possible_conditions"):
        analysis = {
            "possible_conditions": [
                {
                    "name": prediction["disease"],
                    "probability": prediction["probability"],
                    "severity": prediction.get("severity", "Unknown"),
                    "reason": "Matched by the local symptom model.",
                }
                for prediction in ddxplus_predictions
            ],
            "risk_score": round(
                max(
                    [prediction["probability"] for prediction in ddxplus_predictions]
                    or [0]
                ) * 100
            ),
            "severity": {
                "level": "High" if safety["urgency"] == "emergency" else "Low",
                "reason": safety.get("reason") or "No emergency red flags matched.",
            },
            "recommendations": [
                "Seek medical assessment if symptoms persist or worsen."
            ],
        }

    # --------------------------------------------------------
    # FINAL RESPONSE
    # --------------------------------------------------------

    return {

        "status": "success",

        "patient": {
            "age": patient.age,
            "sex": patient.sex,
            "symptoms": [
                symptom.model_dump()
                for symptom in patient.symptoms
            ],
            "existing_conditions": patient.existing_conditions,
            "allergies": patient.allergies,
            "medications": patient.medications,
            "additional_information": patient.additional_information,
            "latitude": patient.latitude,
            "longitude": patient.longitude,
        },

        "possible_conditions": analysis.get("possible_conditions", []),

        "risk_score": analysis.get("risk_score", 0),
        "severity": analysis.get("severity", {}),

        "recommendations": analysis.get("recommendations", []),
        # "required_specialties": analysis.get("required_specialties", []),

        "ddxplus": {
            "evidences": ddxplus_evidences,
            "predictions": ddxplus_predictions
        },

        "safety": safety
    }
