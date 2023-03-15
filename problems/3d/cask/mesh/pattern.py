import numpy as np

num_pins = 5
padding = 1

assembly_map = np.array([[0, 0, 1, 1, 0, 0],
                         [0, 1, 1, 1, 1, 0],
                         [1, 1, 1, 1, 1, 1],
                         [1, 1, 1, 1, 1, 1],
                         [0, 1, 1, 1, 1, 0],
                         [0, 0, 1, 1, 0, 0],
                         ])

assert num_pins + padding == len(assembly_map)

n = len(assembly_map) * num_pins

pattern = ""


for row in range(n):

    if row % num_pins == 0:
        for p in range(padding):
            pattern += "0 " * (n + (len(assembly_map) + 1) * padding) + ";\n"

    pattern += "0 " * padding
    i = row // num_pins

    for assem_type in assembly_map[i]:
        pattern += f"{assem_type} " * num_pins + "0 " * padding
    pattern += ";\n"

for p in range(padding):
    pattern += "0 " * (n + (len(assembly_map) + 1) * padding) + ";\n"

print(pattern)