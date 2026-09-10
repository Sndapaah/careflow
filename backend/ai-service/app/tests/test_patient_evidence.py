from app.evidence_mapper import EvidenceMapper


mapper = EvidenceMapper()


tests = [
    "I have a fever",

    "I am having difficulty breathing",

    "I have burning pain in my left calf",

    "I have sharp pain in my right chest",

    "I have cramping pain in my stomach",

    "I have pain in my left shoulder",

    "My right knee hurts",
]


print()
print("=" * 70)
print("PATIENT EVIDENCE MAPPING TEST")
print("=" * 70)


for text in tests:
    evidences = mapper.map_patient_text(text)

    print()
    print("INPUT:")
    print(text)

    print("EVIDENCE:")

    if evidences:
        for evidence in evidences:
            print(f"  {evidence}")
    else:
        print("  No evidence mapped")