import random
import csv

# Lista studentów
students = [
9,
12,
26,
27,
31,
36,
37,
39,
44,
67,
90,
92,
105,
108,
114,
130,
142,
144,
163,
171,
179,
180,
189,
197,
222,
223,
227,
232,
234,
258

]

# Przykładowy zakres przedmiotów (można dostosować według potrzeb)
subjects = [
    205,
    206,
    207,
    208,
    209,
    210,
    211,
    212,
    213,
    214

]  # ID przedmiotów

# Generowanie danych CSV
rows = []

for subject in subjects:
    for student in students:
        grade = random.randint(2, 6)  # Losowanie oceny z zakresu 2-6
        rows.append([subject, student, grade])

# Zapisanie do pliku CSV
with open("grades.csv", "w", newline="") as file:
    writer = csv.writer(file)
    writer.writerows(rows)

print("CSV file 'grades.csv' generated.")
