import csv, random, os

os.chdir(os.path.dirname(__file__))

rooms_csv = "../Tables Data/Rooms.csv"
courses_csv = "../Tables Data/courses_with_price.csv"
output_csv = "../Tables Data/Courses.csv"
course_modules_csv = "../Tables Data/courses_modules.csv"
course_stationary_meetings_csv = "../Tables Data/StationaryCourseMeeting.csv"

def wczytaj_liste_z_csv(plik):
    with open(plik, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Pomijanie nagłówka
        return [row for row in reader]

courses = wczytaj_liste_z_csv(courses_csv)
course_modules = wczytaj_liste_z_csv(course_modules_csv)
course_stationary_meetings = wczytaj_liste_z_csv(course_stationary_meetings_csv)
rooms = wczytaj_liste_z_csv(rooms_csv)

def make_dict_with_min_course_room_capacity():
    min_course_room_capacity = {}
    for course in courses:
        min_course_room_capacity[course[0]] = 1000
    return min_course_room_capacity

min_course_room_capacity = make_dict_with_min_course_room_capacity()

def make_dict_with_room_capacity():
    room_capacity = {}
    for room in rooms:
        room_capacity[room[0]] = int(room[4])
    return room_capacity
room_capacity = make_dict_with_room_capacity()


for meeting in course_stationary_meetings:
    room = meeting[2]
    capacity = room_capacity[room]
    module = meeting[1]
    course = course_modules[int(module)-1][1]
    if capacity < min_course_room_capacity[course]:
        min_course_room_capacity[course] = capacity
    
for course in courses:
    if min_course_room_capacity[course[0]] == 1000:
        course.append("")
    else:
        random_limit = random.randint(18,min_course_room_capacity[course[0]])
        course.append(str(random_limit))

with open(output_csv, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(["CourseID", "CourseName", "CourseCoordinatorID", "CourseDescription", "CoursePrice", "StudentLimit"])
    for course in courses:
        writer.writerow(course)
