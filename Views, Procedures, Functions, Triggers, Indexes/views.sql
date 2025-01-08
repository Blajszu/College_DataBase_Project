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
--dyplomy studi�w
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


--certyfikaty kurs�w
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


--d�u�nicy

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

--===================================================================================================

--Przychód z Webinarów
CREATE VIEW VW_IncomeFromWebinars AS
SELECT WebinarID, WebinarName, ROUND(SUM(OrderDetails.Price), 2) as 'Przychód'
FROM Webinars
INNER JOIN OrderDetails ON ActivityID = WebinarID
WHERE TypeOfActivity = 1 AND PaymentStatus = 'udana'
GROUP BY WebinarID, WebinarName



--Przychód z Kursów
CREATE VIEW VW_IncomeFromCourses AS
SELECT CourseID, CourseName, ROUND(SUM(OrderDetails.Price), 2) as 'Przychód'
FROM Courses
INNER JOIN OrderDetails ON ActivityID = CourseID
AND TypeOfActivity = 2 AND PaymentStatus = 'udana'
INNER JOIN Orders ON OrderDetails.OrderID = Orders.OrderID
GROUP BY CourseID, CourseName


--Przychód ze studiów
CREATE VIEW VW_IncomeFromStudies AS
SELECT StudiesID, StudyName, (
    (SELECT SUM(Price) FROM OrderDetails
    WHERE ActivityID = StudiesID AND TypeOfActivity = 3 AND PaymentStatus = 'udana'
    GROUP BY ActivityID
    )
    +
    (SELECT SUM(Price) FROM StudyMeetingPayment
    INNER JOIN StudyMeetings ON StudyMeetings.MeetingID = StudyMeetingPayment.MeetingID
    INNER JOIN Subjects ON StudyMeetings.SubjectID = Subjects.SubjectID
    WHERE Subjects.StudiesID = Studies.StudiesID AND PaymentStatus = 'udana'
    GROUP BY Subjects.StudiesID
    )
    +
    (SELECT ISNULL(SUM(Price), 0) FROM Subjects
    LEFT OUTER JOIN StudyMeetings ON Subjects.SubjectID = StudyMeetings.SubjectID
    LEFT OUTER JOIN OrderDetails ON OrderDetails.ActivityID = StudyMeetings.MeetingID
    AND TypeOfActivity = 4 AND PaymentStatus = 'udana'
    WHERE Subjects.StudiesID = Studies.StudiesID
    GROUP BY Subjects.StudiesID
    )
) FROM Studies


---Ogólny przychód
CREATE VIEW VW_IncomeFromAllFormOfEducation AS
SELECT 'Webinar' AS 'Typ', WebinarID, WebinarName, ROUND(SUM(OrderDetails.Price), 2) as 'Przychód'
FROM Webinars
INNER JOIN OrderDetails ON ActivityID = WebinarID
AND TypeOfActivity = 1 AND PaymentStatus = 'udana'
INNER JOIN Orders ON OrderDetails.OrderID = Orders.OrderID
GROUP BY WebinarID, WebinarName
UNION
SELECT 'Kurs' AS 'Typ', CourseID, CourseName, ROUND(SUM(OrderDetails.Price), 2) as 'Przychód'
FROM Courses
INNER JOIN OrderDetails ON ActivityID = CourseID
AND TypeOfActivity = 2 AND PaymentStatus = 'udana'
INNER JOIN Orders ON OrderDetails.OrderID = Orders.OrderID
GROUP BY CourseID, CourseName
UNION
SELECT 'Studia' AS 'Typ',  StudiesID, StudyName, (
    (SELECT ISNULL(SUM(Price), 0) FROM OrderDetails
     WHERE ActivityID = StudiesID AND TypeOfActivity = 3 AND PaymentStatus = 'udana'
     GROUP BY ActivityID
    )
    +
    (SELECT ISNULL(SUM(Price), 0) FROM StudyMeetingPayment
    INNER JOIN StudyMeetings ON StudyMeetings.MeetingID = StudyMeetingPayment.MeetingID
    INNER JOIN Subjects ON StudyMeetings.SubjectID = Subjects.SubjectID
    WHERE Subjects.StudiesID = Studies.StudiesID AND PaymentStatus = 'udana'
    GROUP BY Subjects.StudiesID
    )
    +
    (SELECT ISNULL(SUM(Price), 0) FROM Subjects
    LEFT OUTER JOIN StudyMeetings ON Subjects.SubjectID = StudyMeetings.SubjectID
    LEFT OUTER JOIN OrderDetails ON OrderDetails.ActivityID = StudyMeetings.MeetingID
    AND TypeOfActivity = 4 AND PaymentStatus = 'udana'
    WHERE Subjects.StudiesID = Studies.StudiesID
    GROUP BY Subjects.StudiesID
    )
) FROM Studies


--Dostępność sal
CREATE VIEW VW_RoomsAvailability AS
SELECT Rooms.RoomID, RoomName, StartDate, EndDate FROM Rooms
INNER JOIN StationaryCourseMeeting ON Rooms.RoomID = StationaryCourseMeeting.RoomID
UNION
SELECT Rooms.RoomID, RoomName, StartTime, EndTime FROM Rooms
INNER JOIN StationaryMeetings ON Rooms.RoomID = StationaryMeetings.RoomID
INNER JOIN StudyMeetings ON StationaryMeetings.MeetingID = StudyMeetings.MeetingID



--Liczba ludzi zapisanych na przyszłe webinary
CREATE VIEW VW_NumberOfStudentsSignUpForFutureWebinars AS
SELECT WebinarID, WebinarName, 'Zdalny' as 'Typ', COUNT(StudentID) as 'Liczba uczestników' FROM Webinars
LEFT OUTER JOIN OrderDetails ON OrderDetails.ActivityID = Webinars.WebinarID
AND TypeOfActivity = 1
LEFT OUTER JOIN Orders ON OrderDetails.OrderID = Orders.OrderID
WHERE StartDate > '2025-01-01 00:00'
GROUP BY WebinarID, WebinarName


--Liczba ludzi zapisanych na przyszłe kursy
CREATE VIEW VW_NumberOfStudentsSignUpForFutureCourses AS
SELECT CourseID, CourseName,
       CASE
           WHEN CourseID IN (SELECT Courses.CourseID
                             FROM Courses
                                      INNER JOIN CourseModules ON Courses.CourseID = CourseModules.CourseID
                             WHERE ModuleType = 4) THEN 'Hybrydowy'
           WHEN CourseID IN (SELECT Courses.CourseID
                             FROM Courses
                                      INNER JOIN CourseModules ON Courses.CourseID = CourseModules.CourseID
                             WHERE ModuleType IN (2,3))
                AND
                CourseID IN (SELECT Courses.CourseID
                             FROM Courses
                                      INNER JOIN CourseModules ON Courses.CourseID = CourseModules.CourseID
                             WHERE ModuleType = 1) THEN 'Hybrydowy'
           WHEN CourseID IN (SELECT Courses.CourseID
                             FROM Courses
                                      INNER JOIN CourseModules ON Courses.CourseID = CourseModules.CourseID
                             WHERE ModuleType IN (2,3)) THEN 'Zdalny'
           ELSE 'Stacjonarny'
           END,
       COUNT(StudentID)
FROM Courses
LEFT OUTER JOIN OrderDetails ON OrderDetails.ActivityID = Courses.CourseID
AND TypeOfActivity = 2
LEFT OUTER JOIN Orders ON OrderDetails.OrderID = Orders.OrderID
WHERE CourseID IN (
    SELECT DISTINCT Courses.CourseID FROM Courses
    INNER JOIN CourseModules ON Courses.CourseID = CourseModules.CourseID
    WHERE ModuleID IN (
                    SELECT ModuleID FROM StationaryCourseMeeting WHERE StartDate > '2025-01-01'
                    UNION
                    SELECT ModuleID FROM OnlineCourseMeeting WHERE StartDate > '2025-01-01'
                    ))
GROUP BY CourseID, CourseName


--Liczba ludzi zapisanych na przyszłe spotkania studyjne
CREATE VIEW VW_NumberOfStudentsSignUpForFutureStudyMeetings AS
SELECT MeetingID, 'Spotkanie studyjne ' + STR(MeetingID),
(
    (SELECT COUNT(*) FROM StudyMeetingPayment WHERE PaymentStatus = 'udana' AND StudyMeetingPayment.MeetingID = StudyMeetings.MeetingID)
    +
    (SELECT COUNT(*) FROM OrderDetails WHERE PaymentStatus = 'udana' AND TypeOfActivity = 4 AND ActivityID = StudyMeetings.MeetingID)
)
FROM StudyMeetings
WHERE StartTime > '2025-01-01'


--Liczba ludzi zapisanych na przyszłe wydarzenia razem
CREATE VIEW VW_NumberOfStudentsSignUpForFutureAllFormOfEducation AS
SELECT WebinarID, 'Webinar ' + WebinarName, 'Zdalny' as 'Typ', COUNT(StudentID) as 'Liczba uczestników' FROM Webinars
LEFT OUTER JOIN OrderDetails ON OrderDetails.ActivityID = Webinars.WebinarID
AND TypeOfActivity = 1
LEFT OUTER JOIN Orders ON OrderDetails.OrderID = Orders.OrderID
WHERE StartDate > '2025-01-01 00:00'
GROUP BY WebinarID, WebinarName
UNION
SELECT CourseID, 'Kurs ' + CourseName,
       CASE
           WHEN CourseID IN (SELECT Courses.CourseID
                             FROM Courses
                                      INNER JOIN CourseModules ON Courses.CourseID = CourseModules.CourseID
                             WHERE ModuleType = 4) THEN 'Hybrydowy'
           WHEN CourseID IN (SELECT Courses.CourseID
                             FROM Courses
                                      INNER JOIN CourseModules ON Courses.CourseID = CourseModules.CourseID
                             WHERE ModuleType IN (2,3))
               AND
                CourseID IN (SELECT Courses.CourseID
                             FROM Courses
                                      INNER JOIN CourseModules ON Courses.CourseID = CourseModules.CourseID
                             WHERE ModuleType = 1) THEN 'Hybrydowy'
           WHEN CourseID IN (SELECT Courses.CourseID
                             FROM Courses
                                      INNER JOIN CourseModules ON Courses.CourseID = CourseModules.CourseID
                             WHERE ModuleType IN (2,3)) THEN 'Zdalny'
           ELSE 'Stacjonarny'
           END,
       COUNT(StudentID)
FROM Courses
         LEFT OUTER JOIN OrderDetails ON OrderDetails.ActivityID = Courses.CourseID
    AND TypeOfActivity = 2
         LEFT OUTER JOIN Orders ON OrderDetails.OrderID = Orders.OrderID
WHERE CourseID IN (
    SELECT DISTINCT Courses.CourseID FROM Courses
                                              INNER JOIN CourseModules ON Courses.CourseID = CourseModules.CourseID
    WHERE ModuleID IN (
        SELECT ModuleID FROM StationaryCourseMeeting WHERE StartDate > '2025-01-01'
        UNION
        SELECT ModuleID FROM OnlineCourseMeeting WHERE StartDate > '2025-01-01'
    ))
GROUP BY CourseID, CourseName
UNION
SELECT MeetingID, 'Spotkanie studyjne ' + STR(MeetingID), IIF(MeetingType = 1, 'Stacjonarne', 'Zdalne'),
(
   (SELECT COUNT(*) FROM StudyMeetingPayment WHERE PaymentStatus = 'udana' AND StudyMeetingPayment.MeetingID = StudyMeetings.MeetingID)
    +
   (SELECT COUNT(*) FROM OrderDetails WHERE PaymentStatus = 'udana' AND TypeOfActivity = 4 AND ActivityID = StudyMeetings.MeetingID)
)
FROM StudyMeetings
WHERE StartTime > '2025-01-01'


--Raport obecności na spotkaniach z imieniem, nazwiskiem i datą
CREATE VIEW VW_StudyMeetingsPresenceWithFirstNameLastNameDate AS
SELECT MeetingID, StartTime, FirstName, LastName, IIF(Presence = 1, 'Obecny', 'Nieobecny') FROM StudyMeetingPresence
INNER JOIN StudyMeetings ON StudyMeetingPresence.StudyMeetingID = StudyMeetings.MeetingID
INNER JOIN Users ON StudyMeetingPresence.StudentID = Users.UserID


--Raport języków i tłumaczy na webinarach
CREATE VIEW VW_LanguagesAndTranslatorsOnWebinars AS
SELECT WebinarID, WebinarName, LanguageName, ISNULL(FirstName, 'brak'), ISNULL(LastName, 'brak') FROM Webinars
INNER JOIN Languages ON Webinars.LanguageID = Languages.LanguageID
LEFT OUTER JOIN Employees ON Webinars.TranslatorID = Employees.EmployeeID
LEFT OUTER JOIN Users ON Employees.EmployeeID = Users.UserID


--Raport języków i tłumaczy na kursach
CREATE VIEW VW_LanguagesAndTranslatorsOnCourses AS
SELECT Courses.CourseID, CourseName, LanguageName, ISNULL(FirstName, 'brak'), ISNULL(LastName, 'brak') FROM Courses
INNER JOIN CourseModules ON Courses.CourseID = CourseModules.CourseID
INNER JOIN Languages ON CourseModules.LanguageID = Languages.LanguageID
LEFT OUTER JOIN Employees ON CourseModules.TranslatorID = Employees.EmployeeID
LEFT OUTER JOIN Users ON Employees.EmployeeID = Users.UserID


--Raport języków i tłumaczy na studiach
CREATE VIEW VW_LanguagesAndTranslatorsOnStudies AS
SELECT Studies.StudiesID, StudyName, SubjectName, MeetingID, LanguageName, ISNULL(FirstName, 'brak'), ISNULL(LastName, 'brak') FROM Studies
INNER JOIN Subjects ON Studies.StudiesID = Subjects.StudiesID
INNER JOIN StudyMeetings ON Subjects.SubjectID = StudyMeetings.SubjectID
INNER JOIN Languages ON StudyMeetings.LanguageID = Languages.LanguageID
LEFT OUTER JOIN Employees ON StudyMeetings.TranslatorID = Employees.EmployeeID
LEFT OUTER JOIN Users ON Employees.EmployeeID = Users.UserID


--Miejsce zamieszakania studentów
CREATE VIEW VW_StudentsPlaceOfLive AS
SELECT Users.UserID, FirstName, LastName, CityName FROM Users
INNER JOIN UsersRoles ON Users.UserID = UsersRoles.UserID
AND RoleID = 1
INNER JOIN Cities ON Users.CityID = Cities.CityID

--Koordynatorzy studiów
CREATE VIEW VW_StudiesCoordinators AS
SELECT StudiesID, StudyName, FirstName, LastName FROM Studies
INNER JOIN Employees ON Studies.StudiesCoordinatorID = Employees.EmployeeID
INNER JOIN Users ON Employees.EmployeeID = Users.UserID

--Koordynatorzy kursów
CREATE VIEW VW_CoursesCoordinators AS
SELECT CourseID, CourseName, FirstName, LastName FROM Courses
INNER JOIN Employees ON Courses.CourseCoordinatorID = Employees.EmployeeID
INNER JOIN Users ON Employees.EmployeeID = Users.UserID

--Czas rozpoczęcia i zakończenia dla każdego kursu
CREATE VIEW VW_CoursesStartDateEndDate AS
WITH T1 AS (
    SELECT
        Courses.CourseID AS 'ID',
        MIN(OnlineCourseMeeting.StartDate) AS 'online_start_date',
        MIN(StationaryCourseMeeting.StartDate) AS 'stationary_start_date',
        MAX(OnlineCourseMeeting.EndDate) AS 'online_end_date',
        MAX(StationaryCourseMeeting.EndDate) AS 'stationary_end_date'
    FROM
        Courses
            INNER JOIN
        CourseModules ON Courses.CourseID = CourseModules.CourseID
            LEFT OUTER JOIN
        StationaryCourseMeeting ON CourseModules.ModuleID = StationaryCourseMeeting.ModuleID
            LEFT OUTER JOIN
        OnlineCourseMeeting ON CourseModules.ModuleID = OnlineCourseMeeting.ModuleID
    GROUP BY
        Courses.CourseID
)
SELECT
    id,
    CASE
        WHEN COALESCE(online_start_date, '2050-12-31') < COALESCE(stationary_start_date, '2050-12-31')
            THEN COALESCE(online_start_date, stationary_start_date)
        ELSE COALESCE(stationary_start_date, online_start_date)
        END AS 'Data rozpoczęcia',

    CASE
        WHEN COALESCE(online_end_date, '2010-01-01') > COALESCE(stationary_end_date, '2010-01-01')
            THEN COALESCE(online_end_date, stationary_end_date)
        ELSE COALESCE(stationary_end_date, online_end_date)
        END AS 'Data zakończenia'
FROM
    T1;

--Dla wszystkich pracowników ich funkcja i staż pracy
CREATE VIEW VW_EmployeesFunctionsAndSeniority AS
SELECT EmployeeID, FirstName, LastName, RoleName, CONCAT(
        DATEDIFF(YEAR, HireDate, '2025-01-01'), ' lat ',
        DATEDIFF(MONTH, DATEADD(YEAR, DATEDIFF(YEAR, '2025-01-01', HireDate), '2025-01-01'), HireDate), ' miesiące ',
        DATEDIFF(DAY, DATEADD(MONTH, DATEDIFF(MONTH, DATEADD(YEAR, DATEDIFF(YEAR, '2025-01-01', HireDate), '2025-01-01'), HireDate),
                              DATEADD(YEAR, DATEDIFF(YEAR, '2025-01-01', HireDate), '2025-01-01')), HireDate), ' dni'
                                                  ) AS RóżnicaCzasu
FROM Employees
INNER JOIN Users ON Employees.EmployeeID = Users.UserID
INNER JOIN UsersRoles ON Users.UserID = UsersRoles.UserID
INNER JOIN Roles ON UsersRoles.RoleID = Roles.RoleID


--Dla każdego spotkania studyjnego przedmiot, czas, ilość zapisanych osób
CREATE VIEW VW_StudyMeetingDurationTimeNumberOfStudents AS
SELECT MeetingID, SubjectName, STR(DATEDIFF(minute, StartTime, EndTime)) + ' minut' AS 'Czas trwania',
(
    (SELECT COUNT(*) FROM StudyMeetingPayment WHERE PaymentStatus = 'udana' AND StudyMeetingPayment.MeetingID = StudyMeetings.MeetingID)
        +
    (SELECT COUNT(*) FROM OrderDetails WHERE PaymentStatus = 'udana' AND TypeOfActivity = 4 AND ActivityID = StudyMeetings.MeetingID)
) AS 'Liczba zapisanych osób'
FROM StudyMeetings
INNER JOIN Subjects ON StudyMeetings.SubjectID = Subjects.SubjectID


--Dla każdego użytkownika jego imię, nazwisko, email, telefon, adres zamieszkania
CREATE VIEW VW_UsersPersonalData AS
SELECT FirstName, LastName, Email, Phone, Street, PostalCode, CityName
FROM Users
INNER JOIN Cities ON Users.CityID = Cities.CityID


--Adresy osób do wysyłki dyplomów ze studiów
CREATE VW_UsersDiplomasAddresses AS
SELECT FirstName, LastName, Street, PostalCode, CityName
FROM Studies S
INNER JOIN StudiesResults ON StudiesResults.StudiesID=S.StudiesID
INNER JOIN Users ON Users.UserID = StudiesResults.StudentID
INNER JOIN Grades ON StudiesResults.GradeID=Grades.GradeID
INNER JOIN Cities ON Cities.CityID = Users.CityID


--Adresy do wysyłki certyfikatów z kursów
CREATE VIEW vw_CoursesCertificates AS
SELECT Users.FirstName, Users.LastName, Street, PostalCode, CityName
FROM Courses C
INNER JOIN CourseModules ON CourseModules.CourseID=C.CourseID
INNER JOIN CourseModulesPassed ON CourseModulesPassed.ModuleID=CourseModules.ModuleID
INNER JOIN Users ON Users.UserID = CourseModulesPassed.StudentID
INNER JOIN Cities ON Cities.CityID = Users.CityID
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

