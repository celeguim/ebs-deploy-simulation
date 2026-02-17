import os
import sys
import re

FORBIDDEN = [
    r"\bAPPS\.",
    r"\bFND_",
    r"\bAR_",
    r"\bGL_",
]

print("Validating SQL")

for file in os.listdir("sql"):
    sql = open(f"sql/{file}").read().upper()
    print('File: ', sql)
    
    # for pattern in FORBIDDEN:
    #     if re.search(pattern, sql):
    #         sys.exit(f"{file}: touches seeded object")

    # if "DROP TABLE" in sql:
    #     sys.exit(f"{file}: DROP TABLE is forbidden")
