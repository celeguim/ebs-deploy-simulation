import os
import sys

required_dirs = ["sql", "metadata", "ci"]

print('Validating structure')

for d in required_dirs:
    if not os.path.isdir(d):
        sys.exit(f"Missing required directory: {d}")

sql_files = [f for f in os.listdir("sql") if f.endswith(".sql")]
meta_files = [f for f in os.listdir("metadata") if f.endswith(".yml")]

if not sql_files:
    sys.exit("No SQL files found")

if len(sql_files) != len(meta_files):
    sys.exit("Mismatch between SQL and metadata files")
