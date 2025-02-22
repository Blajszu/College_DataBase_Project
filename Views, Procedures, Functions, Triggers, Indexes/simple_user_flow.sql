EXEC AddNewWebinar
    @WebinarName = 'Nowy Webinar',
	@WebinarDescription = 'opis webinaru',
    @StartDate = '2025-01-27 14:00',
    @EndDate = '2025-01-27 15:30',
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
    @MeetingType = 'Stationary',
    @StartDate = '2025-01-18 12:00',
    @EndDate = '2025-01-18 14:00',
    @RoomID = null

EXEC AddCourseMeeting
    @ModuleID = 2,
    @MeetingType = 'Online',
    @StartDate = '2025-01-18 12:00',
    @EndDate = '2025-01-18 14:00',
    @RoomID = null

EXEC AddNewStudy
    @StudyName = 'Nowe studia',
	@StudyDescription = 'opis studiów',
    @StudiesCoordinatorID = 478,
    @StudyPrice = 500,
    @NumberOfTerms = 7,
    @StudentLimit = 10

EXEC AddNewSubject
    @SubjectName = 'Nowy przedmiot',
	@SubjectDescription = 'opis przedmiotu',
    @TermNumber = 1,
    @NumberOfHoursInTerm = 21,
    @TeacherID = 984,
    @StudiesID = 11

EXEC AddSubjectMeeting
    @SubjectID = 1109,
	@LanguageId = 1,
    @MeetingType = 'Online Synchroniczny',
    @StartTime = '2025-02-01 11:00',
    @EndTime = '2025-02-01 14:00',
	@LecturerID = 5,
    @MeetingPrice = 100,
    @MeetingPriceForOthers = 200,
    @StudentLimit = 10,
    @RoomID = null,
    @MeetingLink = 'link';

EXEC AddSubjectMeeting
    @SubjectID = 1109,
	@LanguageId = 1,
    @MeetingType = 'Stacjonarny',
    @StartTime = '2025-02-02 11:00',
    @EndTime = '2025-02-02 14:00',
	@LecturerID = 5,
    @MeetingPrice = 100,
    @MeetingPriceForOthers = 200,
    @StudentLimit = 10,
    @RoomID = 12,
    @MeetingLink = null;



EXEC UpdatePaymentStatusOrderDetails
	@DetailID = 69412;


EXEC AddUser
	@FirstName = 'Jagoda',
	@LastName = 'Kurosad',
	@Street = 'Tokarskiego 1',
	@City = 'Kraków',
	@Email = 'jagoda.kurosad@example.com',
	@Phone = '659874452',
	@DateOfBirth = '2005-10-05';


DECLARE @ActivityList ACTIVITYLISTTYPE;
INSERT INTO @ActivityList (activityid, typeofactivity)
VALUES 
    (11,3),
    (281,2),
    (5188,1);

DECLARE @UserID INT = 1173;
EXEC AddOrderWithDetails @UserID = @UserID, @ActivityList = @ActivityList;




DECLARE @ActivityList1 ACTIVITYLISTTYPE;
INSERT INTO @ActivityList1 (activityid, typeofactivity)
VALUES 
    (1107,4);

DECLARE @UserID1 INT = 2;
EXEC AddOrderWithDetails @UserID = @UserID1, @ActivityList = @ActivityList1;


select * from usersroles where userid = 9
select * from usersroles where roleid = 2
select * from orders where studentid = 9
select * from CourseModulesPassed where studentid = 9



