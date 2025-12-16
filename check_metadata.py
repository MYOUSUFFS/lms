#!/usr/bin/env python3
"""Check ChromaDB metadata for classroom_id"""

import chromadb
from chromadb.config import Settings

client = chromadb.PersistentClient(
    path="data/chroma_db",
    settings=Settings(anonymized_telemetry=False)
)

collection = client.get_collection("lms_documents")

# Get chunks for the specific document
doc_id = "fb9361eb-9b72-4d0c-9649-2f784137474a"
results = collection.get(
    where={"document_id": doc_id},
    include=["metadatas"]
)

print(f"Checking document: {doc_id}")
print(f"Found {len(results['metadatas']) if results and results['metadatas'] else 0} chunks")
print()

if results and results["metadatas"]:
    for i, metadata in enumerate(results["metadatas"]):
        print(f"Chunk {i}:")
        print(f"  classroom_id: {metadata.get('classroom_id')}")
        print(f"  filename: {metadata.get('filename')}")
        print(f"  All keys: {list(metadata.keys())}")
        print()
else:
    print("No chunks found for this document")
