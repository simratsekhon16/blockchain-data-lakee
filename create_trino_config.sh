# Create Trino configuration directory structure
mkdir -p trino-config/catalog
mkdir -p trino-config/coordinator
mkdir -p trino-config/worker
mkdir -p notebooks

# === Coordinator Configuration ===
cat > trino-config/config.properties << EOF
coordinator=true
node-scheduler.include-coordinator=true
http-server.http.port=8080
discovery.uri=http://localhost:8080
EOF

# === Worker Configuration ===  
cat > trino-config/worker/config.properties << EOF
coordinator=false
http-server.http.port=8080
discovery.uri=http://trino-coordinator:8080
EOF

# === Node Properties ===
cat > trino-config/node.properties << EOF
node.environment=docker
node.id=ffffffff-ffff-ffff-ffff-ffffffffffff
node.data-dir=/data/trino
EOF

# === JVM Configuration ===
cat > trino-config/jvm.config << EOF
-server
-Xmx2G
-XX:InitialRAMPercentage=80
-XX:MaxRAMPercentage=80
-XX:G1HeapRegionSize=32M
-XX:+ExplicitGCInvokesConcurrent
-XX:+HeapDumpOnOutOfMemoryError
-XX:+ExitOnOutOfMemoryError
-XX:ReservedCodeCacheSize=512M
-XX:PerMethodRecompilationCutoff=10000
-XX:PerBytecodeRecompilationCutoff=10000
-Djdk.attach.allowAttachSelf=true
-Djdk.nio.maxCachedBufferSize=2000000
-XX:+UnlockDiagnosticVMOptions
-XX:+UseAESCTRIntrinsics
EOF

# === Iceberg Catalog Configuration ===
cat > trino-config/catalog/iceberg.properties << EOF
connector.name=iceberg
iceberg.catalog.type=rest
iceberg.rest-catalog.uri=http://iceberg-rest:8181
iceberg.rest-catalog.warehouse=s3://warehouse/
hive.s3.endpoint=http://minio:9000
hive.s3.aws-access-key=minioadmin
hive.s3.aws-secret-key=minioadmin123
hive.s3.path-style-access=true
hive.s3.ssl.enabled=false
EOF

# === MinIO Catalog (for raw data access) ===
cat > trino-config/catalog/minio.properties << EOF
connector.name=hive
hive.metastore=file
hive.metastore.catalog.dir=s3://warehouse/
hive.s3.endpoint=http://minio:9000
hive.s3.aws-access-key=minioadmin
hive.s3.aws-secret-key=minioadmin123
hive.s3.path-style-access=true
hive.s3.ssl.enabled=false
EOF

echo "Trino configuration files created successfully!"