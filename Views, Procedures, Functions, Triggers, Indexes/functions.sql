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
