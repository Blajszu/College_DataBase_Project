import csv, random, os, string
from datetime import datetime, timedelta

os.chdir(os.path.dirname(__file__))

def wczystaj_liste_z_csv(plik):
    with open(plik, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)
        return [row for row in reader]
    
def wczytaj_liste_z_csv_z_naglowkiem(plik):
    with open(plik, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        return [row for row in reader]


course_modules_csv = "../Tables Data/CourseModules.csv" 
course_modules = wczystaj_liste_z_csv(course_modules_csv)
courses_csv = "../Tables Data/Courses.csv"
courses = wczystaj_liste_z_csv(courses_csv)
online_course_meetings_csv = "../Tables Data/OnlineCourseMeeting.csv"
online_course_meetings = wczystaj_liste_z_csv(online_course_meetings_csv)
stationary_course_meetings_csv = "../Tables Data/StationaryCourseMeeting.csv"
stationary_course_meetings = wczystaj_liste_z_csv(stationary_course_meetings_csv)
order_details_csv = "../Tables Data/order_details1.csv"
order_details = wczystaj_liste_z_csv(order_details_csv)
users_csv = "../Tables Data/Users.csv"
users = wczystaj_liste_z_csv(users_csv)
orders_csv = "../Tables Data/orders.csv"
orders = wczystaj_liste_z_csv(orders_csv)
studies_csv = "../Tables Data/Studies.csv"
studies = wczystaj_liste_z_csv(studies_csv)
subjects_csv = "../Tables Data/Subjects.csv"
subjects = wczystaj_liste_z_csv(subjects_csv)
webinars_csv = "../Tables Data/Webinars.csv"
webinars = wczystaj_liste_z_csv(webinars_csv)
study_meetings_csv = "../Tables Data/StudyMeetings.csv"
study_meetings = wczystaj_liste_z_csv(study_meetings_csv)
starts_and_ends_csv = "./Result_68.csv"
dates = wczytaj_liste_z_csv_z_naglowkiem(starts_and_ends_csv)



def check_if_date_is_ok(user_id, start_date, end_date):
    cnt = 0
    for meeting in users_meetings[user_id]:
        meeting_start = datetime.strptime(meeting[0][:16],"%Y-%m-%d %H:%M")
        meeting_end = datetime.strptime(meeting[1][:16],"%Y-%m-%d %H:%M")
        if not (end_date <= meeting_start or start_date >= meeting_end):
            cnt += 1
        if cnt>1:
            return False
    return True


users_meetings = {}

#dodaj wszystkie study_meetings i kursy z orderów do usera
for user in users:
    users_meetings[user[0]] = []
    for order in orders:
        if order[1] == user[0]:
            for order_detail in order_details:
                if order_detail[1]==order[0]:
                    if(order_detail[3] == "3"):#studies
                        for subject in subjects:
                            if subject[1]==order_detail[2]:
                                for study_meeting in study_meetings:
                                    if study_meeting[1]==subject[0]:
                                        users_meetings[user[0]].append((study_meeting[6], study_meeting[7]))
                    elif(order_detail[3] == "2"):#courses
                        for course_module in course_modules:
                            if course_module[1]==order_detail[2]:
                                for stationary_course_meeting in stationary_course_meetings:
                                    if stationary_course_meeting[1]==course_modules[0]:
                                        users_meetings[user[0]].append((stationary_course_meeting[3], stationary_course_meeting[4]))
                                for online_course_meeting in online_course_meetings:
                                    if online_course_meeting[1]==course_modules[0]:
                                        users_meetings[user[0]].append((online_course_meeting[2], online_course_meeting[3]))
                    elif(order_detail[3] == "4"):#pojedyncze spotkania studyjne
                        meeting = study_meetings[int(order_detail[2])-1]
                        users_meetings[user[0]].append((study_meeting[6], study_meeting[7]))
                
# print(users_meetings)


#dodaj wszytskie prowadzone spotkania do userów
for user in users:
    for module in course_modules:
        if module[3]!='2' and (module[4]==user[0] or module[5]==user[0]):
            for online_course_meeting in online_course_meetings:
                if online_course_meeting[1]==module[0]:
                    users_meetings[user[0]].append((online_course_meeting[2], online_course_meeting[3]))
            for stationary_course_meeting in stationary_course_meetings:
                if stationary_course_meeting[1]==module[0]:
                    users_meetings[user[0]].append((stationary_course_meeting[3], stationary_course_meeting[4]))
    for webinar in webinars:
        if webinar[3]==user[0] or webinar[6]==user[0]:
            users_meetings[user[0]].append((webinar[7], webinar[8]))
    for meeting in study_meetings:
        if meeting[2]==user[0] or meeting[9]==user[0]:
            users_meetings[user[0]].append((meeting[6], meeting[7]))




#pogrupuj userów po mieście, pogrupować kursy
users_by_city = {}
courses_by_city = {}
courses_cities = {}
for user in users:
    if user[4] not in users_by_city:
        users_by_city[user[4]] = []
    users_by_city[user[4]].append(user[0])
for course in courses:
    for module in course_modules:
        if module[1]==course[0] and module[3]!="2" and module[3]!="3":
            if users[int(module[4])-1][4] not in courses_by_city:
                courses_by_city[users[int(module[4])-1][4]] = []
            courses_by_city[users[int(module[4])-1][4]].append(course[0])
            courses_cities[course[0]] = users[int(module[4])-1][4]


# # print(stationary_course_meetings)
def generate_course_and_webinars_orders():
    global webinars, courses, course_modules, stationary_course_meetings, online_course_meetings, users_by_city, courses_cities, course_dates
    course_dates = {}
    for i, course in enumerate(courses):
        course_dates[str(i+1)] = (datetime.strptime(dates[i][1][:16],"%Y-%m-%d %H:%M"), datetime.strptime(dates[i][2][:16],"%Y-%m-%d %H:%M"))

    # print(course_dates)
    # for course in courses:
    #     start = None
    #     end = None
    #     cnt=0
    #     last1 = 0
    #     last2 = 0
    #     for module in course_modules:
    #         for i in range(last1, len(stationary_course_meetings)):
    #             stationary_course_meeting = stationary_course_meetings[i]
    #             print(stationary_course_meeting)
    #             # print(cnt)
    #             # cnt+=1
    #             if stationary_course_meeting[1]==module[0]:
    #                 if start==None or start>datetime.strptime(stationary_course_meeting[3][:16],"%Y-%m-%d %H:%M"):
    #                     start = datetime.strptime(stationary_course_meeting[3][:16], "%Y-%m-%d %H:%M")
    #                 if end==None or end<datetime.strptime(stationary_course_meeting[4][:16],"%Y-%m-%d %H:%M"):
    #                     end = datetime.strptime(stationary_course_meeting[4][:16], "%Y-%m-%d %H:%M") 
    #             if stationary_course_meeting[1]>module[0]:
    #                 last1 = i
    #                 break
    #         for i in range(last2,len(online_course_meetings)):
    #             online_course_meeting = online_course_meetings[i]
    #             if online_course_meeting[1]==module[0]:
    #                 if start==None or start>datetime.strptime(online_course_meeting[2][:16],"%Y-%m-%d %H:%M"):
    #                     start = datetime.strptime(online_course_meeting[2][:16], "%Y-%m-%d %H:%M")
    #                 if end==None or end<datetime.strptime(online_course_meeting[3][:16],"%Y-%m-%d %H:%M"):
    #                     end = datetime.strptime(online_course_meeting[3][:16],"%Y-%m-%d %H:%M")
    #             if online_course_meeting[1]>module[0]:
    #                 last2 = i
    #                 break
    #     course_dates[course[0]] = (start, end)

#     # print(course_dates)


    webinars_orders = []
    course_orders = []
    all_users = [user for sublist in users_by_city.values() for user in sublist]
    # print(all_users)
    #tworz ordersy sprawdzajac czy dodanie koeljnej aktywności z niczym innym nie koliduje
    # print(courses)
    for course in courses:
        if course[0] in courses_cities.keys():
            city = courses_cities[course[0]]
            limit = random.randint(10, int(course[5]))
            counter = 0
            random.shuffle(users_by_city[city])
            for user in (users_by_city[city]):
                
                start_date = course_dates[course[0]][0]
                print(start_date)
                end_date = course_dates[course[0]][1]
                if check_if_date_is_ok(user, start_date, end_date):
                    string_date = start_date.strftime("%Y-%m-%d %H:%M")
                    course_orders.append([course[0],'2',course[4],user,string_date,'stationary/hybrid'])
                    counter+=1
                if counter==limit:
                    break
        else:
            limit = random.randint(10, 20)
            counter = 0
            random.shuffle(all_users)
            for user in (all_users):
                start_date = course_dates[course[0]][0]
                end_date = course_dates[course[0]][1]
                if check_if_date_is_ok(user, start_date, end_date):
                    string_date = start_date.strftime("%Y-%m-%d %H:%M")
                    course_orders.append([course[0],'2',course[4],user,string_date,'online'])
                    counter+=1
                if counter==limit:
                    break

    
    for webinar in webinars:
        limit = random.randint(10, 20)
        counter = 0
        random.shuffle(all_users)
        for user in (all_users):
            start_date = datetime.strptime(webinar[7][:16],"%Y-%m-%d %H:%M")
            end_date = datetime.strptime(webinar[8][:16],"%Y-%m-%d %H:%M")
            if check_if_date_is_ok(user, start_date, end_date):
                webinars_orders.append([webinar[0],'1',webinar[4],user,start_date,'webinar'])
                counter+=1
            if counter==limit:
                break

    output_file = "course_and_webinars_orders.csv"
    # with open(output_file, mode='w', encoding='utf-8', newline='') as file:
    #     writer = csv.writer(file)
    #     writer.writerow(["acivity_id", "acivity_type", "price", "user_id", "start_date", "type"])
    #     for course_order in course_orders:
    #         writer.writerow(course_order)
    #     for webinar_order in webinars_orders:
    #         writer.writerow(webinar_order)

generate_course_and_webinars_orders()
# #############################################

course_and_webinars_orders_detais_csv = "./course_and_webinars_orders.csv"
course_and_webinars_orders = wczystaj_liste_z_csv(course_and_webinars_orders_detais_csv)
generate_course_and_webinars_orders()

def generate_date(start_date):
    delta_days = random.randint(10, 40)
    generated_date = start_date - timedelta(days=delta_days)
    return generated_date.strftime("%Y-%m-%d %H:%M")

def generate_pamyment_link():
    return f"https://www.paypal.com/pl/home/{''.join(random.choices(string.ascii_letters, k=10))}"

course_and_webinars_orders.sort(key=lambda x: datetime.strptime(x[4][:16], "%Y-%m-%d %H:%M"))
course_and_webinars_orders.sort(key=lambda x: x[3])

i = 0
curr_order_id = 584
curr_detail_id = 584
orders_list = []
advances_to_add = []
order_details_to_add = []
while i<len(course_and_webinars_orders):
    group = []
    j = i
   
    while j<len(course_and_webinars_orders) and course_and_webinars_orders[i][3]==course_and_webinars_orders[j][3] and (datetime.strptime(course_and_webinars_orders[j][4][:16], "%Y-%m-%d %H:%M") - datetime.strptime(course_and_webinars_orders[i][4][:16], "%Y-%m-%d %H:%M")).days < 60:
        group.append(course_and_webinars_orders[j])
        j+=1
    order_id = curr_order_id
    curr_order_id+=1
    user_id = course_and_webinars_orders[i][3]
    order_date = generate_date(datetime.strptime(course_and_webinars_orders[i][4][:16], "%Y-%m-%d %H:%M"))
    if order_date>datetime.now().strftime("%Y-%m-%d %H:%M"):
        while j<len(course_and_webinars_orders) and course_and_webinars_orders[i][3]==course_and_webinars_orders[j][3]:
            j+=1
        i = j
        continue
    
    orders_list.append([order_id, user_id, order_date, 0, None, generate_pamyment_link()])
    for k in range(i,j):
        detail = course_and_webinars_orders[k]
        date_of_order = datetime.strptime(order_date, "%Y-%m-%d %H:%M")
        price = detail[2]
        if price != None and date_of_order<datetime.now()+timedelta(days=11):
            payment_date = date_of_order + timedelta(minutes=random.randint(1, 10))
            status = 'udane'
        else:
            payment_date = None
            status = None
        order_details_to_add.append([curr_detail_id, order_id, detail[0], detail[1], price, payment_date, status])
        if detail[1]=='2':
            payment_date = date_of_order + timedelta(minutes=random.randint(1, 10))
            status = 'udane'
            advances_to_add.append([detail[0], round(0.1*float(price),2), payment_date, status])
        curr_detail_id+=1
    i = j

output_file = "courses_and_webinars_orders_after_groupping_1.csv"
with open(output_file, mode='w', encoding='utf-8', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["orderId", "userId", "orderDate", "paymentDeffered", "deffereDate", "paymentLink"])
    for order in orders_list:
        writer.writerow(order)


output_file = "advances_to_add.csv"
with open(output_file, mode='w', encoding='utf-8', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["detailId", "price", "paymentDate", "status"])
    for advance in advances_to_add:
        writer.writerow(advance)

output_file_1 = "order_details_to_add.csv"
with open(output_file_1, mode='w', encoding='utf-8', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["orderId", "activityId", "activityType", "price", "paymentDate", "status"])
    for detail in order_details_to_add:
        writer.writerow(detail)










            
    
    

