import random, os, csv
from datetime import datetime, timedelta

os.chdir(os.path.dirname(__file__))

courses_csv = "../Tables Data/courses_without_students_limit.csv"
modules_csv = "../Tables Data/CourseModules.csv"
meetings_csv = "../Tables Data/a_new_meetings.csv"
output_csv = "../Tables Data/courses_with_price.csv"

def wczytaj_liste_z_csv(plik):
    with open(plik, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Pomijanie nagłówka
        return [row for row in reader]

courses = wczytaj_liste_z_csv(courses_csv)
modules = wczytaj_liste_z_csv(modules_csv)
meetings = wczytaj_liste_z_csv(meetings_csv)

output_courses = []

modules_meetings = {}
for meeting in meetings:
    if meeting[1] not in modules_meetings.keys():
        modules_meetings[meeting[1]] = []
    modules_meetings[meeting[1]].append(meeting)

courses_modules = {}
for module in modules:
    if module[1] not in courses_modules.keys():
        courses_modules[module[1]] = []
    courses_modules[module[1]].append(module[0])

for course in courses:
    time_of_course_meeetings = timedelta(minutes = 0)
    for module in courses_modules[course[0]]:
        for meeting in modules_meetings[module]:
            time_of_course_meeetings += datetime.strptime(meeting[3], "%Y-%m-%d %H:%M") - datetime.strptime(meeting[2], "%Y-%m-%d %H:%M")
    price = round(time_of_course_meeetings.total_seconds() / 3600 * 50)
    print(price, time_of_course_meeetings.total_seconds() / 3600)
    output_courses.append([course[0], course[1], course[2], course[3], course[4], price])

with open(output_csv, mode='w', encoding='utf-8', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["CourseID", "CourseName", "CourseCoordinatorID", "CourseDescription", "CoursePrice"])
    for row in output_courses:
        writer.writerow(row)


