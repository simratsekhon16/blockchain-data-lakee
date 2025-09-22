# Blockchain-Enabled Data Lake

A modern, open-source data lake implementation combining MinIO object storage, Apache Iceberg table management, Trino distributed querying, with blockchain-based access control using Hyperledger Fabric.

## 🏗️ Architecture

This system integrates:
- **MinIO**: S3-compatible object storage
- **Apache Iceberg**: Modern table format with ACID transactions
- **Trino**: Distributed SQL query engine  
- **PostgreSQL**: Metadata catalog storage
- **Jupyter**: Development and testing environment
- **Hyperledger Fabric**: Blockchain access control (coming soon)

## 🚀 Quick Start

### Prerequisites
- Docker Desktop installed and running
- Git (for cloning)
- 4GB+ available RAM
- 2GB+ available disk space

### Installation

1. **Clone the repository**:
```bash
git clone https://github.com/YOUR_USERNAME/blockchain-data-lake.git
cd blockchain-data-lake
```

2. **Start the data lake**:
```bash
# Make scripts executable (Linux/Mac/Git Bash)
chmod +x *.sh

# Run setup
./setup.sh
```

**Windows Users**: If you encounter shell script issues, use PowerShell and create buckets manually via MinIO Console.

3. **Create buckets and sample data**:

**Option A - Command Line** (Linux/Mac/Git Bash):
```bash
# Create MinIO buckets
docker run --rm --network datalake_network minio/mc:latest mc alias set myminio http://minio:9000 minioadmin minioadmin123
docker run --rm --network datalake_network minio/mc:latest mc mb myminio/warehouse
docker run --rm --network datalake_network minio/mc:latest mc mb myminio/raw-data
```

**Option B - Web Interface** (Windows/All platforms):
- Go to http://localhost:9001
- Login: `minioadmin` / `minioadmin123`
- Create buckets: `warehouse` and `raw-data`

## 🌐 Access Points

After setup, access these services:

| Service | URL | Credentials | Purpose |
|---------|-----|-------------|---------|
| MinIO Console | http://localhost:9001 | minioadmin/minioadmin123 | Data storage management |
| Trino Web UI | http://localhost:8080 | - | Query monitoring |
| Jupyter Lab | http://localhost:8888 | token: easy | Development environment |

## 📊 Testing Your Setup

### 1. Verify MinIO Storage
- Open MinIO Console: http://localhost:9001
- Check for `warehouse` and `raw-data` buckets

### 2. Test Trino Queries
Open Jupyter Lab (http://localhost:8888) and run:

```python
import trino
import pandas as pd

# Connect to Trino
conn = trino.dbapi.connect(
    host='trino-coordinator',
    port=8080,
    user='admin'
)

# Test connection
cur = conn.cursor()
cur.execute("SHOW CATALOGS")
catalogs = cur.fetchall()
print("Available catalogs:", catalogs)
```

### 3. Create Your First Iceberg Table
```sql
CREATE TABLE iceberg.default.employees (
  id bigint,
  name varchar,
  department varchar,
  salary bigint,
  timestamp timestamp
) WITH (
  location = 's3://warehouse/employees/',
  format = 'PARQUET'
)
```

## 🛠️ Development

### Project Structure
```
blockchain-data-lake/
├── docker-compose.yml          # Infrastructure definition
├── setup.sh                    # Automated setup script
├── create_trino_config.sh      # Trino configuration generator
├── trino-config/              # Trino configuration files
├── notebooks/                 # Jupyter notebooks
└── data-samples/             # Sample data files
```

### Adding New Data Sources
1. **Upload data to MinIO** via console or API
2. **Register in Iceberg catalog** using Trino or Spark
3. **Query via Trino** using SQL

### Scaling Workers
To add more Trino workers, modify `docker-compose.yml`:
```yaml
trino-worker-2:
  image: trinodb/trino:435
  volumes:
    - ./trino-config:/etc/trino
  depends_on:
    - trino-coordinator
```

## 🔒 Blockchain Integration (Roadmap)

Future implementation will include:
- **Hyperledger Fabric network** for access control
- **Smart contracts** for data governance policies  
- **Immutable audit trails** for data access
- **Token-based permissions** for data sharing

## 🐛 Troubleshooting

### Common Issues

**Docker not starting:**
```bash
# Check Docker status
docker --version
docker-compose --version

# Restart Docker Desktop
```

**Permission errors (Windows):**
- Use PowerShell as Administrator
- Or use MinIO web console for manual setup

**Memory issues:**
- Ensure Docker has at least 4GB RAM allocated
- Close other applications if needed

**Port conflicts:**
```bash
# Check if ports are in use
netstat -an | findstr "8080\|9000\|9001"

# Stop conflicting services or change ports in docker-compose.yml
```

### Getting Help

1. **Check container logs**:
```bash
docker-compose logs [service-name]
```

2. **Verify all services running**:
```bash
docker-compose ps
```

3. **Clean restart**:
```bash
docker-compose down
docker-compose up -d
```

## 📚 Learn More

- [MinIO Documentation](https://docs.min.io/)
- [Apache Iceberg](https://iceberg.apache.org/)
- [Trino Documentation](https://trino.io/docs/)
- [Docker Compose Guide](https://docs.docker.com/compose/)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push branch: `git push origin feature/new-feature`
5. Submit Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- MinIO team for excellent object storage
- Apache Iceberg community for modern table format
- Trino community for distributed SQL engine
- Hyperledger Fabric for blockchain framework