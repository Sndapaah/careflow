from medical_model import ask_medgemma


prompt = """
You are a medical decision-support AI.

A 25-year-old male reports:
- Fever for 3 days
- Headache for 2 days
- General weakness

There are currently no known allergies, medications, or existing medical conditions.

Explain:
1. Possible causes that should be considered.
2. Important additional information that should be collected.
3. Warning signs that require urgent medical attention.
4. Appropriate next steps.

Do not claim that the patient definitely has any disease.
Do not prescribe medication.
"""


print("\nSending request to MedGemma...\n")

response = ask_medgemma(prompt)

print("===== MEDGEMMA RESPONSE =====")
print(response)