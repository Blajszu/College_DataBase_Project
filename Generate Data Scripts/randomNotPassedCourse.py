import pandas as pd
import numpy as np

# Wczytanie danych z pliku CSV
def modify_csv(input_file, output_file):
    # Wczytaj dane z CSV
    df = pd.read_csv(input_file)

    # Sprawdź kolumnę 'Passed' i znajdź indeksy gdzie jest 1
    ones_indices = df.index[df['Passed'] == 1].tolist()

    # Określ liczbę około 1% jedynek do zmiany
    num_to_change = max(1, int(len(ones_indices) * 0.03))

    # Wybierz losowe indeksy do zamiany
    indices_to_change = np.random.choice(ones_indices, num_to_change, replace=False)

    # Zmień wybrane jedynki na zera
    df.loc[indices_to_change, 'Passed'] = 0

    # Zapisz zmodyfikowany DataFrame do nowego pliku CSV
    df.to_csv(output_file, index=False)
    print(f"Zmodyfikowano {num_to_change} wartości w kolumnie 'Passed'. Plik zapisano jako {output_file}.")

# Użycie funkcji
input_file = './CourseModulesPassed.csv'   # Nazwa wejściowego pliku CSV
output_file = 'zmodyfikowane_dane.csv'  # Nazwa wyjściowego pliku CSV
modify_csv(input_file, output_file)