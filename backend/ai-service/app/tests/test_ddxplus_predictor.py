from app.ddxplus_predictor import DDXPlusPredictor


print("=" * 70)
print("DDXPLUS PREDICTOR TEST")
print("=" * 70)


predictor = DDXPlusPredictor()


tests = [

    {
        "name": "Burning left calf pain",
        "age": 30,
        "sex": "M",
        "evidences": [
            "E_53",
            "E_54_@_V_181",
            "E_55_@_V_120"
        ]
    },

    {
        "name": "Sharp right chest pain",
        "age": 45,
        "sex": "M",
        "evidences": [
            "E_53",
            "E_54_@_V_192",
            "E_55_@_V_55"
        ]
    },

    {
        "name": "Fever and difficulty breathing",
        "age": 25,
        "sex": "F",
        "evidences": [
            "E_91",
            "E_66"
        ]
    }

]


for test in tests:

    print("\n" + "=" * 70)
    print(test["name"])
    print("=" * 70)

    predictions = predictor.predict(
        age=test["age"],
        sex=test["sex"],
        evidences=test["evidences"],
        top_k=5
    )

    for i, prediction in enumerate(predictions, 1):

        print(
            f"{i}. "
            f"{prediction['disease']} "
            f"-> "
            f"{prediction['probability']:.2%}"
        )