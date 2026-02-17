import os
import re

objects = []

print("Detecting objects")

for file in os.listdir("sql"):
    sql = open(f"sql/{file}").read().upper()
    print('File: ', sql)

    matches = re.findall(r"(TABLE|PACKAGE|VIEW)\s+(XX\w+)", sql)
    objects.extend(matches)

print("Impacted objects:")
for o in set(objects):
    print("-", o[0], o[1])

