from ddxplus_predictor import DDXPlusPredictor


predictor = DDXPlusPredictor()


print("\n========================================")
print("DDXPLUS PREDICTION TEST")
print("========================================")


predictions = predictor.predict(
    age=45,
    sex="M",
    evidences=[
        "E_55_@_V_123"
    ],
    top_k=5
)


print("\nPredictions:")

for prediction in predictions:

    print(
        f"{prediction['disease']}: "
        f"{prediction['probability']:.2%}"
    )