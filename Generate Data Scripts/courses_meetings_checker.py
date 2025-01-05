import os, csv, datetime

os.chdir(os.path.dirname(__file__))

def wczytaj_liste_z_csv(plik):
    with open(plik, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Pomijanie nagłówka
        return [row for row in reader]

meetings_csv = "../Tables Data/a_new_meetings.csv"
courses_csv = "../Tables Data/courses_without_students_limit.csv"
modules_csv = "../Tables Data/new_modules.csv"
employees_csv = "../Tables Data/Employees.csv"
webinars_csv = "../Tables Data/Webinars.csv"

meetings = wczytaj_liste_z_csv(meetings_csv)    
courses = wczytaj_liste_z_csv(courses_csv)  
modules = wczytaj_liste_z_csv(modules_csv)  
employees = wczytaj_liste_z_csv(employees_csv)
webinars = wczytaj_liste_z_csv(webinars_csv)

users_meetings = {}
for module in modules:
    if module[4] not in users_meetings:
        users_meetings[module[4]] = []
    if module[6] != "" and module[6] not in users_meetings:
        users_meetings[module[6]] = []

modules_meetings = {}
for meeting in meetings:
    if meeting[1] not in modules_meetings.keys():
        modules_meetings[meeting[1]] = []
    modules_meetings[meeting[1]].append((meeting[2], meeting[3]))

def add_meetings_date_to_users():
    for module in modules_meetings.keys():
        for meeting in modules_meetings[module]:
            users_meetings[modules[int(module)-1][4]].append((meeting[0], meeting[1]))
            if modules[int(module)-1][6] != "":
                users_meetings[modules[int(module)-1][6]].append((meeting[0], meeting[1]))

add_meetings_date_to_users()

def make_dict_with_employees():
    employees_dict = {}
    for employee in employees:
        employees_dict[employee[0]] = employee[1]
    return employees_dict
employees_dict = make_dict_with_employees()

def check_if_date_is_ok(user_id, start_date, end_date):
    cnt = 0
    for meeting in users_meetings[user_id]:
        meeting_start = meeting[0]
        meeting_end = meeting[1]
        if not (end_date <= meeting_start or start_date >= meeting_end):
            cnt += 1
        if cnt>1:
            return False
    return True

def check_if_employee_has_more_than_one_meeting_at_the_same_time():
    for user in users_meetings.keys():
        for meeting in users_meetings[user]:
            if not check_if_date_is_ok(user, meeting[0], meeting[1]):
                print(user, meeting[0], meeting[1])
                print("User has more than one meeting at the same time")
                return False
    return True


def check_if_all_meetings_are_between_monday_and_thursday():
    for module in modules_meetings.keys():
        for meeting in modules_meetings[module]:
            start_date = datetime.datetime.strptime(meeting[0], '%Y-%m-%d %H:%M')
            if start_date.weekday() > 3:
                print(module, meeting[0])
                print("Meeting is not between Monday and Thursday")
                return False
    return True

def check_if_all_meetings_are_between_2021_and_2026():
    for module in modules_meetings.keys():
        for meeting in modules_meetings[module]:
            start_date = datetime.datetime.strptime(meeting[0], '%Y-%m-%d %H:%M')
            if start_date.year < 2021 or start_date.year > 2026:
                print(module, meeting[0])
                print("Meeting is not between 2021 and 2026")
                return False
    return True


def check_if_employee_employed_before_course_start_date():
    for module in modules:
        lecturer_id = module[4]
        translator_id = module[6]
        lecturer_start_date = datetime.datetime.strptime(employees_dict[lecturer_id], '%Y-%m-%d')
        if translator_id != "":
            translator_start_date = datetime.datetime.strptime(employees_dict[translator_id], '%Y-%m-%d')
        else:
            translator_start_date = None
        for meeting in modules_meetings[module[0]]:
            meeting_start_date = datetime.datetime.strptime(meeting[0], '%Y-%m-%d %H:%M')
            if lecturer_start_date > meeting_start_date:
                print(module)
                print("Lecturer was employed after meeting start date")
                return False
            if translator_start_date is not None and translator_start_date and translator_start_date > meeting_start_date:
                print(module)
                print("Translator was employed after meeting start date")
                return False
    return True

def check_if_employee_dont_have_webinar_at_the_same_time():
    for webinar in webinars:
        webinar_start_date = webinar[7]
        webinar_end_date = webinar[8]
        if webinar[3] in users_meetings.keys():
            if not check_if_date_is_ok(webinar[3], webinar_start_date, webinar_end_date):
                print(webinar)
                print("User has more than one meeting at the same time")
                break
        if webinar[6]!= "" and webinar[6] in users_meetings.keys():
            if not check_if_date_is_ok(webinar[6], webinar_start_date, webinar_end_date):
                print(webinar)
                print("User has more than one meeting at the same time")
                return False
        return True

def make_dict_with_beginning_and_end_of_course():
    dict = {}
    for course in courses:
        dict[course[0]] = None
    return dict
courses_dict = make_dict_with_beginning_and_end_of_course()

def check_if_course_is_no_more_than_14_days():
    for module in modules:
        course_id = module[1]
        for meeting in modules_meetings[module[0]]:
            meeting_date = datetime.datetime.strptime(meeting[0], '%Y-%m-%d %H:%M')
            if courses_dict[course_id] is None:
                courses_dict[course_id] = (meeting_date, meeting_date)
            else:
                if meeting_date < courses_dict[course_id][0]:
                    courses_dict[course_id] = (meeting_date, courses_dict[course_id][1])
                if meeting_date > courses_dict[course_id][1]:
                    courses_dict[course_id] = (courses_dict[course_id][0], meeting_date)
    for course in courses_dict.keys():
        if (courses_dict[course][1] - courses_dict[course][0]).days > 14:
            print(course)
            print("Course is longer than 14 days")
            return False
    return True

def check_if_all_modules_have_at_least_one_meeting():
    for module in modules:
        if module[0] not in modules_meetings.keys():
            print(module)
            print("Module has no meetings")
            return False
    return True

def check_if_modules_type_2_has_at_leat_2_meetings():
    for module in modules:
        if module[3] == "2":
            if module[0] not in modules_meetings.keys() or len(modules_meetings[module[0]]) < 2:
                print(module)
                print("Module type 2 has less than 2 meetings")
                return False
    return True

def check_if_all_meetings_are_correct():
    if (check_if_modules_type_2_has_at_leat_2_meetings and check_if_all_meetings_are_between_monday_and_thursday() and check_if_all_meetings_are_between_2021_and_2026() and check_if_employee_dont_have_webinar_at_the_same_time() and check_if_employee_has_more_than_one_meeting_at_the_same_time and check_if_course_is_no_more_than_14_days() and check_if_all_modules_have_at_least_one_meeting() and check_if_modules_type_2_has_at_leat_2_meetings()):
        print("All meetings are correct")
    else:
        print("Meetings are not correct")

check_if_all_meetings_are_correct()




        
