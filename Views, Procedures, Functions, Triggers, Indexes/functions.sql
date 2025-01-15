CREATE FUNCTION CheckIfStudentPassed
(
    @StudentID INT,
    @StudiesID INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT;

    
    IF EXISTS (
        SELECT 1
        FROM Subjects s
        LEFT JOIN SubjectsResults sr ON s.SubjectID = sr.SubjectID AND sr.StudentID = @StudentID
        WHERE s.StudiesID = @StudiesID
          AND (sr.GradeID IS NULL OR sr.GradeID < 2) 
    )
    BEGIN
        SET @Result = 0; 
    END
    ELSE
    BEGIN
        SET @Result = 1; 
    END;

    RETURN @Result;
END;
GO

CREATE FUNCTION CheckIfStudentPassedCourse
(
    @StudentID INT,
    @CourseID INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT;

    
    IF NOT EXISTS (
        SELECT 1
        FROM Courses
        INNER JOIN CourseModules ON Courses.CourseID = CourseModules.CourseID
        LEFT JOIN StationaryCourseMeeting ON CourseModules.ModuleID = StationaryCourseMeeting.ModuleID
        LEFT JOIN OnlineCourseMeeting ON CourseModules.ModuleID = OnlineCourseMeeting.ModuleID
        WHERE Courses.CourseID = @CourseID
        AND GETDATE() > OnlineCourseMeeting.EndDate OR GETDATE() > StationaryCourseMeeting.EndDate
    )
    BEGIN
        SET @Result = 0; 
        RETURN @Result;
    END;

    
    DECLARE @TotalModules INT;
    SELECT @TotalModules = COUNT(ModuleID)
    FROM VW_CourseModulesPassed
    WHERE CourseID = @CourseID;

    
    DECLARE @PassedModules INT;
    SELECT @PassedModules = COUNT(ModuleID)
    FROM VW_CourseModulesPassed
    WHERE CourseID = @CourseID
      AND StudentID = @StudentID
      AND Passed = 1; 

    
    IF (@TotalModules > 0 AND @PassedModules >= 0.8 * @TotalModules)
    BEGIN
        SET @Result = 1; 
    END
    ELSE
    BEGIN
        SET @Result = 0; 
    END;

    RETURN @Result;
END;
GO


CREATE FUNCTION GetStudentOrders(@StudentID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        o.OrderID,
        o.OrderDate,
        o.DeferredDate,
        od.DetailID,
        od.ActivityID,
        od.Price AS DetailPrice,
        od.PaymentStatus AS DetailPaymentStatus
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    WHERE o.StudentID = @StudentID
);

CREATE FUNCTION GetProductsFromOrder
(
    @OrderID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        OD.OrderID,
        OD.ActivityID,
        OD.TypeOfActivity
    FROM 
        OrderDetails OD
    WHERE 
        OD.OrderID = @OrderID
);


CREATE FUNCTION CheckStudentPresenceOnActivity(
    @StudentID INT,
    @MeetingID INT
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @PresenceMessage NVARCHAR(255);

    -- Sprawdzanie obecności na spotkaniu
    IF EXISTS (SELECT 1 FROM StudyMeetingPresence
               WHERE StudentID = @StudentID
               AND StudyMeetingID = @MeetingID
               AND Presence = 1)
    BEGIN
        SET @PresenceMessage = 'Student był obecny na tym spotkaniu.';
    END
    ELSE
    BEGIN
        -- Sprawdzanie, czy student odrobił spotkanie inną aktywnością
        IF EXISTS (SELECT 1 FROM ActivityInsteadOfAbsence
                   WHERE StudentID = @StudentID
                   AND MeetingID = @MeetingID)
        BEGIN
            SET @PresenceMessage = 'Student odrobił to spotkanie inną aktywnością.';
        END
        ELSE
        BEGIN
            SET @PresenceMessage = 'Student nie był obecny na tym spotkaniu ani nie odrobił go inną aktywnością.';
        END
    END

    -- Zwracamy odpowiednią wiadomość
    RETURN @PresenceMessage;
END;
GO



CREATE PROCEDURE GetRemainingSeats
    @ActivityID INT,
    @TypeOfActivity INT,
    @RemainingSeats INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @TypeOfActivity = 1
    BEGIN
        SET @RemainingSeats = 2147483647;
    END

    IF @TypeOfActivity = 2
    BEGIN
        SELECT @RemainingSeats = c.StudentLimit -
            (SELECT ISNULL(COUNT(*), 0)
             FROM OrderDetails od
             WHERE od.ActivityID = c.CourseID AND od.TypeOfActivity = 2)
        FROM Courses c
        WHERE c.CourseID = @ActivityID;

        IF @RemainingSeats IS NULL OR @RemainingSeats < 0
            SET @RemainingSeats = 2147483647;
    END

    IF @TypeOfActivity = 3
    BEGIN
        SELECT @RemainingSeats = s.StudentLimit -
            (SELECT ISNULL(COUNT(*), 0)
             FROM Subjects ss
             INNER JOIN StudyMeetings SM ON SM.SubjectID = ss.SubjectID
             INNER JOIN StudyMeetingPayment SMP ON SMP.MeetingID = SM.MeetingID
             WHERE ss.StudiesID = s.StudiesID)
        FROM Studies s
        WHERE s.StudiesID = @ActivityID;

        IF @RemainingSeats IS NULL OR @RemainingSeats < 0
            SET @RemainingSeats = 2147483647;
    END

    IF @TypeOfActivity = 4
    BEGIN
        SELECT @RemainingSeats = sm.StudentLimit -
            (SELECT ISNULL(COUNT(*), 0)
             FROM StudyMeetingPayment smp
             WHERE smp.MeetingID = sm.MeetingID)
        FROM StationaryMeetings sm
        INNER JOIN StudyMeetings smt ON smt.MeetingID = sm.MeetingID
        WHERE sm.MeetingID = @ActivityID;

        IF @RemainingSeats IS NULL OR @RemainingSeats < 0
            SET @RemainingSeats = 2147483647;
    END

    -- Jeśli @RemainingSeats nie zostało ustawione
    IF @RemainingSeats IS NULL
        SET @RemainingSeats = -1;

    -- Zwrócenie wyniku
    SELECT @RemainingSeats AS RemainingSeats;
END;
GO


CREATE FUNCTION GetAvailableRooms
(
    @StartTime DATETIME,
    @EndTime DATETIME,
    @CityID INT
)
RETURNS TABLE
AS
RETURN
(
    -- Pobranie wolnych sal w podanym czasie w danym mieście
    SELECT Rooms.RoomID, Rooms.RoomName, Rooms.Street, Rooms.CityID, Rooms.Limit
    FROM Rooms
    WHERE Rooms.CityID = @CityID
      AND EXISTS (
          -- Sprawdzenie, czy CityID istnieje w tabeli Cities
          SELECT 1
          FROM Cities
          WHERE CityID = @CityID
      )
      AND Rooms.RoomID NOT IN
      (
          -- Pobranie wszystkich zajętych sal w danym przedziale czasowym
          SELECT RoomID
          FROM VW_RoomsAvailability
          WHERE (@StartTime BETWEEN StartDate AND EndDate)
             OR (@EndTime BETWEEN StartDate AND EndDate)
             OR (StartDate BETWEEN @StartTime AND @EndTime)
             OR (EndDate BETWEEN @StartTime AND @EndTime)
      )
);

CREATE FUNCTION GetStudentAttendanceAtSubjects (@StudentID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM vw_StudentsAttendanceAtSubjects
    WHERE StudentID = @StudentID
      AND EXISTS (
          SELECT 1
          FROM UsersRoles
          WHERE UserID = @StudentID AND RoleID = 1
      )
);


CREATE FUNCTION GetStudentResultsFromStudies (@StudentID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
        U.UserID,
        U.FirstName AS StudentFirstName,
        U.LastName AS StudentLastName,
        S.SubjectName,
        G.GradeName
    FROM SubjectsResults SR
    JOIN Users U ON SR.StudentID = U.UserID
    JOIN Subjects S ON SR.SubjectID = S.SubjectID
    JOIN Grades G ON SR.GradeID = G.GradeID
    WHERE SR.StudentID = @StudentID
      AND EXISTS (
          SELECT 1
          FROM UsersRoles UR
          WHERE UR.UserID = @StudentID AND UR.RoleID = 1
      )
);


CREATE FUNCTION GetCourseModulesPassed (@StudentID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
        CMP.CourseID,
        CMP.CourseName,
        CMP.ModuleID,
        CMP.ModuleName,
        CMP.FirstName,
        CMP.LastName,
        CMP.Passed
    FROM VW_CourseModulesPassed CMP
    WHERE CMP.StudentID = @StudentID
      AND CMP.Passed = 1
      AND EXISTS (
          SELECT 1
          FROM UsersRoles
          WHERE UserID = @StudentID AND RoleID = 1
      )
);


CREATE FUNCTION GetFutureMeetingsForStudent (@StudentID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM VW_allUsersFutureMeetings
    WHERE UserID = @StudentID
      AND EXISTS (
          SELECT 1
          FROM UsersRoles
          WHERE UserID = @StudentID AND RoleID = 1
      )
);


CREATE FUNCTION GetCurrentMeetingsForStudent (@StudentID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM VW_allUsersCurrentMeetings
    WHERE UserID = @StudentID
      AND EXISTS (
          SELECT 1
          FROM UsersRoles
          WHERE UserID = @StudentID AND RoleID = 1
      )
);


CREATE FUNCTION dbo.GetNumberOfHoursOfWorkForAllEmployees
(
    @StartDate datetime,
    @EndDate datetime
)
RETURNS TABLE
    AS
    RETURN
    (
    WITH t1 AS (
        SELECT
            EmployeeID,
            (
                ISNULL(CASE
                            WHEN sm.StartTime >= @StartDate AND sm.EndTime <= @EndDate
                                THEN DATEDIFF(minute, sm.EndTime, sm.StartTime)
                            ELSE 0
                            END, 0) +
                ISNULL(CASE
                            WHEN sm1.StartTime >= @StartDate AND sm1.EndTime <= @EndDate
                                THEN DATEDIFF(minute, sm1.EndTime, sm1.StartTime)
                            ELSE 0
                            END, 0) +
                ISNULL(CASE
                            WHEN w.StartDate >= @StartDate AND w.EndDate <= @EndDate
                                THEN DATEDIFF(minute, w.EndDate, w.StartDate)
                            ELSE 0
                            END, 0) +
                ISNULL(CASE
                            WHEN w1.StartDate >= @StartDate AND w1.EndDate <= @EndDate
                                THEN DATEDIFF(minute, w1.EndDate, w1.StartDate)
                            ELSE 0
                            END, 0) +
                ISNULL(CASE
                            WHEN ocm.StartDate >= @StartDate AND ocm.EndDate <= @EndDate
                                THEN DATEDIFF(minute, ocm.EndDate, ocm.StartDate)
                            ELSE 0
                            END, 0) +
                ISNULL(CASE
                            WHEN ocm1.StartDate >= @StartDate AND ocm1.EndDate <= @EndDate
                                THEN DATEDIFF(minute, ocm1.EndDate, ocm1.StartDate)
                            ELSE 0
                            END, 0) +
                ISNULL(CASE
                            WHEN scm.StartDate >= @StartDate AND scm.EndDate <= @EndDate
                                THEN DATEDIFF(minute, scm.EndDate, scm.StartDate)
                            ELSE 0
                            END, 0) +
                ISNULL(CASE
                            WHEN scm1.StartDate >= @StartDate AND scm1.EndDate <= @EndDate
                                THEN DATEDIFF(minute, scm1.EndDate, scm1.StartDate)
                            ELSE 0
                            END, 0)
                ) * (-1) as liczbaminut
        FROM Employees
        LEFT OUTER JOIN StudyMeetings AS sm ON sm.LecturerID = Employees.EmployeeID
        LEFT OUTER JOIN StudyMeetings AS sm1 ON sm1.TranslatorID = Employees.EmployeeID
        LEFT OUTER JOIN Webinars AS w ON w.TeacherID = Employees.EmployeeID
        LEFT OUTER JOIN Webinars AS w1 ON w1.TranslatorID = Employees.EmployeeID
        LEFT OUTER JOIN CourseModules AS cm ON cm.LecturerID = Employees.EmployeeID
        LEFT OUTER JOIN CourseModules AS cm1 ON cm1.TranslatorID = Employees.EmployeeID
        LEFT OUTER JOIN OnlineCourseMeeting AS ocm ON ocm.ModuleID = cm.ModuleID
        LEFT OUTER JOIN OnlineCourseMeeting AS ocm1 ON ocm1.ModuleID = cm1.ModuleID
        LEFT OUTER JOIN StationaryCourseMeeting AS scm ON scm.ModuleID = cm.ModuleID
        LEFT OUTER JOIN StationaryCourseMeeting AS scm1 ON scm1.ModuleID = cm1.ModuleID

    UNION

    SELECT
        internshipCoordinatorID,
        CASE
            WHEN i.StartDate >= @StartDate AND i.EndDate <= @EndDate
                THEN 3000
            ELSE 0
            END
    FROM internship i
)
SELECT
    EmployeeID,
    ROUND(SUM(liczbaminut)/60.0, 2) as liczbagodzinpracy
FROM t1
GROUP BY EmployeeID
)



CREATE FUNCTION dbo.GetUserDiplomasAndCertificates
(
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        CASE
            WHEN EXISTS (SELECT 1 FROM Users WHERE FirstName = @FirstName AND LastName = @LastName) THEN 'Diploma'
            ELSE 'No User Found'
        END AS CertificateType,
        vw_StudentsDiplomas.StudyName,  -- Zakładając, że ta kolumna istnieje w widoku
        vw_StudentsDiplomas.GradeName,  -- Zakładając, że ta kolumna istnieje w widoku
        vw_StudentsDiplomas.StudyStart,
        vw_StudentsDiplomas.StudyEnd
    FROM
        vw_StudentsDiplomas
    WHERE
        vw_StudentsDiplomas.FirstName = @FirstName
        AND vw_StudentsDiplomas.LastName = @LastName

    UNION ALL

    SELECT
        'Course Certificate' AS CertificateType,
        vw_CoursesCertificates.CourseName,  -- Zakładając, że ta kolumna istnieje w widoku
        NULL AS GradeName,
        vw_CoursesCertificates.CourseStart,
        vw_CoursesCertificates.CourseEnd
    FROM
        Users
    INNER JOIN
        vw_CoursesCertificates
    ON
        vw_CoursesCertificates.FirstName = @FirstName
        AND vw_CoursesCertificates.LastName = @LastName
);


CREATE FUNCTION dbo.GetMeetingsInCity
(
    @cityName NVARCHAR(100)
)
RETURNS TABLE
AS
RETURN
(
    SELECT UserID, 
           FirstName, 
           LastName, 
           ActivityType, 
           ActivityName, 
           StartTime, 
           EndTime, 
           RoomName, 
           Street, 
           PostalCode, 
           CityName
    FROM VW_allUsersStationaryMeetingsWithRoomAndAddresses
    WHERE CityName = @cityName  
);

CREATE VIEW VW_FutureEventsWithDetails AS
-- Kursy
SELECT 
    'Course' AS EventType,
    c.CourseName AS EventName,
    c.StartDate AS StartDate,
    c.EndDate AS EndDate
FROM 
    Courses c
WHERE 
    c.StartDate > GETDATE()

UNION ALL

-- Webinary
SELECT 
    'Webinar' AS EventType,
    w.WebinarTitle AS EventName,
    w.StartDate AS StartDate,
    w.EndDate AS EndDate
FROM 
    Webinars w
WHERE 
    w.StartDate > GETDATE()

UNION ALL

-- Spotkania studiów
SELECT 
    'Study Meeting' AS EventType,
    sm.SubjectName AS EventName,
    sm.StartTime AS StartDate,
    sm.EndTime AS EndDate
FROM 
    StudyMeetings sm
JOIN 
    Subjects s ON sm.SubjectID = s.SubjectID
WHERE 
    sm.StartTime > GETDATE();


CREATE FUNCTION dbo.fn_GetPracticesForCoordinator
(
    @CoordinatorID INT -- Parametr: ID koordynatora
)
    RETURNS TABLE
        AS
        RETURN
        (
        -- Zapytanie do pobrania praktyk dla koordynatora
        SELECT
            p.InternshipID AS PracticeID,          -- ID praktyki
            p.StartDate AS StartDate,            -- Data rozpoczęcia
            p.EndDate AS EndDate,                -- Data zakończenia
            u.FirstName + ' ' + u.LastName AS CoordinatorName -- Imię i nazwisko koordynatora
        FROM
            Internship p
                JOIN Employees c ON p.InternshipCoordinatorID = c.EmployeeID
                JOIN Users u ON c.EmployeeID = u.UserID
        WHERE
            c.EmployeeID = @CoordinatorID    -- Filtrujemy po ID koordynatora
        );
