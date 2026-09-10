from evidence_mapper import EvidenceMapper


mapper = EvidenceMapper()


print("\n======================================")
print("EVIDENCE MAPPER TEST")
print("======================================")

searches = [
    "fever",
    "pain",
    "breathing",
]


for search in searches:

    print(f"\nSearch: {search}")

    results = mapper.search(search)

    if not results:
        print("No matches found.")
        continue

    for result in results[:10]:

        print(
            f"{result['evidence']} -> "
            f"{result['question']}"
        )