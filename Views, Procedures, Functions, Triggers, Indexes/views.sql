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
    TypeName AS 'Typ Modułu',
    L.LanguageName AS ModuleLanguage
FROM Courses C
JOIN CourseModules CM ON C.CourseID = CM.CourseID
JOIN FormOfActivity ON CM.ModuleType = FormOfActivity.ActivityTypeID
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
    AT.TypeName AS ActivityType
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
    COUNT(U.UserID) as StudentsNum
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
    U.LastName AS StudentLastName,
    IIF((IP.Passed = 1), 'Zaliczone', 'Nie zaliczone') AS Passed
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
--dyplomy studi w
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


--certyfikaty kurs w
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
            ) as t) as CourseStart,

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


--d u nicy

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
    ) AS 'Income'
FROM Studies


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
    ) AS 'Income'
FROM Studies


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
           END AS 'Typ',
       COUNT(StudentID) AS 'Liczba osób'
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
SELECT MeetingID, 'Spotkanie studyjne ' + STR(MeetingID) AS 'Nazwa spotkania',
        (
        (SELECT COUNT(*) FROM StudyMeetingPayment WHERE PaymentStatus = 'udana' AND StudyMeetingPayment.MeetingID = StudyMeetings.MeetingID)
            +
        (SELECT COUNT(*) FROM OrderDetails WHERE PaymentStatus = 'udana' AND TypeOfActivity = 4 AND ActivityID = StudyMeetings.MeetingID)
        ) AS 'Liczba uczestników'
FROM StudyMeetings
WHERE StartTime > '2025-01-01'


--Liczba ludzi zapisanych na przyszłe wydarzenia razem
CREATE VIEW VW_NumberOfStudentsSignUpForFutureAllFormOfEducation AS
SELECT WebinarID, 'Webinar ' + WebinarName AS 'Nazwa Webinaru', 'Zdalny' as 'Typ', COUNT(StudentID) as 'Liczba uczestników' FROM Webinars
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
SELECT MeetingID, StartTime, FirstName, LastName, IIF(Presence = 1, 'Obecny', 'Nieobecny') AS 'Obecność' FROM StudyMeetingPresence
INNER JOIN StudyMeetings ON StudyMeetingPresence.StudyMeetingID = StudyMeetings.MeetingID
INNER JOIN Users ON StudyMeetingPresence.StudentID = Users.UserID


--Raport języków i tłumaczy na webinarach
CREATE VIEW VW_LanguagesAndTranslatorsOnWebinars AS
SELECT WebinarID, WebinarName, LanguageName, ISNULL(FirstName, 'brak') AS 'FirstName', ISNULL(LastName, 'brak') AS 'LastName' FROM Webinars
INNER JOIN Languages ON Webinars.LanguageID = Languages.LanguageID
LEFT OUTER JOIN Employees ON Webinars.TranslatorID = Employees.EmployeeID
LEFT OUTER JOIN Users ON Employees.EmployeeID = Users.UserID


--Raport języków i tłumaczy na kursach
CREATE VIEW VW_LanguagesAndTranslatorsOnCourses AS
SELECT Courses.CourseID, CourseName, LanguageName, ISNULL(FirstName, 'brak') AS 'FirstName', ISNULL(LastName, 'brak') AS 'LastName' FROM Courses
INNER JOIN CourseModules ON Courses.CourseID = CourseModules.CourseID
INNER JOIN Languages ON CourseModules.LanguageID = Languages.LanguageID
LEFT OUTER JOIN Employees ON CourseModules.TranslatorID = Employees.EmployeeID
LEFT OUTER JOIN Users ON Employees.EmployeeID = Users.UserID


--Raport języków i tłumaczy na studiach
CREATE VIEW VW_LanguagesAndTranslatorsOnStudies AS
SELECT Studies.StudiesID, StudyName, SubjectName, MeetingID, LanguageName, ISNULL(FirstName, 'brak') AS 'FirstName', ISNULL(LastName, 'brak') AS 'LastName' FROM Studies
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
CREATE VIEW VW_UsersDiplomasAddresses AS
SELECT FirstName, LastName, Street, PostalCode, CityName
FROM Studies S
         INNER JOIN StudiesResults ON StudiesResults.StudiesID=S.StudiesID
         INNER JOIN Users ON Users.UserID = StudiesResults.StudentID
         INNER JOIN Grades ON StudiesResults.GradeID=Grades.GradeID
         INNER JOIN Cities ON Cities.CityID = Users.CityID


--Adresy do wysyłki certyfikatów z kursów
CREATE VIEW vw_CoursesCertificatesAddresses AS
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


CREATE VIEW vw_InternshipCoordinators AS
SELECT FirstName, LastName
FROM Users
         INNER JOIN UsersRoles ON UsersRoles.UserID=Users.UserID
WHERE UsersRoles.RoleID = (SELECT RoleID FROM Roles WHERE RoleName='Koordynator praktyk')

CREATE VIEW vw_CourseCoordinators AS
SELECT FirstName, LastName
FROM Users
         INNER JOIN UsersRoles ON UsersRoles.UserID=Users.UserID
WHERE UsersRoles.RoleID = (SELECT RoleID FROM Roles WHERE RoleName='Koordynator kursu')


CREATE VIEW vw_WebinarTeachers AS
SELECT FirstName, LastName
FROM Users
         INNER JOIN UsersRoles ON UsersRoles.UserID=Users.UserID
WHERE UsersRoles.RoleID = (SELECT RoleID FROM Roles WHERE RoleName='Prowadzący webinaru')

CREATE VIEW vw_StudyCoordinator AS
SELECT FirstName, LastName
FROM Users
         INNER JOIN UsersRoles ON UsersRoles.UserID=Users.UserID
WHERE UsersRoles.RoleID = (SELECT RoleID FROM Roles WHERE RoleName='Koordynator studiów')

CREATE VIEW vw_CoursesLecturers AS
SELECT FirstName, LastName
FROM Users
         INNER JOIN UsersRoles ON UsersRoles.UserID=Users.UserID
WHERE UsersRoles.RoleID = (SELECT RoleID FROM Roles WHERE RoleName='Prowadzący kursu')

CREATE VIEW vw_Students AS
SELECT FirstName, LastName
FROM Users
         INNER JOIN UsersRoles ON UsersRoles.UserID=Users.UserID
WHERE UsersRoles.RoleID = (SELECT RoleID FROM Roles WHERE RoleName='Student')

CREATE VIEW vw_TranslatorsWithLanguages AS
SELECT FirstName, LastName, LanguageName
FROM Users
         INNER JOIN UsersRoles ON UsersRoles.UserID=Users.UserID
         INNER JOIN TranslatedLanguage ON TranslatedLanguage.TranslatorID=Users.UserID
         INNER JOIN Languages ON Languages.LanguageID=TranslatedLanguage.LanguageID
WHERE UsersRoles.RoleID = (SELECT RoleID FROM Roles WHERE RoleName='Tłumacz')

CREATE VIEW vw_Lecturers AS
SELECT FirstName, LastName
FROM Users
         INNER JOIN UsersRoles ON UsersRoles.UserID=Users.UserID
WHERE UsersRoles.RoleID = (SELECT RoleID FROM Roles WHERE RoleName='Wykładowca')

CREATE VIEW vw_PresenceOnPastStudyMeeting AS
WITH t2 AS (
    SELECT 
        sm.MeetingID, 
        COUNT(smp.Presence) AS NumberOfAttendees, 
        (
            SELECT 
                COUNT(DISTINCT od.OrderID) AS NumberOfPurchases
            FROM
                StudyMeetings sm1
            LEFT JOIN 
                Subjects s ON s.SubjectID = sm1.SubjectID
            LEFT JOIN 
                Studies st ON s.StudiesID = st.StudiesID
            LEFT JOIN
                OrderDetails od ON (od.ActivityID = sm1.MeetingID AND od.TypeOfActivity = 4)
                                OR (od.ActivityID = st.StudiesID AND od.TypeOfActivity = 3)
            WHERE sm1.MeetingID = sm.MeetingID
            GROUP BY
                sm1.MeetingID
        ) AS NumberOfPurchases
    FROM 
        StudyMeetings sm
    LEFT JOIN 
        StudyMeetingPresence smp ON smp.StudyMeetingID = sm.MeetingID AND smp.Presence = 1
	WHERE EndTime < '2025-01-01'
    GROUP BY 
        sm.MeetingID
)

SELECT 
    t2.MeetingID,ROUND((CAST(NumberOfAttendees AS FLOAT) / CAST(NumberOfPurchases AS FLOAT)) * 100, 2) AS PercentOfPresentStudents
FROM 
    t2;

CREATE VIEW vw_StudentsAttendanceAtSubjects AS
SELECT
    smp.StudentID,
    sm.SubjectID,
    CAST (SUM(CAST(smp.Presence AS INT)) * 1.0 / COUNT(*) * 100 AS INT) AS AttendancePercentage
FROM
    StudyMeetingPresence smp
        INNER JOIN
    StudyMeetings sm ON sm.MeetingID = smp.StudyMeetingID
GROUP BY
    smp.StudentID,
    sm.SubjectID;


CREATE VIEW bilocation_report AS
 WITH student_meetings AS (
 SELECT
 users.userId,
 orderdetails.ActivityID AS meetingId,
 StudyMeetings.startTime,
 StudyMeetings.endTime
 FROM Users
 JOIN orders on orders.StudentID=users.UserID
 JOIN OrderDetails on OrderDetails.OrderID = orders.orderid
 JOIN StudyMeetings on StudyMeetings.MeetingID=OrderDetails.ActivityID
 where TypeOfActivity = 3
 )
 SELECT
 student_meetings.userId,
 student_meetings.meetingid AS first_meeting_id,
 student_meetings.starttime AS first_meeting_start_time,
 student_meetings.endtime AS first_meeting_end_time,
 SM.meetingid AS second_meeting_id,
 SM.starttime AS second_meeting_start_time,
 SM.endtime AS second_meeting_end_time
 FROM student_meetings
 JOIN orders O ON student_meetings.userid = O.studentid
 JOIN OrderDetails od on od.orderid=O.orderid
 JOiN StudyMeetingPayment SMP on SMP.detailid= od.detailid
 JOIN StudyMeetings SM on SMP.meetingid = SM.meetingid
 WHERE student_meetings.meetingid < SM.meetingid AND
 (student_meetings.starttime >= GETDATE() OR SM.startTime >=
 GETDATE()) AND
 (student_meetings.endtime >= SM.startTime AND
 student_meetings.starttime <= SM.endTime)


CREATE VIEW defferedPayments AS
 SELECT orders.orderid, orders.StudentID, orderdetails.activityid, (select typename FROM FormOfActivity where ActivityTypeID=OrderDetails.TypeOfActivity) AS 'Typ', DeferredDate
 FROM orders 
 INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
 WHERE Orders.PaymentDeferred=1

CREATE VIEW VW_CurrentCoursesPassed AS
SELECT Courses.CourseID, CourseName, CourseModules.ModuleID, ModuleName, StudentID, FirstName, LastName, Passed FROM Courses
INNER JOIN CourseModules ON Courses.CourseID = CourseModules.CourseID
LEFT OUTER JOIN CourseModulesPassed ON CourseModules.ModuleID = CourseModulesPassed.ModuleID
LEFT OUTER JOIN Users ON CourseModulesPassed.StudentID = Users.UserID
WHERE Courses.CourseID IN (
    SELECT id FROM VW_CoursesStartDateEndDate
    WHERE [Data rozpoczęcia] < '2025-01-01' AND [Data zakończenia] > '2025-01-01'
)

CREATE VIEW VW_CourseModulesPassed AS
SELECT C.CourseID, CourseName, CM.ModuleID, ModuleName, StudentID, FirstName, LastName, Passed FROM CourseModulesPassed
INNER JOIN CourseModules CM on CourseModulesPassed.ModuleID = CM.ModuleID
INNER JOIN dbo.Courses C on CM.CourseID = C.CourseID
INNER JOIN dbo.Users U on CourseModulesPassed.StudentID = U.UserID
CREATE VIEW vw_MeetingsWithAbsences AS
SELECT 
  smp.StudyMeetingID, 
  smp.StudentID,
  smp.Presence,
  1 as OtherActivityPresence 
FROM StudyMeetingPresence smp
INNER JOIN ActivityInsteadOfAbsence aioa 
  ON aioa.MeetingID = smp.StudyMeetingID 
  AND aioa.StudentID = smp.StudentID

UNION

SELECT 
  smp.StudyMeetingID, 
  smp.StudentID,
  smp.Presence,
  0 as OtherActivityPresence 
FROM StudyMeetingPresence smp
LEFT OUTER JOIN ActivityInsteadOfAbsence aioa 
  ON aioa.MeetingID = smp.StudyMeetingID 
  AND aioa.StudentID = smp.StudentID
WHERE 
  smp.presence = 0 
  AND aioa.MeetingID IS NULL;




--wszystkie spotkania studyjne użytkowników
CREATE VIEW VW_allUsersStudyMeetings AS
SELECT Users.UserID, Users.FirstName, Users.LastName, 
(SELECT StudyName FROM Studies WHERE Subjects.StudiesID=Studies.StudiesID) As NazwaKierunku,
SubjectName, StartTime, EndTime, StudyMeetingPayment.PaymentStatus
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN StudyMeetingPayment ON StudyMeetingPayment.DetailID=OrderDetails.DetailID
INNER JOIN StudyMeetings ON StudyMeetings.MeetingID=StudyMeetingPayment.MeetingID
INNER JOIN Subjects ON Subjects.SubjectID=StudyMeetings.SubjectID
WHERE OrderDetails.TypeOfActivity=3

--wszystkie spotkania kursów użytkowników
CREATE VIEW VW_allUsersCourseMeetings AS
SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
    Courses.CourseName AS NazwaKursu, 
    CourseModules.ModuleName AS NazwaModulu, 
    StationaryCourseMeeting.StartDate, 
    StationaryCourseMeeting.EndDate, 
    OrderDetails.PaymentStatus
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN StationaryCourseMeeting ON StationaryCourseMeeting.ModuleID = CourseModules.ModuleID
WHERE OrderDetails.TypeOfActivity=2

UNION

SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
    Courses.CourseName AS NazwaKursu, 
    CourseModules.ModuleName AS NazwaModulu, 
    OnlineCourseMeeting.StartDate, 
    OnlineCourseMeeting.EndDate, 
    OrderDetails.PaymentStatus
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN OnlineCourseMeeting ON OnlineCourseMeeting.ModuleID = CourseModules.ModuleID
WHERE OrderDetails.TypeOfActivity=2

--wszystkie webinaria użytkowników
CREATE VIEW VW_allUsersWebinars AS
SELECT Users.UserID, Users.FirstName, Users.LastName, Webinars.WebinarName, Webinars.StartDate, Webinars.EndDate, OrderDetails.PaymentStatus
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON Orders.OrderID=OrderDetails.OrderID
INNER JOIN Webinars ON Webinars.WebinarID=OrderDetails.ActivityID
WHERE TypeOfActivity=1

--wszytskie spotkania do których jest przypisany użytkownik
CREATE VIEW VW_allUsersMeetings AS
SELECT Users.UserID, Users.FirstName, Users.LastName, 
(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
(SELECT StudyName FROM Studies WHERE Subjects.StudiesID=Studies.StudiesID) As ActivityName,
StartTime, EndTime, StudyMeetingPayment.PaymentStatus
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN StudyMeetingPayment ON StudyMeetingPayment.DetailID=OrderDetails.DetailID
INNER JOIN StudyMeetings ON StudyMeetings.MeetingID=StudyMeetingPayment.MeetingID
INNER JOIN Subjects ON Subjects.SubjectID=StudyMeetings.SubjectID
WHERE OrderDetails.TypeOfActivity=3

UNION 

SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
	(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
    Courses.CourseName AS ActivityName, 
    StationaryCourseMeeting.StartDate as StartTime, 
    StationaryCourseMeeting.EndDate as EndTime, 
    OrderDetails.PaymentStatus
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN ActivitiesTypes ON ActivitiesTypes.ActivityTypeID=OrderDetails.ActivityID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN StationaryCourseMeeting ON StationaryCourseMeeting.ModuleID = CourseModules.ModuleID
WHERE OrderDetails.TypeOfActivity=2

UNION

SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
	(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
    Courses.CourseName AS ActivityName, 
    OnlineCourseMeeting.StartDate as StartTime, 
    OnlineCourseMeeting.EndDate as EndTime, 
    OrderDetails.PaymentStatus
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN ActivitiesTypes ON OrderDetails.TypeOfActivity = ActivitiesTypes.ActivityTypeID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN OnlineCourseMeeting ON OnlineCourseMeeting.ModuleID = CourseModules.ModuleID
WHERE OrderDetails.TypeOfActivity=2

UNION

SELECT Users.UserID, Users.FirstName, Users.LastName, 
(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
Webinars.WebinarName as ActivityName, Webinars.StartDate as StartTime, Webinars.EndDate as EndTime, OrderDetails.PaymentStatus
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON Orders.OrderID=OrderDetails.OrderID
INNER JOIN Webinars ON Webinars.WebinarID=OrderDetails.ActivityID
WHERE TypeOfActivity=1

--wszystkie przeszłe studyjne użytkowników
CREATE VIEW VW_allUsersPastStudyMeetings
SELECT Users.UserID, Users.FirstName, Users.LastName, 
(SELECT StudyName FROM Studies WHERE Subjects.StudiesID=Studies.StudiesID) As NazwaKierunku,
SubjectName, StartTime, EndTime
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN StudyMeetingPayment ON StudyMeetingPayment.DetailID=OrderDetails.DetailID
INNER JOIN StudyMeetings ON StudyMeetings.MeetingID=StudyMeetingPayment.MeetingID
INNER JOIN Subjects ON Subjects.SubjectID=StudyMeetings.SubjectID
WHERE OrderDetails.TypeOfActivity=3 AND StudyMeetings.EndTime<GETDATE()

--wszystkie przeszłe kursy użytkowników
CREATE VIEW VW_allUsersPastCourseMeetings
SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
    Courses.CourseName AS NazwaKursu, 
    CourseModules.ModuleName AS NazwaModulu, 
    StationaryCourseMeeting.StartDate, 
    StationaryCourseMeeting.EndDate
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN StationaryCourseMeeting ON StationaryCourseMeeting.ModuleID = CourseModules.ModuleID
WHERE OrderDetails.TypeOfActivity=2 AND EndDate<GETDATE()

UNION

SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
    Courses.CourseName AS NazwaKursu, 
    CourseModules.ModuleName AS NazwaModulu, 
    OnlineCourseMeeting.StartDate, 
    OnlineCourseMeeting.EndDate
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN OnlineCourseMeeting ON OnlineCourseMeeting.ModuleID = CourseModules.ModuleID
WHERE OrderDetails.TypeOfActivity=2 AND EndDate<GETDATE()

--wszystkie przeszłe webinaria użytkowników
CREATE VIEW VW_allPastUsersWebinars AS
SELECT Users.UserID, Users.FirstName, Users.LastName, Webinars.WebinarName, Webinars.StartDate, Webinars.EndDate
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON Orders.OrderID=OrderDetails.OrderID
INNER JOIN Webinars ON Webinars.WebinarID=OrderDetails.ActivityID
WHERE TypeOfActivity=1 AND EndDate<GETDATE()

--wszytskie przeszłe spotkania użytkowników
CREATE VIEW VW_allUsersPastMeetings AS
SELECT Users.UserID, Users.FirstName, Users.LastName, 
(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
(SELECT StudyName FROM Studies WHERE Subjects.StudiesID=Studies.StudiesID) As ActivityName,
StartTime, EndTime
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN StudyMeetingPayment ON StudyMeetingPayment.DetailID=OrderDetails.DetailID
INNER JOIN StudyMeetings ON StudyMeetings.MeetingID=StudyMeetingPayment.MeetingID
INNER JOIN Subjects ON Subjects.SubjectID=StudyMeetings.SubjectID
WHERE OrderDetails.TypeOfActivity=3 AND EndTime < GETDATE()

UNION 

SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
	(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
    Courses.CourseName AS ActivityName, 
    StationaryCourseMeeting.StartDate as StartTime, 
    StationaryCourseMeeting.EndDate as EndTime
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN ActivitiesTypes ON ActivitiesTypes.ActivityTypeID=OrderDetails.ActivityID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN StationaryCourseMeeting ON StationaryCourseMeeting.ModuleID = CourseModules.ModuleID
WHERE OrderDetails.TypeOfActivity=2 AND EndDate < GETDATE()

UNION

SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
	(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
    Courses.CourseName AS ActivityName, 
    OnlineCourseMeeting.StartDate as StartTime, 
    OnlineCourseMeeting.EndDate as EndTime
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN ActivitiesTypes ON OrderDetails.TypeOfActivity = ActivitiesTypes.ActivityTypeID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN OnlineCourseMeeting ON OnlineCourseMeeting.ModuleID = CourseModules.ModuleID
WHERE OrderDetails.TypeOfActivity=2 AND EndDate < GETDATE()

UNION

SELECT Users.UserID, Users.FirstName, Users.LastName, 
(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
Webinars.WebinarName as ActivityName, Webinars.StartDate as StartTime, Webinars.EndDate as EndTime
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON Orders.OrderID=OrderDetails.OrderID
INNER JOIN Webinars ON Webinars.WebinarID=OrderDetails.ActivityID
WHERE TypeOfActivity=1 AND EndDate < GETDATE()


--wszystkie przyszłe spotkania studyjne użytkowników
CREATE VIEW VW_allUsersFutureStudyMeetings
SELECT Users.UserID, Users.FirstName, Users.LastName, 
(SELECT StudyName FROM Studies WHERE Subjects.StudiesID=Studies.StudiesID) As NazwaKierunku,
SubjectName, StartTime, EndTime
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN StudyMeetingPayment ON StudyMeetingPayment.DetailID=OrderDetails.DetailID
INNER JOIN StudyMeetings ON StudyMeetings.MeetingID=StudyMeetingPayment.MeetingID
INNER JOIN Subjects ON Subjects.SubjectID=StudyMeetings.SubjectID
WHERE OrderDetails.TypeOfActivity=3 AND StudyMeetings.StartTime>GETDATE()

--wszystkie przyszłe spotkania kursowe użytkowników
CREATE VIEW VW_allUsersFutureCourseMeetings
SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
    Courses.CourseName AS NazwaKursu, 
    CourseModules.ModuleName AS NazwaModulu, 
    StationaryCourseMeeting.StartDate, 
    StationaryCourseMeeting.EndDate
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN StationaryCourseMeeting ON StationaryCourseMeeting.ModuleID = CourseModules.ModuleID
WHERE OrderDetails.TypeOfActivity=2 AND StartDate>GETDATE()

UNION

SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
    Courses.CourseName AS NazwaKursu, 
    CourseModules.ModuleName AS NazwaModulu, 
    OnlineCourseMeeting.StartDate, 
    OnlineCourseMeeting.EndDate
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN OnlineCourseMeeting ON OnlineCourseMeeting.ModuleID = CourseModules.ModuleID
WHERE OrderDetails.TypeOfActivity=2 AND StartDate>GETDATE()

--wszystkie przeszłe webinaria użytkowników
CREATE VIEW VW_allUsersFutureWebinars
SELECT Users.UserID, Users.FirstName, Users.LastName, Webinars.WebinarName, Webinars.StartDate, Webinars.EndDate
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON Orders.OrderID=OrderDetails.OrderID
INNER JOIN Webinars ON Webinars.WebinarID=OrderDetails.ActivityID
WHERE TypeOfActivity=1 AND StartDate>GETDATE()


--wszytskie przyszłe spotkania do których jest przypisany użytkownik
CREATE VIEW VW_allUsersFutureMeetings
SELECT Users.UserID, Users.FirstName, Users.LastName, 
(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
(SELECT StudyName FROM Studies WHERE Subjects.StudiesID=Studies.StudiesID) As ActivityName,
StartTime, EndTime
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN StudyMeetingPayment ON StudyMeetingPayment.DetailID=OrderDetails.DetailID
INNER JOIN StudyMeetings ON StudyMeetings.MeetingID=StudyMeetingPayment.MeetingID
INNER JOIN Subjects ON Subjects.SubjectID=StudyMeetings.SubjectID
WHERE OrderDetails.TypeOfActivity=3 AND StartTime > GETDATE()

UNION 

SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
	(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
    Courses.CourseName AS ActivityName, 
    StationaryCourseMeeting.StartDate as StartTime, 
    StationaryCourseMeeting.EndDate as EndTime
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN ActivitiesTypes ON ActivitiesTypes.ActivityTypeID=OrderDetails.ActivityID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN StationaryCourseMeeting ON StationaryCourseMeeting.ModuleID = CourseModules.ModuleID
WHERE OrderDetails.TypeOfActivity=2 AND StartDate > GETDATE()

UNION

SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
	(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
    Courses.CourseName AS ActivityName, 
    OnlineCourseMeeting.StartDate as StartTime, 
    OnlineCourseMeeting.EndDate as EndTime
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN ActivitiesTypes ON OrderDetails.TypeOfActivity = ActivitiesTypes.ActivityTypeID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN OnlineCourseMeeting ON OnlineCourseMeeting.ModuleID = CourseModules.ModuleID
WHERE OrderDetails.TypeOfActivity=2 AND StartDate > GETDATE()

UNION

SELECT Users.UserID, Users.FirstName, Users.LastName, 
(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
Webinars.WebinarName as ActivityName, Webinars.StartDate as StartTime, Webinars.EndDate as EndTime
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON Orders.OrderID=OrderDetails.OrderID
INNER JOIN Webinars ON Webinars.WebinarID=OrderDetails.ActivityID
WHERE TypeOfActivity=1 AND StartDate > GETDATE()

--wszystkie aktualnie trwające spotkania studyjne użytkowników
CREATE VIEW VW_allUsersCurrentStudyMeetings
SELECT Users.UserID, Users.FirstName, Users.LastName, 
(SELECT StudyName FROM Studies WHERE Subjects.StudiesID=Studies.StudiesID) As NazwaKierunku,
SubjectName, StartTime, EndTime
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN StudyMeetingPayment ON StudyMeetingPayment.DetailID=OrderDetails.DetailID
INNER JOIN StudyMeetings ON StudyMeetings.MeetingID=StudyMeetingPayment.MeetingID
INNER JOIN Subjects ON Subjects.SubjectID=StudyMeetings.SubjectID
WHERE OrderDetails.TypeOfActivity=3 AND StudyMeetings.StartTime<GETDATE() AND StudyMeetings.StartTime>GETDATE()

--wszystkie aktualne spotkania kursowe użytkowników
CREATE VIEW VW_allUsersCurrentCourseMeetings
SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
    Courses.CourseName AS NazwaKursu, 
    CourseModules.ModuleName AS NazwaModulu, 
    StationaryCourseMeeting.StartDate, 
    StationaryCourseMeeting.EndDate
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN StationaryCourseMeeting ON StationaryCourseMeeting.ModuleID = CourseModules.ModuleID
WHERE OrderDetails.TypeOfActivity=2 AND StartDate<GETDATE() AND EndDate>GETDATE()

UNION

SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
    Courses.CourseName AS NazwaKursu, 
    CourseModules.ModuleName AS NazwaModulu, 
    OnlineCourseMeeting.StartDate, 
    OnlineCourseMeeting.EndDate
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN OnlineCourseMeeting ON OnlineCourseMeeting.ModuleID = CourseModules.ModuleID
WHERE OrderDetails.TypeOfActivity=2 AND StartDate<GETDATE() AND EndDate>GETDATE()

--wszystkie aktualne webinaria użytkowników
CREATE VIEW VW_allUsersCurrentWebinars AS
SELECT Users.UserID, Users.FirstName, Users.LastName, Webinars.WebinarName, Webinars.StartDate, Webinars.EndDate
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON Orders.OrderID=OrderDetails.OrderID
INNER JOIN Webinars ON Webinars.WebinarID=OrderDetails.ActivityID
WHERE TypeOfActivity=1 AND StartDate<GETDATE() AND EndDate>GETDATE()


--wszytskie aktualnie trwające spotkania do których jest przypisany użytkownik
CREATE VIEW VW_allUsersCurrentMeetings
SELECT Users.UserID, Users.FirstName, Users.LastName, 
(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
(SELECT StudyName FROM Studies WHERE Subjects.StudiesID=Studies.StudiesID) As ActivityName,
StartTime, EndTime
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN StudyMeetingPayment ON StudyMeetingPayment.DetailID=OrderDetails.DetailID
INNER JOIN StudyMeetings ON StudyMeetings.MeetingID=StudyMeetingPayment.MeetingID
INNER JOIN Subjects ON Subjects.SubjectID=StudyMeetings.SubjectID
LEFT JOIN StationaryMeetings ON StationaryMeetings.MeetingID=StudyMeetings.MeetingID
WHERE OrderDetails.TypeOfActivity=3 AND StartTime<GETDATE() AND EndTime>GETDATE()

UNION 

SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
	(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
    Courses.CourseName AS ActivityName, 
    StationaryCourseMeeting.StartDate as StartTime, 
    StationaryCourseMeeting.EndDate as EndTime
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN ActivitiesTypes ON ActivitiesTypes.ActivityTypeID=OrderDetails.ActivityID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN StationaryCourseMeeting ON StationaryCourseMeeting.ModuleID = CourseModules.ModuleID
WHERE OrderDetails.TypeOfActivity=2 AND StartDate<GETDATE() AND EndDate>GETDATE()

UNION

SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
	(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
    Courses.CourseName AS ActivityName, 
    OnlineCourseMeeting.StartDate as StartTime, 
    OnlineCourseMeeting.EndDate as EndTime
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN ActivitiesTypes ON OrderDetails.TypeOfActivity = ActivitiesTypes.ActivityTypeID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN OnlineCourseMeeting ON OnlineCourseMeeting.ModuleID = CourseModules.ModuleID
WHERE OrderDetails.TypeOfActivity=2 AND StartDate < GETDATE() AND EndDate > GETDATE()

UNION

SELECT Users.UserID, Users.FirstName, Users.LastName, 
(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
Webinars.WebinarName as ActivityName, Webinars.StartDate as StartTime, Webinars.EndDate as EndTime
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON Orders.OrderID=OrderDetails.OrderID
INNER JOIN Webinars ON Webinars.WebinarID=OrderDetails.ActivityID
WHERE TypeOfActivity=1 AND StartDate < GETDATE() AND EndDate > GETDATE()

--wszystkie aktualnie trwające stacjonarne spotkania wraz z salą i adresem
CREATE VIEW VW_allUsersStationaryMeetingsWithRoomAndAddresses
SELECT Users.UserID, Users.FirstName, Users.LastName, 
(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
(SELECT StudyName FROM Studies WHERE Subjects.StudiesID=Studies.StudiesID) As ActivityName,
StartTime, EndTime, Rooms.RoomName, Rooms.Street, PostalCode, CityName
FROM Users
INNER JOIN Orders ON Orders.StudentID=Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN StudyMeetingPayment ON StudyMeetingPayment.DetailID=OrderDetails.DetailID
INNER JOIN StudyMeetings ON StudyMeetings.MeetingID=StudyMeetingPayment.MeetingID
INNER JOIN Subjects ON Subjects.SubjectID=StudyMeetings.SubjectID
LEFT JOIN StationaryMeetings ON StationaryMeetings.MeetingID=StudyMeetings.MeetingID
LEFT JOIN Rooms ON Rooms.RoomID=StationaryMeetings.RoomID
LEFT JOIN Cities ON Cities.CityID=Rooms.CityID
WHERE OrderDetails.TypeOfActivity=3 AND StartTime<GETDATE() AND EndTime>GETDATE()

UNION 

SELECT 
    Users.UserID, 
    Users.FirstName, 
    Users.LastName, 
	(SELECT TypeName FROM ActivitiesTypes WHERE OrderDetails.TypeOfActivity=ActivitiesTypes.ActivityTypeID) as ActivityType,
    Courses.CourseName AS ActivityName, 
    StationaryCourseMeeting.StartDate as StartTime, 
    StationaryCourseMeeting.EndDate as EndTime,
	Rooms.RoomName, Rooms.Street, PostalCode, CityName
FROM Users
INNER JOIN Orders ON Orders.StudentID = Users.UserID
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN ActivitiesTypes ON ActivitiesTypes.ActivityTypeID=OrderDetails.ActivityID
INNER JOIN Courses ON Courses.CourseID = OrderDetails.ActivityID
INNER JOIN CourseModules ON CourseModules.CourseID = Courses.CourseID
INNER JOIN StationaryCourseMeeting ON StationaryCourseMeeting.ModuleID = CourseModules.ModuleID
INNER JOIN Rooms ON Rooms.RoomID=StationaryCourseMeeting.RoomID
INNER JOIN Cities ON Cities.CityID=Rooms.CityID
WHERE OrderDetails.TypeOfActivity=2 AND StartDate<GETDATE() AND EndDate>GETDATE()



CREATE VIEW VW_BilocationBetweenAllActivities AS
WITH T1 (StudentID, StartTime, EndTime, TypeOfActivity, ActivityID) AS (
        SELECT StudentID, StartDate, EndDate, 'Webinar', WebinarID FROM Orders
        INNER JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
        AND TypeOfActivity = 1
        INNER JOIN Webinars ON WebinarID = OrderDetails.ActivityID
        WHERE StartDate > '2025-01-01'
        UNION
        SELECT StudentID, StartDate, EndDate, 'Kurs', CM.CourseID FROM StationaryCourseMeeting
        INNER JOIN dbo.CourseModules CM on StationaryCourseMeeting.ModuleID = CM.ModuleID
        INNER JOIN Courses ON CM.CourseID = Courses.CourseID
        INNER JOIN OrderDetails ON OrderDetails.ActivityID = Courses.CourseID
        AND TypeOfActivity = 2
        INNER JOIN Orders ON OrderDetails.OrderID = Orders.OrderID
        WHERE StartDate > '2025-01-01'
        UNION
        SELECT StudentID, StartTime, EndTime, 'Spotkanie studyjne', StudyMeetings.MeetingID FROM StudyMeetings
        INNER JOIN StudyMeetingPayment ON StudyMeetingPayment.MeetingID = StudyMeetings.MeetingID
        INNER JOIN OrderDetails ON OrderDetails.DetailID = StudyMeetingPayment.DetailID
        AND TypeOfActivity = 3
        INNER JOIN Orders ON OrderDetails.OrderID = Orders.OrderID
        WHERE StartTime > '2025-01-01'
        UNION
        SELECT Orders.StudentID, StartTime, EndTime, 'Spotkanie studyjne', MeetingID FROM Orders
        INNER JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
        AND TypeOfActivity = 4
        INNER JOIN StudyMeetings ON StudyMeetings.MeetingID = OrderDetails.ActivityID
        WHERE StartTime > '2025-01-01'
)
SELECT
    t2.StudentID,
    t2.StartTime AS StartTime1,
    t2.EndTime AS EndTime1,
    t2.TypeOfActivity AS Typ1,
    t2.ActivityID AS 'ID Aktywności 1',
    t3.StartTime AS StartTime2,
    t3.EndTime AS EndTime2,
    t3.TypeOfActivity AS Typ2,
    t3.ActivityID AS 'Typ Aktywności 2'
FROM
    T1 AS t2
JOIN
    T1 AS t3
    ON
        t2.StudentID = t3.StudentID
            AND t2.StartTime < t3.EndTime
            AND t2.EndTime > t3.StartTime
            AND t2.StartTime <> t3.StartTime


CREATE VIEW VW_StudiesStartDateEndDate AS
With t1 as
(SELECT S2.StudiesID, CONCAT(DATENAME(MONTH, MIN(StudyMeetings.StartTime)),' ' + DATENAME(YEAR, MIN(StudyMeetings.StartTime))) as startDate
        FROM StudyMeetings
                 INNER JOIN Subjects ON Subjects.SubjectID=StudyMeetings.SubjectID
                 INNER JOIN Studies S2 ON S2.StudiesID=Subjects.StudiesID
				 GROUP BY S2.StudiesID)
SELECT S2.StudiesID, t1.startDate, CONCAT(DATENAME(MONTH, MAX(StudyMeetings.EndTime)),' ' + DATENAME(YEAR, MAX(StudyMeetings.EndTime))) as endDate
FROM StudyMeetings
INNER JOIN Subjects ON Subjects.SubjectID=StudyMeetings.SubjectID
INNER JOIN Studies S2 ON S2.StudiesID=Subjects.StudiesID
INNER JOIN t1 ON t1.studiesID=S2.StudiesID
GROUP BY S2.StudiesID, t1.startDate


CREATE VIEW VW_allOrderedActivities AS
SELECT ActivityID, 
(SELECT typename FROM ActivitiesTypes WHERE ActivitiesTypes.ActivityTypeID=OrderDetails.TypeOfActivity) as ActivityType,
Studies.StudyName as ActivityName, 
vw.StartDate, vw.EndDate
FROM Orders 
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN VW_StudiesStartDateEndDate vw ON vw.studiesid=OrderDetails.ActivityID
INNER JOIN Studies ON Studies.StudiesID=OrderDetails.ActivityID
WHERE TypeOfActivity=3
UNION
SELECT ActivityID, 
(SELECT typename FROM ActivitiesTypes WHERE ActivitiesTypes.ActivityTypeID=OrderDetails.TypeOfActivity) as ActivityType,
Courses.CourseName as ActivityName,
DATENAME(DAY, vw.[Data rozpoczęcia])+' '+DATENAME(MONTH, vw.[Data rozpoczęcia])+' '+ DATENAME(YEAR, vw.[Data rozpoczęcia]) as StartDate, 
DATENAME(DAY, vw.[Data rozpoczęcia])+' '+DATENAME(MONTH,vw.[Data zakończenia]) + ' ' +DATENAME(YEAR,vw.[Data zakończenia]) as EndDate
FROM Orders 
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN VW_CoursesStartDateEndDate vw ON vw.id=OrderDetails.ActivityID
INNER JOIN Courses ON Courses.CourseID=OrderDetails.ActivityID
WHERE TypeOfActivity=2
UNION
SELECT ActivityID, 
(SELECT typename FROM ActivitiesTypes WHERE ActivitiesTypes.ActivityTypeID=OrderDetails.TypeOfActivity) as ActivityType,
Webinars.WebinarName as ActivityName,
DATENAME(DAY,StartDate)+' '+DATENAME(MONTH,StartDate)+' '+DATENAME(YEAR,StartDate)+' '+DATENAME(HOUR,StartDate)+':'+DATENAME(MINUTE,StartDate),
DATENAME(DAY,EndDate)+' '+DATENAME(MONTH,EndDate)+' '+DATENAME(YEAR,EndDate)+' '+DATENAME(HOUR,EndDate)+':'+DATENAME(MINUTE,EndDate)
FROM Orders 
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN VW_CoursesStartDateEndDate vw ON vw.id=OrderDetails.ActivityID
INNER JOIN Webinars ON Webinars.WebinarID=OrderDetails.ActivityID
WHERE TypeOfActivity=1


CREATE VIEW vw_NumberOfHoursOfWOrkForAllEmployees as
with t1 as (
select EmployeeID, (ISNULL(DATEDIFF(minute,sm.EndTime , sm.StartTime), 0)+ ISNULL(DATEDIFF(minute,sm1.EndTime, sm1.StartTime), 0)+ISNULL(DATEDIFF(minute,w.EndDate,w.StartDate), 0)+ ISNULL(DATEDIFF(minute,w1.EndDate, w1.StartDate), 0)+ISNULL(DATEDIFF(minute,ocm.EndDate, ocm.StartDate), 0)+ISNULL(DATEDIFF(minute,ocm1.EndDate, ocm1.StartDate), 0)+ISNULL(DATEDIFF(minute,scm.EndDate,scm.StartDate), 0)+ISNULL(DATEDIFF(minute,scm1.EndDate,scm1.StartDate), 0)) * (-1) as liczbaminut from Employees
left outer join StudyMeetings as sm on sm.LecturerID = Employees.EmployeeID
left outer join StudyMeetings as sm1 on sm1.TranslatorID = Employees.EmployeeID
left outer join Webinars as w on w.TeacherID = Employees.EmployeeID
left outer join Webinars as w1 on w1.TranslatorID = Employees.EmployeeID
left outer join CourseModules as cm on cm.LecturerID = Employees.EmployeeID
left outer join CourseModules as cm1 on cm1.TranslatorID = Employees.EmployeeID
left outer join OnlineCourseMeeting as ocm on ocm.ModuleID = cm.ModuleID
left outer join OnlineCourseMeeting as ocm1 on ocm1.ModuleID = cm1.ModuleID
left outer join StationaryCourseMeeting as scm on scm.ModuleID = cm.ModuleID
left outer join StationaryCourseMeeting as scm1 on scm1.ModuleID = cm1.ModuleID
UNION
select internshipCoordinatorID, 3000 from internship
)

select employeeid, round(SUM(liczbaminut)/60,2) as liczbagodzinpracy from t1
group by EmployeeID


