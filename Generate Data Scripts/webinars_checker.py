import csv
from datetime import datetime, timedelta

webinars_csv = '../Tables Data/Webinars.csv'
user_roles_csv = '../Tables Data/UserRoles.csv'
employees_csv = '../Tables Data/Employees.csv'
Translated_languages_csv = '../Tables Data/TranslatedLanguage.csv'


def wczytaj_liste_z_csv(plik):
    with open(plik, mode = 'r', encoding = 'utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Pomijanie nagłówka
        return [row for row in reader]


webinars = wczytaj_liste_z_csv(webinars_csv)
user_roles = wczytaj_liste_z_csv(user_roles_csv)
employees = wczytaj_liste_z_csv(employees_csv)
translated_languages = wczytaj_liste_z_csv(Translated_languages_csv)
translations = dict()
teaching = dict()
flags = [True] * 6


def check_if_translator_employed_before_start_date():
    for webinar in webinars:
        start_date = datetime.strptime(webinar[7], '%d.%m.%Y %H:%M')
        translator_id = webinar[6]
        translations[translator_id] = None
        for employee in employees:
            if employee[0] == translator_id:
                employment_date = datetime.strptime(employee[1], '%Y-%m-%d')
                if employment_date > start_date:
                    print(f"Translator {translator_id} was employed after start date of webinar {webinar[1]}")
                    flags[0] = False
                break


def check_if_teacher_employed_before_start_date():
    for webinar in webinars:
        start_date = datetime.strptime(webinar[7], '%d.%m.%Y %H:%M')
        teacher_id = webinar[3]
        teaching[teacher_id] = None
        for employee in employees:
            if employee[0] == teacher_id:
                employment_date = datetime.strptime(employee[1], '%Y-%m-%d')
                if employment_date > start_date:
                    print(f"Teacher {teacher_id} was employed after start date of webinary {webinar[1]}")
                    flags[1] = False
                break


def check_if_there_arent_two_translations_at_the_same_time_for_one_employee():
    for webinar in webinars:
        start_date = datetime.strptime(webinar[7], '%d.%m.%Y %H:%M')
        end_date = datetime.strptime(webinar[8], '%d.%m.%Y %H:%M')
        translator_id = webinar[6]
        teacher_id = webinar[3]
        if translator_id != "" and (translations[translator_id] == None or translations[translator_id] <= start_date):
            translations[translator_id] = end_date
        elif translator_id != "":
            print(f"Translator {translator_id} has two translations at the same time for webinary {webinar[1]}")
            flags[2] = False
        if teaching[teacher_id] == None or teaching[teacher_id] <= start_date:
            teaching[teacher_id] = end_date
        else:
            print(f"Teacher {teacher_id} has two translations at the same time for webinary {webinar[1]}")
            flags[3] = False


def check_if_start_date_is_before_end_date():
    for webinar in webinars:
        start_date = datetime.strptime(webinar[7], '%d.%m.%Y %H:%M')
        end_date = datetime.strptime(webinar[8], '%d.%m.%Y %H:%M')
        if start_date > end_date:
            print(f"Start date is after end date for webinary {webinar[1]}")
            flags[4] = False


def check_if_duration_is_between_45_and_180():
    for webinar in webinars:
        start_date = datetime.strptime(webinar[7], '%d.%m.%Y %H:%M')
        end_date = datetime.strptime(webinar[8], '%d.%m.%Y %H:%M')
        duration = end_date - start_date
        if duration < timedelta(minutes = 45) or duration > timedelta(minutes = 180):
            print(
                f"Duration of webinar {webinar[1]} is not between 45 and 180 minutes, webinar no {webinar[0]} - {duration}")
            flags[5] = False


if __name__ == "__main__":
    check_if_translator_employed_before_start_date()
    check_if_teacher_employed_before_start_date()
    check_if_there_arent_two_translations_at_the_same_time_for_one_employee()
    check_if_start_date_is_before_end_date()
    check_if_duration_is_between_45_and_180()
    if all(flags):
        print("ALl data correct")
    else:
        print("Something incorrect")
