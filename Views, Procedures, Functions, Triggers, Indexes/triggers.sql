CREATE TRIGGER trg_UpdatePaymentStatus
ON OrderDetails
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE od
    SET od.PaymentStatus = 'udana',
        od.Price = 0
    FROM OrderDetails od
    INNER JOIN inserted i ON od.DetailID = i.DetailID
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


CREATE TRIGGER BeforeOrderDetailsInsert
ON OrderDetails
FOR INSERT
AS
BEGIN
    DECLARE @ActivityID INT;
    DECLARE @TypeOfActivity INT;
    DECLARE @RemainingSeats INT;

    SELECT @ActivityID = I.ActivityID, @TypeOfActivity = I.TypeOfActivity
    FROM INSERTED I
	INNER JOIN Orders O ON I.OrderID=O.OrderID;

    IF @TypeOfActivity = 4
    BEGIN
        
        SET @RemainingSeats = dbo.GetRemainingSeatsFn(@ActivityID, @TypeOfActivity);
        IF (@RemainingSeats<=0)
        BEGIN
            RAISERROR ('Brak miejsc na spotkaniu o ID %d.', 16, 1, @ActivityID);
            ROLLBACK TRANSACTION; 
            RETURN;
        END
    END


    IF @TypeOfActivity = 3
    BEGIN
        SET @RemainingSeats = dbo.GetRemainingSeatsFn(@ActivityID, @TypeOfActivity);

        IF (@RemainingSeats<=0)
        BEGIN
            RAISERROR ('Brak miejsc na studiach o ID %d.', 16, 1, @ActivityID);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END

    IF @TypeOfActivity = 2
    BEGIN
        SET @RemainingSeats = dbo.GetRemainingSeatsFn(@ActivityID, @TypeOfActivity);

        IF (@RemainingSeats<=0)
        BEGIN
            RAISERROR ('Brak miejsc na kursie  o ID %d.', 16, 1, @ActivityID);
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
    DECLARE @OldActivityID INT;
    DECLARE @NewActivityID INT;
    DECLARE @TypeOfActivity INT;
    DECLARE @StudentLimit INT;
    DECLARE @TotalBooked INT;

    SELECT 
           @OldActivityID = OD.ActivityID, 
           @NewActivityID = I.ActivityID, 
           @TypeOfActivity = OD.TypeOfActivity
    FROM INSERTED I
    INNER JOIN DELETED D ON I.DetailID = D.DetailID
	INNER JOIN Orders O ON O.OrderID = I.OrderID
	INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
    WHERE I.OrderID = D.OrderID;


    IF @OldActivityID != @NewActivityID
    BEGIN
        IF @TypeOfActivity = 4
        BEGIN
            SELECT @StudentLimit = SM.StudentLimit
            FROM StationaryMeetings SM
            INNER JOIN StudyMeetings SM2 ON SM.MeetingID = SM2.MeetingID
            WHERE SM2.MeetingID = @NewActivityID;

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


    SELECT @EarliestMeetingDate = MIN(SM.StartTime)
    FROM StudyMeetings SM
    INNER JOIN Subjects S ON SM.SubjectID = S.SubjectID
    WHERE S.StudiesID = @StudiesID;

    IF @EarliestMeetingDate <= @CurrentDate
    BEGIN
		DECLARE @FormattedDate VARCHAR(20) = CONVERT(VARCHAR(20), @EarliestMeetingDate, 120);
        RAISERROR ('Nie można edytować danych studiów po rozpoczęciu studiów. Najwcześniejsze spotkanie miało miejsce %s.', 16, 1, @FormattedDate);
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

    SELECT @EarliestMeetingDate = MIN(SM.StartTime)
    FROM StudyMeetings SM
    INNER JOIN Subjects S ON SM.SubjectID = S.SubjectID
    WHERE S.StudiesID = @StudiesID;

    IF @EarliestMeetingDate <= @CurrentDate
    BEGIN
		DECLARE @FormattedDate VARCHAR(20) = CONVERT(VARCHAR(20), @EarliestMeetingDate, 120);
        RAISERROR ('Nie można edytować danych przedmiotu po rozpoczęciu studiów. Najwcześniejsze spotkanie miało miejsce %s.', 16, 1, @FormattedDate);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

CREATE TRIGGER CheckStudyMeetingOverlap
ON StudyMeetings
INSTEAD OF INSERT
AS
BEGIN
    -- Sprawdzanie pokrycia czasowego
    IF EXISTS (
        SELECT 1
        FROM Inserted i
        INNER JOIN Subjects s ON i.SubjectID = s.SubjectID
        INNER JOIN StudyMeetings sm ON sm.SubjectID = s.SubjectID
        WHERE sm.EndTime > i.StartTime AND sm.StartTime < i.EndTime
          AND sm.MeetingID != i.MeetingID -- Aby nie porównywać tego samego spotkania
          AND s.StudiesID = (SELECT StudiesID FROM Subjects WHERE SubjectID = i.SubjectID)
    )
    BEGIN
        RAISERROR ('Spotkanie pokrywa się czasowo z innym spotkaniem w ramach tych samych studiów.', 16, 1);
        RETURN;
    END

    -- Jeśli nie ma konfliktów czasowych, wstaw wiersz do StudyMeetings
    INSERT INTO StudyMeetings (SubjectID, LecturerID, MeetingType, MeetingPrice, MeetingPriceForOthers, StartTime, EndTime, LanguageID, TranslatorID)
    SELECT SubjectID, LecturerID, MeetingType, MeetingPrice, MeetingPriceForOthers, StartTime, EndTime, LanguageID, TranslatorID
    FROM Inserted;
END;

CREATE TRIGGER CheckUserRoleInsert
ON UsersRoles
INSTEAD OF INSERT
AS
BEGIN
    -- Sprawdzenie, czy istnieje użytkownik w tabeli Users
    IF EXISTS (
        SELECT 1
        FROM Inserted i
        LEFT JOIN Users u ON i.UserID = u.UserID
        WHERE u.UserID IS NULL
    )
    BEGIN
        RAISERROR ('Podany użytkownik nie istnieje w tabeli Users.', 16, 1);
        RETURN;
    END

    -- Sprawdzenie, czy istnieje rola w tabeli Roles
    IF EXISTS (
        SELECT 1
        FROM Inserted i
        LEFT JOIN Roles r ON i.RoleID = r.RoleID
        WHERE r.RoleID IS NULL
    )
    BEGIN
        RAISERROR ('Podana rola nie istnieje w tabeli Roles.', 16, 1);
        RETURN;
    END

    -- Jeśli wszystkie warunki są spełnione, wstaw dane do UsersRoles
    INSERT INTO UsersRoles (UserID, RoleID)
    SELECT UserID, RoleID
    FROM Inserted;
END;

CREATE TRIGGER CheckEmployeeExistsInUsers
ON Employees
INSTEAD OF INSERT
AS
BEGIN
    -- Sprawdzenie, czy EmployeeID istnieje w tabeli Users
    IF EXISTS (
        SELECT 1
        FROM Inserted i
        LEFT JOIN Users u ON i.EmployeeID = u.UserID
        WHERE u.UserID IS NULL
    )
    BEGIN
        RAISERROR ('EmployeeID nie istnieje w tabeli Users.', 16, 1);
        RETURN;
    END

    -- Jeśli warunek jest spełniony, wstaw dane do tabeli Employees
    INSERT INTO Employees (EmployeeID, HireDate, DegreeID)
    SELECT EmployeeID, HireDate, DegreeID
    FROM Inserted;
END;

CREATE TRIGGER CheckTranslatedLanguageValidity
ON TranslatedLanguage
INSTEAD OF INSERT
AS
BEGIN
    -- Sprawdzenie, czy TranslatorID istnieje w tabeli Users oraz LanguageID w tabeli Languages
    IF EXISTS (
        SELECT 1
        FROM Inserted i
        LEFT JOIN Users u ON i.TranslatorID = u.UserID
        LEFT JOIN Languages l ON i.LanguageID = l.LanguageID
        WHERE u.UserID IS NULL OR l.LanguageID IS NULL
    )
    BEGIN
        RAISERROR ('TranslatorID nie istnieje w tabeli Users lub LanguageID nie istnieje w tabeli Languages.', 16, 1);
        RETURN;
    END

    -- Jeśli warunek jest spełniony, wstaw dane do tabeli TranslatedLanguage
    INSERT INTO TranslatedLanguage (TranslatorID, LanguageID)
    SELECT TranslatorID, LanguageID
    FROM Inserted;
END;

CREATE TRIGGER CheckUserDeactivation
ON Users
INSTEAD OF UPDATE
AS
BEGIN
    -- Sprawdzenie, czy użytkownik jest dezaktywowany
    IF EXISTS (
        SELECT 1
        FROM Inserted i
        JOIN Deleted d ON i.UserID = d.UserID
        WHERE d.Active = 1 AND i.Active = 0
    )
    BEGIN
        -- Sprawdzamy każdą dezaktywację osobno
        DECLARE @UserID INT, @RoleID INT;
        DECLARE UserCursor CURSOR FOR
        SELECT i.UserID, ur.RoleID
        FROM Inserted i
        JOIN Deleted d ON i.UserID = d.UserID
        JOIN UsersRoles ur ON i.UserID = ur.UserID
        WHERE d.Active = 1 AND i.Active = 0;

        OPEN UserCursor;
        FETCH NEXT FROM UserCursor INTO @UserID, @RoleID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Jeśli użytkownik jest studentem (RoleID = 1)
            IF @RoleID = 1
            BEGIN
                IF EXISTS (
                    SELECT 1
                    FROM Orders o
                    JOIN OrderDetails od ON o.OrderID = od.OrderID
                    LEFT JOIN StudyMeetings sm ON od.ActivityID = sm.MeetingID AND od.TypeOfActivity = 4
                    LEFT JOIN Webinars w ON od.ActivityID = w.WebinarID AND od.TypeOfActivity = 1
                    LEFT JOIN Courses c ON od.ActivityID = c.CourseID AND od.TypeOfActivity = 2
                    LEFT JOIN Studies s ON od.ActivityID = s.StudiesID AND od.TypeOfActivity = 3
                    WHERE o.StudentID = @UserID
                      AND (
                          (sm.StartTime > GETDATE()) OR
                          (w.StartDate > GETDATE()) OR
                          (EXISTS (
                              SELECT 1
                              FROM StationaryCourseMeeting scm
                              WHERE scm.ModuleID = c.CourseID AND scm.StartDate > GETDATE()
                          )) OR
                          (EXISTS (
                              SELECT 1
                              FROM OnlineCourseMeeting ocm
                              WHERE ocm.ModuleID = c.CourseID AND ocm.StartDate > GETDATE()
                          ))
                      )
                )
                BEGIN
                    ROLLBACK TRANSACTION;
                    RAISERROR ('Nie można dezaktywować użytkownika, który jest studentem i jest przypisany do przyszłego wydarzenia.', 16, 1);
                    RETURN;
                END
            END
            ELSE
            BEGIN
                -- Jeśli użytkownik jest pracownikiem (RoleID ≠ 1)
                IF EXISTS (
                    SELECT 1
                    FROM StudyMeetings sm
                    WHERE (sm.LecturerID = @UserID OR sm.TranslatorID = @UserID)
                      AND sm.StartTime <= GETDATE()
                      AND sm.EndTime >= GETDATE()
                )
                OR EXISTS (
                    SELECT 1
                    FROM Courses c
                    WHERE c.CourseCoordinatorID = @UserID
                )
                OR EXISTS (
                    SELECT 1
                    FROM Webinars w
                    WHERE (w.TeacherID = @UserID OR w.TranslatorID = @UserID)
                      AND w.StartDate <= GETDATE()
                      AND w.EndDate >= GETDATE()
                )
                OR EXISTS (
                    SELECT 1
                    FROM CourseModules cm
                    LEFT JOIN StationaryCourseMeetings scm ON StationaryCourseMeetings.ModuleID = cm.ModuleID
                    LEFT JOIN OnlineCourseMeetings ocm ON OnlineCourseMeetings.ModuleID = cm.ModuleID
                    WHERE (cm.LecturerID = @UserID OR cm.TranslatorID = @UserID)
                      AND ((scm.StartTime <= GETDATE()
                      AND scm.EndTime >= GETDATE()) OR ocm.StartTime <=GETDATE() AND ocm.EndTime >= GETDATE())
                )
                BEGIN
                    ROLLBACK TRANSACTION;
                    RAISERROR ('Nie można dezaktywować użytkownika, który jest pracownikiem i jest przypisany do obecnie trwającego wydarzenia jako prowadzący, koordynator lub tłumacz.', 16, 1);
                    RETURN;
                END
            END

            FETCH NEXT FROM UserCursor INTO @UserID, @RoleID;
        END;

        CLOSE UserCursor;
        DEALLOCATE UserCursor;
    END;

    -- Jeśli wszystkie warunki są spełnione, wykonaj aktualizację
    UPDATE Users
    SET Active = i.Active
    FROM Users u
    JOIN Inserted i ON u.UserID = i.UserID;
END;