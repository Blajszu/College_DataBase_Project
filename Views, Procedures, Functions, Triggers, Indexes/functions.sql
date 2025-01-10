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


