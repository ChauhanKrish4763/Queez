"""
Migration script to add questionCount field to existing quizzes.
This should be run once to update all existing quiz documents in MongoDB.
"""

import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
from pymongo import UpdateOne

# MongoDB connection
MONGO_URI = "mongodb://localhost:27017"
DATABASE_NAME = "quizdb"
COLLECTION_NAME = "quizzes"


async def migrate_question_counts():
    """Add questionCount field to all existing quizzes"""
    client = AsyncIOMotorClient(MONGO_URI)
    db = client[DATABASE_NAME]
    collection = db[COLLECTION_NAME]
    
    print("Starting migration: Adding questionCount to existing quizzes...")
    
    # Find all quizzes that don't have questionCount field
    cursor = collection.find({"questionCount": {"$exists": False}})
    quizzes = await cursor.to_list(length=None)
    
    print(f"Found {len(quizzes)} quizzes without questionCount field")
    
    if not quizzes:
        print("No quizzes to migrate. All quizzes already have questionCount.")
        return
    
    # Prepare bulk update operations
    updates = []
    for quiz in quizzes:
        question_count = len(quiz.get("questions", []))
        updates.append(
            UpdateOne(
                {"_id": quiz["_id"]},
                {"$set": {"questionCount": question_count}}
            )
        )
    
    # Execute bulk update
    if updates:
        result = await collection.bulk_write(updates)
        print(f"✓ Migration complete!")
        print(f"  - Modified: {result.modified_count} documents")
        print(f"  - Matched: {result.matched_count} documents")
    
    client.close()


async def verify_migration():
    """Verify all quizzes have questionCount field"""
    client = AsyncIOMotorClient(MONGO_URI)
    db = client[DATABASE_NAME]
    collection = db[COLLECTION_NAME]
    
    print("\nVerifying migration...")
    
    total_count = await collection.count_documents({})
    with_count = await collection.count_documents({"questionCount": {"$exists": True}})
    without_count = await collection.count_documents({"questionCount": {"$exists": False}})
    
    print(f"  - Total quizzes: {total_count}")
    print(f"  - With questionCount: {with_count}")
    print(f"  - Without questionCount: {without_count}")
    
    if without_count == 0:
        print("✓ All quizzes have questionCount field!")
    else:
        print(f"⚠ Warning: {without_count} quizzes still missing questionCount")
    
    client.close()


async def create_index():
    """Create index on creatorId and createdAt for optimized queries"""
    client = AsyncIOMotorClient(MONGO_URI)
    db = client[DATABASE_NAME]
    collection = db[COLLECTION_NAME]
    
    print("\nCreating database index...")
    
    # Create compound index for optimized sorting
    await collection.create_index([("creatorId", 1), ("createdAt", -1)])
    print("✓ Created index on (creatorId, createdAt)")
    
    client.close()


async def main():
    print("=" * 60)
    print("Quiz Database Migration Script")
    print("=" * 60)
    
    await migrate_question_counts()
    await verify_migration()
    await create_index()
    
    print("\n" + "=" * 60)
    print("Migration completed successfully!")
    print("=" * 60)


if __name__ == "__main__":
    asyncio.run(main())
