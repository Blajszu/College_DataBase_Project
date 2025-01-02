import os, csv, random
from datetime import datetime, timedelta

os.chdir(os.path.dirname(__file__))

course_modules_csv = "../Tables Data/courses_modules.csv"
meetings_csv = "../Tables Data/OnlineCourseMeeting.csv"
courses_csv = "../Tables Data/Courses.csv"

def wczytaj_liste_z_csv(plik):
    with open(plik, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Pomijanie nagłówka
        return [row for row in reader]

modules = wczytaj_liste_z_csv(course_modules_csv)
meetings = wczytaj_liste_z_csv(meetings_csv)
courses = wczytaj_liste_z_csv(courses_csv)

courses_dates = {}
for course in courses:
    courses_dates[course[0]] = None

for meeting in meetings:
    start = datetime.strptime(meeting[2], "%Y-%m-%d %H:%M")
    end = datetime.strptime(meeting[3], "%Y-%m-%d %H:%M")
    module = meeting[1]
    course = modules[int(module)-1][1]
    if courses_dates[course] == None:
        courses_dates[course] = [start, end]
    else:
        if start < courses_dates[course][0]:
            courses_dates[course][0] = start
        if end > courses_dates[course][1]:
            courses_dates[course][1] = end

for meeting in meetings:
    module = meeting[1]
    course = modules[int(module)-1][1]
    if modules[int(module)-1][3] == "2":
        meeting[2] = courses_dates[course][0]
        meeting[3] = courses_dates[course][1]

with open(meetings_csv, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(["MeetingID", "ModuleID", "StartDate", "EndDate", "MeetingLink", "VideoLink"])
    for meeting in meetings:
        writer.writerow(meeting)



