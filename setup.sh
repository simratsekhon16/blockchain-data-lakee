#!/bin/bash

echo "🚀 Setting up Blockchain-Enabled Data Lake..."

# Step 1: Create directory structure
echo "📁 Creating directory structure..."
mkdir -p trino-config/catalog
mkdir -p notebooks
mkdir -p data-samples

# Step 2: Generate Trino configuration
echo "⚙️  Generating Trino configuration..."
bash create_trino_config.sh

# Step 3: Start the infrastructure
echo "🐳 Starting Docker containers..."
docker-compose up -d

# Step 4: Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Step 5: Create MinIO bucket for warehouse
echo "🪣 Creating MinIO warehouse bucket..."
docker run --rm --network datalake_network \
  -e MINIO_ROOT_USER=minioadmin \
  -e MINIO_ROOT_PASSWORD=minioadmin123 \
  minio/mc:latest sh -c "
  mc alias set myminio http://minio:9000 minioadmin minioadmin123
  mc mb myminio/warehouse
  mc mb myminio/raw-data
  echo 'Buckets created successfully!'
"

# Step 6: Create sample data
echo "📊 Creating sample data..."
cat > data-samples/sample_data.json << 'EOF'
{"id": 1, "name": "Alice", "department": "Engineering", "salary": 95000, "timestamp": "2024-01-15T10:30:00Z"}
{"id": 2, "name": "Bob", "department": "Marketing", "salary": 75000, "timestamp": "2024-01-15T11:00:00Z"}  
{"id": 3, "name": "Carol", "department": "Engineering", "salary": 105000, "timestamp": "2024-01-15T11:30:00Z"}
{"id": 4, "name": "David", "department": "Sales", "salary": 85000, "timestamp": "2024-01-15T12:00:00Z"}
{"id": 5, "name": "Eve", "department": "Engineering", "salary": 98000, "timestamp": "2024-01-15T12:30:00Z"}
EOF

# Step 7: Upload sample data to MinIO
echo "⬆️  Uploading sample data to MinIO..."
docker run --rm --network datalake_network \
  -v "$(pwd)/data-samples:/data" \
  minio/mc:latest sh -c "
  mc alias set myminio http://minio:9000 minioadmin minioadmin123
  mc cp /data/sample_data.json myminio/raw-data/employees/sample_data.json
  echo 'Sample data uploaded!'
"

# Step 8: Create Jupyter notebook for testing
cat > notebooks/test_data_lake.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Data Lake Testing Notebook\n",
    "This notebook demonstrates querying your MinIO + Iceberg + Trino data lake."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "# Install required packages\n",
    "!pip install trino pandas pyiceberg boto3"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "import trino\n",
    "import pandas as pd\n",
    "\n",
    "# Connect to Trino\n",
    "conn = trino.dbapi.connect(\n",
    "    host='trino-coordinator',\n",
    "    port=8080,\n",
    "    user='admin'\n",
    ")\n",
    "\n",
    "# Test connection\n",
    "cur = conn.cursor()\n",
    "cur.execute(\"SHOW CATALOGS\")\n",
    "catalogs = cur.fetchall()\n",
    "print(\"Available catalogs:\", catalogs)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "# Create Iceberg table from sample data\n",
    "create_table_sql = \"\"\"\n",
    "CREATE TABLE iceberg.default.employees (\n",
    "  id bigint,\n",
    "  name varchar,\n",
    "  department varchar,\n",
    "  salary bigint,\n",
    "  timestamp timestamp\n",
    ") WITH (\n",
    "  location = 's3://warehouse/employees/',\n",
    "  format = 'PARQUET'\n",
    ")\n",
    "\"\"\"\n",
    "\n",
    "cur.execute(create_table_sql)\n",
    "print(\"Table created successfully!\")"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

echo "✅ Setup complete!"
echo ""
echo "🌐 Access URLs:"
echo "  MinIO Console: http://localhost:9001 (minioadmin/minioadmin123)"
echo "  Trino Web UI:  http://localhost:8080"
echo "  Jupyter Lab:   http://localhost:8888 (token: easy)"
echo ""
echo "🔧 Next steps:"
echo "  1. Open Jupyter Lab and run the test notebook"
echo "  2. Access MinIO console to explore your data"
echo "  3. Use Trino Web UI to run queries"
echo "  4. Add Hyperledger Fabric integration"