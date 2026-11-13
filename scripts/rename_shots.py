import json
import os
import re
import sys


def walk(node, out):
    if isinstance(node, dict):
        exported = node.get("exportedFileName")
        name = node.get("attachmentName") or node.get("suggestedHumanReadableName")
        if exported and name:
            out.append((exported, name))
        for value in node.values():
            walk(value, out)
    elif isinstance(node, list):
        for item in node:
            walk(item, out)


def main():
    folder = sys.argv[1]
    manifest = os.path.join(folder, "manifest.json")
    pairs = []
    if os.path.exists(manifest):
        with open(manifest) as handle:
            walk(json.load(handle), pairs)
    for exported, name in pairs:
        src = os.path.join(folder, exported)
        if not os.path.exists(src):
            continue
        clean = re.sub(r"[^A-Za-z0-9_-]+", "-", str(name)).strip("-")
        if not clean:
            continue
        dst = os.path.join(folder, clean + ".png")
        counter = 1
        while os.path.exists(dst) and dst != src:
            dst = os.path.join(folder, f"{clean}-{counter}.png")
            counter += 1
        if dst != src:
            os.rename(src, dst)
    print("shots dir:", sorted(os.listdir(folder)))


if __name__ == "__main__":
    main()
