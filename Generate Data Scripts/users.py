import csv
import random
from datetime import datetime, timedelta

# Pliki wejściowe
imiona_csv = "imiona.csv"
nazwiska_csv = "nazwiska.csv"
ulice_csv = "ulice.csv"

# Plik wyjściowy
output_csv = "generated_users.csv"

# Wczytywanie danych z plików CSV
def wczytaj_liste_z_csv(plik):
    with open(plik, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Pomijanie nagłówka
        return [row[0] for row in reader]

imiona = wczytaj_liste_z_csv(imiona_csv)
nazwiska = wczytaj_liste_z_csv(nazwiska_csv)
ulice = wczytaj_liste_z_csv(ulice_csv)

# Generowanie unikalnych kombinacji imion i nazwisk
unikalne_kombinacje = list(set((imie, nazwisko) for imie in imiona for nazwisko in nazwiska))
random.shuffle(unikalne_kombinacje)
unikalne_kombinacje = unikalne_kombinacje[:1100]

# Przygotowanie rozkładu CityID
city_distribution = [1] * 200 + [2] * 150 + [3] * 125 + [4] * 125 + [5] * 100 + [6] * 100 + [7] * 100 + [8] * 100 + [9] * 50 + [10] * 50
random.shuffle(city_distribution)

# Generowanie danych użytkowników
dane_uzytkownikow = []
for idx, (imie, nazwisko) in enumerate(unikalne_kombinacje, start=1):
    street = f"{random.choice(ulice)} {random.randint(1, 99)}"
    city_id = city_distribution.pop() if city_distribution else random.randint(9, 10)
    email = f"{imie.lower()}.{nazwisko.lower()}@example.com".replace("ą", "a").replace("ć", "c").replace("ę", "e").replace("ł", "l").replace("ń", "n").replace("ó", "o").replace("ś", "s").replace("ź", "z").replace("ż", "z")
    phone = f"{random.randint(600000000, 999999999)}"
    date_of_birth = (datetime.now() - timedelta(days=random.randint(6570, 18250))).strftime("%Y-%m-%d")  # 18-50 lat
    dane_uzytkownikow.append([idx, imie, nazwisko, street, city_id, email, phone, date_of_birth])

# Zapisywanie danych do pliku CSV
with open(output_csv, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(["UserID", "FirstName", "LastName", "Street", "CityID", "Email", "Phone", "DateOfBirth"])
    writer.writerows(dane_uzytkownikow)

output_csv
