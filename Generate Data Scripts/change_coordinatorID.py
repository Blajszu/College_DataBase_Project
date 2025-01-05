import csv, os, random

os.chdir(os.path.dirname(__file__))


def wczytaj_liste_z_csv(plik):
    with open(plik, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Pomijanie nagłówka
        return [row for row in reader]
    
user_roles_csv = "../Tables Data/UserRoles.csv"
courses_csv = "../Tables Data/Courses.csv"
modules_csv = "../Tables Data/CourseModules.csv"
employees_csv = "../Tables Data/Employees.csv"
users_csv = "../Tables Data/Users.csv"
output_csv = "Courses1.csv"

user_roles = wczytaj_liste_z_csv(user_roles_csv)
courses = wczytaj_liste_z_csv(courses_csv)
modules = wczytaj_liste_z_csv(modules_csv)
employees = wczytaj_liste_z_csv(employees_csv)
users = wczytaj_liste_z_csv(users_csv)

coordinators = {}

for user in user_roles:
    if user[1] == "3":
        user_city = users[int(user[0])-1][4]
        if user_city not in coordinators.keys():
            coordinators[user_city] = []
        coordinators[user_city].append(user[0])
print(coordinators)

for course in courses:
    flag = False
    
    for module in modules:
        if module[1]==course[0] and (module[3] == "1" or module[3] == "4"):
            course_city = users[int(module[4])-1][4]
            print(module[4])
            course[2] = random.choice(coordinators[course_city])
            flag = True
            break
    if not flag:
        course_city = random.choice(list(coordinators.keys()))
        course[2] = random.choice(coordinators[course_city])

with open(output_csv, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(["CourseID", "CourseName","CourseCoordinatorID", "CourseDescription","CoursePrice", "StudentLimit"])
    for course in courses:
        writer.writerow(course)

        




