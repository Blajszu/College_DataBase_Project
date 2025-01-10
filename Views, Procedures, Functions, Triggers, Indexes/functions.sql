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
        WHERE CourseID = @CourseID
          AND GETDATE() > EndDate 
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
        o.TotalPrice,
        o.PaymentStatus,
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


CREATE FUNCTION CheckStudentPresenceOrActivity
    @StudentID INT,
    @MeetingID INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM StudyMeetingPresence 
               WHERE StudentID = @StudentID 
               AND StudyMeetingID = @MeetingID
               AND Presence = 1)
    BEGIN
        SELECT 'Student był obecny na tym spotkaniu.' AS Presence;
    END
    ELSE
    BEGIN
        IF EXISTS (SELECT 1 FROM ActivityInsteadOfAbsence 
                   WHERE StudentID = @StudentID 
                   AND MeetingID = @MeetingID)
        BEGIN
            SELECT 'Student odrobił to spotkanie inną aktywnością.' AS Presence;
        END
        ELSE
        BEGIN
            SELECT 'Student nie był obecny na tym spotkaniu ani nie odrobił go inną aktywnością.' AS Presence;
        END
    END
END;


CREATE FUNCTION GetRemainingSeats
    @ActivityID INT,
    @TypeOfActivity INT,
    @RemainingSeats INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @TypeOfActivity = 1
    BEGIN
        SET @RemainingSeats = 2147483647;
        SELECT @RemainingSeats;
    END

    IF @TypeOfActivity = 2
    BEGIN
        SELECT @RemainingSeats = c.StudentLimit - 
            ISNULL(COUNT(od.OrderID), 0)
        FROM Courses c
        INNER JOIN OrderDetails od ON od.ActivityID = c.CourseID AND od.TypeOfActivity = 2
        WHERE c.CourseID = @ActivityID;

        IF @RemainingSeats IS NULL OR @RemainingSeats < 0
            SET @RemainingSeats = 2147483647;
        SELECT @RemainingSeats;
    END

    IF @TypeOfActivity = 3
    BEGIN
        @RemainingSeats = SELECT s.StudentLimit - 
            ISNULL(COUNT(SMP.DetailID), 0)
        FROM Studies s
        INNER JOIN Subjects ss ON ss.StudiesID = s.StudiesID
        INNER JOIN StudyMeetings SM ON SM.SubjectID = ss.SubjectID
        INNER JOIN StudyMeetingPayments SMP ON SMP.MeetingID = SM.MeetingID
        WHERE s.StudiesID = @ActivityID;

        IF @RemainingSeats IS NULL OR @RemainingSeats < 0
            SET @RemainingSeats = 2147483647;
        SELECT @RemainingSeats;
    END

    IF @TypeOfActivity = 4
    BEGIN
        SELECT @RemainingSeats = sm.StudentLimit - 
            ISNULL(COUNT(smp.StudentID), 0)
        FROM StationaryMeetings sm
        INNER JOIN StudyMeetings smt ON smt.MeetingID = sm.MeetingID
        INNER JOIN StudyMeetingPayments smp ON smp.MeetingID = sm.MeetingID
        WHERE sm.MeetingID = @ActivityID;

        IF @RemainingSeats IS NULL OR @RemainingSeats < 0
            SET @RemainingSeats = 2147483647;
        SELECT @RemainingSeats;
    END
    ELSE
    SET @RemainingSeats = -1;
    SELECT @RemainingSeats;
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
    -- Sprawdzenie, czy CityID istnieje w tabeli Cities
    IF EXISTS (SELECT 1 FROM Cities WHERE CityID = @CityID)
    BEGIN
        -- Pobranie wolnych sal w podanym czasie w danym mieście
        SELECT Rooms.RoomID, Rooms.RoomName, Rooms.Street, Rooms.CityID, Rooms.Limit
        FROM Rooms
        WHERE Rooms.CityID = @CityID
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
    END
    ELSE
    BEGIN
        -- Zwrócenie pustego zestawu danych, jeśli CityID nie istnieje
        THROW 50002, 'CityID does not exist in the Cities table.', 1;
    END
);

CREATE FUNCTION GetStudentAttendanceAtSubjects (@StudentID INT)
RETURNS TABLE
AS
RETURN
(
    
    IF EXISTS (SELECT 1 FROM UsersRoles WHERE UserID = @StudentID AND RoleID = 1)
    BEGIN
        
        SELECT *
        FROM vw_StudentsAttendanceAtSubjects
        WHERE StudentID = @StudentID;
    END
    ELSE
    BEGIN
        
        THROW 50001, 'User is not a student (RoleID != 1).', 1;
    END
);


CREATE FUNCTION GetStudentResultsFromStudies (@StudentID INT)
RETURNS TABLE
AS
RETURN
(
    
    IF EXISTS (SELECT 1 FROM UsersRoles WHERE UserID = @StudentID AND RoleID = 1)
    BEGIN
        
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
        WHERE SR.StudentID = @StudentID;
    END
    ELSE
    BEGIN
        
        THROW 50001, 'User is not a student (RoleID != 1).', 1;
    END
);



CREATE FUNCTION GetCourseModulesPassed (@StudentID INT)
RETURNS TABLE
AS
RETURN
(
    
    IF EXISTS (SELECT 1 FROM UsersRoles WHERE UserID = @StudentID AND RoleID = 1)
    BEGIN
        
        SELECT
            CMP.CourseID,
            CMP.CourseName,
            CMP.ModuleID,
            CMP.ModuleName,
            CMP.FirstName,
            CMP.LastName,
            CMP.Passed
        FROM VW_CourseModulesPassed CMP
        WHERE CMP.StudentID = @StudentID AND CMP.Passed = 1;
    END
    ELSE
    BEGIN
        
        THROW 50001, 'User is not a student (RoleID != 1).', 1;
    END
);


CREATE FUNCTION GetFutureMeetingsForStudent (@StudentID INT)
RETURNS TABLE
AS
RETURN
(
    
    IF EXISTS (SELECT 1 FROM UsersRoles WHERE UserID = @StudentID AND RoleID = 1)
    BEGIN
        
        SELECT *
        FROM VW_allUsersFutureMeetings
        WHERE UserID = @StudentID;
    END
    ELSE
    BEGIN
        
        THROW 50001, 'User is not a student (RoleID != 1).', 1;
    END
);


CREATE FUNCTION GetCurrentMeetingsForStudent (@StudentID INT)
RETURNS TABLE
AS
RETURN
(
    
    IF EXISTS (SELECT 1 FROM UsersRoles WHERE UserID = @StudentID AND RoleID = 1)
    BEGIN
        
        SELECT *
        FROM VW_allUsersCurrentMeetings
        WHERE UserID = @StudentID;
    END
    ELSE
    BEGIN
        
        THROW 50001, 'User is not a student (RoleID != 1).', 1;
    END
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

<<<<<<< Updated upstream
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
=======
        SELECT 
            InternshipCoordinatorID AS EmployeeID, 
            ISNULL(DATEDIFF(minute, 
                             CASE 
                                WHEN Internship.StartDate >= @StartTime THEN Internship.StartDate 
                                ELSE @StartTime 
                             END,
                             CASE 
                                WHEN Internship.EndDate <= @EndTime THEN Internship.EndDate 
                                ELSE @EndTime 
                             END), 0) AS liczbaminut
        FROM Internship
    )
    SELECT 
        EmployeeID, 
        ROUND(SUM(liczbaminut) / 60.0, 2) AS liczbagodzinpracy
    FROM t1
    GROUP BY EmployeeID
);



CREATE FUNCTION dbo.GetUserDiplomasAndCertificates
(
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100)
)
RETURNS TABLE
AS
RETURN
(
    IF NOT EXISTS (SELECT 1 FROM Users WHERE FirstName = @FirstName AND LastName = @LastName)
    BEGIN
        SELECT 'Brak użytkownika o podanych danych.' AS ErrorMessage;
        RETURN;
    END

    SELECT 
        'Diploma' AS CertificateType,
        Studies.StudyName,
        Grades.GradeName,
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
        Courses.CourseName,
        NULL AS GradeName,
        vw_CoursesCertificates.CourseStart,
        vw_CoursesCertificates.CourseEnd
    FROM
        Users
    INNER JOIN
        vw_CoursesCertificates
    WHERE
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

>>>>>>> Stashed changes
