import csv
import random
from datetime import datetime, timedelta
import os

os.chdir(os.path.dirname(__file__))

def load_modules():
    modules = []
    with open('COURSES_MODULES.csv', 'r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        for row in reader:
            modules.append({
                'ModuleID': int(row['ModuleID']),
                'CourseID': int(row['CourseID']),
                'LecturerID': int(row['LecturerID']),
                'TranslatorID': int(row['TranslatorID']) if row['TranslatorID'] else None
            })
    return modules

def generate_meeting_time(base_date):
    # Generate random time between 8:00 and 18:00
    hour = random.randint(8, 17)
    minute = random.choice([0, 15, 30, 45])
    return base_date.replace(hour=hour, minute=minute)

def check_lecturer_translator_conflict(schedule, lecturer_id, translator_id, start_time, duration):
    end_time = start_time + timedelta(minutes=duration)
    
    for existing in schedule:
        existing_end = existing['start'] + timedelta(minutes=existing['Duration'])
        if start_time < existing_end and end_time > existing['start']:
            if lecturer_id == existing['lecturer_id']:
                return True
            if translator_id and translator_id == existing['translator_id']:
                return True
    return False

def generate_meetings():
    modules = load_modules()
    meetings = []
    schedule = []
    meeting_id = 1
    
    # Group modules by course
    courses = {}
    for module in modules:
        if module['CourseID'] not in courses:
            courses[module['CourseID']] = []
        courses[module['CourseID']].append(module)

    for course_modules in courses.values():
        # Generate base date for the course
        base_year = random.randint(2021, 2025)
        base_month = random.randint(1, 12)
        base_day = random.randint(1, 28)  # Avoiding month end issues
        course_start_date = datetime(base_year, base_month, base_day)

        for module in course_modules:
            # Generate random day within 14 days from course start
            days_offset = random.randint(0, 14)
            module_date = course_start_date + timedelta(days=days_offset)
            
            # Ensure it's Monday-Thursday
            while module_date.weekday() >= 4:
                module_date += timedelta(days=1)

            # Generate 2-4 meetings for the module
            num_meetings = random.randint(2, 4)
            durations = [45, 60, 90]
            
            for _ in range(num_meetings):
                while True:
                    duration = random.choice(durations)
                    start_time = generate_meeting_time(module_date)
                    
                    if not check_lecturer_translator_conflict(
                        schedule, 
                        module['LecturerID'], 
                        module['TranslatorID'], 
                        start_time, 
                        duration
                    ):
                        meeting = {
                            'MeetingID': meeting_id,
                            'ModuleID': module['ModuleID'],
                            'StartTime': start_time,
                            'Duration': duration,
                            'lecturer_id': module['LecturerID'],
                            'translator_id': module['TranslatorID'],
                            'start': start_time  # For conflict checking
                        }
                        schedule.append(meeting)
                        meetings.append(meeting)
                        print(f"Generated meeting {meeting_id} for module {module['ModuleID']}")
                        meeting_id += 1
                        break

    return meetings

def save_meetings(meetings):
    with open('claude_meeting_generated.csv', 'w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(['MeetingID', 'ModuleID', 'StartTime', 'EndTIme'])
        for meeting in meetings:
            print(meeting['MeetingID'])
            writer.writerow([
                meeting['MeetingID'],
                meeting['ModuleID'],
                meeting['StartTime'].strftime('%Y-%m-%d %H:%M'),
                (meeting['StartTime'] + timedelta(minutes=meeting['Duration'])).strftime('%Y-%m-%d %H:%M')
            ])

if __name__ == '__main__':
    meetings = generate_meetings()
    save_meetings(meetings)
    print(f"Generated {len(meetings)} meetings")