import numpy as np

num_pins = 5
padding = 1

pitch = 0.032 # m
z = 1.0 # m

assembly_map = np.array([[0, 0, 1, 1, 0, 0],
                         [0, 1, 1, 1, 1, 0],
                         [1, 1, 1, 1, 1, 1],
                         [1, 1, 1, 1, 1, 1],
                         [0, 1, 1, 1, 1, 0],
                         [0, 0, 1, 1, 0, 0],
                         ])

assert num_pins + padding == len(assembly_map) # Ensures resulting pattern is square

n = len(assembly_map) * num_pins

pattern = ""

positions = open("positions.txt", 'w')

for row in range(n):

    if row % num_pins == 0:
        for p in range(padding):
            pattern += "0 " * (n + (len(assembly_map) + 1) * padding) + ";\n"

    pattern += "0 " * padding
    i = row // num_pins

    for j, assem_type in enumerate(assembly_map[i]):
        pattern += f"{assem_type} " * num_pins + "0 " * padding

        if assem_type == 1:
            row_i = row + (i + 1) * padding
            start_col = num_pins * j + padding * (j + 1)
            for col in range(start_col, start_col + num_pins):
                positions.write(f"{col * pitch} {-row_i * pitch} {z}\n")

    pattern += ";\n"

for p in range(padding):
    pattern += "0 " * (n + (len(assembly_map) + 1) * padding) + ";\n"

print(pattern)
print(pattern.count("0"), pattern.count("1"))

positions.close()