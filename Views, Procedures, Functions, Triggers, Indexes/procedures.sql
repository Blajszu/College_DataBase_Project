ENDCREATE PROCEDURE AddNewStudy
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
        END;
        ELSE
        BEGIN
            THROW 50006, 'Nieprawidłowy typ spotkania. Użyj "Stationary" lub "Online".', 1;
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Wystąpił błąd.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;


CREATE PROCEDURE AddLanguage
    @LanguageName NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        
        IF EXISTS (SELECT 1 FROM Languages WHERE LanguageName = @LanguageName)
        BEGIN
            PRINT 'Błąd: Język o podanej nazwie już istnieje.';
            RETURN;
        END

        
        INSERT INTO Languages (LanguageName)
        VALUES (@LanguageName);

        PRINT 'Język został pomyślnie dodany.';
    END TRY
    BEGIN CATCH
        PRINT 'Wystąpił błąd podczas dodawania języka: ' + ERROR_MESSAGE();
    END CATCH
END;



CREATE PROCEDURE UpdateLanguage
    @LanguageID INT,
    @NewLanguageName NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        
        IF NOT EXISTS (SELECT 1 FROM Languages WHERE LanguageID = @LanguageID)
        BEGIN
            PRINT 'Błąd: Język o podanym ID nie istnieje.';
            RETURN;
        END

        
        IF EXISTS (SELECT 1 FROM Languages WHERE LanguageName = @NewLanguageName)
        BEGIN
            PRINT 'Błąd: Język o podanej nowej nazwie już istnieje.';
            RETURN;
        END

        
        UPDATE Languages
        SET LanguageName = @NewLanguageName
        WHERE LanguageID = @LanguageID;

        PRINT 'Nazwa języka została pomyślnie zaktualizowana.';
    END TRY
    BEGIN CATCH
        PRINT 'Wystąpił błąd podczas aktualizacji języka: ' + ERROR_MESSAGE();
    END CATCH
END;


CREATE PROCEDURE DeleteLanguageFromTranslatedLanguage
    @LanguageID INT
AS
BEGIN
    
    IF EXISTS (SELECT 1 FROM Languages WHERE LanguageID = @LanguageID)
    BEGIN
        
        DELETE FROM TranslatedLanguage
        WHERE LanguageID = @LanguageID;

        PRINT 'Rekordy w tabeli TranslatedLanguage zostały usunięte, ale język pozostaje w tabeli Languages.';
    END
    ELSE
    BEGIN
        
        PRINT 'Nie znaleziono języka o podanym LanguageID.';
    END
END;





CREATE PROCEDURE AddCountry
    @CountryName NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        
        IF EXISTS (SELECT 1 FROM Countries WHERE CountryName = @CountryName)
        BEGIN
            PRINT 'Błąd: Kraj o podanej nazwie już istnieje.';
            RETURN;
        END

        
        INSERT INTO Countries (CountryName)
        VALUES (@CountryName);

        PRINT 'Kraj został pomyślnie dodany.';
    END TRY
    BEGIN CATCH
        PRINT 'Wystąpił błąd podczas dodawania kraju: ' + ERROR_MESSAGE();
    END CATCH
END;



CREATE PROCEDURE UpdateCountry
    @CountryID INT,
    @NewCountryName NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        
        IF NOT EXISTS (SELECT 1 FROM Countries WHERE CountryID = @CountryID)
        BEGIN
            PRINT 'Błąd: Kraj o podanym ID nie istnieje.';
            RETURN;
        END

        
        IF EXISTS (SELECT 1 FROM Countries WHERE CountryName = @NewCountryName)
        BEGIN
            PRINT 'Błąd: Kraj o podanej nowej nazwie już istnieje.';
            RETURN;
        END

        
        UPDATE Countries
        SET CountryName = @NewCountryName
        WHERE CountryID = @CountryID;

        PRINT 'Nazwa kraju została pomyślnie zaktualizowana.';
    END TRY
    BEGIN CATCH
        PRINT 'Wystąpił błąd podczas aktualizacji kraju: ' + ERROR_MESSAGE();
    END CATCH
END;


-CITIES


CREATE PROCEDURE AddCity
    @CityName NVARCHAR(100),
    @PostalCode NVARCHAR(6),
    @CountryID INT
AS
BEGIN
    BEGIN TRY
        
        IF NOT EXISTS (SELECT 1 FROM Countries WHERE CountryID = @CountryID)
        BEGIN
            PRINT 'Błąd: Kraj o podanym ID nie istnieje.';
            RETURN;
        END

        
        IF EXISTS (SELECT 1 FROM Cities WHERE CityName = @CityName AND PostalCode = @PostalCode AND CountryID = @CountryID)
        BEGIN
            PRINT 'Błąd: Miasto o podanej nazwie i kodzie pocztowym już istnieje w wybranym kraju.';
            RETURN;
        END

        
        INSERT INTO Cities (CityName, PostalCode, CountryID)
        VALUES (@CityName, @PostalCode, @CountryID);

        PRINT 'Miasto zostało pomyślnie dodane.';
    END TRY
    BEGIN CATCH
        PRINT 'Wystąpił błąd podczas dodawania miasta: ' + ERROR_MESSAGE();
    END CATCH
END;




CREATE PROCEDURE UpdateCity
    @CityID INT,
    @NewCityName NVARCHAR(100) = NULL,
    @NewPostalCode NVARCHAR(20) = NULL
AS
BEGIN
    
    IF EXISTS (SELECT 1 FROM Cities WHERE CityID = @CityID)
    BEGIN
        
        DECLARE @CountryID INT;
        SELECT @CountryID = CountryID FROM Cities WHERE CityID = @CityID;

        
        IF @NewCityName IS NOT NULL AND EXISTS (
            SELECT 1 
            FROM Cities 
            WHERE CityName = @NewCityName AND CountryID = @CountryID AND CityID <> @CityID
        )
        BEGIN
            
            PRINT 'Miasto o tej nazwie już istnieje w wybranym kraju. Aktualizacja nie może zostać wykonana.';
        END
        ELSE
        BEGIN
            UPDATE Cities
            SET 
                CityName = ISNULL(@NewCityName, CityName),   
                PostalCode = ISNULL(@NewPostalCode, PostalCode)  
            WHERE CityID = @CityID;

            PRINT 'Dane miasta zostały zaktualizowane.';
        END
    END
    ELSE
    BEGIN
        
        PRINT 'Miasto o podanym CityID nie zostało znalezione.';
    END
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






CREATE PROCEDURE AddTranslatedLanguage
    @TranslatorID INT,
    @LanguageID INT
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM UsersRoles WHERE UserID = @TranslatorID AND RoleID = 2)
    BEGIN
        PRINT 'Użytkownik nie jest tłumaczem.';
        RETURN;
    END;

    
    IF NOT EXISTS (SELECT 1 FROM Languages WHERE LanguageID = @LanguageID)
    BEGIN
        PRINT 'Podany język nie istnieje.';
        RETURN;
    END;

    
    IF EXISTS (SELECT 1 FROM TranslatedLanguage WHERE TranslatorID = @TranslatorID AND LanguageID = @LanguageID)
    BEGIN
        PRINT 'Rekord już istnieje.';
        RETURN;
    END;

    
    INSERT INTO TranslatedLanguage (TranslatorID, LanguageID)
    VALUES (@TranslatorID, @LanguageID);
    PRINT 'Rekord został dodany.';
END;



CREATE PROCEDURE UpdateTranslatedLanguage
    @OldTranslatorID INT,
    @OldLanguageID INT,
    @NewTranslatorID INT,
    @NewLanguageID INT
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM TranslatedLanguage WHERE TranslatorID = @OldTranslatorID AND LanguageID = @OldLanguageID)
    BEGIN
        PRINT 'Rekord do modyfikacji nie istnieje.';
        RETURN;
    END;

    
    IF NOT EXISTS (SELECT 1 FROM UsersRoles WHERE UserID = @NewTranslatorID AND RoleID = 2)
    BEGIN
        PRINT 'Nowy tłumacz nie ma odpowiedniej roli.';
        RETURN;
    END;

    
    IF NOT EXISTS (SELECT 1 FROM Languages WHERE LanguageID = @NewLanguageID)
    BEGIN
        PRINT 'Podany język nie istnieje.';
        RETURN;
    END;

    
    IF EXISTS (SELECT 1 FROM TranslatedLanguage WHERE TranslatorID = @NewTranslatorID AND LanguageID = @NewLanguageID)
    BEGIN
        PRINT 'Nowy rekord już istnieje.';
        RETURN;
    END;

    
    UPDATE TranslatedLanguage
    SET TranslatorID = @NewTranslatorID, LanguageID = @NewLanguageID
    WHERE TranslatorID = @OldTranslatorID AND LanguageID = @OldLanguageID;

    PRINT 'Rekord został zaktualizowany.';
END;



CREATE PROCEDURE DeleteTranslatedLanguage
    @TranslatorID INT,
    @LanguageID INT
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM TranslatedLanguage WHERE TranslatorID = @TranslatorID AND LanguageID = @LanguageID)
    BEGIN
        PRINT 'Rekord do usunięcia nie istnieje.';
        RETURN;
    END;

    
    DELETE FROM TranslatedLanguage
    WHERE TranslatorID = @TranslatorID AND LanguageID = @LanguageID;

    PRINT 'Rekord został usunięty.';
END;






CREATE PROCEDURE AddRoom
    @RoomName NVARCHAR(100),
    @Street NVARCHAR(100),
    @CityID INT,
    @Limit INT
AS
BEGIN
    
    IF EXISTS (SELECT 1 FROM Rooms WHERE RoomName = @RoomName AND CityID = @CityID)
    BEGIN
        PRINT 'Sala o podanej nazwie już istnieje w tym mieście.';
        RETURN;
    END;

    
    IF @Limit <= 0
    BEGIN
        PRINT 'Limit osób musi być większy niż 0.';
        RETURN;
    END;

    
    INSERT INTO Rooms (RoomName, Street, CityID, Limit)
    VALUES (@RoomName, @Street, @CityID, @Limit);

    PRINT 'Sala została dodana.';
END;



CREATE PROCEDURE UpdateRoom
    @OldRoomID INT,
    @NewRoomName NVARCHAR(100),

AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM Rooms WHERE RoomID = @OldRoomID)
    BEGIN
        PRINT 'Sala do modyfikacji nie istnieje.';
        RETURN;
    END;

    
    IF EXISTS (SELECT 1 FROM Rooms WHERE RoomName = @NewRoomName AND CityID = @NewCityID AND RoomID != @OldRoomID)
    BEGIN
        PRINT 'Sala o podanej nazwie już istnieje w tym mieście.';
        RETURN;
    END;

    
    UPDATE Rooms
    SET RoomName = @NewRoomName
    WHERE RoomID = @OldRoomID;

    PRINT 'Sala została zaktualizowana.';
END;





CREATE PROCEDURE AddInternship
    @StudiesID INT,
    @InternshipCoordinatorID INT,
    @StartDate DATE,
    @EndDate DATE,
    @NumberOfHours INT,
    @Term INT
AS
BEGIN
    
    DECLARE @NumberOfTerms INT;
    SELECT @NumberOfTerms = NumberOfTerms FROM Studies WHERE StudiesID = @StudiesID;
    
    IF @Term < 1 OR @Term > @NumberOfTerms
    BEGIN
        PRINT 'Invalid Term for the given Studies.';
        RETURN;
    END

    
    IF EXISTS (SELECT 1 FROM Internship WHERE StudiesID = @StudiesID AND Term = @Term)
    BEGIN
        PRINT 'There is already an internship for this term of these studies.';
        RETURN;
    END

    
    IF DATEDIFF(DAY, @StartDate, @EndDate) <> 14
    BEGIN
        PRINT 'Internship must last exactly 14 days.';
        RETURN;
    END

    
    IF NOT EXISTS (SELECT 1 FROM UsersRoles WHERE UserID = @InternshipCoordinatorID AND RoleID = 4)
    BEGIN
        PRINT 'The specified user is not a coordinator for internships.';
        RETURN;
    END

    
    IF EXISTS (
        SELECT 1 
        FROM StudyMeetings SM
        INNER JOIN Subjects S ON SM.SubjectID = S.SubjectID
        WHERE S.StudiesID = @StudiesID
        AND ((@StartDate BETWEEN SM.StartTime AND SM.EndTime) OR (@EndDate BETWEEN SM.StartTime AND SM.EndTime))
    )
    BEGIN
        PRINT 'Internship overlaps with a study meeting for the given studies.';
        RETURN;
    END

    
    INSERT INTO Internship (StudiesID, InternshipCoordinatorID, StartDate, EndDate, NumberOfHours, Term)
    VALUES (@StudiesID, @InternshipCoordinatorID, @StartDate, @EndDate, @NumberOfHours, @Term);

    PRINT 'Internship added successfully.';
END;





CREATE PROCEDURE UpdateInternship
    @InternshipID INT,
    @StudiesID INT,
    @InternshipCoordinatorID INT,
    @StartDate DATE,
    @EndDate DATE,
    @NumberOfHours INT,
    @Term INT
AS
BEGIN
    
    DECLARE @NumberOfTerms INT;
    SELECT @NumberOfTerms = NumberOfTerms FROM Studies WHERE StudiesID = @StudiesID;
    
    IF @Term < 1 OR @Term > @NumberOfTerms
    BEGIN
        PRINT 'Invalid Term for the given Studies.';
        RETURN;
    END

    
    IF EXISTS (SELECT 1 FROM Internship WHERE StudiesID = @StudiesID AND Term = @Term AND InternshipID != @InternshipID)
    BEGIN
        PRINT 'There is already an internship for this term of these studies.';
        RETURN;
    END

    
    IF DATEDIFF(DAY, @StartDate, @EndDate) <> 14
    BEGIN
        PRINT 'Internship must last exactly 14 days.';
        RETURN;
    END

    
    IF NOT EXISTS (SELECT 1 FROM UsersRoles WHERE UserID = @InternshipCoordinatorID AND RoleID = 4)
    BEGIN
        PRINT 'The specified user is not a coordinator for internships.';
        RETURN;
    END

    
    IF EXISTS (
        SELECT 1 
        FROM StudyMeetings SM
        INNER JOIN Subjects S ON SM.SubjectID = S.SubjectID
        WHERE S.StudiesID = @StudiesID
        AND ((@StartDate BETWEEN SM.StartTime AND SM.EndTime) OR (@EndDate BETWEEN SM.StartTime AND SM.EndTime))
    )
    BEGIN
        PRINT 'Internship overlaps with a study meeting for the given studies.';
        RETURN;
    END

    
    UPDATE Internship
    SET StudiesID = @StudiesID, 
        InternshipCoordinatorID = @InternshipCoordinatorID, 
        StartDate = @StartDate, 
        EndDate = @EndDate, 
        NumberOfHours = @NumberOfHours, 
        Term = @Term
    WHERE InternshipID = @InternshipID;

    PRINT 'Internship updated successfully.';
END;




 
CREATE PROCEDURE DeleteInternship
    @InternshipID INT
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM Internship WHERE InternshipID = @InternshipID)
    BEGIN
        PRINT 'Internship not found.';
        RETURN;
    END

    
    DELETE FROM Internship WHERE InternshipID = @InternshipID;

    PRINT 'Internship deleted successfully.';
END;






CREATE PROCEDURE AddCourseModulePassed
    @ModuleID INT,
    @StudentID INT,
    @Passed BIT
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM Modules WHERE ModuleID = @ModuleID)
    BEGIN
        PRINT 'Moduł o podanym ID nie istnieje.'
        RETURN
    END
    
    IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
    BEGIN
        PRINT 'Student o podanym ID nie istnieje.'
        RETURN
    END
    
    
    IF NOT EXISTS (SELECT 1
                   FROM Orders O
                   JOIN OrderDetails OD ON O.OrderID = OD.OrderID
                   WHERE O.StudentID = @StudentID AND OD.TypeOfActivity = 2 
                   AND OD.ActivityID IN (SELECT CourseID FROM Courses WHERE CourseID = OD.ActivityID)
                   AND EXISTS (SELECT 1 FROM CourseModules CM WHERE CM.CourseID = OD.ActivityID AND CM.ModuleID = @ModuleID))
    BEGIN
        PRINT 'Student nie jest zapisany na kurs lub nie ma dostępu do tego modułu.'
        RETURN
    END
    
    
    IF EXISTS (SELECT 1 FROM CourseModulePassed WHERE ModuleID = @ModuleID AND StudentID = @StudentID)
    BEGIN
        PRINT 'Rekord już istnieje dla tego studenta i modułu.'
        RETURN
    END
    
    
    INSERT INTO CourseModulePassed (ModuleID, StudentID, Passed)
    VALUES (@ModuleID, @StudentID, @Passed)

    PRINT 'Rekord został pomyślnie dodany.'
END




CREATE PROCEDURE UpdateCourseModulePassed
    @ModuleID INT,
    @StudentID INT,
    @Passed BIT
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1
                   FROM Orders O
                   JOIN OrderDetails OD ON O.OrderID = OD.OrderID
                   WHERE O.StudentID = @StudentID AND OD.TypeOfActivity = 2 
                   AND OD.ActivityID IN (SELECT CourseID FROM Courses WHERE CourseID = OD.ActivityID)
                   AND EXISTS (SELECT 1 FROM CourseModules CM WHERE CM.CourseID = OD.ActivityID AND CM.ModuleID = @ModuleID))
    BEGIN
        PRINT 'Student nie jest zapisany na kurs lub nie ma dostępu do tego modułu.'
        RETURN
    END
    
    
    IF NOT EXISTS (SELECT 1 FROM CourseModulePassed WHERE ModuleID = @ModuleID AND StudentID = @StudentID)
    BEGIN
        PRINT 'Rekord do modyfikacji nie istnieje.'
        RETURN
    END
    
    
    UPDATE CourseModulePassed
    SET Passed = @Passed
    WHERE ModuleID = @ModuleID AND StudentID = @StudentID

    PRINT 'Rekord został pomyślnie zaktualizowany.'
END




CREATE PROCEDURE DeleteCourseModulePassed
    @ModuleID INT,
    @StudentID INT
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1
                   FROM Orders O
                   JOIN OrderDetails OD ON O.OrderID = OD.OrderID
                   WHERE O.StudentID = @StudentID AND OD.TypeOfActivity = 2 
                   AND OD.ActivityID IN (SELECT CourseID FROM Courses WHERE CourseID = OD.ActivityID)
                   AND EXISTS (SELECT 1 FROM CourseModules CM WHERE CM.CourseID = OD.ActivityID AND CM.ModuleID = @ModuleID))
    BEGIN
        PRINT 'Student nie jest zapisany na kurs lub nie ma dostępu do tego modułu.'
        RETURN
    END
    
    
    IF NOT EXISTS (SELECT 1 FROM CourseModulePassed WHERE ModuleID = @ModuleID AND StudentID = @StudentID)
    BEGIN
        PRINT 'Rekord do usunięcia nie istnieje.'
        RETURN
    END
    
    
    DELETE FROM CourseModulePassed
    WHERE ModuleID = @ModuleID AND StudentID = @StudentID

    PRINT 'Rekord został pomyślnie usunięty.'
END


CREATE PROCEDURE AddUserRole
    @UserID INT,
    @RoleID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID)
    BEGIN
        PRINT 'Użytkownik o podanym UserID nie istnieje.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Roles WHERE RoleID = @RoleID)
    BEGIN
        PRINT 'Rola o podanym RoleID nie istnieje.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM UsersRoles WHERE UserID = @UserID AND RoleID = @RoleID)
    BEGIN
        PRINT 'Użytkownik już posiada tę rolę.';
        RETURN;
    END

    INSERT INTO UsersRoles (UserID, RoleID)
    VALUES (@UserID, @RoleID);
    PRINT 'Rola została pomyślnie dodana użytkownikowi.';
END;


CREATE PROCEDURE AddStudyResult
    @StudentID INT,
    @StudiesID INT,
    @GradeID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @StudentID)
    BEGIN
        PRINT 'Student o podanym StudentID nie istnieje.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Studies WHERE StudiesID = @StudiesID)
    BEGIN
        PRINT 'Kierunek studiów o podanym StudiesID nie istnieje.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Grades WHERE GradeID = @GradeID)
    BEGIN
        PRINT 'Ocena o podanym GradeID nie istnieje.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Orders O
                   INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
                   WHERE O.UserID = @StudentID AND OD.ActivityID = @StudiesID)
    BEGIN
        PRINT 'Student nie złożył zamówienia na te studia.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM StudiesResults WHERE StudentID = @StudentID AND StudiesID = @StudiesID)
    BEGIN
        PRINT 'Rezultat dla tego studenta i kierunku już istnieje.';
        RETURN;
    END

    INSERT INTO StudiesResults (StudentID, StudiesID, GradeID)
    VALUES (@StudentID, @StudiesID, @GradeID);

    PRINT 'Rezultat studiów został pomyślnie dodany.';
END;



CREATE PROCEDURE AddSubjectResult
    @StudentID INT,
    @SubjectID INT,
    @GradeID INT

AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @StudentID)
    BEGIN
        PRINT 'Student o podanym StudentID nie istnieje.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Subjects WHERE SubjectID = @SubjectID)
    BEGIN
        PRINT 'Przedmiot o podanym SubjectID nie istnieje.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Grades WHERE GradeID = @GradeID)
    BEGIN
        PRINT 'Ocena o podanym GradeID nie istnieje.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Orders O
                   INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
                   INNER JOIN Subjects S ON OD.ActivityID = S.StudiesID
                   WHERE O.UserID = @StudentID AND S.SubjectID = @SubjectID)
    BEGIN
        PRINT 'Student nie złożył zamówienia na studia, w ramach którego jest podany przedmiot.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM SubjectsResults WHERE StudentID = @StudentID AND SubjectID = @SubjectID)
    BEGIN
        PRINT 'Rezultat dla tego studenta i przedmiotu już istnieje.';
        RETURN;
    END

    INSERT INTO SubjectsResults (SubjectID, StudentID, GradeID)
    VALUES (@SubjectID, @StudentID, @GradeID);

    PRINT 'Rezultat przedmiotu został pomyślnie dodany.';
END;


CREATE PROCEDURE AddInternshipResult
    @StudentID INT,
    @InternshipID INT,
    @GradeID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @StudentID)
    BEGIN
        PRINT 'Student o podanym StudentID nie istnieje.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Internship WHERE InternshipID = @InternshipID)
    BEGIN
        PRINT 'Praktyka o podanym InternshipID nie istnieje.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Grades WHERE GradeID = @GradeID)
    BEGIN
        PRINT 'Ocena o podanym GradeID nie istnieje.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Orders O
                   INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
                   INNER JOIN Internship I ON OD.ActivityID = I.StudiesID
                   WHERE O.UserID = @StudentID AND I.InternshipID = @InternshipID)
    BEGIN
        PRINT 'Student nie złożył zamówienia na studia, w ramach których odbywają się praktyki.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM InternshipPassed WHERE StudentID = @StudentID AND InternshipID = @InternshipID)
    BEGIN
        PRINT 'Rezultat praktyk dla tego studenta już istnieje.';
        RETURN;
    END

    INSERT INTO InternshipPassed (InternshipID, StudentID, GradeID)
    VALUES (@InternshipID, @StudentID, @GradeID);

    PRINT 'Rezultat praktyk został pomyślnie dodany.';
END;


CREATE PROCEDURE AddStudyMeetingPresence
    @StudentID INT,
    @MeetingID INT,
    @PresenceStatus BIT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @StudentID)
    BEGIN
        PRINT 'Student o podanym StudentID nie istnieje.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM StudyMeetings WHERE MeetingID = @MeetingID)
    BEGIN
        PRINT 'Spotkanie o podanym MeetingID nie istnieje.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Orders O
                   INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
                   WHERE O.UserID = @StudentID AND OD.ActivityID = @MeetingID 
                   UNION 
                   SELECT 1 FROM Orders O
                   INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
                   INNER JOIN StudyMeetingPayment SMP ON OD.DetailID = SMP.DetailID
                   WHERE O.UserID = @StudentID AND SMP.MeetingID = @MeetingID)
    BEGIN
        PRINT 'Student nie wykupił tego spotkania.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM StudyMeetingPresence WHERE StudyMeetingID = @MeetingID AND StudentID = @StudentID)
    BEGIN
        PRINT 'Obecność na to spotkanie dla tego studenta już istnieje.';
        RETURN;
    END

    INSERT INTO StudyMeetingPresence (StudyMeetingID, StudentID, PresenceStatus)
    VALUES (@MeetingID, @StudentID, @PresenceStatus);

    PRINT 'Obecność została pomyślnie dodana.';
END;


CREATE PROCEDURE AddActivityInsteadOfPresence
    @StudentID INT,
    @MeetingID INT,
    @ActivityID INT,
    @TypeOfActivity INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @StudentID)
    BEGIN
        PRINT 'Student o podanym StudentID nie istnieje.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM StudyMeetings WHERE MeetingID = @MeetingID)
    BEGIN
        PRINT 'Spotkanie o podanym MeetingID nie istnieje.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM StudyMeetingPresence WHERE StudentID = @StudentID AND StudyMeetingID = @MeetingID AND PresenceStatus = 0)
    BEGIN
        PRINT 'Student nie ma nieobecności na to spotkanie.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM StudyMeetings WHERE MeetingID = @ActivityID)
    BEGIN
        PRINT 'Odrabiana aktywność o podanym ActivityID nie istnieje.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM ActivityInsteadOfAbsence WHERE MeetingID = @MeetingID AND StudentID = @StudentID AND ActivityID = @ActivityID)
    BEGIN
        PRINT 'Odrabianie dla tego spotkania i studenta zostało już dodane.';
        RETURN;
    END

    INSERT INTO ActivityInsteadOfAbsence (MeetingID, StudentID, ActivityID, TypeOfActivity)
    VALUES (@MeetingID, @StudentID, @ActivityID, @TypeOfActivity);

    PRINT 'Odrabianie zostało pomyślnie dodane.';
END;


CREATE PROCEDURE AddOrderWithDetails
    @UserID INT,
    @ActivityList ActivityListType READONLY 
AS
BEGIN
    DECLARE @OrderID INT;
    DECLARE @ActivityID INT;
    DECLARE @TypeOfActivity INT;
    DECLARE @Price DECIMAL(18,2);
    DECLARE @DetailID INT;
    DECLARE @StudentLimit INT;
    DECLARE @TotalBooked INT;
    DECLARE @EntryFee DECIMAL(18,2);
    DECLARE @PaymentAdvance DECIMAL(18,2);
    DECLARE @OrderDate DATETIME = GETDATE();
    DECLARE @PaymentDeferred BIT = NULL;
    DECLARE @DeferredDate DATETIME = NULL;
    DECLARE @PaymentLink VARCHAR(255) = NULL;

    DECLARE @InvalidActivityType INT;
    
    SELECT @InvalidActivityType = COUNT(*)
    FROM @ActivityList AL
    LEFT JOIN ActivitiesTypes AT ON AL.TypeOfActivity = AT.ActivityTypeID
    WHERE AT.ActivityTypeID IS NULL;

    IF @InvalidActivityType > 0
    BEGIN
        RAISERROR ('Jedna lub więcej typów aktywności nie są poprawne w tabeli ActivitiesTypes.', 16, 1);
        RETURN;
    END

    DECLARE ActivityCursor CURSOR FOR
    SELECT ActivityID, TypeOfActivity
    FROM @ActivityList;

    OPEN ActivityCursor;

    FETCH NEXT FROM ActivityCursor INTO @ActivityID, @TypeOfActivity;

    WHILE @@FETCH_STATUS = 0
    BEGIN
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
                CLOSE ActivityCursor;
                DEALLOCATE ActivityCursor;
                RETURN;
            END
        END
        IF @TypeOfActivity = 3
        BEGIN
            SELECT @StudentLimit =  S.StudentLimit
            FROM Studies S WHERE S.StudiesID = @ActivityID;

            SELECT @TotalBooked = COUNT(OD.OrderID)
            FROM OrderDetails OD
            WHERE OD.ActivityID = @ActivityID
            AND OD.TypeOfActivity = @TypeOfActivity;

            IF (@TotalBooked + 1) > @StudentLimit
            BEGIN
                RAISERROR ('Przekroczono limit miejsc na studiach dla aktywności o ID %d.', 16, 1, @ActivityID);
                CLOSE ActivityCursor;
                DEALLOCATE ActivityCursor;
                RETURN;
            END

            SELECT @StudentLimit =  MIN(S.StudentLimit
            FROM StationaryMeetings SM
            INNER JOIN StudyMeetings SM2 ON SM.MeetingID = SM2.MeetingID
            INNER JOIN StudyMeetingPayment SMP ON SM2.MeetingID = SMP.MeetingID
            INNER JOIN OrderDetails OD ON SMP.DetailID = OD.DetailID
            WHERE ActivityID = @ActivityID)

            SELECT @TotalBooked = COUNT(SM.DetailID)
            FROM StudyMeetings SM
            INNER JOIN Subjects S ON SM.SubjectID = S.SubjectID
            WHERE S.StudiesID = @ActivityID

            IF (@TotalBooked + 1) > @StudentLimit
            BEGIN
                RAISERROR ('Przekroczono limit miejsc na spotkaniach studyjnych dla aktywności o ID %d.', 16, 1, @ActivityID);
                CLOSE ActivityCursor;
                DEALLOCATE ActivityCursor;
                RETURN;
            END
        END    

        IF @TypeOfActivity = 2
        BEGIN
            SELECT @StudentLimit =  C.StudentLimit
            FROM Courses C WHERE C.CourseID = @ActivityID AND @TypeOfActivity = 2;

            SELECT @TotalBooked = COUNT(OD.OrderID)
            FROM OrderDetails OD
            WHERE OD.ActivityID = @Activity AND @TypeOfActivity = 2;    

            IF @StudentLimit IS NOT NULL && (@TotalBooked + 1) > @StudentLimit
            BEGIN
                RAISERROR ('Przekroczono limit miejsc na kursie dla aktywności o ID %d.', 16, 1, @ActivityID);
                CLOSE ActivityCursor;
                DEALLOCATE ActivityCursor;
                RETURN;
            END

        IF @TypeOfActivity = 4
            SELECT @Price = MeetingPriceForOthers FROM StudyMeetings WHERE MeetingID = @ActivityID;
        ELSE IF @TypeOfActivity = 3
            SELECT @Price = EntryFee FROM Studies WHERE StudiesID = @ActivityID;
        ELSE IF @TypeOfActivity = 2
            SELECT @Price = CoursePrice FROM Courses WHERE CourseID = @ActivityID;
        ELSE IF @TypeOfActivity = 1
            SELECT @Price = Price FROM Webinars WHERE WebinarID = @ActivityID;

        SET @DetailID = SCOPE_IDENTITY();
        INSERT INTO OrderDetails (DetailID, OrderID, ActivityID, TypeOfActivity, Price, PaidDate, PaymentStatus)
        VALUES (@DetailID, @OrderID, @ActivityID, @TypeOfActivity, @Price, NULL, NULL);

        IF @TypeOfActivity = 2
        BEGIN
            SET @AdvancePrice = @Price * 0.10;
            INSERT INTO PaymentsAdvances (DetailID, AdvancePrice, AdvancePaidDate, AdvancePaymentStatus)
            VALUES (@DetailID, @AdvancePrice, NULL, NULL);
        END
        
        IF @TypeOfActivity = 3
        BEGIN
            DECLARE MeetingCursor CURSOR FOR
            SELECT MeetingID, MeetingPrice FROM StudyMeetings INNER JOIN Subjects ON Subjects.SubjectID=StudyMeetings.SubjectID WHERE StudiesID = @ActivityID;
            
            OPEN MeetingCursor;
            FETCH NEXT FROM MeetingCursor INTO @MeetingID, @MeetingPrice;
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                INSERT INTO StudyMeetingPayment (DetailID, MeetingID, Price, PaidDate, PaymentStatus)
                VALUES (@DetailID, @MeetingID, @MeetingPrice, NULL, NULL);
                
                FETCH NEXT FROM MeetingCursor INTO @MeetingID, @MeetingPrice;
            END
            
            CLOSE MeetingCursor;
            DEALLOCATE MeetingCursor;
        END
        
        FETCH NEXT FROM ActivityCursor INTO @ActivityID, @TypeOfActivity;
    END
    
    CLOSE ActivityCursor;
    DEALLOCATE ActivityCursor;
    
    COMMIT TRANSACTION;
END


CREATE PROCEDURE ModifyOrder
    @OrderID INT,
    @NewUserID INT = NULL,
    @PaymentDeferred BIT = NULL,
    @DeferredDate DATETIME = NULL,
    @PaymentLink VARCHAR(255) = NULL 
AS
BEGIN
    BEGIN TRANSACTION;

    UPDATE Orders
    SET UserID = ISNULL(@NewUserID, UserID),
        PaymentDeferred = ISNULL(@PaymentDeferred, PaymentDeferred),
        DeferredDate = ISNULL(@DeferredDate, DeferredDate),
        PaymentLink = ISNULL(@PaymentLink, PaymentLink)
    WHERE OrderID = @OrderID;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR ('Zamówienie o podanym ID nie istnieje.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    COMMIT TRANSACTION;
END;

CREATE PROCEDURE DeleteOrder
    @OrderID INT
AS
BEGIN
    BEGIN TRANSACTION;

    DELETE FROM OrderDetails
    WHERE OrderID = @OrderID;

    DELETE FROM Orders
    WHERE OrderID = @OrderID;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR ('Zamówienie o podanym ID nie istnieje.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    COMMIT TRANSACTION;
END;

CREATE PROCEDURE ModifyOrderDetail
    @DetailID INT,
    @NewActivityID INT = NULL,
    @NewTypeOfActivity INT = NULL,
    @NewPrice DECIMAL(18,2) = NULL, 
    @NewPaymentStatus BIT = NULL 
AS
BEGIN
    BEGIN TRANSACTION;

    DECLARE @PaidStatus BIT;
    SELECT @PaidStatus = PaymentStatus
    FROM OrderDetails
    WHERE DetailID = @DetailID;

    IF @PaidStatus = 1
    BEGIN
        RAISERROR ('Nie można zmodyfikować aktywności, która została opłacona. Usuń ją i dodaj nową.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    UPDATE OrderDetails
    SET ActivityID = ISNULL(@NewActivityID, ActivityID),
        TypeOfActivity = ISNULL(@NewTypeOfActivity, TypeOfActivity),
        Price = ISNULL(@NewPrice, Price),
        PaymentStatus = ISNULL(@NewPaymentStatus, PaymentStatus)
    WHERE DetailID = @DetailID;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR ('Szczegóły zamówienia o podanym ID nie istnieją.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    COMMIT TRANSACTION;
END;

CREATE PROCEDURE DeleteOrderDetail
    @DetailID INT
AS
BEGIN
    BEGIN TRANSACTION;

    DELETE FROM OrderDetails
    WHERE DetailID = @DetailID;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR ('Szczegóły zamówienia o podanym ID nie istnieją.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    COMMIT TRANSACTION;
END;


CREATE PROCEDURE ModifyUserRole
    @UserID INT,
    @NewRoleID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM UsersRoles WHERE UserID = @UserID)
    BEGIN
        UPDATE UsersRoles
        SET RoleID = @NewRoleID
        WHERE UserID = @UserID;
    END
    ELSE
    BEGIN
        INSERT INTO UsersRoles (UserID, RoleID)
        VALUES (@UserID, @NewRoleID);
    END
END;
GO

CREATE PROCEDURE DeleteUserRole
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM UsersRoles WHERE UserID = @UserID;
END;
GO


CREATE PROCEDURE ModifyStudiesResult
    @StudentID INT,
    @StudiesID INT,
    @GradeID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM StudiesResults WHERE StudentID = @StudentID AND StudiesID = @StudiesID)
    BEGIN
        UPDATE StudiesResults
        SET GradeID = @GradeID
        WHERE StudentID = @StudentID AND StudiesID = @StudiesID;
    END
    ELSE
    BEGIN
        INSERT INTO StudiesResults (StudentID, StudiesID, GradeID)
        VALUES (@StudentID, @StudiesID, @GradeID);
    END
END;


CREATE PROCEDURE DeleteStudiesResult
    @StudentID INT,
    @StudiesID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM StudiesResults
    WHERE StudentID = @StudentID AND StudiesID = @StudiesID;
END;


CREATE PROCEDURE ModifySubjectResult
    @StudentID INT,
    @SubjectID INT,
    @GradeID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM SubjectsResults WHERE StudentID = @StudentID AND SubjectID = @SubjectID)
    BEGIN
        UPDATE SubjectsResults
        SET GradeID = @GradeID
        WHERE StudentID = @StudentID AND SubjectID = @SubjectID;
    END
    ELSE
    BEGIN
        INSERT INTO SubjectsResults (StudentID, SubjectID, GradeID)
        VALUES (@StudentID, @SubjectID, @GradeID);
    END
END;

CREATE PROCEDURE DeleteSubjectResult
    @StudentID INT,
    @SubjectID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM SubjectsResults
    WHERE StudentID = @StudentID AND SubjectID = @SubjectID;
END;


CREATE PROCEDURE ModifyInternshipResult
    @StudentID INT,
    @InternshipID INT,
    @Passed BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM InternshipPassed WHERE StudentID = @StudentID AND InternshipID = @InternshipID)
    BEGIN
        UPDATE InternshipPassed
        SET Passed = @Passed
        WHERE StudentID = @StudentID AND InternshipID = @InternshipID;
    END
    ELSE
    BEGIN
        INSERT INTO InternshipPassed (StudentID, InternshipID, Passed)
        VALUES (@StudentID, @InternshipID, @Passed);
    END
END;


CREATE PROCEDURE DeleteInternshipResult
    @StudentID INT,
    @InternshipID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM InternshipPassed
    WHERE StudentID = @StudentID AND InternshipID = @InternshipID;
END;


CREATE PROCEDURE ModifyStudyMeetingPresence
    @StudentID INT,
    @MeetingID INT,
    @Present BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM StudyMeetingsPresence WHERE StudentID = @StudentID AND MeetingID = @MeetingID)
    BEGIN
        UPDATE StudyMeetingsPresence
        SET Present = @Present
        WHERE StudentID = @StudentID AND MeetingID = @MeetingID;
    END
    ELSE
    BEGIN
        INSERT INTO StudyMeetingsPresence (StudentID, MeetingID, Present)
        VALUES (@StudentID, @MeetingID, @Present);
    END
END;


CREATE PROCEDURE DeleteStudyMeetingPresence
    @StudentID INT,
    @MeetingID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM StudyMeetingsPresence
    WHERE StudentID = @StudentID AND MeetingID = @MeetingID;
END;


CREATE PROCEDURE ModifyActivityInsteadOfAbsence
    @StudentID INT,
    @AbsenceMeetingID INT,
    @ReplacementActivityID INT
    @TypeOfActivity INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM ActivitiesTypes WHERE ActivityTypeID = @TypeOfActivity)
    BEGIN
        RAISERROR('Nieprawidłowy typ aktywności.', 16, 1);
        RETURN;
    END
    IF EXISTS (SELECT 1 FROM ActivityInsteadOfAbsence WHERE StudentID = @StudentID AND MeetingID = @AbsenceMeetingID)
    BEGIN
        UPDATE ActivityInsteadOfAbsence
        SET ActivityID = @ReplacementActivityID
        WHERE StudentID = @StudentID AND MeetingID = @AbsenceMeetingID;
    END
    ELSE
    BEGIN
        INSERT INTO ActivityInsteadOfAbsence (StudentID, MeetingID, ActivityID, TypeOfActivity)
        VALUES (@StudentID, @AbsenceMeetingID, @ReplacementActivityID, @TypeOfActivity);
    END
END;


CREATE PROCEDURE DeleteActivityInsteadOfAbsence
    @StudentID INT,
    @AbsenceMeetingID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM ActivityInsteadOfAbsence
    WHERE StudentID = @StudentID AND MeetingID = @AbsenceMeetingID;
END;


