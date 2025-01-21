EXEC AddNewWebinar
    @WebinarName = 'Nowy Webinar',
    @StartDate = '2025-01-16 14:00',
    @EndDate = '2025-01-16 15:30',
    @TeacherID = 977,
    @TranslatorID = null,
    @LanguageID = 1,
    @Price = 200

EXEC AddNewCourse
    @CourseName = 'Nowy kurs',
    @CourseDescription = 'Opis Kursu',
    @CourseCoordinatorID = 13,
    @CoursePrice = 500,
    @StudentLimit = 20

EXEC AddCourseModule
    @CourseID = 281,
    @ModuleName = 'Modul 1',
    @ModuleType = 1,
    @LecturerID = 319,
    @TranslatorID = null,
    @LanguageID = 1

EXEC AddCourseModule
     @CourseID = 281,
     @ModuleName = 'Modul 2',
     @ModuleType = 2,
     @LecturerID = 248,
     @TranslatorID = null,
     @LanguageID = 1

EXEC AddCourseModule
     @CourseID = 281,
     @ModuleName = 'Modul 3',
     @ModuleType = 3,
     @LecturerID = 936,
     @TranslatorID = null,
     @LanguageID = 1

EXEC AddCourseModule
     @CourseID = 281,
     @ModuleName = 'Modul 4',
     @ModuleType = 4,
     @LecturerID = 307,
     @TranslatorID = null,
     @LanguageID = 1

EXEC AddCourseMeeting
    @ModuleID = 2,
    @MeetingType = 2,
    @StartDate = '2025-01-18 12:00',
    @EndDate = '2025-01-18 14:00',
    @RoomID = null

EXEC AddNewStudy
    @StudyName = 'Nowe studia',
    @StudiesCoordinatorID = 6,
    @StudyPrice = 500,
    @NumberOfTerms = 7,
    @StudentLimit = 10

EXEC AddNewSubject
    @SubjectName = 'Nowy przedmiot',
    @TermNumber = 1,
    @NumberOfHoursInTerm = 21,
    @TeacherID = 984,
    @StudiesID = 10

EXEC AddSubjectMeeting
    @SubjectID = 263,
    @MeetingType = 1,
    @StartTime = '2025-02-01 11:00',
    @EndTime = '2025-02-01 14:00',
    @MeetingPrice = 100,
    @MeetingPriceForOthers = 200,
    @StudentLimit = 10,
    @RoomID = 12,
    @MeetingLink = null