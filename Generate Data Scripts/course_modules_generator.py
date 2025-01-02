import random, csv, os

os.chdir(os.path.dirname(__file__))

user_roles_csv = "UserRoles.csv"
courses_csv = "courses_without_students_limit.csv"
translated_languages_csv = "TranslatedLanguage.csv"
users_csv = "Users.csv"


def wczytaj_liste_z_csv(plik):
    with open(plik, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Pomijanie nagłówka
        return [row for row in reader]

user_roles = wczytaj_liste_z_csv(user_roles_csv)
courses = wczytaj_liste_z_csv(courses_csv)
translated_languages = wczytaj_liste_z_csv(translated_languages_csv)
users = wczytaj_liste_z_csv(users_csv)
output_csv = 'courses_modules.csv'

lecturers = []
translators = []
for user_role in user_roles:
    if user_role[1] == "7":
        lecturers.append(user_role[0])
    if user_role == "2":
        translators.append(user_role[0])

users_cities = {}
cities_users = {}
cities_translators = {}
cities_teachers = {}
for user in users:
    city = user[4]
    users_cities[user[0]] = city
    if city not in cities_users.keys():
        cities_users[city] = []
    cities_users[city].append(user[0])
    if user[0] in lecturers:
        if city not in cities_teachers.keys():
            cities_teachers[city] = []
        cities_teachers[city].append(user[0])
    if user[0] in translators:
        if city not in cities_translators.keys():
            cities_teachers[city] = []
        cities_translators[city].append(user[0])

dict_of_traslators_for_certain_language_in_certain_city = {}
translators_for_languages = {}
for language in translated_languages:
    if language[1] not in translators_for_languages.keys():
        translators_for_languages[language[1]] = []
    city = users_cities[language[0]]
    if city not in dict_of_traslators_for_certain_language_in_certain_city.keys():
        dict_of_traslators_for_certain_language_in_certain_city[city] = {}
    if language[1] not in dict_of_traslators_for_certain_language_in_certain_city[city].keys():
        dict_of_traslators_for_certain_language_in_certain_city[city][language[1]] = []
    dict_of_traslators_for_certain_language_in_certain_city[city][language[1]].append(language[0])
    translators_for_languages[language[1]].append(language[0])
all_possibilities_of_translations = len(translated_languages)

def generate_language_and_translator():
    random_value = random.random()
    if random_value<0.7:
        language = 1 #70% chances for polish
        return (1, None) 
    top_limit = 0.7
    for language in translators_for_languages.keys(): 
        top_limit += len(translators_for_languages[language]) / all_possibilities_of_translations * (1-0.7)
        if random_value <= top_limit:
            translator = random.choice(translators_for_languages[language])
            return (language, translator)
        
def generate_language_and_translator_from_city(city):
    while True:
        random_value = random.random()
        if random_value<0.7:
            language = 1 #70% chances for polish
            return (1, None) 
        top_limit = 0.7
        for language in translators_for_languages.keys(): 
            top_limit += len(translators_for_languages[language]) / all_possibilities_of_translations * (1-0.7)
            if random_value <= top_limit:
                if language in dict_of_traslators_for_certain_language_in_certain_city[city].keys():
                    translator = random.choice(dict_of_traslators_for_certain_language_in_certain_city[city][language])
                    return (language, translator)

def generate_teacher_from_city(city):
    if city is None:
        return random.choice(lecturers)
    else:
        return random.choice(cities_teachers[city])
                


def generate_course_modules():
    module_number = 1
    course_modules = []
    for course in courses:
        city = None
        course_id = course[0]
        number_of_modules = random.randint(3, 8)
        for i in range(number_of_modules):
            module_id = module_number
            module_number += 1
            module_name = f"Moduł {i + 1} kursu '{course[1]}'"
            module_description = f"Część {i+1} kursu '{course[1]}'"
            module_type = random.randint(1, 4)
            if module_type == 2 or module_type == 3:\
                #for online courses it doen't matters from which city the employee is
                module_language, module_translator = generate_language_and_translator()
                teacher_id = random.choice(lecturers)
            else:
                if city is None:
                    module_language, module_translator = generate_language_and_translator()
                    if module_language != 1:
                        city = users_cities[module_translator]
                else:
                    module_language, module_translator = generate_language_and_translator_from_city(city)
                teacher_id = generate_teacher_from_city(city)
            course_modules.append([module_id, course_id, module_name, module_type, teacher_id, module_language, module_translator])
    return course_modules
        


course_modules = generate_course_modules()
with open(output_csv, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(["ModuleID", "CourseID", "ModuleName", "ModuleType", "LecturerID", "LanguageID", "TranslatorID"])
    writer.writerows(course_modules)


            