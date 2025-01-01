import csv
from datetime import datetime

webinaries_csv = 'final_webinaries.csv'
user_roles_csv = 'UserRoles.csv'
employees_csv = 'Employees.csv'
Translated_languages_csv = 'TranslatedLanguage.csv'


def wczytaj_liste_z_csv(plik):
    with open(plik, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Pomijanie nagłówka
        return [row for row in reader]
    

webinaries = wczytaj_liste_z_csv(webinaries_csv)
user_roles = wczytaj_liste_z_csv(user_roles_csv)
employees = wczytaj_liste_z_csv(employees_csv)
translated_languages = wczytaj_liste_z_csv(Translated_languages_csv)
translations = dict()
teaching = dict()
flags = [True]*5

def check_if_translator_employeed_before_start_date():
    for webinary in webinaries:
        start_date = datetime.strptime(webinary[7], '%d.%m.%Y %H:%M')
        translator_id = webinary[6]
        translations[translator_id] = None
        for employee in employees:
            if employee[0] == translator_id:
                employment_date = datetime.strptime(employee[1], '%Y-%m-%d')
                if employment_date > start_date:
                    print(f"Translator {translator_id} was employed after start date of webinary {webinary[1]}")
                    flags[0] = False
                break

def check_if_teacher_employeed_before_start_date():
    for webinary in webinaries:
        start_date = datetime.strptime(webinary[7], '%d.%m.%Y %H:%M')
        teacher_id = webinary[3]
        teaching[teacher_id] = None
        for employee in employees:
            if employee[0] == teacher_id:
                employment_date = datetime.strptime(employee[1], '%Y-%m-%d')
                if employment_date > start_date:
                    print(f"Teacher {teacher_id} was employed after start date of webinary {webinary[1]}")
                    flags[1] = False
                break

def check_if_there_arent_two_translations_at_the_same_time_for_one_employee():
    for webinary in webinaries:
        start_date = datetime.strptime(webinary[7], '%d.%m.%Y %H:%M')
        end_date = datetime.strptime(webinary[8], '%d.%m.%Y %H:%M')
        translator_id = webinary[6]
        teacher_id = webinary[3]
        if translator_id != "" and (translations[translator_id] == None or translations[translator_id] <= start_date):
            translations[translator_id] = end_date
        elif translator_id != "":
            print(f"Translator {translator_id} has two translations at the same time for webinary {webinary[1]}")
            flags[2] = False
        if teaching[teacher_id] == None or teaching[teacher_id] <= start_date:
            teaching[teacher_id] = end_date
        else:
            print(f"Teacher {teacher_id} has two translations at the same time for webinary {webinary[1]}")
            flags[3] = False

def check_if_start_date_is_before_end_date():
    for webinary in webinaries:
        start_date = datetime.strptime(webinary[7], '%d.%m.%Y %H:%M')
        end_date = datetime.strptime(webinary[8], '%d.%m.%Y %H:%M')
        if start_date > end_date:
            print(f"Start date is after end date for webinary {webinary[1]}")
            flags[4] = False

if __name__ == "__main__":
    check_if_translator_employeed_before_start_date()
    check_if_teacher_employeed_before_start_date()
    check_if_there_arent_two_translations_at_the_same_time_for_one_employee()
    if flags:
        print("All checks passed")
   

