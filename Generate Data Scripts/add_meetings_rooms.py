import random, csv, os

os.chdir(os.path.dirname(__file__))

meetings_csv = "../Tables Data/StationaryCourseMeeting.csv"
courses_csv = "../Tables Data/Courses.csv"
modules_csv = "../Tables Data/CourseModules.csv"
users = "../Tables Data/Users.csv"
rooms = "../Tables Data/Rooms.csv"


def wczytaj_liste_z_csv(plik):
    with open(plik, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Pomijanie nagłówka
        return [row for row in reader]

meetings = wczytaj_liste_z_csv(meetings_csv)
courses = wczytaj_liste_z_csv(courses_csv)
modules = wczytaj_liste_z_csv(modules_csv)
users = wczytaj_liste_z_csv(users)
rooms = wczytaj_liste_z_csv(rooms)


def make_dict_with_cities_rooms():
    cities_rooms = {}
    for room in rooms:
        city = room[3]
        if city not in cities_rooms.keys():
            cities_rooms[city] = []
        cities_rooms[city].append(room[0])
    return cities_rooms

cities_rooms = make_dict_with_cities_rooms()

cnt = 0
for meeting in meetings:
    module = modules[int(meeting[1])-1]
    course_id = module[1]
    lecturer = users[int(module[4])-1]
    city = lecturer[4]
    if city in cities_rooms.keys():
        room = random.choice(cities_rooms[city])
    else:
        cnt += 1
        print(course_id)
    meeting.insert(2, room)

output = 'new_stationary_meetings.csv'
with open(output, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(["MeetingID", "ModuleID", "RoomID", "StartDate", "EndDate"])
    for meeting in meetings:
        writer.writerow(meeting)

