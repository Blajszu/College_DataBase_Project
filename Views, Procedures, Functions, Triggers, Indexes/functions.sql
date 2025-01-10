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


CREATE PROCEDURE CheckStudentPresenceOrActivity
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






