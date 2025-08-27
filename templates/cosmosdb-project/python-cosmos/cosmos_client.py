#!/usr/bin/env python3
"""
Azure CosmosDB Client Example
Demonstrates connection and basic operations with CosmosDB Emulator
"""

import os
import json
from typing import Dict, List, Any, Optional
from azure.cosmos import CosmosClient, PartitionKey, exceptions
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

class CosmosDBClient:
    """Azure CosmosDB client for local development with emulator"""
    
    def __init__(self):
        # CosmosDB Emulator configuration
        self.endpoint = "https://127.0.0.1:8081"
        self.key = "C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw=="
        
        # Initialize client with SSL verification disabled for emulator
        self.client = CosmosClient(
            self.endpoint, 
            self.key,
            connection_verify=False  # Required for emulator
        )
        
        # Default database and container names
        self.database_name = "dev-database"
        self.container_name = "dev-container"
        
        self.database = None
        self.container = None
    
    def create_database_if_not_exists(self) -> None:
        """Create database if it doesn't exist"""
        try:
            self.database = self.client.create_database_if_not_exists(
                id=self.database_name
            )
            print(f"✅ Database '{self.database_name}' ready")
        except exceptions.CosmosHttpResponseError as e:
            print(f"❌ Error creating database: {e}")
            raise
    
    def create_container_if_not_exists(self, partition_key: str = "/id") -> None:
        """Create container if it doesn't exist"""
        try:
            self.container = self.database.create_container_if_not_exists(
                id=self.container_name,
                partition_key=PartitionKey(path=partition_key),
                offer_throughput=400
            )
            print(f"✅ Container '{self.container_name}' ready")
        except exceptions.CosmosHttpResponseError as e:
            print(f"❌ Error creating container: {e}")
            raise
    
    def initialize(self, database_name: str = None, container_name: str = None) -> None:
        """Initialize database and container"""
        if database_name:
            self.database_name = database_name
        if container_name:
            self.container_name = container_name
            
        self.create_database_if_not_exists()
        self.create_container_if_not_exists()
    
    def create_item(self, item: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new item in the container"""
        try:
            response = self.container.create_item(body=item)
            print(f"✅ Item created with id: {response['id']}")
            return response
        except exceptions.CosmosHttpResponseError as e:
            print(f"❌ Error creating item: {e}")
            raise
    
    def read_item(self, item_id: str, partition_key: str) -> Dict[str, Any]:
        """Read an item by ID and partition key"""
        try:
            response = self.container.read_item(
                item=item_id,
                partition_key=partition_key
            )
            print(f"✅ Item read: {item_id}")
            return response
        except exceptions.CosmosResourceNotFoundError:
            print(f"❌ Item not found: {item_id}")
            return None
        except exceptions.CosmosHttpResponseError as e:
            print(f"❌ Error reading item: {e}")
            raise
    
    def query_items(self, query: str, parameters: List[Dict[str, Any]] = None) -> List[Dict[str, Any]]:
        """Query items using SQL syntax"""
        try:
            items = list(self.container.query_items(
                query=query,
                parameters=parameters,
                enable_cross_partition_query=True
            ))
            print(f"✅ Query returned {len(items)} items")
            return items
        except exceptions.CosmosHttpResponseError as e:
            print(f"❌ Error querying items: {e}")
            raise
    
    def update_item(self, item_id: str, partition_key: str, updates: Dict[str, Any]) -> Dict[str, Any]:
        """Update an existing item"""
        try:
            # Read existing item
            existing_item = self.read_item(item_id, partition_key)
            if not existing_item:
                raise ValueError(f"Item {item_id} not found")
            
            # Apply updates
            existing_item.update(updates)
            
            # Replace item
            response = self.container.replace_item(
                item=item_id,
                body=existing_item
            )
            print(f"✅ Item updated: {item_id}")
            return response
        except exceptions.CosmosHttpResponseError as e:
            print(f"❌ Error updating item: {e}")
            raise
    
    def delete_item(self, item_id: str, partition_key: str) -> None:
        """Delete an item"""
        try:
            self.container.delete_item(
                item=item_id,
                partition_key=partition_key
            )
            print(f"✅ Item deleted: {item_id}")
        except exceptions.CosmosResourceNotFoundError:
            print(f"❌ Item not found: {item_id}")
        except exceptions.CosmosHttpResponseError as e:
            print(f"❌ Error deleting item: {e}")
            raise
    
    def get_container_info(self) -> Dict[str, Any]:
        """Get container information and statistics"""
        try:
            container_info = {
                'id': self.container.id,
                'partition_key': self.container.partition_key,
                'properties': self.container.read()
            }
            return container_info
        except exceptions.CosmosHttpResponseError as e:
            print(f"❌ Error getting container info: {e}")
            raise


def main():
    """Example usage of CosmosDB client"""
    print("🌌 CosmosDB Emulator Client Example")
    print("=" * 40)
    
    # Initialize client
    cosmos_client = CosmosDBClient()
    cosmos_client.initialize()
    
    # Example data
    sample_items = [
        {
            "id": "user_001",
            "name": "Alice Johnson",
            "email": "alice@example.com",
            "department": "Engineering",
            "skills": ["Python", "CosmosDB", "Azure"],
            "created_at": "2024-01-15T10:30:00Z"
        },
        {
            "id": "user_002", 
            "name": "Bob Smith",
            "email": "bob@example.com",
            "department": "Data Science",
            "skills": ["Python", "Machine Learning", "SQL"],
            "created_at": "2024-01-16T14:20:00Z"
        },
        {
            "id": "device_001",
            "name": "Temperature Sensor",
            "type": "IoT Device",
            "location": "Building A",
            "readings": [
                {"timestamp": "2024-01-15T10:00:00Z", "value": 23.5},
                {"timestamp": "2024-01-15T11:00:00Z", "value": 24.2}
            ]
        }
    ]
    
    # Create sample items
    print("\n📝 Creating sample items...")
    for item in sample_items:
        cosmos_client.create_item(item)
    
    # Query examples
    print("\n🔍 Querying items...")
    
    # Query all users
    users = cosmos_client.query_items(
        "SELECT * FROM c WHERE c.department != null"
    )
    print(f"Found {len(users)} users")
    
    # Query by specific criteria
    engineers = cosmos_client.query_items(
        "SELECT * FROM c WHERE c.department = @dept",
        parameters=[{"name": "@dept", "value": "Engineering"}]
    )
    print(f"Found {len(engineers)} engineers")
    
    # Read specific item
    print("\n📖 Reading specific item...")
    user = cosmos_client.read_item("user_001", "user_001")
    if user:
        print(f"User: {user['name']} ({user['email']})")
    
    # Update item
    print("\n✏️ Updating item...")
    cosmos_client.update_item(
        "user_001", 
        "user_001",
        {"last_login": "2024-01-17T09:15:00Z", "skills": ["Python", "CosmosDB", "Azure", "Docker"]}
    )
    
    # Query updated item
    updated_user = cosmos_client.read_item("user_001", "user_001")
    print(f"Updated user skills: {updated_user['skills']}")
    
    # Container info
    print("\n📊 Container Information...")
    container_info = cosmos_client.get_container_info()
    print(f"Container ID: {container_info['id']}")
    print(f"Partition Key: {container_info['partition_key']}")
    
    print("\n✅ Example completed successfully!")
    print("\n💡 Tips:")
    print("  • Access CosmosDB Data Explorer: https://127.0.0.1:8081/_explorer/")
    print("  • Use CosmosDB emulator for local development")
    print("  • Remember to disable SSL verification for emulator")


if __name__ == "__main__":
    main()