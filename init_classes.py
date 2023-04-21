import re
from glob import glob

find_class = re.compile("class_name\s+(.+)")
find_base = re.compile("extends\s+(.+)")
classes = []  # { file, class name, base class name }

for file in glob("**/*.gd", recursive=True):
    with open(file, "r") as f:
        text = f"{f.readline()}\n{f.readline()}\n{f.readline()}\n{f.readline()}"  # 4 lines: extend, class, tool, icon
        m = find_class.search(text)
        if not m:
            continue
        class_name = m.groups()[0]
        m = find_base.search(text)
        base = m.groups()[0]
        classes.append(
            {"class_name": class_name, "base_class_name": base, "file": file}
        )

first = True
print("list=[", end="")
for c in classes:
    if not first:
        print(", ", end="")
    first = False
    print("{")
    print(f'"base": "{c["base_class_name"]}",')
    print(f'"class": &"{c["class_name"]}",')
    print('"language": &"GDScript",')
    print(f'"path": "res://{c["file"]}"')
    print("}", end="")
print("]")
