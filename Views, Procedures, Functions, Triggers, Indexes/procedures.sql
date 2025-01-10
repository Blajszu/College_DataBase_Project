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
        -- Sprawdzenie, czy koordynator istnieje
        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @StudiesCoordinatorID)
        BEGIN
            RAISERROR('Koordynator o podanym ID nie istnieje.', 16, 1);
            RETURN;
        END

        -- Sprawdzenie poprawności dat
        IF @StartDate >= @EndDate
        BEGIN
            RAISERROR('Data rozpoczęcia musi być wcześniejsza niż data zakończenia.', 16, 1);
            RETURN;
        END

        -- Sprawdzenie poprawności liczby semestrów i ceny studiów
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

        -- Dodanie nowych studiów
        INSERT INTO Studies (StudyName, StudiesCoordinatorID, StudyPrice, NumberOfTerms, StartDate, EndDate)
        VALUES (@StudyName, @StudiesCoordinatorID, @StudyPrice, @NumberOfTerms, @StartDate, @EndDate);

        PRINT 'Studia zostały pomyślnie dodane.';
    END TRY
    BEGIN CATCH
        -- Obsługa błędów
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
        -- Sprawdzenie, czy koordynator kursu istnieje
        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @CourseCoordinatorID)
        BEGIN
            RAISERROR('Koordynator kursu o podanym ID nie istnieje.', 16, 1);
            RETURN;
        END

        -- Sprawdzenie poprawności dat
        IF @StartDate >= @EndDate
        BEGIN
            RAISERROR('Data rozpoczęcia musi być wcześniejsza niż data zakończenia.', 16, 1);
            RETURN;
        END

        -- Sprawdzenie poprawności limitu studentów i ceny kursu
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

        -- Dodanie nowego kursu
        INSERT INTO Courses (CourseName, CourseCoordinatorID, CoursePrice, StudentLimit, StartDate, EndDate)
        VALUES (@CourseName, @CourseCoordinatorID, @CoursePrice, @StudentLimit, @StartDate, @EndDate);

        PRINT 'Kurs został pomyślnie dodany.';
    END TRY
    BEGIN CATCH
        -- Obsługa błędów
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
        -- Sprawdzenie poprawności dat
        IF @StartDate >= @EndDate
        BEGIN
            RAISERROR('Data rozpoczęcia musi być wcześniejsza niż data zakończenia.', 16, 1);
            RETURN;
        END

        -- Sprawdzenie, czy nauczyciel istnieje
        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @TeacherID)
        BEGIN
            RAISERROR('Nauczyciel o podanym ID nie istnieje.', 16, 1);
            RETURN;
        END

        -- Sprawdzenie, czy tłumacz istnieje (jeśli podany)
        IF @TranslatorID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @TranslatorID)
        BEGIN
            RAISERROR('Tłumacz o podanym ID nie istnieje.', 16, 1);
            RETURN;
        END

        -- Sprawdzenie, czy język istnieje
        IF NOT EXISTS (SELECT 1 FROM Languages WHERE LanguageID = @LanguageID)
        BEGIN
            RAISERROR('Język o podanym ID nie istnieje.', 16, 1);
            RETURN;
        END

        -- Sprawdzenie poprawności ceny
        IF @Price < 0
        BEGIN
            RAISERROR('Cena webinaru nie może być ujemna.', 16, 1);
            RETURN;
        END

        -- Dodanie nowego webinaru
        INSERT INTO Webinars (WebinarName, StartDate, EndDate, TeacherID, TranslatorID, LanguageID, Price)
        VALUES (@WebinarName, @StartDate, @EndDate, @TeacherID, @TranslatorID, @LanguageID, @Price);

        PRINT 'Webinar został pomyślnie dodany.';
    END TRY
    BEGIN CATCH
        -- Obsługa błędów
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
        -- Sprawdzenie poprawności liczby godzin
        IF @NumberOfHoursInTerm <= 0
        BEGIN
            RAISERROR('Liczba godzin w semestrze musi być większa od zera.', 16, 1);
            RETURN;
        END

        -- Sprawdzenie, czy nauczyciel istnieje
        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @TeacherID)
        BEGIN
            RAISERROR('Nauczyciel o podanym ID nie istnieje.', 16, 1);
            RETURN;
        END

        -- Sprawdzenie, czy studia istnieją
        IF NOT EXISTS (SELECT 1 FROM Studies WHERE StudiesID = @StudiesID)
        BEGIN
            RAISERROR('Studia o podanym ID nie istnieją.', 16, 1);
            RETURN;
        END

        -- Dodanie nowego przedmiotu
        INSERT INTO Subjects (SubjectName, NumberOfHoursInTerm, TeacherID, StudiesID)
        VALUES (@SubjectName, @NumberOfHoursInTerm, @TeacherID, @StudiesID);

        PRINT 'Przedmiot został pomyślnie dodany.';
    END TRY
    BEGIN CATCH
        -- Obsługa błędów
        PRINT 'Wystąpił błąd podczas dodawania przedmiotu.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE AddSubjectMeeting
    @SubjectID INT,
    @MeetingType NVARCHAR(50), -- 'stationary' lub 'online'
    @StartTime DATETIME,
    @EndTime DATETIME,
    @MeetingPrice DECIMAL(10, 2),
    @MeetingPriceForOthers DECIMAL(10, 2),
    @StudentLimit INT = NULL, -- Opcjonalne, tylko dla stacjonarnych spotkań
    @RoomID INT = NULL,       -- Opcjonalne, tylko dla stacjonarnych spotkań
    @MeetingLink NVARCHAR(255) = NULL -- Opcjonalne, tylko dla spotkań online
AS
BEGIN
    BEGIN TRY
        -- Walidacja czasu spotkania
        IF @StartTime >= @EndTime
        BEGIN
            RAISERROR('Czas rozpoczęcia spotkania musi być wcześniejszy niż czas zakończenia.', 16, 1);
            RETURN;
        END

        -- Sprawdzenie, czy przedmiot istnieje
        IF NOT EXISTS (SELECT 1 FROM Subjects WHERE SubjectID = @SubjectID)
        BEGIN
            RAISERROR('Przedmiot o podanym ID nie istnieje.', 16, 1);
            RETURN;
        END

        -- Dodanie spotkania do tabeli StudyMeetings
        DECLARE @MeetingID INT;
        INSERT INTO StudyMeetings (SubjectID, StartTime, EndTime, MeetingPrice, MeetingPriceForOthers)
        VALUES (@SubjectID, @StartTime, @EndTime, @MeetingPrice, @MeetingPriceForOthers);

        -- Pobranie ID nowo dodanego spotkania
        SET @MeetingID = SCOPE_IDENTITY();

        -- Obsługa typu spotkania
        IF LOWER(@MeetingType) = 'stationary'
        BEGIN
            -- Walidacja danych dla spotkań stacjonarnych
            IF @RoomID IS NULL
            BEGIN
                RAISERROR('Dla spotkań stacjonarnych wymagane jest podanie ID sali.', 16, 1);
                RETURN;
            END

            -- Dodanie do tabeli StationaryMeetings
            INSERT INTO StationaryMeetings (MeetingID, RoomID, StudentLimit)
            VALUES (@MeetingID, @RoomID, @StudentLimit);
        END
        ELSE IF LOWER(@MeetingType) = 'online'
        BEGIN
            -- Walidacja danych dla spotkań online
            IF @MeetingLink IS NULL
            BEGIN
                RAISERROR('Dla spotkań online wymagane jest podanie linku do spotkania.', 16, 1);
                RETURN;
            END

            -- Dodanie do tabeli OnlineMeetings
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
        -- Obsługa błędów
        PRINT 'Wystąpił błąd podczas dodawania spotkania.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;

