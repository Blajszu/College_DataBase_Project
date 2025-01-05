import csv, os, random, string, datetime

os.chdir(os.path.dirname(__file__))

def wczystaj_liste_z_csv(plik):
    with open(plik, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)
        return [row for row in reader]
    
meetings_csv = "../Tables Data/a_new_meetings.csv"
modules_csv = "../Tables Data/new_modules.csv"

meetings = wczystaj_liste_z_csv(meetings_csv)
modules = wczystaj_liste_z_csv(modules_csv)

stationary_meetings = []
online_meetings = []
stationary_meetings_csv = "../Tables Data/StationaryCourseMeeting.csv"
online_meetings_csv = "../Tables Data/OnlineCourseMeeting.csv"

def generate_video_link():
    return "https://www.video-platform.com/watch?v=" + ''.join(random.choice(string.ascii_letters) for i in range(11))
def generate_meeting_link():
    return "https://www.meeting-platform.com/meeting?id=" + ''.join(random.choice(string.ascii_letters) for i in range(11))

modules_meeting = {}
for module in modules:
    modules_meeting[module[0]] = []
for meeting in meetings:
    modules_meeting[meeting[1]].append(meeting)

last_module = None
for meeting in meetings:
    module = modules[int(meeting[1])-1]
    if module[0] != last_module:
        meeting_number = 0
        last_module = module[0]
    if module[3] == "1":
        stationary_meetings.append([meeting[0], meeting[1], meeting[2], meeting[3]])
    if module[3] =="2" or module[3] == "3":
        date = datetime.datetime.strptime(meeting[2], '%Y-%m-%d %H:%M')
        if date < datetime.datetime.now()+datetime.timedelta(days=20):
            meeting_link = generate_meeting_link()
        else:
            meeting_link = None
        if date < datetime.datetime.now():
            video_link = generate_video_link()
        else:
            video_link = None
        online_meetings.append([meeting[0],meeting[1], meeting[2], meeting[3], meeting_link, video_link])
    if module[3] == "4":
        meeting_number += 1
        number_of_meetings = len(modules_meeting[meeting[1]])
        if (meeting_number) % 2 == 0:#stationary meeting
            stationary_meetings.append([meeting[0], meeting[1], meeting[2], meeting[3]])
        else:#online meeting
            date = datetime.datetime.strptime(meeting[2], '%Y-%m-%d %H:%M')
            if date < datetime.datetime.now()+datetime.timedelta(days=20):
                meeting_link = generate_meeting_link()
            else:
                meeting_link = None
            if date < datetime.datetime.now():
                video_link = generate_video_link()
            else:
                video_link = None
            online_meetings.append([meeting[0],meeting[1], meeting[2], meeting[3], meeting_link, video_link])

with open(stationary_meetings_csv, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['MeetingID', 'ModuleID', 'StartDate', 'EndDate'])
    for meeting in stationary_meetings:
        writer.writerow(meeting)

with open(online_meetings_csv, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['MeetingID', 'ModuleID', 'StartDate', 'EndDate', 'MeetingLink', 'VideoLink'])
    for meeting in online_meetings:
        writer.writerow(meeting)



