#!/usr/bin/env python3

from pathlib import Path
from hashlib import md5
import json

score_hash_map = {}

directory = Path("./scores")
contents = directory.iterdir()

for item in contents:
    name = item.name.replace(".png", "")
    f = item.read_bytes()
    hash = md5(f).hexdigest()
    score_hash_map[name] = hash
    print("{}'s hash is {}".format(name,hash))

with open("score_hashes.json", "w") as f:
    f.write(json.dumps(score_hash_map))