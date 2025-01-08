CREATE VIEW vw_UsersWithRoles AS
SELECT 
    U.UserID,
    U.FirstName,
    U.LastName,
    U.Email,
    R.RoleName
FROM Users U
JOIN UsersRoles UR ON U.UserID = UR.UserID
JOIN Roles R ON UR.RoleID = R.RoleID;


CREATE VIEW vw_CoursesWithModules AS
SELECT 
    C.CourseID,
    C.CourseName,
    C.CourseDescription,
    CM.ModuleID,
    CM.ModuleName,
    L.LanguageName AS ModuleLanguage
FROM Courses C
JOIN CourseModules CM ON C.CourseID = CM.CourseID
JOIN Languages L ON CM.LanguageID = L.LanguageID;

CREATE VIEW vw_InternshipDetails AS
SELECT 
    I.InternshipID,
	I.Term,
	S.StudyName,
    I.StartDate,
    I.EndDate,
    I.NumerOfHours,
    U.FirstName AS CoordinatorFirstName,
    U.LastName AS CoordinatorLastName
FROM Internship I
JOIN Employees E ON I.InternshipCoordinatorID = E.EmployeeID
JOIN Users U ON U.UserID = E.EmployeeID
JOIN Studies S ON S.StudiesID=I.StudiesID;

CREATE VIEW vw_OrdersWithDetails AS
SELECT 
    O.OrderID,
    O.OrderDate,
    O.PaymentDeferred,
    OD.ActivityID,
    AT.TypeName AS ActivityType,
    OD.Price,
    OD.PaymentStatus
FROM Orders O
JOIN OrderDetails OD ON O.OrderID = OD.OrderID
JOIN ActivitiesTypes AT ON OD.TypeOfActivity = AT.ActivityTypeID;

CREATE VIEW vw_StudyMeetings AS
SELECT 
    SM.MeetingID,
    S.SubjectName,
    SM.StartTime,
    SM.EndTime,
    L.LanguageName AS MeetingLanguage,
    U.FirstName AS LecturerFirstName,
    U.LastName AS LecturerLastName
FROM StudyMeetings SM
JOIN Subjects S ON SM.SubjectID = S.SubjectID
JOIN Languages L ON SM.LanguageID = L.LanguageID
JOIN Users U ON SM.LecturerID = U.UserID;


CREATE VIEW vw_SubjectsEachGradesNumber AS
SELECT 
    S.SubjectID,
    S.SubjectName,
    G.GradeName,
	COUNT(U.UserID)
FROM SubjectsResults SR
JOIN Subjects S ON SR.SubjectID = S.SubjectID
JOIN Users U ON SR.StudentID = U.UserID
JOIN Grades G ON SR.GradeID = G.GradeID
GROUP BY S.SubjectID,S.SubjectName, G.GradeID, G.GradeName

CREATE VIEW vw_EmployeeDegrees AS
SELECT 
    E.EmployeeID,
    U.FirstName,
    U.LastName,
    D.DegreeName
FROM Employees E
JOIN Users U ON E.EmployeeID = U.UserID
JOIN Degrees D ON E.DegreeID = D.DegreeID;


CREATE VIEW vw_WebinarsWithDetails AS
SELECT 
    W.WebinarID,
    W.WebinarName,
    W.WebinarDescription,
    W.StartDate,
    W.EndDate,
    L.LanguageName AS WebinarLanguage,
    U.FirstName AS LecturerFirstName,
    U.LastName AS LecturerLastName
FROM Webinars W
JOIN Languages L ON W.LanguageID = L.LanguageID
JOIN Users U ON W.TeacherID = U.UserID;


CREATE VIEW vw_InternshipsParticipants AS
SELECT 
    I.InternshipID,
    I.StartDate,
    I.EndDate,
    U.FirstName AS StudentFirstName,
    U.LastName AS StudentLastName
FROM Internship I
JOIN InternshipPassed IP ON I.InternshipID = IP.InternshipID
JOIN Users U ON IP.StudentID = U.UserID
JOIN USERS U1 ON I.InternshipCoordinatorID = U1.UserID;


CREATE VIEW vw_StudentsGradesWithSubjects AS
SELECT 
    U.FirstName AS StudentFirstName,
    U.LastName AS StudentLastName,
    S.SubjectName,
    G.GradeName
FROM SubjectsResults SR
JOIN Users U ON SR.StudentID = U.UserID
JOIN Subjects S ON SR.SubjectID = S.SubjectID
JOIN Grades G ON SR.GradeID = G.GradeID;

CREATE VIEW vw_LecturerMeetings AS
SELECT 
    U.FirstName AS LecturerFirstName,
    U.LastName AS LecturerLastName,
    S.SubjectName,
    SM.StartTime,
    SM.EndTime,
    L.LanguageName AS MeetingLanguage
FROM StudyMeetings SM
JOIN Users U ON SM.LecturerID = U.UserID
JOIN Subjects S ON SM.SubjectID = S.SubjectID
JOIN Languages L ON SM.LanguageID = L.LanguageID;

CREATE VIEW vw_CourseModulesLanguages AS
SELECT 
    C.CourseID,
    C.CourseName,
	CM.ModuleName,
    L.LanguageName
FROM Courses C
JOIN CourseModules CM ON C.CourseID = CM.CourseID
JOIN Languages L ON CM.LanguageID = L.LanguageID;


CREATE VIEW vw_WebinarsLanguages AS
SELECT 
	W.WebinarID, W.WebinarName, L.LanguageName
FROM Webinars W
JOIN Languages L ON W.LanguageID = L.LanguageID;


------------------------------------------------------
--dyplomy studiów
CREATE VIEW vw_StudentsDiplomas AS
SELECT Users.FirstName, Users.LastName, S.StudyName, Grades.GradeName, 
(SELECT CONCAT(DATENAME(MONTH, MIN(StudyMeetings.StartTime)),' ' + DATENAME(YEAR, MIN(StudyMeetings.StartTime)))
FROM StudyMeetings 
INNER JOIN Subjects ON Subjects.SubjectID=StudyMeetings.SubjectID
INNER JOIN Studies S2 ON S2.StudiesID=Subjects.StudiesID
WHERE S2.StudiesId=S.StudiesID) as StudyStart, 
(SELECT CONCAT(DATENAME(MONTH, MAX(StudyMeetings.EndTime)),' ' + DATENAME(YEAR, MAX(StudyMeetings.EndTime)))
FROM StudyMeetings 
INNER JOIN Subjects ON Subjects.SubjectID=StudyMeetings.SubjectID
INNER JOIN Studies S2 ON S2.StudiesID=Subjects.StudiesID
WHERE S2.StudiesId=S.StudiesID) as StudyEnd
FROM Studies S
INNER JOIN StudiesResults ON StudiesResults.StudiesID=S.StudiesID
INNER JOIN Users ON Users.UserID = StudiesResults.StudentID
INNER JOIN Grades ON StudiesResults.GradeID=Grades.GradeID


--dyplomy kursów
CREATE VIEW vw_CoursesCertificates AS
SELECT Users.FirstName, Users.LastName, C.CourseName, 
	(SELECT DATENAME(DAY,MIN(t.first_meeting_date)) + ' ' + DATENAME(MONTH,MIN(t.first_meeting_date)) + ' ' + DATENAME(YEAR,MIN(t.first_meeting_date))  as course_start_date
	FROM(
		(SELECT MIN(StationaryCourseMeeting.StartDate) as first_meeting_date
		FROM StationaryCourseMeeting
		INNER JOIN CourseModules ON CourseModules.ModuleID=StationaryCourseMeeting.ModuleID
		INNER JOIN Courses ON Courses.CourseID=CourseModules.CourseID
		WHERE Courses.CourseID = C.CourseID) 
			UNION
		(SELECT MIN(OnlineCourseMeeting.StartDate) as first_meeting_date
		FROM OnlineCourseMeeting
		INNER JOIN CourseModules ON CourseModules.ModuleID=OnlineCourseMeeting.ModuleID
		INNER JOIN Courses ON Courses.CourseID=CourseModules.CourseID
		WHERE Courses.CourseID = C.CourseID)
	) as t) as courseStart,

	(SELECT (DATENAME(DAY,MAX(t.last_meeting_date)) + ' ' + DATENAME(MONTH,MAX(t.last_meeting_date)) + ' ' + DATENAME(YEAR,MAX(t.last_meeting_date))) as end_date  
	FROM(
		(SELECT MAX(StationaryCourseMeeting.EndDate) as last_meeting_date
		FROM StationaryCourseMeeting
		INNER JOIN CourseModules ON CourseModules.ModuleID=StationaryCourseMeeting.ModuleID
		INNER JOIN Courses ON Courses.CourseID=CourseModules.CourseID
		WHERE Courses.CourseID = C.CourseID) 
			UNION
		(SELECT MAX(OnlineCourseMeeting.EndDate) as last_meeting_date
		FROM OnlineCourseMeeting
		INNER JOIN CourseModules ON CourseModules.ModuleID=OnlineCourseMeeting.ModuleID
		INNER JOIN Courses ON Courses.CourseID=CourseModules.CourseID
		WHERE Courses.CourseID = C.CourseID)
	) as t) as CourseEnd
FROM Courses C
INNER JOIN CourseModules ON CourseModules.CourseID=C.CourseID
INNER JOIN CourseModulesPassed ON CourseModulesPassed.ModuleID=CourseModules.ModuleID
INNER JOIN Users ON Users.UserID = CourseModulesPassed.StudentID
WHERE (
	SELECT COUNT(DISTINCT CourseModulesPassed.ModuleID) 
	FROM CourseModulesPassed 
	INNER JOIN CourseModules ON CourseModules.ModuleID=CourseModulesPassed.ModuleID
	INNER JOIN Courses C1 ON C1.CourseID=CourseModules.CourseID
	WHERE C1.CourseID=C.CourseID AND CourseModulesPassed.StudentID=Users.UserID AND CourseModulesPassed.Passed=1)
	/
	(SELECT COUNT(DISTINCT CourseModules.ModuleID) 
	FROM CourseModules
	INNER JOIN Courses C1 ON C1.CourseID=CourseModules.CourseID
	WHERE C1.CourseID=C.CourseID) >= 0.8


--d³u¿nicy

CREATE VIEW vw_Debtors AS
(SELECT Users.FirstName, Users.LastName, Users.Email, Users.Phone
FROM Orders
INNER JOIN Users ON Users.UserID=Orders.StudentID
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN StudyMeetingPayment ON StudyMeetingPayment.DetailID=OrderDetails.DetailID
INNER JOIN StudyMeetings ON StudyMeetings.MeetingID=StudyMeetingPayment.MeetingID
WHERE TypeOfActivity=(SELECT ActivityTypeID FROM ActivitiesTypes WHERE TypeName='Studia') 
AND (OrderDetails.PaidDate is NULL OR (StudyMeetings.StartTime<DATEADD(DAY,3,GETDATE()) AND StudyMeetingPayment.PaidDate is NULL) OR 
OrderDetails.PaidDate>DATEADD(HOUR,6,Orders.OrderDate) OR (StudyMeetingPayment.PaidDate is NOT NULL AND
StudyMeetingPayment.PaidDate>DATEADD(DAY,-3,StudyMeetings.StartTime))))

UNION 

(SELECT Users.FirstName, Users.LastName, Users.Email, Users.Phone
FROM Orders
INNER JOIN Users ON Users.UserID=Orders.StudentID
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN PaymentsAdvances ON PaymentsAdvances.DetailID=OrderDetails.DetailID
WHERE TypeOfActivity=(SELECT ActivityTypeID FROM ActivitiesTypes WHERE TypeName='Kurs') AND (
(AdvancePaidDate is NULL 
AND (SELECT MIN(t.first_meeting_date)
	FROM(
		(SELECT isnull(MIN(StationaryCourseMeeting.StartDate),GETDATE()) as first_meeting_date
		FROM StationaryCourseMeeting
		INNER JOIN CourseModules ON CourseModules.ModuleID=StationaryCourseMeeting.ModuleID
		INNER JOIN Courses ON Courses.CourseID=CourseModules.CourseID
		WHERE Courses.CourseID = ActivityID)
			UNION
		(SELECT isnull(MIN(OnlineCourseMeeting.StartDate),GETDATE()) as first_meeting_date
		FROM OnlineCourseMeeting
		INNER JOIN CourseModules ON CourseModules.ModuleID=OnlineCourseMeeting.ModuleID
		INNER JOIN Courses ON Courses.CourseID=CourseModules.CourseID
		WHERE Courses.CourseID = ActivityID)) as t)<DATEADD(DAY,3,GETDATE()))
OR 
PaymentsAdvances.AdvancePaidDate>DATEADD(HOUR,6,Orders.OrderDate) OR
OrderDetails.PaidDate>DATEADD(DAY,-3,
	(SELECT MIN(t.first_meeting_date)
	FROM(
		(SELECT isnull(MIN(StationaryCourseMeeting.StartDate),GETDATE()) as first_meeting_date
		FROM StationaryCourseMeeting
		INNER JOIN CourseModules ON CourseModules.ModuleID=StationaryCourseMeeting.ModuleID
		INNER JOIN Courses ON Courses.CourseID=CourseModules.CourseID
		WHERE Courses.CourseID = ActivityID)
			UNION
		(SELECT isnull(MIN(OnlineCourseMeeting.StartDate),GETDATE()) as first_meeting_date
		FROM OnlineCourseMeeting
		INNER JOIN CourseModules ON CourseModules.ModuleID=OnlineCourseMeeting.ModuleID
		INNER JOIN Courses ON Courses.CourseID=CourseModules.CourseID
		WHERE Courses.CourseID = ActivityID)) as t)
	)))


UNION

(SELECT Users.FirstName, Users.LastName, Users.Email, Users.Phone
FROM Orders
INNER JOIN Users ON Users.UserID=Orders.StudentID
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN Webinars ON Webinars.WebinarID=OrderDetails.ActivityID
WHERE TypeOfActivity=(SELECT activityTypeID FROM ActivitiesTypes WHERE TypeName='Webinar') 
AND (Webinars.Price IS NOT NULL) AND (PaidDate is NULL OR PaidDate>Webinars.StartDate))

UNION

(SELECT Users.FirstName, Users.LastName, Users.Email, Users.Phone
FROM Orders
INNER JOIN Users ON Users.UserID=Orders.StudentID
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN StudyMeetings ON StudyMeetings.MeetingID=ActivityId
WHERE TypeOfActivity=(SELECT ActivityTypeID FROM ActivitiesTypes WHERE TypeName='Spotkanie studyjne') 
AND ((StudyMeetings.StartTime<DATEADD(DAY,3,GETDATE()) AND OrderDetails.PaidDate is NULL) OR 
(OrderDetails.PaidDate is NOT NULL AND
OrderDetails.PaidDate>DATEADD(DAY,-3,StudyMeetings.StartTime))))












