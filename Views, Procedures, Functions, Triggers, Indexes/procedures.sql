CREATE PROCEDURE AddNewStudy
    @StudyName NVARCHAR(255),
    @StudiesCoordinatorID INT,
    @StudyPrice DECIMAL(10, 2),
    @NumberOfTerms INT,
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    BEGIN TRY
        
        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @StudiesCoordinatorID)
        BEGIN
            RAISERROR('Koordynator o podanym ID nie istnieje.', 16, 1);
            RETURN;
        END

        
        IF @StartDate >= @EndDate
        BEGIN
            RAISERROR('Data rozpoczęcia musi być wcześniejsza niż data zakończenia.', 16, 1);
            RETURN;
        END

        
        IF @NumberOfTerms <= 0
        BEGIN
            RAISERROR('Liczba semestrów musi być większa od zera.', 16, 1);
            RETURN;
        END
        IF @StudyPrice < 0
        BEGIN
            RAISERROR('Cena studiów nie może być ujemna.', 16, 1);
            RETURN;
        END

        
        INSERT INTO Studies (StudyName, StudiesCoordinatorID, StudyPrice, NumberOfTerms, StartDate, EndDate)
        VALUES (@StudyName, @StudiesCoordinatorID, @StudyPrice, @NumberOfTerms, @StartDate, @EndDate);

        PRINT 'Studia zostały pomyślnie dodane.';
    END TRY
    BEGIN CATCH
        
        PRINT 'Wystąpił błąd podczas dodawania studiów.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;


CREATE PROCEDURE AddNewCourse
    @CourseName NVARCHAR(255),
    @CourseCoordinatorID INT,
    @CoursePrice DECIMAL(10, 2),
    @StudentLimit INT,
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    BEGIN TRY
        
        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @CourseCoordinatorID)
        BEGIN
            RAISERROR('Koordynator kursu o podanym ID nie istnieje.', 16, 1);
            RETURN;
        END

        
        IF @StartDate >= @EndDate
        BEGIN
            RAISERROR('Data rozpoczęcia musi być wcześniejsza niż data zakończenia.', 16, 1);
            RETURN;
        END

        
        IF @StudentLimit <= 0 AND @StudentLimit IS NOT NULL
        BEGIN
            RAISERROR('Limit studentów musi być większy od zera lub NULL.', 16, 1);
            RETURN;
        END
        IF @CoursePrice < 0
        BEGIN
            RAISERROR('Cena kursu nie może być ujemna.', 16, 1);
            RETURN;
        END

        
        INSERT INTO Courses (CourseName, CourseCoordinatorID, CoursePrice, StudentLimit, StartDate, EndDate)
        VALUES (@CourseName, @CourseCoordinatorID, @CoursePrice, @StudentLimit, @StartDate, @EndDate);

        PRINT 'Kurs został pomyślnie dodany.';
    END TRY
    BEGIN CATCH
        
        PRINT 'Wystąpił błąd podczas dodawania kursu.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE AddNewWebinar
    @WebinarName NVARCHAR(255),
    @StartDate DATETIME,
    @EndDate DATETIME,
    @TeacherID INT,
    @TranslatorID INT = NULL,
    @LanguageID INT,
    @Price DECIMAL(10, 2) = 0.0
AS
BEGIN
    BEGIN TRY
        
        IF @StartDate >= @EndDate
        BEGIN
            RAISERROR('Data rozpoczęcia musi być wcześniejsza niż data zakończenia.', 16, 1);
            RETURN;
        END

        
        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @TeacherID)
        BEGIN
            RAISERROR('Nauczyciel o podanym ID nie istnieje.', 16, 1);
            RETURN;
        END

        IF @LanguageID NOT IN (SELECT LanguageID FROM TranslatedLanguages)
        BEGIN
            THROW 67007, 'Language not available.', 1; 
        END

        
        IF @TranslatorID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @TranslatorID)
        BEGIN
            RAISERROR('Tłumacz o podanym ID nie istnieje.', 16, 1);
            RETURN;
        END

        
        IF NOT EXISTS (SELECT 1 FROM Languages WHERE LanguageID = @LanguageID)
        BEGIN
            RAISERROR('Język o podanym ID nie istnieje.', 16, 1);
            RETURN;
        END

        
        IF @Price < 0
        BEGIN
            RAISERROR('Cena webinaru nie może być ujemna.', 16, 1);
            RETURN;
        END

        
        INSERT INTO Webinars (WebinarName, StartDate, EndDate, TeacherID, TranslatorID, LanguageID, Price)
        VALUES (@WebinarName, @StartDate, @EndDate, @TeacherID, @TranslatorID, @LanguageID, @Price);

        PRINT 'Webinar został pomyślnie dodany.';
    END TRY
    BEGIN CATCH
        
        PRINT 'Wystąpił błąd podczas dodawania webinaru.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE AddNewSubject
    @SubjectName NVARCHAR(255),
    @NumberOfHoursInTerm INT,
    @TeacherID INT,
    @StudiesID INT
AS
BEGIN
    BEGIN TRY
        
        IF @NumberOfHoursInTerm <= 0 AND @NumberOfHoursInTerm > (SELECT numberOfTerms FROM Studies WHERE StudiesID = @StudiesID)
        BEGIN
            RAISERROR('Liczba godzin w semestrze musi być większa od zera.', 16, 1);
            RETURN;
        END

        
        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @TeacherID)
        BEGIN
            RAISERROR('Nauczyciel o podanym ID nie istnieje.', 16, 1);
            RETURN;
        END

        
        IF NOT EXISTS (SELECT 1 FROM Studies WHERE StudiesID = @StudiesID)
        BEGIN
            RAISERROR('Studia o podanym ID nie istnieją.', 16, 1);
            RETURN;
        END

        
        INSERT INTO Subjects (SubjectName, NumberOfHoursInTerm, TeacherID, StudiesID)
        VALUES (@SubjectName, @NumberOfHoursInTerm, @TeacherID, @StudiesID);

        PRINT 'Przedmiot został pomyślnie dodany.';
    END TRY
    BEGIN CATCH
        
        PRINT 'Wystąpił błąd podczas dodawania przedmiotu.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE AddSubjectMeeting
    @SubjectID INT,
    @MeetingType NVARCHAR(50), 
    @StartTime DATETIME,
    @EndTime DATETIME,
    @MeetingPrice DECIMAL(10, 2),
    @MeetingPriceForOthers DECIMAL(10, 2),
    @StudentLimit INT = NULL, 
    @RoomID INT = NULL,       
    @MeetingLink NVARCHAR(255) = NULL 
AS
BEGIN
    BEGIN TRY
        
        IF @StartTime >= @EndTime
        BEGIN
            RAISERROR('Czas rozpoczęcia spotkania musi być wcześniejszy niż czas zakończenia.', 16, 1);
            RETURN;
        END

        
        IF NOT EXISTS (SELECT 1 FROM Subjects WHERE SubjectID = @SubjectID)
        BEGIN
            RAISERROR('Przedmiot o podanym ID nie istnieje.', 16, 1);
            RETURN;
        END

        
        DECLARE @MeetingID INT;
        INSERT INTO StudyMeetings (SubjectID, StartTime, EndTime, MeetingPrice, MeetingPriceForOthers)
        VALUES (@SubjectID, @StartTime, @EndTime, @MeetingPrice, @MeetingPriceForOthers);

        
        SET @MeetingID = SCOPE_IDENTITY();

        
        IF LOWER(@MeetingType) = 'stationary'
        BEGIN
            
            IF @RoomID IS NULL
            BEGIN
                RAISERROR('Dla spotkań stacjonarnych wymagane jest podanie ID sali.', 16, 1);
                RETURN;
            END

            
            INSERT INTO StationaryMeetings (MeetingID, RoomID, StudentLimit)
            VALUES (@MeetingID, @RoomID, @StudentLimit);
        END
        ELSE IF LOWER(@MeetingType) = 'online'
        BEGIN
            
            IF @MeetingLink IS NULL
            BEGIN
                RAISERROR('Dla spotkań online wymagane jest podanie linku do spotkania.', 16, 1);
                RETURN;
            END

            
            INSERT INTO OnlineMeetings (MeetingID, MeetingLink, StudentLimit)
            VALUES (@MeetingID, @MeetingLink, @StudentLimit);
        END
        ELSE
        BEGIN
            RAISERROR('Nieprawidłowy typ spotkania. Użyj wartości "stationary" lub "online".', 16, 1);
            RETURN;
        END

        PRINT 'Spotkanie zostało pomyślnie dodane.';
    END TRY
    BEGIN CATCH
        
        PRINT 'Wystąpił błąd.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE AddCourseModule
    @CourseID INT,
    @ModuleName NVARCHAR(255),
    @ModuleType INT, 
    @LecturerID INT,
    @TranslatorID INT = NULL, 
    @LanguageID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @LanguageID NOT IN (SELECT LanguageID FROM TranslatedLanguages)
        BEGIN
            THROW 67007, 'Language not available.', 1; 
        END;

        
        IF NOT EXISTS (
            SELECT 1
            FROM FormOfActivity
            WHERE ActivityTypeID = @ModuleType
        )
        BEGIN
            THROW 50001, 'Nieprawidłowy typ modułu.', 1;
        END;

        
        INSERT INTO CourseModules (CourseID, ModuleName, ModuleType, LecturerID, TranslatorID, LanguageID)
        VALUES (@CourseID, @ModuleName, @ModuleType, @LecturerID, @TranslatorID, @LanguageID);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

CREATE PROCEDURE AddCourseMeeting
    @ModuleID INT,
    @MeetingType NVARCHAR(20), 
    @StartDate DATETIME,
    @EndDate DATETIME,
    @RoomID INT = NULL, 
    @StudentLimit INT = NULL 
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        
        DECLARE @ModuleType INT;
        SELECT @ModuleType = ModuleType
        FROM CourseModules
        WHERE ModuleID = @ModuleID;

        
        IF @ModuleType IS NULL
        BEGIN
            THROW 50001, 'Nie znaleziono modułu o podanym ModuleID.', 1;
        END;

        
        IF @StartDate >= @EndDate
        BEGIN
            THROW 50002, 'Data rozpoczęcia musi być wcześniejsza niż data zakończenia.', 1;
        END;

        
        IF @MeetingType = 'Stationary'
        BEGIN
            
            IF @ModuleType IN (1, 4)
            BEGIN
                THROW 50003, 'Do modułu o typie innym niż Stacjonarny lub Hybrydowy nie można dodać spotkania Stacjonarnego.', 1;
            END;

            
            IF @RoomID IS NULL
            BEGIN
                THROW 50004, 'RoomID jest wymagany dla stacjonarnych spotkań.', 1;
            END;

            
            INSERT INTO StationaryCourseMeeting (ModuleID, StartDate, EndDate, RoomID, StudentLimit)
            VALUES (@ModuleID, @StartDate, @EndDate, @RoomID, @StudentLimit);
        END
        ELSE IF @MeetingType = 'Online'
        BEGIN
            
            IF @ModuleType NOT IN (3, 4)
            BEGIN
                THROW 50005, 'Do modułu o typie innym niż Online lub Hybrydowy nie można dodać spotkania Online.', 1;
            END;

            
            INSERT INTO OnlineCourseMeeting (ModuleID, StartDate, EndDate, StudentLimit)
            VALUES (@ModuleID, @StartDate, @EndDate, @StudentLimit);
        END
        ELSE
        BEGIN
            
            THROW 50006, 'Nieprawidłowy typ spotkania. Użyj "Stationary" lub "Online".', 1;
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Wystąpił błąd.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE AddUser
    @FirstName NVARCHAR(40),
    @LastName NVARCHAR(40),
    @Street NVARCHAR(40),
    @City NVARCHAR(40),
    @Email NVARCHAR(40),
    @Phone NVARCHAR(40),
    @DateOfBirth DATE
AS
BEGIN
    BEGIN TRY
        DECLARE @CityID INT;

        
        SELECT @CityID = CityID
        FROM Cities
        WHERE CityName = @City;

        
        IF @CityID IS NULL
        BEGIN
            THROW 50001, 'City does not exist in the Cities table.', 1;
        END;

        
        INSERT INTO Users (FirstName, LastName, Street, CityID, Email, Phone, DateOfBirth)
        VALUES (@FirstName, @LastName, @Street, @CityID, @Email, @Phone, @DateOfBirth);
    END TRY
    BEGIN CATCH
        
        PRINT 'Wystąpił błąd.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE AddEmployee
    @EmployeeID INT,          
    @HireDate DATE,           
    @DegreeName NVARCHAR(50) = NULL, 
    @RoleName NVARCHAR(50)    
AS
BEGIN
    BEGIN TRY
        
        IF NOT EXISTS (
            SELECT 1
            FROM Users
            WHERE UserID = @EmployeeID
        )
        BEGIN
            THROW 50002, 'User does not exist in the Users table.', 1;
        END;

        
        DECLARE @RoleID INT;

        SELECT @RoleID = RoleID
        FROM Roles
        WHERE RoleName = @RoleName;

        IF @RoleID IS NULL
        BEGIN
            THROW 50005, 'Role does not exist in the Roles table.', 1;
        END;

        
        DECLARE @DegreeID INT = NULL;

        IF @DegreeName IS NOT NULL
        BEGIN
            SELECT @DegreeID = DegreeID
            FROM Degrees
            WHERE DegreeName = @DegreeName;

            IF @DegreeID IS NULL
            BEGIN
                THROW 50006, 'Degree does not exist in the Degrees table.', 1;
            END;
        END;

        
        INSERT INTO Employees (EmployeeID, UserID, HireDate, DegreeID)
        VALUES (@UserID, @HireDate, @DegreeID);

        
        EXEC AddUserRole @UserID = @UserID, @RoleID = @RoleID;
    END TRY
    BEGIN CATCH
        
        PRINT 'Wystąpił błąd.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE DeleteUser
    @UserID INT
AS
BEGIN
    BEGIN TRY
        
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Users
            WHERE UserID = @UserID
        )
        BEGIN
            THROW 60001, 'User does not exist.', 1;
        END;

        
        IF EXISTS (
            SELECT 1
            FROM Employees
            WHERE EmployeeID = @UserID
        )
        BEGIN
            
            DELETE FROM Employees
            WHERE EmployeeID = @UserID;
        END;

        
        DELETE FROM UserRoles
        WHERE UserID = @UserID;

        
        DELETE FROM Users
        WHERE UserID = @UserID;

        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        
        ROLLBACK TRANSACTION;
        PRINT 'Wystąpił błąd.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE DeleteWebinar
    @WebinarID INT
AS
BEGIN
    BEGIN TRY
        
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Webinars
            WHERE WebinarID = @WebinarID
        )
        BEGIN
            THROW 60002, 'Webinar does not exist.', 1;
        END;

        
        DELETE FROM Webinars
        WHERE WebinarID = @WebinarID;

        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        
        ROLLBACK TRANSACTION;
        PRINT 'Wystąpił błąd.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE DeleteStudyMeeting
    @MeetingID INT
AS
BEGIN
    BEGIN TRY
        
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM StudyMeetings
            WHERE MeetingID = @MeetingID
        )
        BEGIN
            THROW 60003, 'Study meeting does not exist.', 1;
        END;

        
        IF EXISTS (
            SELECT 1
            FROM StationaryMeetings
            WHERE MeetingID = @MeetingID
        )
        BEGIN
            DELETE FROM StationaryMeetings
            WHERE MeetingID = @MeetingID;
        END;

        
        IF EXISTS (
            SELECT 1
            FROM OnlineMeetings
            WHERE MeetingID = @MeetingID
        )
        BEGIN
            DELETE FROM OnlineMeetings
            WHERE MeetingID = @MeetingID;
        END;

        
        DELETE FROM StudyMeetings
        WHERE MeetingID = @MeetingID;

        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        
        ROLLBACK TRANSACTION;
        PRINT 'Wystąpił błąd.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE DeleteSubject
    @SubjectID INT
AS
BEGIN
    BEGIN TRY
        
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Subjects
            WHERE SubjectID = @SubjectID
        )
        BEGIN
            THROW 60004, 'Subject does not exist.', 1;
        END;

        
        DECLARE @MeetingID INT;

        DECLARE MeetingCursor CURSOR FOR
        SELECT MeetingID
        FROM StudyMeetings
        WHERE SubjectID = @SubjectID;

        
        OPEN MeetingCursor;

        FETCH NEXT FROM MeetingCursor INTO @MeetingID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            
            DELETE FROM StationaryMeetings
            WHERE MeetingID = @MeetingID;

            
            DELETE FROM OnlineMeetings
            WHERE MeetingID = @MeetingID;

            
            DELETE FROM StudyMeetings
            WHERE MeetingID = @MeetingID;

            
            FETCH NEXT FROM MeetingCursor INTO @MeetingID;
        END;

        
        CLOSE MeetingCursor;
        DEALLOCATE MeetingCursor;

        
        DELETE FROM Subjects
        WHERE SubjectID = @SubjectID;

        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        
        ROLLBACK TRANSACTION;

        
        THROW;
    END CATCH
END;

CREATE PROCEDURE DeleteStudy
    @StudyID INT
AS
BEGIN
    BEGIN TRY
        
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Studies
            WHERE StudyID = @StudyID
        )
        BEGIN
            THROW 60005, 'Study does not exist.', 1;
        END;

        
        DECLARE @SubjectID INT;

        DECLARE SubjectCursor CURSOR FOR
        SELECT SubjectID
        FROM Subjects
        WHERE StudyID = @StudyID;

        
        OPEN SubjectCursor;

        FETCH NEXT FROM SubjectCursor INTO @SubjectID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            
            EXEC DeleteSubject @SubjectID = @SubjectID;

            
            FETCH NEXT FROM SubjectCursor INTO @SubjectID;
        END;

        
        CLOSE SubjectCursor;
        DEALLOCATE SubjectCursor;

        
        DELETE FROM Studies
        WHERE StudyID = @StudyID;

        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        
        ROLLBACK TRANSACTION;

        
        THROW;
    END CATCH
END;

CREATE PROCEDURE DeleteCourseMeeting
    @MeetingID INT
AS
BEGIN
    BEGIN TRY
        
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM CourseMeetings
            WHERE MeetingID = @MeetingID
        )
        BEGIN
            THROW 60006, 'Course meeting does not exist.', 1;
        END;

        
        DELETE FROM OnlineCourseMeetings
        WHERE MeetingID = @MeetingID;

        
        DELETE FROM StationaryCourseMeetings
        WHERE MeetingID = @MeetingID;

        
        DELETE FROM CourseMeetings
        WHERE MeetingID = @MeetingID;

        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        
        ROLLBACK TRANSACTION;

        
        THROW;
    END CATCH
END;

CREATE PROCEDURE DeleteCourseModule
    @ModuleID INT
AS
BEGIN
    BEGIN TRY
        
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Modules
            WHERE ModuleID = @ModuleID
        )
        BEGIN
            THROW 60007, 'Course module does not exist.', 1;
        END;

        
        DELETE FROM CourseMeetings
        WHERE ModuleID = @ModuleID;

        
        DELETE FROM Modules
        WHERE ModuleID = @ModuleID;

        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        
        ROLLBACK TRANSACTION;

        
        THROW;
    END CATCH
END;

CREATE PROCEDURE DeleteCourse
    @CourseID INT
AS
BEGIN
    BEGIN TRY
        
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Courses
            WHERE CourseID = @CourseID
        )
        BEGIN
            THROW 60008, 'Course does not exist.', 1;
        END;

        
        DECLARE @ModuleID INT;

        DECLARE ModuleCursor CURSOR FOR
        SELECT ModuleID
        FROM Modules
        WHERE CourseID = @CourseID;

        
        OPEN ModuleCursor;

        FETCH NEXT FROM ModuleCursor INTO @ModuleID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            
            EXEC DeleteCourseModule @ModuleID = @ModuleID;

            
            FETCH NEXT FROM ModuleCursor INTO @ModuleID;
        END;

        
        CLOSE ModuleCursor;
        DEALLOCATE ModuleCursor;

        
        DELETE FROM Courses
        WHERE CourseID = @CourseID;

        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        
        ROLLBACK TRANSACTION;

        
        THROW;
    END CATCH
END;

CREATE PROCEDURE DeleteEmployee
    @EmployeeID INT
AS
BEGIN
    BEGIN TRY
        
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Employees
            WHERE EmployeeID = @EmployeeID
        )
        BEGIN
            THROW 60009, 'Employee does not exist.', 1;
        END;

        
        DECLARE @UserID INT;
        SELECT @UserID = UserID
        FROM Employees
        WHERE EmployeeID = @EmployeeID;

        
        DELETE FROM UserRoles
        WHERE UserID = @UserID AND RoleID != 1;

        
        DELETE FROM Employees
        WHERE EmployeeID = @EmployeeID;

        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        
        ROLLBACK TRANSACTION;

        
        THROW;
    END CATCH
END;

CREATE PROCEDURE UpdateUser
    @UserID INT,
    @FirstName VARCHAR(40),
    @LastName VARCHAR(40),
    @Street VARCHAR(40),
    @City VARCHAR(40),
    @Email VARCHAR(40),
    @Phone VARCHAR(40),
    @DateOfBirth DATE
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Users
            WHERE UserID = @UserID
        )
        BEGIN
            THROW 60010, 'User does not exist.', 1;
        END;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Cities
            WHERE CityName = @City
        )
        BEGIN
            THROW 60011, 'City does not exist.', 1;
        END;

        
        UPDATE Users
        SET
            FirstName = @FirstName,
            LastName = @LastName,
            Street = @Street,
            CityID = (SELECT CityID FROM Cities WHERE CityName = @City),
            Email = @Email,
            Phone = @Phone,
            DateOfBirth = @DateOfBirth
        WHERE UserID = @UserID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

CREATE PROCEDURE UpdateEmployee
    @EmployeeID INT,
    @HireDate DATE,
    @DegreeName VARCHAR(50) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Employees
            WHERE EmployeeID = @EmployeeID
        )
        BEGIN
            THROW 60012, 'Employee does not exist.', 1;
        END;

        
        DECLARE @DegreeID INT = NULL;
        IF @DegreeName IS NOT NULL
        BEGIN
            SELECT @DegreeID = DegreeID
            FROM Degrees
            WHERE DegreeName = @DegreeName;

            IF @DegreeID IS NULL
            BEGIN
                THROW 60013, 'Degree does not exist.', 1;
            END;
        END;

        
        UPDATE Employees
        SET
            HireDate = @HireDate,
            DegreeID = @DegreeID
        WHERE EmployeeID = @EmployeeID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

CREATE PROCEDURE UpdateCourse
    @CourseID INT,
    @CourseName VARCHAR(40),
    @CourseCoordinatorID INT,
    @CourseDescription VARCHAR(255),
    @CoursePrice MONEY,
    @StudentLimit INT = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Courses
            WHERE CourseID = @CourseID
        )
        BEGIN
            THROW 61001, 'Course does not exist.', 1;
        END;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Employees E
            JOIN UserRoles UR ON E.EmployeeID = UR.UserID
            WHERE E.EmployeeID = @CourseCoordinatorID
              AND UR.RoleID = 3 
        )
        BEGIN
            THROW 61002, 'CourseCoordinatorID is not valid or does not have the required role.', 1;
        END;

        
        UPDATE Courses
        SET
            CourseName = @CourseName,
            CourseCoordinatorID = @CourseCoordinatorID,
            CourseDescription = @CourseDescription,
            CoursePrice = @CoursePrice,
            StudentLimit = @StudentLimit
        WHERE CourseID = @CourseID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

CREATE PROCEDURE UpdateWebinar
    @WebinarID INT,
    @WebinarName VARCHAR(40),
    @WebinarDescription VARCHAR(255),
    @TeacherID INT,
    @Price MONEY,
    @LanguageID INT,
    @TranslatorID INT = NULL,
    @StartDate DATETIME,
    @EndDate DATETIME,
    @VideoLink VARCHAR(255) = NULL,
    @MeetingLink VARCHAR(255) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Webinars
            WHERE WebinarID = @WebinarID
        )
        BEGIN
            THROW 62001, 'Webinar does not exist.', 1;
        END;

        
        IF NOT EXISTS (
            SELECT 1
            FROM UsersRoles
            WHERE UserID = @TeacherID AND RoleID = 8
        )
        BEGIN
            THROW 62002, 'Invalid TeacherID. The user is not assigned as a webinar lecturer.', 1;
        END;

        IF @LanguageID NOT IN (SELECT LanguageID FROM TranslatedLanguages)
        BEGIN
            THROW 67007, 'Language not available.', 1; 
        END;

        
        IF @TranslatorID IS NOT NULL AND NOT EXISTS (
            SELECT 1
            FROM UsersRoles
            WHERE UserID = @TranslatorID AND RoleID = 2
        )
        BEGIN
            THROW 62003, 'Invalid TranslatorID. The user is not assigned as a translator.', 1;
        END;

        
        UPDATE Webinars
        SET
            WebinarName = @WebinarName,
            WebinarDescription = @WebinarDescription,
            TeacherID = @TeacherID,
            Price = @Price,
            LanguageID = @LanguageID,
            TranslatorID = @TranslatorID,
            StartDate = @StartDate,
            EndDate = @EndDate,
            VideoLink = @VideoLink,
            MeetingLink = @MeetingLink
        WHERE WebinarID = @WebinarID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE UpdateCourseModule
    @ModuleID INT,
    @CourseID INT,
    @ModuleName VARCHAR(255),
    @ModuleType INT,
    @LecturerID INT,
    @LanguageID INT,
    @TranslatorID INT = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM CourseModules
            WHERE ModuleID = @ModuleID
        )
        BEGIN
            THROW 63001, 'Module does not exist.', 1;
        END;

        
        IF NOT EXISTS (
            SELECT 1
            FROM UsersRoles
            WHERE UserID = @LecturerID AND RoleID = 6
        )
        BEGIN
            THROW 63002, 'Invalid LecturerID. The user is not assigned as a lecturer.', 1;
        END;

        IF @LanguageID NOT IN (SELECT LanguageID FROM TranslatedLanguages)
        BEGIN
            THROW 67007, 'Language not available.', 1; 
        END;

        
        IF @TranslatorID IS NOT NULL AND NOT EXISTS (
            SELECT 1
            FROM UsersRoles
            WHERE UserID = @TranslatorID AND RoleID = 2
        )
        BEGIN
            THROW 63003, 'Invalid TranslatorID. The user is not assigned as a translator.', 1;
        END;

        
        IF @ModuleType = 1 
        AND EXISTS (
            SELECT 1
            FROM OnlineCourseMeetings
            WHERE ModuleID = @ModuleID
        )
        BEGIN
            THROW 63004, 'Cannot change module type to Stationary. Online meetings exist for this module.', 1;
        END;

        IF @ModuleType = 3 
        AND EXISTS (
            SELECT 1
            FROM StationaryCourseMeetings
            WHERE ModuleID = @ModuleID
        )
        BEGIN
            THROW 63005, 'Cannot change module type to Online. Stationary meetings exist for this module.', 1;
        END;

        
        UPDATE CourseModules
        SET
            CourseID = @CourseID,
            ModuleName = @ModuleName,
            ModuleType = @ModuleType,
            LecturerID = @LecturerID,
            LanguageID = @LanguageID,
            TranslatorID = @TranslatorID
        WHERE ModuleID = @ModuleID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE UpdateCourseModuleMeeting
    @MeetingID INT,
    @ModuleID INT,
    @MeetingType INT, 
    @StartDateTime DATETIME,
    @EndDateTime DATETIME,
    @LocationOrLink VARCHAR(255)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM CourseModules
            WHERE ModuleID = @ModuleID
        )
        BEGIN
            THROW 64001, 'Module does not exist.', 1;
        END;

        
        DECLARE @ModuleType INT;
        SELECT @ModuleType = ModuleType
        FROM CourseModules
        WHERE ModuleID = @ModuleID;

        
        IF @MeetingType = 1 AND @ModuleType NOT IN (1, 4) 
        BEGIN
            THROW 64002, 'Cannot add a stationary meeting to a non-stationary module.', 1;
        END;

        IF @MeetingType = 2 AND @ModuleType NOT IN (3, 4) 
        BEGIN
            THROW 64003, 'Cannot add an online meeting to a non-online module.', 1;
        END;

        
        IF @MeetingType = 1 AND NOT EXISTS (
            SELECT 1
            FROM StationaryCourseMeetings
            WHERE MeetingID = @MeetingID AND ModuleID = @ModuleID
        )
        BEGIN
            THROW 64004, 'Stationary meeting does not exist for the specified module.', 1;
        END;

        IF @MeetingType = 2 AND NOT EXISTS (
            SELECT 1
            FROM OnlineCourseMeetings
            WHERE MeetingID = @MeetingID AND ModuleID = @ModuleID
        )
        BEGIN
            THROW 64005, 'Online meeting does not exist for the specified module.', 1;
        END;

        
        IF @MeetingType = 1
        BEGIN
            UPDATE StationaryCourseMeetings
            SET
                StartDateTime = @StartDateTime,
                EndDateTime = @EndDateTime,
                Location = @LocationOrLink
            WHERE MeetingID = @MeetingID AND ModuleID = @ModuleID;
        END
        ELSE IF @MeetingType = 2
        BEGIN
            UPDATE OnlineCourseMeetings
            SET
                StartDateTime = @StartDateTime,
                EndDateTime = @EndDateTime,
                MeetingLink = @LocationOrLink
            WHERE MeetingID = @MeetingID AND ModuleID = @ModuleID;
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE UpdateStudies
    @StudiesID INT,
    @StudiesCoordinatorID INT,
    @StudyName VARCHAR(40),
    @StudyPrice MONEY,
    @StudyDescription VARCHAR(255),
    @NumberOfTerms INT,
    @StudentLimit INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Studies
            WHERE StudiesID = @StudiesID
        )
        BEGIN
            THROW 65001, 'Studies with the specified ID do not exist.', 1;
        END;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Employees
            WHERE EmployeeID = @StudiesCoordinatorID
        )
        BEGIN
            THROW 65002, 'The specified coordinator does not exist.', 1;
        END;

        
        IF NOT EXISTS (
            SELECT 1
            FROM UserRoles
            WHERE UserID = (SELECT UserID FROM Employees WHERE EmployeeID = @StudiesCoordinatorID)
              AND RoleID = 4
        )
        BEGIN
            THROW 65003, 'The specified coordinator does not have the required role (Coordinator of Studies).', 1;
        END;

        
        UPDATE Studies
        SET
            StudiesCoordinatorID = @StudiesCoordinatorID,
            StudyName = @StudyName,
            StudyPrice = @StudyPrice,
            StudyDescription = @StudyDescription,
            NumberOfTerms = @NumberOfTerms,
            StudentLimit = @StudentLimit
        WHERE StudiesID = @StudiesID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE UpdateSubject
    @SubjectID INT,
    @StudiesID INT,
    @SubjectName VARCHAR(40),
    @SubjectDescription VARCHAR(255),
    @LecturerID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Subjects
            WHERE SubjectID = @SubjectID
        )
        BEGIN
            THROW 66001, 'Subject with the specified ID does not exist.', 1;
        END;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Studies
            WHERE StudiesID = @StudiesID
        )
        BEGIN
            THROW 66002, 'Studies with the specified ID do not exist.', 1;
        END;

        
        IF NOT EXISTS (
            SELECT 1
            FROM Employees
            WHERE EmployeeID = @LecturerID
        )
        BEGIN
            THROW 66003, 'The specified lecturer does not exist.', 1;
        END;

        
        IF NOT EXISTS (
            SELECT 1
            FROM UserRoles
            WHERE UserID = (SELECT UserID FROM Employees WHERE EmployeeID = @LecturerID)
              AND RoleID = 6
        )
        BEGIN
            THROW 66004, 'The specified lecturer does not have the required role (Lecturer).', 1;
        END;

        
        UPDATE Subjects
        SET
            StudiesID = @StudiesID,
            SubjectName = @SubjectName,
            SubjectDescription = @SubjectDescription,
            LecturerID = @LecturerID
        WHERE SubjectID = @SubjectID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE UpdateStudyMeeting
    @MeetingID INT,
    @MeetingType INT, 
    @SubjectID INT,
    @LecturerID INT,
    @MeetingPrice MONEY,
    @MeetingPriceForOthers MONEY,
    @StartTime DATETIME,
    @EndTime DATETIME,
    @LanguageID INT,
    @TranslatorID INT = NULL,
    @MeetingLink VARCHAR(255) = NULL, 
    @StudentLimit INT, 
    @RoomID INT = NULL 
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        
        IF NOT EXISTS (
            SELECT 1
            FROM StudyMeetings
            WHERE MeetingID = @MeetingID
        )
        BEGIN
            THROW 67001, 'Study meeting with the specified ID does not exist.', 1;
        END;

        
        IF @MeetingType NOT IN (1, 2)
        BEGIN
            THROW 67002, 'Invalid MeetingType. Must be 1 (Stationary) or 2 (Online).', 1;
        END;

        IF @LanguageID NOT IN (SELECT LanguageID FROM TranslatedLanguages)
        BEGIN
            THROW 67007, 'Language not available.', 1; 
        END;

        
        UPDATE StudyMeetings
        SET
            SubjectID = @SubjectID,
            LecturerID = @LecturerID,
            MeetingType = @MeetingType,
            MeetingPrice = @MeetingPrice,
            MeetingPriceForOthers = @MeetingPriceForOthers,
            StartTime = @StartTime,
            EndTime = @EndTime,
            LanguageID = @LanguageID,
            TranslatorID = @TranslatorID
        WHERE MeetingID = @MeetingID;

        
        IF @MeetingType = 1
        BEGIN
            
            IF @RoomID IS NULL
            BEGIN
                THROW 67003, 'RoomID must be provided for stationary meetings.', 1;
            END;

            
            DELETE FROM OnlineMeetings
            WHERE MeetingID = @MeetingID;

            
            IF EXISTS (
                SELECT 1
                FROM StationaryMeetings
                WHERE MeetingID = @MeetingID
            )
            BEGIN
                UPDATE StationaryMeetings
                SET
                    RoomID = @RoomID,
                    StudentLimit = @StudentLimit
                WHERE MeetingID = @MeetingID;
            END
            ELSE
            BEGIN
                INSERT INTO StationaryMeetings (MeetingID, RoomID, StudentLimit)
                VALUES (@MeetingID, @RoomID, @StudentLimit);
            END;
        END

        
        ELSE IF @MeetingType = 2
        BEGIN
            
            IF @MeetingLink IS NULL
            BEGIN
                THROW 67004, 'MeetingLink must be provided for online meetings.', 1;
            END;

            
            DELETE FROM StationaryMeetings
            WHERE MeetingID = @MeetingID;

            
            IF EXISTS (
                SELECT 1
                FROM OnlineMeetings
                WHERE MeetingID = @MeetingID
            )
            BEGIN
                UPDATE OnlineMeetings
                SET
                    MeetingLink = @MeetingLink,
                    StudentLimit = @StudentLimit
                WHERE MeetingID = @MeetingID;
            END
            ELSE
            BEGIN
                INSERT INTO OnlineMeetings (MeetingID, MeetingLink, StudentLimit)
                VALUES (@MeetingID, @MeetingLink, @StudentLimit);
            END;
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE AddUserWithRoleAndEmployee
(
    @FirstName VARCHAR(40),
    @LastName VARCHAR(40),
    @Street VARCHAR(40),
    @CityName VARCHAR(40),
    @Email VARCHAR(40),
    @Phone VARCHAR(40),
    @DateOfBirth DATE,
    @RoleName VARCHAR(40), 
    @HireDate DATE = NULL, 
    @DegreeName VARCHAR(255) = NULL 
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        
        DECLARE @CityID INT;
        SELECT @CityID = CityID
        FROM Cities
        WHERE CityName = @CityName;

        IF @CityID IS NULL
        BEGIN
            THROW 50000, 'Podane miasto nie istnieje w tabeli Cities.', 1;
        END;

        
        IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email)
        BEGIN
            THROW 50003, 'Podany adres e-mail już istnieje w tabeli Users.', 1;
        END;

        
        DECLARE @UserID INT;
        INSERT INTO Users (FirstName, LastName, Street, CityID, Email, Phone, DateOfBirth)
        VALUES (@FirstName, @LastName, @Street, @CityID, @Email, @Phone, @DateOfBirth);

        SET @UserID = SCOPE_IDENTITY();

        
        DECLARE @RoleID INT;
        SELECT @RoleID = RoleID
        FROM Roles
        WHERE RoleName = @RoleName;

        IF @RoleID IS NULL
        BEGIN
            THROW 50001, 'Podana rola nie istnieje w tabeli Roles.', 1;
        END;

        
        EXEC AddUserRole @UserID, @RoleID;

        
        IF @RoleID <> 1
        BEGIN
            
            DECLARE @DegreeID INT = NULL;

            IF @DegreeName IS NOT NULL
            BEGIN
                SELECT @DegreeID = DegreeID
                FROM Degrees
                WHERE DegreeName = @DegreeName;

                IF @DegreeID IS NULL
                BEGIN
                    THROW 50002, 'Podany stopień naukowy nie istnieje w tabeli Degrees.', 1;
                END;
            END;

            
            INSERT INTO Employees (EmployeeID, HireDate, DegreeID)
            VALUES (@UserID, @HireDate, @DegreeID);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        
        THROW;
    END CATCH;
END;
GO
