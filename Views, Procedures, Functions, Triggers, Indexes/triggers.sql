CREATE TRIGGER trg_UpdatePaymentStatus
ON OrderDetails
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE od
    SET od.PaymentStatus = 'udana',
        od.Price = 0
    FROM OrderDetails od
    INNER JOIN inserted i ON od.OrderDetailID = i.OrderDetailID
    WHERE i.Price IS NULL OR i.Price = 0;
END;


CREATE TRIGGER trg_SetPaymentDeferred
ON Orders
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE o
    SET o.PaymentDeferred = CASE 
        WHEN i.DeferredDate IS NOT NULL THEN 1
        ELSE 0
    END
    FROM Orders o
    INNER JOIN inserted i ON o.OrderID = i.OrderID;
END;

CREATE TRIGGER trg_BlockPaymentLinkIfPriceIsZero
ON OrderDetails
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE (Price = 0 OR Price IS NULL)
          AND PaymentLink IS NOT NULL
    )
    BEGIN
        RAISERROR('Nie można dodać linku płatności, jeśli cena wynosi 0 lub NULL.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;


CREATE TRIGGER trg_BlockPaymentLinkIfPriceIsZero_StudyMeetingPayments
ON StudyMeetingPayment
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE (Price = 0 OR Price IS NULL)
          AND PaymentLink IS NOT NULL
    )
    BEGIN
        RAISERROR('Nie można dodać linku płatności, jeśli cena wynosi 0 lub NULL.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;


CREATE TRIGGER trg_BlockPaymentLinkIfPriceIsZero_PaymentAdvances
ON PaymentsAdvances
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE (Price = 0 OR Price IS NULL)
          AND PaymentLink IS NOT NULL
    )
    BEGIN
        RAISERROR('Nie można dodać linku płatności, jeśli cena wynosi 0 lub NULL.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;



CREATE TRIGGER BeforeOrderDetailsInsert
ON OrderDetails
FOR INSERT
AS
BEGIN
    DECLARE @UserID INT;
    DECLARE @ActivityID INT;
    DECLARE @TypeOfActivity INT;
    DECLARE @StudentLimit INT;
    DECLARE @TotalBooked INT;

    SELECT @UserID = O.UserID, @ActivityID = O.ActivityID, @TypeOfActivity = O.TypeOfActivity
    FROM INSERTED O;

    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND Active = 1)
    BEGIN
        RAISERROR ('Użytkownik o ID %d jest nieaktywny i nie może złożyć zamówienia.', 16, 1, @UserID);
        ROLLBACK TRANSACTION; 
        RETURN;
    END

    IF @TypeOfActivity = 4
    BEGIN
        SELECT @StudentLimit = SM.StudentLimit
        FROM StationaryMeetings SM
        INNER JOIN StudyMeetings SM2 ON SM.MeetingID = SM2.MeetingID
        WHERE SM2.ActivityID = @ActivityID;

        SELECT @TotalBooked = COUNT(O.OrderID)
        FROM Orders O
        INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
        WHERE OD.ActivityID = @ActivityID
        AND OD.TypeOfActivity = @TypeOfActivity;

        IF (@TotalBooked + 1) > @StudentLimit
        BEGIN
            RAISERROR ('Przekroczono limit miejsc na spotkaniu stacjonarnym dla aktywności o ID %d.', 16, 1, @ActivityID);
            ROLLBACK TRANSACTION; 
            RETURN;
        END
    END


    IF @TypeOfActivity = 3
    BEGIN
        SELECT @StudentLimit = S.StudentLimit
        FROM Studies S WHERE S.StudiesID = @ActivityID;

        SELECT @TotalBooked = COUNT(OD.OrderID)
        FROM OrderDetails OD
        WHERE OD.ActivityID = @ActivityID
        AND OD.TypeOfActivity = @TypeOfActivity;

        IF (@TotalBooked + 1) > @StudentLimit
        BEGIN
            RAISERROR ('Przekroczono limit miejsc na studiach dla aktywności o ID %d.', 16, 1, @ActivityID);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END

    IF @TypeOfActivity = 2
    BEGIN
        SELECT @StudentLimit = C.StudentLimit
        FROM Courses C WHERE C.CourseID = @ActivityID;

        SELECT @TotalBooked = COUNT(OD.OrderID)
        FROM OrderDetails OD
        WHERE OD.ActivityID = @ActivityID
        AND OD.TypeOfActivity = @TypeOfActivity;

        IF (@TotalBooked + 1) > @StudentLimit
        BEGIN
            RAISERROR ('Przekroczono limit miejsc na kursie dla aktywności o ID %d.', 16, 1, @ActivityID);
            ROLLBACK TRANSACTION; 
            RETURN;
        END
    END
END;


CREATE TRIGGER BeforeOrderDetailsUpdate
ON OrderDetails
FOR UPDATE
AS
BEGIN
    DECLARE @UserID INT;
    DECLARE @OldActivityID INT;
    DECLARE @NewActivityID INT;
    DECLARE @TypeOfActivity INT;
    DECLARE @StudentLimit INT;
    DECLARE @TotalBooked INT;

    SELECT @UserID = O.UserID, 
           @OldActivityID = O.ActivityID, 
           @NewActivityID = I.ActivityID, 
           @TypeOfActivity = O.TypeOfActivity
    FROM INSERTED I
    INNER JOIN DELETED D ON I.DetailID = D.DetailID
    WHERE I.OrderID = D.OrderID;


    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND Active = 1)
    BEGIN
        RAISERROR ('Użytkownik o ID %d jest nieaktywny i nie może zaktualizować zamówienia.', 16, 1, @UserID);
        ROLLBACK TRANSACTION; 
        RETURN;
    END

    IF @OldActivityID != @NewActivityID
    BEGIN
        IF @TypeOfActivity = 4
        BEGIN
            SELECT @StudentLimit = SM.StudentLimit
            FROM StationaryMeetings SM
            INNER JOIN StudyMeetings SM2 ON SM.MeetingID = SM2.MeetingID
            WHERE SM2.ActivityID = @NewActivityID;

            SELECT @TotalBooked = COUNT(O.OrderID)
            FROM Orders O
            INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
            WHERE OD.ActivityID = @NewActivityID
            AND OD.TypeOfActivity = @TypeOfActivity;

            IF (@TotalBooked + 1) > @StudentLimit
            BEGIN
                RAISERROR ('Przekroczono limit miejsc na spotkaniu stacjonarnym dla aktywności o ID %d.', 16, 1, @NewActivityID);
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END

        IF @TypeOfActivity = 3
        BEGIN
            SELECT @StudentLimit = S.StudentLimit
            FROM Studies S WHERE S.StudiesID = @NewActivityID;

            SELECT @TotalBooked = COUNT(OD.OrderID)
            FROM OrderDetails OD
            WHERE OD.ActivityID = @NewActivityID
            AND OD.TypeOfActivity = @TypeOfActivity;

            IF (@TotalBooked + 1) > @StudentLimit
            BEGIN
                RAISERROR ('Przekroczono limit miejsc na studiach dla aktywności o ID %d.', 16, 1, @NewActivityID);
                ROLLBACK TRANSACTION; 
                RETURN;
            END
        END

        IF @TypeOfActivity = 2
        BEGIN
            SELECT @StudentLimit = C.StudentLimit
            FROM Courses C WHERE C.CourseID = @NewActivityID;

            SELECT @TotalBooked = COUNT(OD.OrderID)
            FROM OrderDetails OD
            WHERE OD.ActivityID = @NewActivityID
            AND OD.TypeOfActivity = @TypeOfActivity;

            IF (@TotalBooked + 1) > @StudentLimit
            BEGIN
                RAISERROR ('Przekroczono limit miejsc na kursie dla aktywności o ID %d.', 16, 1, @NewActivityID);
                ROLLBACK TRANSACTION; 
                RETURN;
            END
        END
    END
END;



CREATE TRIGGER PreventStudyUpdateAfterStart
ON Studies
FOR UPDATE
AS
BEGIN
    DECLARE @StudiesID INT;
    DECLARE @EarliestMeetingDate DATETIME;
    DECLARE @CurrentDate DATETIME = GETDATE();


    SELECT @StudiesID = StudiesID FROM INSERTED;


    SELECT @EarliestMeetingDate = MIN(SM.MeetingDate)
    FROM StudyMeetings SM
    INNER JOIN Subjects S ON SM.SubjectID = S.SubjectID
    WHERE S.StudiesID = @StudiesID;

    IF @EarliestMeetingDate <= @CurrentDate
    BEGIN
        RAISERROR ('Nie można edytować danych studiów po rozpoczęciu studiów. Najwcześniejsze spotkanie miało miejsce %s.', 16, 1, @EarliestMeetingDate);
        ROLLBACK TRANSACTION; 
        RETURN;
    END
END;


CREATE TRIGGER PreventSubjectUpdateAfterStart
ON Subjects
FOR UPDATE
AS
BEGIN
    DECLARE @StudiesID INT;
    DECLARE @EarliestMeetingDate DATETIME;
    DECLARE @CurrentDate DATETIME = GETDATE();

    SELECT @StudiesID = StudiesID FROM INSERTED;

    SELECT @EarliestMeetingDate = MIN(SM.MeetingDate)
    FROM StudyMeetings SM
    INNER JOIN Subjects S ON SM.SubjectID = S.SubjectID
    WHERE S.StudiesID = @StudiesID;

    IF @EarliestMeetingDate <= @CurrentDate
    BEGIN
        RAISERROR ('Nie można edytować danych przedmiotu po rozpoczęciu studiów. Najwcześniejsze spotkanie miało miejsce %s.', 16, 1, @EarliestMeetingDate);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;












