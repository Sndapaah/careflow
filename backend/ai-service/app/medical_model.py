import os
import json

from dotenv import load_dotenv
from google import genai

load_dotenv()

client = genai.Client(
    api_key=os.getenv("GEMINI_API_KEY")
)


SYSTEM_PROMPT = """
You are CareFlow AI.

Return ONLY valid JSON.

Do not wrap the JSON inside markdown.

The JSON MUST have this exact structure:

{
  "possible_conditions": [
    {
      "condition": "",
      "probability": 0,
      "severity": "",
      "reason": ""
    }
  ],
  "missing_information": [],
  "warning_signs": [],
  "recommended_tests": [],
  "recommendations": []
}

Rules:

- probability must be between 0 and 1
- severity must be Low, Moderate or High
- Never diagnose with certainty.
- Never prescribe medication.
- Never output explanations outside the JSON.
"""


def ask_ai(prompt: str):

    response = client.models.generate_content(
        model="gemini-3.5-flash",
        contents=f"{SYSTEM_PROMPT}\n\n{prompt}",
    )

    text = response.text.strip()

    # Remove markdown if Gemini adds it
    text = text.replace("```json", "").replace("```", "").strip()

    return json.loads(text)



















# import os
# import json

# from dotenv import load_dotenv
# from google import genai
# from google.genai import types

# load_dotenv()

# client = genai.Client(
#   api_key=os.getenv("GEMINI_API_KEY"),
#   # http_options=types.HttpOptions(timeout=12000),
#   http_options=types.HttpOptions(timeout=45000),
# )

# MODEL_NAME = os.getenv("GEMINI_MODEL", "gemini-3.6-flash")


# SYSTEM_PROMPT = """
# You are CareFlow AI.

# Return ONLY valid JSON.

# Do not wrap the JSON inside markdown.

# The JSON MUST have this exact structure:

# {
#   "possible_conditions": [
#     {
#       "condition": "",
#       "probability": 0,
#       "severity": "",
#       "reason": ""
#     }
#   ],
#   "missing_information": [],
#   "warning_signs": [],
#   "recommended_tests": [],
#   "recommendations": []
# }

# Rules:

# - probability must be between 0 and 1
# - severity must be Low, Moderate or High
# - Never diagnose with certainty.
# - Never prescribe medication.
# - Never output explanations outside the JSON.
# """


# def ask_ai(prompt: str):

#     if not os.getenv("GEMINI_API_KEY"):
#         raise RuntimeError("GEMINI_API_KEY is not configured")

#     response = client.models.generate_content(
#       model=MODEL_NAME,
#       contents=f"{SYSTEM_PROMPT}\n\n{prompt}",
#       config=types.GenerateContentConfig(
#           response_mime_type="application/json",
#           temperature=0.2,
#       ),
#     )

#     text = response.text.strip()

#     # Remove markdown if Gemini adds it
#     text = text.replace("```json", "").replace("```", "").strip()

#     parsed = json.loads(text)
#     if not isinstance(parsed, dict):
#         raise ValueError("Gemini returned a non-object response")
#     return parsed
