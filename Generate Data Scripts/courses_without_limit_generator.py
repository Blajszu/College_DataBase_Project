import random, os, csv

os.chdir(os.path.dirname(__file__))

topics = courses = [
    "Kurs Python dla Początkujących", "Zaawansowany Haskell", "Programowanie w Erlangu", "Tworzenie Aplikacji w Elixirze",
    "Podstawy Asemblera", "Wprowadzenie do Ady", "TypeScript w Praktyce", "Analiza Danych w R", "Matlab dla Inżynierów", 
    "Kurs Julii: Język dla Obliczeń Naukowych", "Java od Podstaw do Eksperta", "Programowanie w C++", 
    "Tworzenie Aplikacji w JavaScript", "SQL: Zarządzanie Bazami Danych", "HTML i CSS: Podstawy Tworzenia Stron", 
    "Projektowanie za Pomocą CSS", "Uczenie Maszynowe dla Każdego", "Nauka o Danych: Od Teorii do Praktyki", 
    "Głębokie Uczenie: Neural Networks", "Sztuczna Inteligencja: Wprowadzenie", "Wizja Komputerowa w Praktyce", 
    "Przetwarzanie Języka Naturalnego", "Tworzenie Stron Internetowych", "Tworzenie Aplikacji Mobilnych", 
    "Wprowadzenie do Tworzenia Gier", "Cyberbezpieczeństwo: Podstawy", "Etyczny Hacking: Certyfikowany Specjalista", 
    "Blockchain: Zastosowania i Implementacje", "Wprowadzenie do Komputerów Kwantowych", "Podstawy Chmury Obliczeniowej", 
    "Big Data: Analiza i Zarządzanie", "Internet Rzeczy: Zastosowania", "Rozszerzona Rzeczywistość w Praktyce", 
    "Wirtualna Rzeczywistość: Tworzenie Światów", "Podstawy Robotyki", "Wprowadzenie do Pojazdów Autonomicznych", 
    "Drony: Programowanie i Zastosowania", "Druk 3D dla Początkujących", "Biotechnologia: Podstawy i Aplikacje", 
    "Inżynieria Genetyczna", "Nanotechnologia: Od Teorii do Praktyki", "Energia Odnawialna: Kurs dla Początkujących", 
    "Eksploracja Kosmosu", "Astronomia dla Amatorów", "Astrofizyka: Wprowadzenie", "Podstawy Fizyki Kwantowej", 
    "Fizyka Cząstek: Eksploracja Mikrokosmosu", "Teoria Strun dla Początkujących", "Kosmologia: Struktura Wszechświata", 
    "Neurobiologia: Jak Działa Mózg", "Psychologia: Podstawy", "Socjologia: Zrozumieć Społeczeństwo", 
    "Ekonomia: Wprowadzenie do Makro i Mikroekonomii", "Nauki Polityczne dla Początkujących", "Historia: Chronologia Świata", 
    "Filozofia: Wprowadzenie do Myślenia Krytycznego", "Literatura: Klasyka i Nowoczesność", "Sztuka: Wprowadzenie do Technik", 
    "Muzyka: Teoria i Praktyka", "Kino: Tworzenie i Analiza", "Teatr: Sztuka Aktorstwa", "Fotografia: Podstawy i Zaawansowane Techniki", 
    "Projektowanie Mody: Kreatywne Rozwiązania", "Projektowanie Wnętrz: Estetyka i Funkcjonalność", 
    "Projektowanie Graficzne: Narzędzia i Techniki", "Projektowanie Produktu: Od Koncepcji do Realizacji", 
    "Architektura: Teoria i Praktyka", "Planowanie Urbanistyczne: Zrównoważony Rozwój", 
    "Architektura Krajobrazu: Kreowanie Przestrzeni", "Inżynieria Lądowa: Projekty Budowlane", 
    "Inżynieria Mechaniczna: Od Podstaw do Zaawansowania", "Inżynieria Elektryczna: Systemy i Zastosowania", 
    "Inżynieria Chemiczna: Procesy i Materiały", "Inżynieria Kosmiczna: Projektowanie Satelitów", 
    "Inżynieria Biomedyczna: Rozwiązania dla Zdrowia", "Inżynieria Środowiska: Zrównoważone Technologie", 
    "Inżynieria Przemysłowa: Optymalizacja Procesów", "Nauka o Materiałach: Wprowadzenie", "Matematyka: Podstawy i Analizy", 
    "Statystyka: Narzędzia Analizy Danych", "Fizyka: Klasyczna i Współczesna", "Chemia: Związki i Reakcje", 
    "Biologia: Struktura i Funkcje Życia", "Geologia: Badanie Ziemi", "Geografia: Mapy i Krajobrazy", 
    "Meteorologia: Prognozowanie Pogody", "Oceanografia: Eksploracja Oceanów", "Ekologia: Zrozumieć Przyrodę", 
    "Zoologia: Życie Zwierząt", "Botanika: Nauka o Roślinach", "Mikrobiologia: Świat Mikroorganizmów", 
    "Genetyka: Dziedziczenie i DNA", "Biochemia: Podstawy Życia", "Farmakologia: Nauka o Lekach", 
    "Medycyna: Anatomia i Diagnostyka", "Pielęgniarstwo: Podstawy Opieki Zdrowotnej", "Stomatologia: Opieka nad Zębami", 
    "Farmacja: Nauka i Praktyka", "Weterynaria: Opieka nad Zwierzętami", "Fizjoterapia: Ruch i Rehabilitacja", 
    "Terapia Zajęciowa: Przywracanie Funkcjonalności", "Logopedia: Terapia Mowy", "Dietetyka: Zdrowe Żywienie", 
    "Żywienie: Zasady i Praktyka", "Zdrowie Publiczne: Polityka i Strategie", "Zarządzanie Opieką Zdrowotną", 
    "Informatyka Zdrowotna: Technologie Medyczne", "Edukacja Zdrowotna: Promocja Zdrowia",
    "Wprowadzenie do Cyberbezpieczeństwa", "Pentesting w Praktyce", "Tworzenie Bezpiecznych Aplikacji Webowych", 
    "Forensics: Analiza Cyfrowych Śladów", "Zarządzanie Incydentami Bezpieczeństwa", "Kryptografia dla Programistów", 
    "Bezpieczeństwo Chmury: Best Practices", "Zaawansowana Inżynieria Sieciowa", "Systemy Operacyjne: Linux w Praktyce", 
    "Automatyzacja Zadań IT za pomocą Ansible", "Kubernetes dla Początkujących", "Docker: Tworzenie i Zarządzanie Kontenerami", 
    "Wprowadzenie do DevOps", "Zarządzanie Projektami IT: Scrum i Agile", "Zarządzanie Infrastrukturą IT", "Zarządzanie Sieciami Komputerowymi",
    "Wprowadzenie do Programowania Funkcyjnego", "Programowanie Obiektowe: Java i Python", "Programowanie Strukturalne: C i Pascal",
    "Programowanie Funkcyjne: Haskell i Erlang", "Programowanie Logiczne: Prolog i Lisp", "Programowanie Aspektowe: Spring i AspectJ",
    "Programowanie Reaktywne: Akka i RxJava", "Programowanie Rozproszone: Architektura Mikroserwisów", "Programowanie Niskopoziomowe: C i Asembler",
    "Programowanie Współbieżne: Wątki i Procesy", "Programowanie Gier: Unity i Unreal Engine", "Tworzenie Aplikacji Mobilnych: Android i iOS",
    "Tworzenie Aplikacji Webowych: React i Angular", "Tworzenie Aplikacji Desktopowych: Java i C#", "Tworzenie Aplikacji Chmurowych: AWS i Azure",
    "Tworzenie Aplikacji IoT: Arduino i Raspberry Pi", "Tworzenie Aplikacji Blockchain: Ethereum i Hyperledger", "Tworzenie Aplikacji AI: TensorFlow i PyTorch",
    "Tworzenie Aplikacji VR: Unity i Unreal Engine", "Tworzenie Aplikacji AR: ARCore i ARKit", "Tworzenie Aplikacji 3D: Blender i Maya",
    "Tworzenie Aplikacji 2D: GIMP i Inkscape", "Tworzenie Aplikacji Biznesowych: SAP i Salesforce", "Tworzenie Aplikacji Naukowych: MATLAB i LabVIEW",
    "Tworzenie Aplikacji Artystycznych: Adobe Creative Suite", "Tworzenie Aplikacji Edukacyjnych: Moodle i Blackboard", "Tworzenie Aplikacji Medycznych: DICOM i HL7",
    "Tworzenie Aplikacji Finansowych: Bloomberg i Reuters", "Tworzenie Aplikacji E-commerce: Magento i Shopify", "Tworzenie Aplikacji SaaS: Salesforce i Slack",
    "Tworzenie Aplikacji PWA: Progressive Web Apps", "Tworzenie Aplikacji SPA: Single Page Applications", "Tworzenie Aplikacji MERN: MongoDB, Express, React, Node.js",
    "Tworzenie Aplikacji MEAN: MongoDB, Express, Angular, Node.js", "Tworzenie Aplikacji LAMP: Linux, Apache, MySQL, PHP", "Tworzenie Aplikacji JAMstack: JavaScript, APIs, Markup",
    "Tworzenie Aplikacji Serverless: AWS Lambda i Azure Functions", "Tworzenie Aplikacji Microservices: Docker i Kubernetes", "Tworzenie Aplikacji Monolitycznych: Legacy Systems",
    "Tworzenie Aplikacji Open Source: GitHub i GitLab", "Tworzenie Aplikacji Cross-platform: Flutter i Xamarin", "Tworzenie Aplikacji Native: Swift i Kotlin",
    "Tworzenie Aplikacji Hybrydowych: Ionic i PhoneGap", "Tworzenie Aplikacji Progressive: Progressive Web Apps", "Tworzenie Aplikacji Responsive: Responsive Web Design",
    "Tworzenie Aplikacji Adaptive: Adaptive Web Design", "Tworzenie Aplikacji Mobile-first: Mobile-first Design", "Tworzenie Aplikacji Desktop-first: Desktop-first Design",
    "Tworzenie Aplikacji Voice-first: Voice-first Design", "Tworzenie Aplikacji AI-first: AI-first Design", "Tworzenie Aplikacji VR-first: VR-first Design",
    "Tworzenie Aplikacji AR-first: AR-first Design", "Tworzenie Aplikacji 3D-first: 3D-first Design", "Tworzenie Aplikacji 2D-first: 2D-first Design",
    "Tworzenie Aplikacji Biznesowych: Business Applications", "Tworzenie Aplikacji Naukowych: Scientific Applications", "Tworzenie Aplikacji Artystycznych: Artistic Applications",
    "Tworzenie Aplikacji Edukacyjnych: Educational Applications", "Tworzenie Aplikacji Medycznych: Medical Applications", "Tworzenie Aplikacji Finansowych: Financial Applications",
    "Tworzenie Aplikacji E-commerce: E-commerce Applications", "Tworzenie Aplikacji SaaS: Software as a Service", "Tworzenie Aplikacji PWA: Progressive Web Applications",
    "Finanse Osobiste: Jak Planować Budżet", "Zarządzanie Inwestycjami: Akcje, Obligacje, ETF-y", "Kryptowaluty: Handel i Inwestowanie", 
    "Makroekonomia: Kluczowe Pojęcia i Wskaźniki", "Podstawy Mikroekonomii: Zasady Działania Rynku", 
    "Ekonomia Behawioralna: Psychologia Decyzji Ekonomicznych", "Analiza Rynków Finansowych", "Podstawy Rachunkowości", 
    "Zarządzanie Finansami Przedsiębiorstw", "Podatki: Prawo i Planowanie", "E-commerce: Zarządzanie Sklepem Online", 
    "FinTech: Przyszłość Finansów", "Bankowość Elektroniczna: Systemy i Bezpieczeństwo"
]



user_roles_csv = "UserRoles.csv"
coordinator_role_no = '3'

def wczytaj_liste_z_csv(plik):
    with open(plik, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Pomijanie nagłówka
        return [row for row in reader]

user_roles = wczytaj_liste_z_csv(user_roles_csv)
coordinators = []
for user_role in user_roles:
    if user_role[1] == coordinator_role_no:
        coordinators.append(user_role[0])

def generate_name():
    return random.choice(topics)

def generate_description(name):
    return "Kurs " + name + " obejmuje wszystkie podstawowe i zaawansowane kwestie oraz zapewnia praktyczne doświadczenie z projektami z prawdziwego świata. Kurs prowadzony jest przez ekspertów branżowych i jest odpowiedni zarówno dla początkujących, jak i doświadczonych profesjonalistów. Po zakończeniu kursu będziesz miał solidne zrozumienie tematu i będziesz w stanie zastosować swoją wiedzę do rozwiązywania złożonych problemów. Zapisz się teraz i rozpocznij swoją podróż do zostania ekspertem w dziedzinie !"

    
def generate_coordinator():
    return random.choice(coordinators)

def generate_price():
    price = random.randint(400, 1600)
    if price%10 != 0 and price%10 != 5 and price%10 != 9:
        price = random.choice([(price//10) * 10, (price//10) * 10 +5, (price//10) * 10 + 9])
    return price

def generate_courses():
    courses = [[0 for i in range(5)] for j in range(280)]
    for i in range(280):
        courses[i][0] = i+1
        courses[i][1] = generate_name()
        courses[i][2] = generate_coordinator()
        courses[i][3] = generate_description(courses[i][1])
        courses[i][4] = generate_price()
    return courses

courses = generate_courses()
courses_without_price_and_students_limit_csv = 'courses_without_students_limit.csv'

with open(courses_without_price_and_students_limit_csv, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(["CourseID", "CourseName", "CourseCoordinatorID", "CourseDescription", "CoursePrice"])
    writer.writerows(courses)
