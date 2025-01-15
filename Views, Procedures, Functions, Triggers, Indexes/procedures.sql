 CREATE PROCEDURE Addnewstudy @StudyName            NVARCHAR(255),
                             @StudiesCoordinatorID INT,
                             @StudyPrice           DECIMAL(10, 2),
                             @NumberOfTerms        INT
AS
  BEGIN
      BEGIN try
          IF NOT EXISTS (SELECT 1
                         FROM   employees
                         WHERE  employeeid = @StudiesCoordinatorID)
            BEGIN
                RAISERROR('Koordynator o podanym ID nie istnieje.',16,1);

                RETURN;
            END

          IF @NumberOfTerms <= 0
            BEGIN
                RAISERROR('Liczba semestrów musi być większa od zera.',16,1);

                RETURN;
            END

          IF @StudyPrice < 0
            BEGIN
                RAISERROR('Cena studiów nie może być ujemna.',16,1);

                RETURN;
            END

          INSERT INTO studies
                      (studyname,
                       studiescoordinatorid,
                       studyprice,
                       numberofterms)
          VALUES      (@StudyName,
                       @StudiesCoordinatorID,
                       @StudyPrice,
                       @NumberOfTerms);

          PRINT 'Studia zostały pomyślnie dodane.';
      END try

      BEGIN catch
          PRINT 'Wystąpił błąd podczas dodawania studiów.';

          PRINT Error_message();
      END catch
  END;

CREATE PROCEDURE Addnewcourse @CourseName          NVARCHAR(255),
                              @CourseCoordinatorID INT,
                              @CoursePrice         DECIMAL(10, 2),
                              @StudentLimit        INT
AS
  BEGIN
      BEGIN try
          IF NOT EXISTS (SELECT 1
                         FROM   employees
                         WHERE  employeeid = @CourseCoordinatorID)
            BEGIN
                RAISERROR('Koordynator kursu o podanym ID nie istnieje.',16,1);

                RETURN;
            END

          IF @StudentLimit <= 0
             AND @StudentLimit IS NOT NULL
            BEGIN
                RAISERROR(
                'Limit studentów musi być większy od zera lub NULL.',
                16,1
                );

                RETURN;
            END

          IF @CoursePrice < 0
            BEGIN
                RAISERROR('Cena kursu nie może być ujemna.',16,1);

                RETURN;
            END

          INSERT INTO courses
                      (coursename,
                       coursecoordinatorid,
                       courseprice,
                       studentlimit)
          VALUES      (@CourseName,
                       @CourseCoordinatorID,
                       @CoursePrice,
                       @StudentLimit);

          PRINT 'Kurs został pomyślnie dodany.';
      END try

      BEGIN catch
          PRINT 'Wystąpił błąd podczas dodawania kursu.';

          PRINT Error_message();
      END catch
  END;

CREATE PROCEDURE Addnewwebinar @WebinarName  NVARCHAR(255),
                               @StartDate    DATETIME,
                               @EndDate      DATETIME,
                               @TeacherID    INT,
                               @TranslatorID INT = NULL,
                               @LanguageID   INT,
                               @Price        DECIMAL(10, 2) = 0.0
AS
  BEGIN
      BEGIN try
          IF @StartDate >= @EndDate
            BEGIN
                RAISERROR(
      'Data rozpoczęcia musi być wcześniejsza niż data zakończenia.',16
      ,1);

      RETURN;
            END

          IF NOT EXISTS (SELECT 1
                         FROM   employees
                         WHERE  employeeid = @TeacherID)
            BEGIN
                RAISERROR('Nauczyciel o podanym ID nie istnieje.',16,1);

                RETURN;
            END

          IF @LanguageID NOT IN (SELECT languageid
                                 FROM   translatedlanguage)
            BEGIN
                THROW 67007, 'Language not available.', 1;
            END

          IF @TranslatorID IS NOT NULL
             AND NOT EXISTS (SELECT 1
                             FROM   employees
                             WHERE  employeeid = @TranslatorID)
            BEGIN
                RAISERROR('Tłumacz o podanym ID nie istnieje.',16,1);

                RETURN;
            END

          IF NOT EXISTS (SELECT 1
                         FROM   languages
                         WHERE  languageid = @LanguageID)
            BEGIN
                RAISERROR('Język o podanym ID nie istnieje.',16,1);

                RETURN;
            END

          IF @Price < 0
            BEGIN
                RAISERROR('Cena webinaru nie może być ujemna.',16,1);

                RETURN;
            END

          INSERT INTO webinars
                      (webinarname,
                       startdate,
                       enddate,
                       teacherid,
                       translatorid,
                       languageid,
                       price)
          VALUES      (@WebinarName,
                       @StartDate,
                       @EndDate,
                       @TeacherID,
                       @TranslatorID,
                       @LanguageID,
                       @Price);

          PRINT 'Webinar został pomyślnie dodany.';
      END try

      BEGIN catch
          PRINT 'Wystąpił błąd podczas dodawania webinaru.';

          PRINT Error_message();
      END catch
  END;

CREATE PROCEDURE Addnewsubject @SubjectName         NVARCHAR(255),
                               @NumberOfHoursInTerm INT,
                               @TeacherID           INT,
                               @StudiesID           INT
AS
  BEGIN
      BEGIN try
          IF @NumberOfHoursInTerm <= 0
             AND @NumberOfHoursInTerm > (SELECT numberofterms
                                         FROM   studies
                                         WHERE  studiesid = @StudiesID)
            BEGIN
                RAISERROR(
                'Liczba godzin w semestrze musi być większa od zera.',
                16,1
                );

                RETURN;
            END

          IF NOT EXISTS (SELECT 1
                         FROM   employees
                         WHERE  employeeid = @TeacherID)
            BEGIN
                RAISERROR('Nauczyciel o podanym ID nie istnieje.',16,1);

                RETURN;
            END

          IF NOT EXISTS (SELECT 1
                         FROM   studies
                         WHERE  studiesid = @StudiesID)
            BEGIN
                RAISERROR('Studia o podanym ID nie istnieją.',16,1);

                RETURN;
            END

          INSERT INTO subjects
                      (subjectname,
                       numberofhoursinterm,
                       teacherid,
                       studiesid)
          VALUES      (@SubjectName,
                       @NumberOfHoursInTerm,
                       @TeacherID,
                       @StudiesID);

          PRINT 'Przedmiot został pomyślnie dodany.';
      END try

      BEGIN catch
          PRINT 'Wystąpił błąd podczas dodawania przedmiotu.';

          PRINT Error_message();
      END catch
  END;

CREATE PROCEDURE Addcoursemodule @CourseID     INT,
                                 @ModuleName   NVARCHAR(255),
                                 @ModuleType   INT,
                                 @LecturerID   INT,
                                 @TranslatorID INT = NULL,
                                 @LanguageID   INT
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF @LanguageID NOT IN (SELECT languageid
                                 FROM   translatedlanguage)
            BEGIN
                THROW 67007, 'Language not available.', 1;
            END;

          IF NOT EXISTS (SELECT 1
                         FROM   formofactivity
                         WHERE  activitytypeid = @ModuleType)
            BEGIN
                THROW 50001, 'Nieprawidłowy typ modułu.', 1;
            END;

          INSERT INTO coursemodules
                      (courseid,
                       modulename,
                       moduletype,
                       lecturerid,
                       translatorid,
                       languageid)
          VALUES      (@CourseID,
                       @ModuleName,
                       @ModuleType,
                       @LecturerID,
                       @TranslatorID,
                       @LanguageID);

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          THROW;
      END catch
  END;

CREATE PROCEDURE Addcoursemeeting @ModuleID    INT,
                                  @MeetingType NVARCHAR(20),
                                  @StartDate   DATETIME,
                                  @EndDate     DATETIME,
                                  @RoomID      INT = NULL
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          DECLARE @ModuleType INT;

          SELECT @ModuleType = moduletype
          FROM   coursemodules
          WHERE  moduleid = @ModuleID;

          IF @ModuleType IS NULL
            BEGIN
                THROW 50001, 'Nie znaleziono modułu o podanym ModuleID.', 1;
            END;

          IF @StartDate >= @EndDate
            BEGIN
                THROW 50002,
      'Data rozpoczęcia musi być wcześniejsza niż data zakończenia.', 1
      ;
            END;

          IF @MeetingType = 'Stationary'
            BEGIN
                IF @ModuleType IN ( 1, 4 )
                  BEGIN
                      THROW 50003,
'Do modułu o typie innym niż Stacjonarny lub Hybrydowy nie można dodać spotkania Stacjonarnego.'
    , 1;
END;

    IF @RoomID IS NULL
      BEGIN
          THROW 50004, 'RoomID jest wymagany dla stacjonarnych spotkań.', 1;
      END;

    INSERT INTO stationarycoursemeeting
                (moduleid,
                 startdate,
                 enddate,
                 roomid)
    VALUES      (@ModuleID,
                 @StartDate,
                 @EndDate,
                 @RoomID);
END
ELSE IF @MeetingType = 'Online'
  BEGIN
      IF @ModuleType NOT IN ( 3, 4 )
        BEGIN
            THROW 50005,
'Do modułu o typie innym niż Online lub Hybrydowy nie można dodać spotkania Online.'
    , 1;
END;

    INSERT INTO onlinecoursemeeting
                (moduleid,
                 startdate,
                 enddate)
    VALUES      (@ModuleID,
                 @StartDate,
                 @EndDate);
END;
ELSE
  BEGIN
      THROW 50006,
      'Nieprawidłowy typ spotkania. Użyj "Stationary" lub "Online".', 1;
  END

    COMMIT TRANSACTION;
END try

    BEGIN catch
        ROLLBACK TRANSACTION;

        PRINT 'Wystąpił błąd.';

        PRINT Error_message();
    END catch
END;

CREATE PROCEDURE Addlanguage @LanguageName NVARCHAR(100)
AS
  BEGIN
      BEGIN try
          IF EXISTS (SELECT 1
                     FROM   languages
                     WHERE  languagename = @LanguageName)
            BEGIN
                PRINT 'Błąd: Język o podanej nazwie już istnieje.';

                RETURN;
            END

          INSERT INTO languages
                      (languagename)
          VALUES      (@LanguageName);

          PRINT 'Język został pomyślnie dodany.';
      END try

      BEGIN catch
          PRINT 'Wystąpił błąd podczas dodawania języka: '
                + Error_message();
      END catch
  END;

CREATE PROCEDURE Updatelanguage @LanguageID      INT,
                                @NewLanguageName NVARCHAR(100)
AS
  BEGIN
      BEGIN try
          IF NOT EXISTS (SELECT 1
                         FROM   languages
                         WHERE  languageid = @LanguageID)
            BEGIN
                PRINT 'Błąd: Język o podanym ID nie istnieje.';

                RETURN;
            END

          IF EXISTS (SELECT 1
                     FROM   languages
                     WHERE  languagename = @NewLanguageName)
            BEGIN
                PRINT 'Błąd: Język o podanej nowej nazwie już istnieje.';

                RETURN;
            END

          UPDATE languages
          SET    languagename = @NewLanguageName
          WHERE  languageid = @LanguageID;

          PRINT 'Nazwa języka została pomyślnie zaktualizowana.';
      END try

      BEGIN catch
          PRINT 'Wystąpił błąd podczas aktualizacji języka: '
                + Error_message();
      END catch
  END;

CREATE PROCEDURE Deletelanguagefromtranslatedlanguage @LanguageID INT
AS
  BEGIN
      IF EXISTS (SELECT 1
                 FROM   languages
                 WHERE  languageid = @LanguageID)
        BEGIN
            DELETE FROM translatedlanguage
            WHERE  languageid = @LanguageID;

            PRINT
'Rekordy w tabeli TranslatedLanguage zostały usunięte, ale język pozostaje w tabeli Languages.'
    ;
END
ELSE
  BEGIN
      PRINT 'Nie znaleziono języka o podanym LanguageID.';
  END
END;

CREATE PROCEDURE Addcountry @CountryName NVARCHAR(100)
AS
  BEGIN
      BEGIN try
          IF EXISTS (SELECT 1
                     FROM   countries
                     WHERE  countryname = @CountryName)
            BEGIN
                PRINT 'Błąd: Kraj o podanej nazwie już istnieje.';

                RETURN;
            END

          INSERT INTO countries
                      (countryname)
          VALUES      (@CountryName);

          PRINT 'Kraj został pomyślnie dodany.';
      END try

      BEGIN catch
          PRINT 'Wystąpił błąd podczas dodawania kraju: '
                + Error_message();
      END catch
  END;

CREATE PROCEDURE Updatecountry @CountryID      INT,
                               @NewCountryName NVARCHAR(100)
AS
  BEGIN
      BEGIN try
          IF NOT EXISTS (SELECT 1
                         FROM   countries
                         WHERE  countryid = @CountryID)
            BEGIN
                PRINT 'Błąd: Kraj o podanym ID nie istnieje.';

                RETURN;
            END

          IF EXISTS (SELECT 1
                     FROM   countries
                     WHERE  countryname = @NewCountryName)
            BEGIN
                PRINT 'Błąd: Kraj o podanej nowej nazwie już istnieje.';

                RETURN;
            END

          UPDATE countries
          SET    countryname = @NewCountryName
          WHERE  countryid = @CountryID;

          PRINT 'Nazwa kraju została pomyślnie zaktualizowana.';
      END try

      BEGIN catch
          PRINT 'Wystąpił błąd podczas aktualizacji kraju: '
                + Error_message();
      END catch
  END;

CREATE PROCEDURE Addcity @CityName   NVARCHAR(100),
                         @PostalCode NVARCHAR(6),
                         @CountryID  INT
AS
  BEGIN
      BEGIN try
          IF NOT EXISTS (SELECT 1
                         FROM   countries
                         WHERE  countryid = @CountryID)
            BEGIN
                PRINT 'Błąd: Kraj o podanym ID nie istnieje.';

                RETURN;
            END

          IF EXISTS (SELECT 1
                     FROM   cities
                     WHERE  cityname = @CityName
                            AND postalcode = @PostalCode
                            AND countryid = @CountryID)
            BEGIN
                PRINT
'Błąd: Miasto o podanej nazwie i kodzie pocztowym już istnieje w wybranym kraju.'
    ;

    RETURN;
END

    INSERT INTO cities
                (cityname,
                 postalcode,
                 countryid)
    VALUES      (@CityName,
                 @PostalCode,
                 @CountryID);

    PRINT 'Miasto zostało pomyślnie dodane.';
END try

    BEGIN catch
        PRINT 'Wystąpił błąd podczas dodawania miasta: '
              + Error_message();
    END catch
END;

CREATE PROCEDURE Updatecity @CityID        INT,
                            @NewCityName   NVARCHAR(100) = NULL,
                            @NewPostalCode NVARCHAR(20) = NULL
AS
  BEGIN
      IF EXISTS (SELECT 1
                 FROM   cities
                 WHERE  cityid = @CityID)
        BEGIN
            DECLARE @CountryID INT;

            SELECT @CountryID = countryid
            FROM   cities
            WHERE  cityid = @CityID;

            IF @NewCityName IS NOT NULL
               AND EXISTS (SELECT 1
                           FROM   cities
                           WHERE  cityname = @NewCityName
                                  AND countryid = @CountryID
                                  AND cityid <> @CityID)
              BEGIN
                  PRINT
'Miasto o tej nazwie już istnieje w wybranym kraju. Aktualizacja nie może zostać wykonana.'
    ;
END
ELSE
  BEGIN
      UPDATE cities
      SET    cityname = Isnull(@NewCityName, cityname),
             postalcode = Isnull(@NewPostalCode, postalcode)
      WHERE  cityid = @CityID;

      PRINT 'Dane miasta zostały zaktualizowane.';
  END
END
ELSE
  BEGIN
      PRINT 'Miasto o podanym CityID nie zostało znalezione.';
  END
END;

CREATE PROCEDURE Adduser @FirstName   NVARCHAR(40),
                         @LastName    NVARCHAR(40),
                         @Street      NVARCHAR(40),
                         @City        NVARCHAR(40),
                         @Email       NVARCHAR(40),
                         @Phone       NVARCHAR(40),
                         @DateOfBirth DATE
AS
  BEGIN
      BEGIN try
          DECLARE @CityID INT;

          SELECT @CityID = cityid
          FROM   cities
          WHERE  cityname = @City;

          IF @CityID IS NULL
            BEGIN
                THROW 50001, 'City does not exist in the Cities table.', 1;
            END;

          INSERT INTO users
                      (firstname,
                       lastname,
                       street,
                       cityid,
                       email,
                       phone,
                       dateofbirth)
          VALUES      (@FirstName,
                       @LastName,
                       @Street,
                       @CityID,
                       @Email,
                       @Phone,
                       @DateOfBirth);
      END try

      BEGIN catch
          PRINT 'Wystąpił błąd.';

          PRINT Error_message();
      END catch
  END;

CREATE PROCEDURE Addemployee @EmployeeID INT,
                             @HireDate   DATE,
                             @DegreeName NVARCHAR(50) = NULL,
                             @RoleName   NVARCHAR(50)
AS
  BEGIN
      BEGIN try
          IF NOT EXISTS (SELECT 1
                         FROM   users
                         WHERE  userid = @EmployeeID)
            BEGIN
                THROW 50002, 'User does not exist in the Users table.', 1;
            END;

          DECLARE @RoleID INT;

          SELECT @RoleID = roleid
          FROM   roles
          WHERE  rolename = @RoleName;

          IF @RoleID IS NULL
            BEGIN
                THROW 50005, 'Role does not exist in the Roles table.', 1;
            END;

          DECLARE @DegreeID INT = NULL;

          IF @DegreeName IS NOT NULL
            BEGIN
                SELECT @DegreeID = degreeid
                FROM   degrees
                WHERE  degreename = @DegreeName;

                IF @DegreeID IS NULL
                  BEGIN
                      THROW 50006, 'Degree does not exist in the Degrees table.'
                      ,
                      1;
                  END;
            END;

          INSERT INTO employees
                      (employeeid,
                       hiredate,
                       degreeid)
          VALUES      (@EmployeeID,
                       @HireDate,
                       @DegreeID);

          EXEC Adduserrole
            @UserID = @EmployeeID,
            @RoleID = @RoleID;
      END try

      BEGIN catch
          PRINT 'Wystąpił błąd.';

          PRINT Error_message();
      END catch
  END;

CREATE PROCEDURE Deleteuser @UserID INT
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF NOT EXISTS (SELECT 1
                         FROM   users
                         WHERE  userid = @UserID)
            BEGIN
                THROW 60001, 'User does not exist.', 1;
            END;

          IF EXISTS (SELECT 1
                     FROM   employees
                     WHERE  employeeid = @UserID)
            BEGIN
                DELETE FROM employees
                WHERE  employeeid = @UserID;
            END;

          DELETE FROM usersroles
          WHERE  userid = @UserID;

          DELETE FROM users
          WHERE  userid = @UserID;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          PRINT 'Wystąpił błąd.';

          PRINT Error_message();
      END catch
  END;

CREATE PROCEDURE Deletewebinar @WebinarID INT
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF NOT EXISTS (SELECT 1
                         FROM   webinars
                         WHERE  webinarid = @WebinarID)
            BEGIN
                THROW 60002, 'Webinar does not exist.', 1;
            END;

          DELETE FROM webinars
          WHERE  webinarid = @WebinarID;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          PRINT 'Wystąpił błąd.';

          PRINT Error_message();
      END catch
  END;

CREATE PROCEDURE Deletestudymeeting @MeetingID INT
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF NOT EXISTS (SELECT 1
                         FROM   studymeetings
                         WHERE  meetingid = @MeetingID)
            BEGIN
                THROW 60003, 'Study meeting does not exist.', 1;
            END;

          IF EXISTS (SELECT 1
                     FROM   stationarymeetings
                     WHERE  meetingid = @MeetingID)
            BEGIN
                DELETE FROM stationarymeetings
                WHERE  meetingid = @MeetingID;
            END;

          IF EXISTS (SELECT 1
                     FROM   onlinemeetings
                     WHERE  meetingid = @MeetingID)
            BEGIN
                DELETE FROM onlinemeetings
                WHERE  meetingid = @MeetingID;
            END;

          DELETE FROM studymeetings
          WHERE  meetingid = @MeetingID;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          PRINT 'Wystąpił błąd.';

          PRINT Error_message();
      END catch
  END;

CREATE PROCEDURE Deletesubject @SubjectID INT
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF NOT EXISTS (SELECT 1
                         FROM   subjects
                         WHERE  subjectid = @SubjectID)
            BEGIN
                THROW 60004, 'Subject does not exist.', 1;
            END;

          DECLARE @MeetingID INT;
          DECLARE meetingcursor CURSOR FOR
            SELECT meetingid
            FROM   studymeetings
            WHERE  subjectid = @SubjectID;

          OPEN meetingcursor;

          FETCH next FROM meetingcursor INTO @MeetingID;

          WHILE @@FETCH_STATUS = 0
            BEGIN
                DELETE FROM stationarymeetings
                WHERE  meetingid = @MeetingID;

                DELETE FROM onlinemeetings
                WHERE  meetingid = @MeetingID;

                DELETE FROM studymeetings
                WHERE  meetingid = @MeetingID;

                FETCH next FROM meetingcursor INTO @MeetingID;
            END;

          CLOSE meetingcursor;

          DEALLOCATE meetingcursor;

          DELETE FROM subjects
          WHERE  subjectid = @SubjectID;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          THROW;
      END catch
  END;

CREATE PROCEDURE Deletestudy @StudyID INT
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF NOT EXISTS (SELECT 1
                         FROM   studies
                         WHERE  studiesid = @StudyID)
            BEGIN
                THROW 60005, 'Study does not exist.', 1;
            END;

          DECLARE @SubjectID INT;
          DECLARE subjectcursor CURSOR FOR
            SELECT subjectid
            FROM   subjects
            WHERE  studiesid = @StudyID;

          OPEN subjectcursor;

          FETCH next FROM subjectcursor INTO @SubjectID;

          WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC Deletesubject
                  @SubjectID = @SubjectID;

                FETCH next FROM subjectcursor INTO @SubjectID;
            END;

          CLOSE subjectcursor;

          DEALLOCATE subjectcursor;

          DELETE FROM studies
          WHERE  studiesid = @StudyID;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          THROW;
      END catch
  END;

CREATE PROCEDURE Deletecoursemeeting @MeetingID INT
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          DELETE FROM onlinecoursemeeting
          WHERE  meetingid = @MeetingID;

          DELETE FROM stationarycoursemeeting
          WHERE  meetingid = @MeetingID;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          THROW;
      END catch
  END;

CREATE PROCEDURE Deletecoursemodule @ModuleID INT
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          DELETE FROM coursemodules
          WHERE  moduleid = @ModuleID;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          THROW;
      END catch
  END;

CREATE PROCEDURE Deletecourse @CourseID INT
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF NOT EXISTS (SELECT 1
                         FROM   courses
                         WHERE  courseid = @CourseID)
            BEGIN
                THROW 60008, 'Course does not exist.', 1;
            END;

          DECLARE @ModuleID INT;
          DECLARE modulecursor CURSOR FOR
            SELECT moduleid
            FROM   coursemodules
            WHERE  courseid = @CourseID;

          OPEN modulecursor;

          FETCH next FROM modulecursor INTO @ModuleID;

          WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC Deletecoursemodule
                  @ModuleID = @ModuleID;

                FETCH next FROM modulecursor INTO @ModuleID;
            END;

          CLOSE modulecursor;

          DEALLOCATE modulecursor;

          DELETE FROM courses
          WHERE  courseid = @CourseID;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          THROW;
      END catch
  END;

CREATE PROCEDURE Deleteemployee @EmployeeID INT
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF NOT EXISTS (SELECT 1
                         FROM   employees
                         WHERE  employeeid = @EmployeeID)
            BEGIN
                THROW 60009, 'Employee does not exist.', 1;
            END;

          DECLARE @UserID INT;

          SELECT @UserID = employeeid
          FROM   employees
          WHERE  employeeid = @EmployeeID;

          DELETE FROM usersroles
          WHERE  userid = @UserID
                 AND roleid != 1;

          DELETE FROM employees
          WHERE  employeeid = @EmployeeID;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          THROW;
      END catch
  END;

CREATE PROCEDURE Updateuser @UserID      INT,
                            @FirstName   VARCHAR(40),
                            @LastName    VARCHAR(40),
                            @Street      VARCHAR(40),
                            @City        VARCHAR(40),
                            @Email       VARCHAR(40),
                            @Phone       VARCHAR(40),
                            @DateOfBirth DATE
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF NOT EXISTS (SELECT 1
                         FROM   users
                         WHERE  userid = @UserID)
            BEGIN
                THROW 60010, 'User does not exist.', 1;
            END;

          IF NOT EXISTS (SELECT 1
                         FROM   cities
                         WHERE  cityname = @City)
            BEGIN
                THROW 60011, 'City does not exist.', 1;
            END;

          UPDATE users
          SET    firstname = @FirstName,
                 lastname = @LastName,
                 street = @Street,
                 cityid = (SELECT cityid
                           FROM   cities
                           WHERE  cityname = @City),
                 email = @Email,
                 phone = @Phone,
                 dateofbirth = @DateOfBirth
          WHERE  userid = @UserID;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          THROW;
      END catch
  END;

CREATE PROCEDURE Updateemployee @EmployeeID INT,
                                @HireDate   DATE,
                                @DegreeName VARCHAR(50) = NULL
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF NOT EXISTS (SELECT 1
                         FROM   employees
                         WHERE  employeeid = @EmployeeID)
            BEGIN
                THROW 60012, 'Employee does not exist.', 1;
            END;

          DECLARE @DegreeID INT = NULL;

          IF @DegreeName IS NOT NULL
            BEGIN
                SELECT @DegreeID = degreeid
                FROM   degrees
                WHERE  degreename = @DegreeName;

                IF @DegreeID IS NULL
                  BEGIN
                      THROW 60013, 'Degree does not exist.', 1;
                  END;
            END;

          UPDATE employees
          SET    hiredate = @HireDate,
                 degreeid = @DegreeID
          WHERE  employeeid = @EmployeeID;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          THROW;
      END catch
  END;

CREATE PROCEDURE Updatecourse @CourseID            INT,
                              @CourseName          VARCHAR(40),
                              @CourseCoordinatorID INT,
                              @CourseDescription   VARCHAR(255),
                              @CoursePrice         MONEY,
                              @StudentLimit        INT = NULL
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF NOT EXISTS (SELECT 1
                         FROM   courses
                         WHERE  courseid = @CourseID)
            BEGIN
                THROW 61001, 'Course does not exist.', 1;
            END;

          IF NOT EXISTS (SELECT 1
                         FROM   employees E
                                JOIN usersroles UR
                                  ON E.employeeid = UR.userid
                         WHERE  E.employeeid = @CourseCoordinatorID
                                AND UR.roleid = 3)
            BEGIN
                THROW 61002,
      'CourseCoordinatorID is not valid or does not have the required role.'
      , 1;
            END;

          UPDATE courses
          SET    coursename = @CourseName,
                 coursecoordinatorid = @CourseCoordinatorID,
                 coursedescription = @CourseDescription,
                 courseprice = @CoursePrice,
                 studentlimit = @StudentLimit
          WHERE  courseid = @CourseID;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          THROW;
      END catch
  END;

CREATE PROCEDURE Updatewebinar @WebinarID          INT,
                               @WebinarName        VARCHAR(40),
                               @WebinarDescription VARCHAR(255),
                               @TeacherID          INT,
                               @Price              MONEY,
                               @LanguageID         INT,
                               @TranslatorID       INT = NULL,
                               @StartDate          DATETIME,
                               @EndDate            DATETIME,
                               @VideoLink          VARCHAR(255) = NULL,
                               @MeetingLink        VARCHAR(255) = NULL
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF NOT EXISTS (SELECT 1
                         FROM   webinars
                         WHERE  webinarid = @WebinarID)
            BEGIN
                THROW 62001, 'Webinar does not exist.', 1;
            END;

          IF NOT EXISTS (SELECT 1
                         FROM   usersroles
                         WHERE  userid = @TeacherID
                                AND roleid = 8)
            BEGIN
                THROW 62002,
      'Invalid TeacherID. The user is not assigned as a webinar lecturer.',
      1;
            END;

          IF @LanguageID NOT IN (SELECT languageid
                                 FROM   translatedlanguage)
            BEGIN
                THROW 67007, 'Language not available.', 1;
            END;

          IF @TranslatorID IS NOT NULL
             AND NOT EXISTS (SELECT 1
                             FROM   usersroles
                             WHERE  userid = @TranslatorID
                                    AND roleid = 2)
            BEGIN
                THROW 62003,
      'Invalid TranslatorID. The user is not assigned as a translator.',
      1;
            END;

          UPDATE webinars
          SET    webinarname = @WebinarName,
                 webinardescription = @WebinarDescription,
                 teacherid = @TeacherID,
                 price = @Price,
                 languageid = @LanguageID,
                 translatorid = @TranslatorID,
                 startdate = @StartDate,
                 enddate = @EndDate,
                 videolink = @VideoLink,
                 meetinglink = @MeetingLink
          WHERE  webinarid = @WebinarID;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          THROW;
      END catch;
  END;

go

CREATE PROCEDURE Updatecoursemodule @ModuleID     INT,
                                    @CourseID     INT,
                                    @ModuleName   VARCHAR(255),
                                    @ModuleType   INT,
                                    @LecturerID   INT,
                                    @LanguageID   INT,
                                    @TranslatorID INT = NULL
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF NOT EXISTS (SELECT 1
                         FROM   coursemodules
                         WHERE  moduleid = @ModuleID)
            BEGIN
                THROW 63001, 'Module does not exist.', 1;
            END;

          IF NOT EXISTS (SELECT 1
                         FROM   usersroles
                         WHERE  userid = @LecturerID
                                AND roleid = 6)
            BEGIN
                THROW 63002,
                'Invalid LecturerID. The user is not assigned as a lecturer.'
                ,
                1;
            END;

          IF @LanguageID NOT IN (SELECT languageid
                                 FROM   translatedlanguage)
            BEGIN
                THROW 67007, 'Language not available.', 1;
            END;

          IF @TranslatorID IS NOT NULL
             AND NOT EXISTS (SELECT 1
                             FROM   usersroles
                             WHERE  userid = @TranslatorID
                                    AND roleid = 2)
            BEGIN
                THROW 63003,
      'Invalid TranslatorID. The user is not assigned as a translator.',
      1;
            END;

          IF @ModuleType = 1
             AND EXISTS (SELECT 1
                         FROM   onlinecoursemeeting
                         WHERE  moduleid = @ModuleID)
            BEGIN
                THROW 63004,
'Cannot change module type to Stationary. Online meetings exist for this module.'
    , 1;
END;

    IF @ModuleType = 3
       AND EXISTS (SELECT 1
                   FROM   stationarycoursemeeting
                   WHERE  moduleid = @ModuleID)
      BEGIN
          THROW 63005,
'Cannot change module type to Online. Stationary meetings exist for this module.'
    , 1;
END;

    UPDATE coursemodules
    SET    courseid = @CourseID,
           modulename = @ModuleName,
           moduletype = @ModuleType,
           lecturerid = @LecturerID,
           languageid = @LanguageID,
           translatorid = @TranslatorID
    WHERE  moduleid = @ModuleID;

    COMMIT TRANSACTION;
END try

    BEGIN catch
        ROLLBACK TRANSACTION;

        THROW;
    END catch;
END;

go

CREATE PROCEDURE Updatecoursemodulemeeting @MeetingID      INT,
                                           @ModuleID       INT,
                                           @MeetingType    INT,
                                           @StartDateTime  DATETIME,
                                           @EndDateTime    DATETIME,
                                           @LocationOrLink VARCHAR(255)
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF NOT EXISTS (SELECT 1
                         FROM   coursemodules
                         WHERE  moduleid = @ModuleID)
            BEGIN
                THROW 64001, 'Module does not exist.', 1;
            END;

          DECLARE @ModuleType INT;

          SELECT @ModuleType = moduletype
          FROM   coursemodules
          WHERE  moduleid = @ModuleID;

          IF @MeetingType = 1
             AND @ModuleType NOT IN ( 1, 4 )
            BEGIN
                THROW 64002,
                'Cannot add a stationary meeting to a non-stationary module.'
                ,
                1;
            END;

          IF @MeetingType = 2
             AND @ModuleType NOT IN ( 3, 4 )
            BEGIN
                THROW 64003,
                'Cannot add an online meeting to a non-online module.', 1
                ;
            END;

          IF @MeetingType = 1
             AND NOT EXISTS (SELECT 1
                             FROM   stationarycoursemeeting
                             WHERE  meetingid = @MeetingID
                                    AND moduleid = @ModuleID)
            BEGIN
                THROW 64004,
                'Stationary meeting does not exist for the specified module.'
                ,
                1;
            END;

          IF @MeetingType = 2
             AND NOT EXISTS (SELECT 1
                             FROM   onlinecoursemeeting
                             WHERE  meetingid = @MeetingID
                                    AND moduleid = @ModuleID)
            BEGIN
                THROW 64005,
                'Online meeting does not exist for the specified module.'
                , 1;
            END;

          IF @MeetingType = 1
            BEGIN
                UPDATE stationarycoursemeeting
                SET    startdate = @StartDateTime,
                       enddate = @EndDateTime
                WHERE  meetingid = @MeetingID
                       AND moduleid = @ModuleID;
            END
          ELSE IF @MeetingType = 2
            BEGIN
                UPDATE onlinecoursemeeting
                SET    startdate = @StartDateTime,
                       enddate = @EndDateTime,
                       meetinglink = @LocationOrLink
                WHERE  meetingid = @MeetingID
                       AND moduleid = @ModuleID;
            END;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          THROW;
      END catch;
  END;

go

CREATE PROCEDURE Updatestudies @StudiesID            INT,
                               @StudiesCoordinatorID INT,
                               @StudyName            VARCHAR(40),
                               @StudyPrice           MONEY,
                               @StudyDescription     VARCHAR(255),
                               @NumberOfTerms        INT,
                               @StudentLimit         INT
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF NOT EXISTS (SELECT 1
                         FROM   studies
                         WHERE  studiesid = @StudiesID)
            BEGIN
                THROW 65001, 'Studies with the specified ID do not exist.', 1;
            END;

          IF NOT EXISTS (SELECT 1
                         FROM   employees
                         WHERE  employeeid = @StudiesCoordinatorID)
            BEGIN
                THROW 65002, 'The specified coordinator does not exist.', 1;
            END;

          IF NOT EXISTS (SELECT 1
                         FROM   usersroles
                         WHERE  userid = (SELECT userid
                                          FROM   employees
                                          WHERE
                                employeeid = @StudiesCoordinatorID)
                                AND roleid = 4)
            BEGIN
                THROW 65003,
'The specified coordinator does not have the required role (Coordinator of Studies).'
    , 1;
END;

    UPDATE studies
    SET    studiescoordinatorid = @StudiesCoordinatorID,
           studyname = @StudyName,
           studyprice = @StudyPrice,
           studydescription = @StudyDescription,
           numberofterms = @NumberOfTerms,
           studentlimit = @StudentLimit
    WHERE  studiesid = @StudiesID;

    COMMIT TRANSACTION;
END try

    BEGIN catch
        ROLLBACK TRANSACTION;

        THROW;
    END catch;
END;

go

CREATE PROCEDURE Updatesubject @SubjectID          INT,
                               @StudiesID          INT,
                               @SubjectName        VARCHAR(40),
                               @SubjectDescription VARCHAR(255),
                               @LecturerID         INT
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF NOT EXISTS (SELECT 1
                         FROM   subjects
                         WHERE  subjectid = @SubjectID)
            BEGIN
                THROW 66001, 'Subject with the specified ID does not exist.', 1;
            END;

          IF NOT EXISTS (SELECT 1
                         FROM   studies
                         WHERE  studiesid = @StudiesID)
            BEGIN
                THROW 66002, 'Studies with the specified ID do not exist.', 1;
            END;

          IF NOT EXISTS (SELECT 1
                         FROM   employees
                         WHERE  employeeid = @LecturerID)
            BEGIN
                THROW 66003, 'The specified lecturer does not exist.', 1;
            END;

          IF NOT EXISTS (SELECT 1
                         FROM   usersroles
                         WHERE  userid = (SELECT userid
                                          FROM   employees
                                          WHERE  employeeid = @LecturerID)
                                AND roleid = 6)
            BEGIN
                THROW 66004,
      'The specified lecturer does not have the required role (Lecturer).',
      1;
            END

          UPDATE subjects
          SET    studiesid = @StudiesID,
                 subjectname = @SubjectName,
                 subjectdescription = @SubjectDescription,
                 teacherid = @LecturerID
          WHERE  subjectid = @SubjectID;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          THROW;
      END catch;
  END;

go

CREATE PROCEDURE Updatestudymeeting @MeetingID             INT,
                                    @MeetingType           INT,
                                    @SubjectID             INT,
                                    @LecturerID            INT,
                                    @MeetingPrice          MONEY,
                                    @MeetingPriceForOthers MONEY,
                                    @StartTime             DATETIME,
                                    @EndTime               DATETIME,
                                    @LanguageID            INT,
                                    @TranslatorID          INT = NULL,
                                    @MeetingLink           VARCHAR(255) = NULL,
                                    @StudentLimit          INT,
                                    @RoomID                INT = NULL
AS
  BEGIN
      BEGIN try
          BEGIN TRANSACTION;

          IF NOT EXISTS (SELECT 1
                         FROM   studymeetings
                         WHERE  meetingid = @MeetingID)
            BEGIN
                THROW 67001,
                'Study meeting with the specified ID does not exist.'
                , 1;
            END;

          IF @MeetingType NOT IN ( 1, 2 )
            BEGIN
                THROW 67002,
                'Invalid MeetingType. Must be 1 (Stationary) or 2 (Online).',
                1
                ;
            END;

          IF @LanguageID NOT IN (SELECT languageid
                                 FROM   translatedlanguage)
            BEGIN
                THROW 67007, 'Language not available.', 1;
            END;

          UPDATE studymeetings
          SET    subjectid = @SubjectID,
                 lecturerid = @LecturerID,
                 meetingtype = @MeetingType,
                 meetingprice = @MeetingPrice,
                 meetingpriceforothers = @MeetingPriceForOthers,
                 starttime = @StartTime,
                 endtime = @EndTime,
                 languageid = @LanguageID,
                 translatorid = @TranslatorID
          WHERE  meetingid = @MeetingID;

          IF @MeetingType = 1
            BEGIN
                IF @RoomID IS NULL
                  BEGIN
                      THROW 67003,
                      'RoomID must be provided for stationary meetings.',
                      1;
                  END;

                DELETE FROM onlinemeetings
                WHERE  meetingid = @MeetingID;

                IF EXISTS (SELECT 1
                           FROM   stationarymeetings
                           WHERE  meetingid = @MeetingID)
                  BEGIN
                      UPDATE stationarymeetings
                      SET    roomid = @RoomID,
                             studentlimit = @StudentLimit
                      WHERE  meetingid = @MeetingID;
                  END
                ELSE
                  BEGIN
                      INSERT INTO stationarymeetings
                                  (meetingid,
                                   roomid,
                                   studentlimit)
                      VALUES      (@MeetingID,
                                   @RoomID,
                                   @StudentLimit);
                  END;
            END
          ELSE IF @MeetingType = 2
            BEGIN
                IF @MeetingLink IS NULL
                  BEGIN
                      THROW 67004,
                      'MeetingLink must be provided for online meetings.'
                      , 1;
                  END;

                DELETE FROM stationarymeetings
                WHERE  meetingid = @MeetingID;

                IF EXISTS (SELECT 1
                           FROM   onlinemeetings
                           WHERE  meetingid = @MeetingID)
                  BEGIN
                      UPDATE onlinemeetings
                      SET    meetinglink = @MeetingLink,
                             studentlimit = @StudentLimit
                      WHERE  meetingid = @MeetingID;
                  END
                ELSE
                  BEGIN
                      INSERT INTO onlinemeetings
                                  (meetingid,
                                   meetinglink,
                                   studentlimit)
                      VALUES      (@MeetingID,
                                   @MeetingLink,
                                   @StudentLimit);
                  END;
            END;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          THROW;
      END catch;
  END;

go

CREATE PROCEDURE Adduserwithroleandemployee (@FirstName   VARCHAR(40),
                                             @LastName    VARCHAR(40),
                                             @Street      VARCHAR(40),
                                             @CityName    VARCHAR(40),
                                             @Email       VARCHAR(40),
                                             @Phone       VARCHAR(40),
                                             @DateOfBirth DATE,
                                             @RoleName    VARCHAR(40),
                                             @HireDate    DATE = NULL,
                                             @DegreeName  VARCHAR(255) = NULL)
AS
  BEGIN
      SET nocount ON;

      BEGIN try
          BEGIN TRANSACTION;

          DECLARE @CityID INT;

          SELECT @CityID = cityid
          FROM   cities
          WHERE  cityname = @CityName;

          IF @CityID IS NULL
            BEGIN
                THROW 50000, 'Podane miasto nie istnieje w tabeli Cities.', 1;
            END;

          IF EXISTS (SELECT 1
                     FROM   users
                     WHERE  email = @Email)
            BEGIN
                THROW 50003, 'Podany adres e-mail już istnieje w tabeli Users.'
                ,
                1;
            END;

          DECLARE @UserID INT;

          INSERT INTO users
                      (firstname,
                       lastname,
                       street,
                       cityid,
                       email,
                       phone,
                       dateofbirth)
          VALUES      (@FirstName,
                       @LastName,
                       @Street,
                       @CityID,
                       @Email,
                       @Phone,
                       @DateOfBirth);

          SET @UserID = Scope_identity();

          DECLARE @RoleID INT;

          SELECT @RoleID = roleid
          FROM   roles
          WHERE  rolename = @RoleName;

          IF @RoleID IS NULL
            BEGIN
                THROW 50001, 'Podana rola nie istnieje w tabeli Roles.', 1;
            END;

          EXEC Adduserrole
            @UserID,
            @RoleID;

          IF @RoleID <> 1
            BEGIN
                DECLARE @DegreeID INT = NULL;

                IF @DegreeName IS NOT NULL
      BEGIN
          SELECT @DegreeID = degreeid
          FROM   degrees
          WHERE  degreename = @DegreeName;

          IF @DegreeID IS NULL
            BEGIN
                THROW 50002,
                'Podany stopień naukowy nie istnieje w tabeli Degrees.',
                1;
            END;
      END;

                INSERT INTO employees
                            (employeeid,
                             hiredate,
                             degreeid)
                VALUES      (@UserID,
                             @HireDate,
                             @DegreeID);
            END;

          COMMIT TRANSACTION;
      END try

      BEGIN catch
          ROLLBACK TRANSACTION;

          THROW;
      END catch;
  END;

go

CREATE PROCEDURE Addtranslatedlanguage @TranslatorID INT,
                                       @LanguageID   INT
AS
  BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM   usersroles
                     WHERE  userid = @TranslatorID
                            AND roleid = 2)
        BEGIN
            PRINT 'Użytkownik nie jest tłumaczem.';

            RETURN;
        END;

      IF NOT EXISTS (SELECT 1
                     FROM   languages
                     WHERE  languageid = @LanguageID)
        BEGIN
            PRINT 'Podany język nie istnieje.';

            RETURN;
        END;

      IF EXISTS (SELECT 1
                 FROM   translatedlanguage
                 WHERE  translatorid = @TranslatorID
                        AND languageid = @LanguageID)
        BEGIN
            PRINT 'Rekord już istnieje.';

            RETURN;
        END;

      INSERT INTO translatedlanguage
                  (translatorid,
                   languageid)
      VALUES      (@TranslatorID,
                   @LanguageID);

      PRINT 'Rekord został dodany.';
  END;

CREATE PROCEDURE Updatetranslatedlanguage @OldTranslatorID INT,
                                          @OldLanguageID   INT,
                                          @NewTranslatorID INT,
                                          @NewLanguageID   INT
AS
  BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM   translatedlanguage
                     WHERE  translatorid = @OldTranslatorID
                            AND languageid = @OldLanguageID)
        BEGIN
            PRINT 'Rekord do modyfikacji nie istnieje.';

            RETURN;
        END;

      IF NOT EXISTS (SELECT 1
                     FROM   usersroles
                     WHERE  userid = @NewTranslatorID
                            AND roleid = 2)
        BEGIN
            PRINT 'Nowy tłumacz nie ma odpowiedniej roli.';

            RETURN;
        END;

      IF NOT EXISTS (SELECT 1
                     FROM   languages
                     WHERE  languageid = @NewLanguageID)
        BEGIN
            PRINT 'Podany język nie istnieje.';

            RETURN;
        END;

      IF EXISTS (SELECT 1
                 FROM   translatedlanguage
                 WHERE  translatorid = @NewTranslatorID
                        AND languageid = @NewLanguageID)
        BEGIN
            PRINT 'Nowy rekord już istnieje.';

            RETURN;
        END;

      UPDATE translatedlanguage
      SET    translatorid = @NewTranslatorID,
             languageid = @NewLanguageID
      WHERE  translatorid = @OldTranslatorID
             AND languageid = @OldLanguageID;

      PRINT 'Rekord został zaktualizowany.';
  END;

CREATE PROCEDURE Deletetranslatedlanguage @TranslatorID INT,
                                          @LanguageID   INT
AS
  BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM   translatedlanguage
                     WHERE  translatorid = @TranslatorID
                            AND languageid = @LanguageID)
        BEGIN
            PRINT 'Rekord do usunięcia nie istnieje.';

            RETURN;
        END;

      DELETE FROM translatedlanguage
      WHERE  translatorid = @TranslatorID
             AND languageid = @LanguageID;

      PRINT 'Rekord został usunięty.';
  END;

CREATE PROCEDURE Addroom @RoomName NVARCHAR(100),
                         @Street   NVARCHAR(100),
                         @CityID   INT,
                         @Limit    INT
AS
  BEGIN
      IF EXISTS (SELECT 1
                 FROM   rooms
                 WHERE  roomname = @RoomName
                        AND cityid = @CityID)
        BEGIN
            PRINT 'Sala o podanej nazwie już istnieje w tym mieście.';

            RETURN;
        END;

      IF @Limit <= 0
        BEGIN
            PRINT 'Limit osób musi być większy niż 0.';

            RETURN;
        END;

      INSERT INTO rooms
                  (roomname,
                   street,
                   cityid,
                   limit)
      VALUES      (@RoomName,
                   @Street,
                   @CityID,
                   @Limit);

      PRINT 'Sala została dodana.';
  END;

CREATE PROCEDURE Updateroom @OldRoomID   INT,
                            @NewRoomName NVARCHAR(100)
AS
  BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM   rooms
                     WHERE  roomid = @OldRoomID)
        BEGIN
            PRINT 'Sala do modyfikacji nie istnieje.';

            RETURN;
        END;

      IF EXISTS (SELECT 1
                 FROM   rooms
                 WHERE  roomname = @NewRoomName
                        AND roomid != @OldRoomID)
        BEGIN
            PRINT 'Sala o podanej nazwie już istnieje w tym mieście.';

            RETURN;
        END;

      UPDATE rooms
      SET    roomname = @NewRoomName
      WHERE  roomid = @OldRoomID;

      PRINT 'Sala została zaktualizowana.';
  END;

CREATE PROCEDURE Addinternship @StudiesID               INT,
                               @InternshipCoordinatorID INT,
                               @StartDate               DATE,
                               @EndDate                 DATE,
                               @NumberOfHours           INT,
                               @Term                    INT
AS
  BEGIN
      DECLARE @NumberOfTerms INT;

      SELECT @NumberOfTerms = numberofterms
      FROM   studies
      WHERE  studiesid = @StudiesID;

      IF @Term < 1
          OR @Term > @NumberOfTerms
        BEGIN
            PRINT 'Invalid Term for the given Studies.';

            RETURN;
        END

      IF EXISTS (SELECT 1
                 FROM   internship
                 WHERE  studiesid = @StudiesID
                        AND term = @Term)
        BEGIN
            PRINT
        'There is already an internship for this term of these studies.'
            ;

            RETURN;
        END

      IF Datediff(day, @StartDate, @EndDate) <> 14
        BEGIN
            PRINT 'Internship must last exactly 14 days.';

            RETURN;
        END

      IF NOT EXISTS (SELECT 1
                     FROM   usersroles
                     WHERE  userid = @InternshipCoordinatorID
                            AND roleid = 4)
        BEGIN
            PRINT 'The specified user is not a coordinator for internships.';

            RETURN;
        END

      IF EXISTS (SELECT 1
                 FROM   studymeetings SM
                        INNER JOIN subjects S
                                ON SM.subjectid = S.subjectid
                 WHERE  S.studiesid = @StudiesID
                        AND ( ( @StartDate BETWEEN SM.starttime AND SM.endtime )
                               OR ( @EndDate BETWEEN SM.starttime AND
                            SM.endtime ) ))
        BEGIN
            PRINT
        'Internship overlaps with a study meeting for the given studies.';

            RETURN;
        END

      INSERT INTO internship
                  (studiesid,
                   internshipcoordinatorid,
                   startdate,
                   enddate,
                   numerofhours,
                   term)
      VALUES      (@StudiesID,
                   @InternshipCoordinatorID,
                   @StartDate,
                   @EndDate,
                   @NumberOfHours,
                   @Term);

      PRINT 'Internship added successfully.';
  END;

CREATE PROCEDURE Updateinternship @InternshipID            INT,
                                  @StudiesID               INT,
                                  @InternshipCoordinatorID INT,
                                  @StartDate               DATE,
                                  @EndDate                 DATE,
                                  @NumberOfHours           INT,
                                  @Term                    INT
AS
  BEGIN
      DECLARE @NumberOfTerms INT;

      SELECT @NumberOfTerms = numberofterms
      FROM   studies
      WHERE  studiesid = @StudiesID;

      IF @Term < 1
          OR @Term > @NumberOfTerms
        BEGIN
            PRINT 'Invalid Term for the given Studies.';

            RETURN;
        END

      IF EXISTS (SELECT 1
                 FROM   internship
                 WHERE  studiesid = @StudiesID
                        AND term = @Term
                        AND internshipid != @InternshipID)
        BEGIN
            PRINT
        'There is already an internship for this term of these studies.'
            ;

            RETURN;
        END

      IF Datediff(day, @StartDate, @EndDate) <> 14
        BEGIN
            PRINT 'Internship must last exactly 14 days.';

            RETURN;
        END

      IF NOT EXISTS (SELECT 1
                     FROM   usersroles
                     WHERE  userid = @InternshipCoordinatorID
                            AND roleid = 4)
        BEGIN
            PRINT 'The specified user is not a coordinator for internships.';

            RETURN;
        END

      IF EXISTS (SELECT 1
                 FROM   studymeetings SM
                        INNER JOIN subjects S
                                ON SM.subjectid = S.subjectid
                 WHERE  S.studiesid = @StudiesID
                        AND ( ( @StartDate BETWEEN SM.starttime AND SM.endtime )
                               OR ( @EndDate BETWEEN SM.starttime AND
                            SM.endtime ) ))
        BEGIN
            PRINT
        'Internship overlaps with a study meeting for the given studies.';

            RETURN;
        END;

      UPDATE internship
      SET    studiesid = @StudiesID,
             internshipcoordinatorid = @InternshipCoordinatorID,
             startdate = @StartDate,
             enddate = @EndDate,
             numerofhours = @NumberOfHours,
             term = @Term
      WHERE  internshipid = @InternshipID;

      PRINT 'Internship updated successfully.';
  END;

CREATE PROCEDURE Deleteinternship @InternshipID INT
AS
  BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM   internship
                     WHERE  internshipid = @InternshipID)
        BEGIN
            PRINT 'Internship not found.';

            RETURN;
        END

      DELETE FROM internship
      WHERE  internshipid = @InternshipID;

      PRINT 'Internship deleted successfully.';
  END;

CREATE PROCEDURE Addcoursemodulepassed @ModuleID  INT,
                                       @StudentID INT,
                                       @Passed    BIT
AS
  BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM   coursemodules
                     WHERE  moduleid = @ModuleID)
        BEGIN
            PRINT 'Moduł o podanym ID nie istnieje.'

            RETURN
        END

      IF NOT EXISTS (SELECT 1
                     FROM   usersroles
                     WHERE  roleid = 1
                            AND userid = @StudentID)
        BEGIN
            PRINT 'Student o podanym ID nie istnieje.'

            RETURN
        END

      IF NOT EXISTS (SELECT 1
                     FROM   orders O
                            JOIN orderdetails OD
                              ON O.orderid = OD.orderid
                     WHERE  O.studentid = @StudentID
                            AND OD.typeofactivity = 2
                            AND OD.activityid IN (SELECT courseid
                                                  FROM   courses
                                                  WHERE
                                courseid = OD.activityid)
                            AND EXISTS (SELECT 1
                                        FROM   coursemodules CM
                                        WHERE  CM.courseid = OD.activityid
                                               AND CM.moduleid = @ModuleID))
        BEGIN
            PRINT
        'Student nie jest zapisany na kurs lub nie ma dostępu do tego modułu.'

            RETURN
        END

      IF EXISTS (SELECT 1
                 FROM   coursemodulespassed
                 WHERE  moduleid = @ModuleID
                        AND studentid = @StudentID)
        BEGIN
            PRINT 'Rekord już istnieje dla tego studenta i modułu.'

            RETURN
        END

      INSERT INTO coursemodulespassed
                  (moduleid,
                   studentid,
                   passed)
      VALUES      (@ModuleID,
                   @StudentID,
                   @Passed)

      PRINT 'Rekord został pomyślnie dodany.'
  END

CREATE PROCEDURE Updatecoursemodulepassed @ModuleID  INT,
                                          @StudentID INT,
                                          @Passed    BIT
AS
  BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM   orders O
                            JOIN orderdetails OD
                              ON O.orderid = OD.orderid
                     WHERE  O.studentid = @StudentID
                            AND OD.typeofactivity = 2
                            AND OD.activityid IN (SELECT courseid
                                                  FROM   courses
                                                  WHERE
                                courseid = OD.activityid)
                            AND EXISTS (SELECT 1
                                        FROM   coursemodules CM
                                        WHERE  CM.courseid = OD.activityid
                                               AND CM.moduleid = @ModuleID))
        BEGIN
            PRINT
        'Student nie jest zapisany na kurs lub nie ma dostępu do tego modułu.'

            RETURN
        END

      IF NOT EXISTS (SELECT 1
                     FROM   coursemodulespassed
                     WHERE  moduleid = @ModuleID
                            AND studentid = @StudentID)
        BEGIN
            PRINT 'Rekord do modyfikacji nie istnieje.'

            RETURN
        END

      UPDATE coursemodulespassed
      SET    passed = @Passed
      WHERE  moduleid = @ModuleID
             AND studentid = @StudentID

      PRINT 'Rekord został pomyślnie zaktualizowany.'
  END

CREATE PROCEDURE Deletecoursemodulepassed @ModuleID  INT,
                                          @StudentID INT
AS
  BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM   orders O
                            JOIN orderdetails OD
                              ON O.orderid = OD.orderid
                     WHERE  O.studentid = @StudentID
                            AND OD.typeofactivity = 2
                            AND OD.activityid IN (SELECT courseid
                                                  FROM   courses
                                                  WHERE
                                courseid = OD.activityid)
                            AND EXISTS (SELECT 1
                                        FROM   coursemodules CM
                                        WHERE  CM.courseid = OD.activityid
                                               AND CM.moduleid = @ModuleID))
        BEGIN
            PRINT
        'Student nie jest zapisany na kurs lub nie ma dostępu do tego modułu.'

            RETURN
        END

      IF NOT EXISTS (SELECT 1
                     FROM   coursemodulespassed
                     WHERE  moduleid = @ModuleID
                            AND studentid = @StudentID)
        BEGIN
            PRINT 'Rekord do usunięcia nie istnieje.'

            RETURN
        END

      DELETE FROM coursemodulespassed
      WHERE  moduleid = @ModuleID
             AND studentid = @StudentID

      PRINT 'Rekord został pomyślnie usunięty.'
  END

CREATE PROCEDURE Adduserrole @UserID INT,
                             @RoleID INT
AS
  BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM   users
                     WHERE  userid = @UserID)
        BEGIN
            PRINT 'Użytkownik o podanym UserID nie istnieje.';

            RETURN;
        END

      IF NOT EXISTS (SELECT 1
                     FROM   roles
                     WHERE  roleid = @RoleID)
        BEGIN
            PRINT 'Rola o podanym RoleID nie istnieje.';

            RETURN;
        END

      IF EXISTS (SELECT 1
                 FROM   usersroles
                 WHERE  userid = @UserID
                        AND roleid = @RoleID)
        BEGIN
            PRINT 'Użytkownik już posiada tę rolę.';

            RETURN;
        END

      INSERT INTO usersroles
                  (userid,
                   roleid)
      VALUES      (@UserID,
                   @RoleID);

      PRINT 'Rola została pomyślnie dodana użytkownikowi.';
  END;

CREATE PROCEDURE Addstudyresult @StudentID INT,
                                @StudiesID INT,
                                @GradeID   INT
AS
  BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM   users
                     WHERE  userid = @StudentID)
        BEGIN
            PRINT 'Student o podanym StudentID nie istnieje.';

            RETURN;
        END

      IF NOT EXISTS (SELECT 1
                     FROM   studies
                     WHERE  studiesid = @StudiesID)
        BEGIN
            PRINT 'Kierunek studiów o podanym StudiesID nie istnieje.';

            RETURN;
        END

      IF NOT EXISTS (SELECT 1
                     FROM   grades
                     WHERE  gradeid = @GradeID)
        BEGIN
            PRINT 'Ocena o podanym GradeID nie istnieje.';

            RETURN;
        END

      IF NOT EXISTS (SELECT 1
                     FROM   orders O
                            INNER JOIN orderdetails OD
                                    ON O.orderid = OD.orderid
                     WHERE  O.studentid = @StudentID
                            AND OD.activityid = @StudiesID)
        BEGIN
            PRINT 'Student nie złożył zamówienia na te studia.';

            RETURN;
        END

      IF EXISTS (SELECT 1
                 FROM   studiesresults
                 WHERE  studentid = @StudentID
                        AND studiesid = @StudiesID)
        BEGIN
            PRINT 'Rezultat dla tego studenta i kierunku już istnieje.';

            RETURN;
        END

      INSERT INTO studiesresults
                  (studentid,
                   studiesid,
                   gradeid)
      VALUES      (@StudentID,
                   @StudiesID,
                   @GradeID);

      PRINT 'Rezultat studiów został pomyślnie dodany.';
  END;

CREATE PROCEDURE Addsubjectresult @StudentID INT,
                                  @SubjectID INT,
                                  @GradeID   INT
AS
  BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM   users
                     WHERE  userid = @StudentID)
        BEGIN
            PRINT 'Student o podanym StudentID nie istnieje.';

            RETURN;
        END

      IF NOT EXISTS (SELECT 1
                     FROM   subjects
                     WHERE  subjectid = @SubjectID)
        BEGIN
            PRINT 'Przedmiot o podanym SubjectID nie istnieje.';

            RETURN;
        END

      IF NOT EXISTS (SELECT 1
                     FROM   grades
                     WHERE  gradeid = @GradeID)
        BEGIN
            PRINT 'Ocena o podanym GradeID nie istnieje.';

            RETURN;
        END

      IF NOT EXISTS (SELECT 1
                     FROM   orders O
                            INNER JOIN orderdetails OD
                                    ON O.orderid = OD.orderid
                            INNER JOIN subjects S
                                    ON OD.activityid = S.studiesid
                     WHERE  O.studentid = @StudentID
                            AND S.subjectid = @SubjectID)
        BEGIN
            PRINT
'Student nie złożył zamówienia na studia, w ramach którego jest podany przedmiot.'
    ;

    RETURN;
END

    IF EXISTS (SELECT 1
               FROM   subjectsresults
               WHERE  studentid = @StudentID
                      AND subjectid = @SubjectID)
      BEGIN
          PRINT 'Rezultat dla tego studenta i przedmiotu już istnieje.';

          RETURN;
      END

    INSERT INTO subjectsresults
                (subjectid,
                 studentid,
                 gradeid)
    VALUES      (@SubjectID,
                 @StudentID,
                 @GradeID);

    PRINT 'Rezultat przedmiotu został pomyślnie dodany.';
END;

CREATE PROCEDURE Addinternshipresult @StudentID    INT,
                                     @InternshipID INT,
                                     @Passed       BIT
AS
  BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM   users
                     WHERE  userid = @StudentID)
        BEGIN
            PRINT 'Student o podanym StudentID nie istnieje.';

            RETURN;
        END

      IF NOT EXISTS (SELECT 1
                     FROM   internship
                     WHERE  internshipid = @InternshipID)
        BEGIN
            PRINT 'Praktyka o podanym InternshipID nie istnieje.';

            RETURN;
        END

      IF NOT EXISTS (SELECT 1
                     FROM   orders O
                            INNER JOIN orderdetails OD
                                    ON O.orderid = OD.orderid
                            INNER JOIN internship I
                                    ON OD.activityid = I.studiesid
                     WHERE  O.studentid = @StudentID
                            AND I.internshipid = @InternshipID)
        BEGIN
            PRINT
'Student nie złożył zamówienia na studia, w ramach których odbywają się praktyki.'
    ;

    RETURN;
END

    IF EXISTS (SELECT 1
               FROM   internshippassed
               WHERE  studentid = @StudentID
                      AND internshipid = @InternshipID)
      BEGIN
          PRINT 'Rezultat praktyk dla tego studenta już istnieje.';

          RETURN;
      END

    INSERT INTO internshippassed
                (internshipid,
                 studentid,
                 passed)
    VALUES      (@InternshipID,
                 @StudentID,
                 @Passed);

    PRINT 'Rezultat praktyk został pomyślnie dodany.';
END;

CREATE PROCEDURE Addstudymeetingpresence @StudentID INT,
                                         @MeetingID INT,
                                         @Presence  BIT
AS
  BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM   users
                     WHERE  userid = @StudentID)
        BEGIN
            PRINT 'Student o podanym StudentID nie istnieje.';

            RETURN;
        END

      IF NOT EXISTS (SELECT 1
                     FROM   studymeetings
                     WHERE  meetingid = @MeetingID)
        BEGIN
            PRINT 'Spotkanie o podanym MeetingID nie istnieje.';

            RETURN;
        END

      IF NOT EXISTS (SELECT 1
                     FROM   orders O
                            INNER JOIN orderdetails OD
                                    ON O.orderid = OD.orderid
                     WHERE  O.studentid = @StudentID
                            AND OD.activityid = @MeetingID
                     UNION
                     SELECT 1
                     FROM   orders O
                            INNER JOIN orderdetails OD
                                    ON O.orderid = OD.orderid
                            INNER JOIN studymeetingpayment SMP
                                    ON OD.detailid = SMP.detailid
                     WHERE  O.studentid = @StudentID
                            AND SMP.meetingid = @MeetingID)
        BEGIN
            PRINT 'Student nie wykupił tego spotkania.';

            RETURN;
        END

      IF EXISTS (SELECT 1
                 FROM   studymeetingpresence
                 WHERE  studymeetingid = @MeetingID
                        AND studentid = @StudentID)
        BEGIN
            PRINT 'Obecność na to spotkanie dla tego studenta już istnieje.';

            RETURN;
        END

      INSERT INTO studymeetingpresence
                  (studymeetingid,
                   studentid,
                   presence)
      VALUES      (@MeetingID,
                   @StudentID,
                   @Presence);

      PRINT 'Obecność została pomyślnie dodana.';
  END;

CREATE PROCEDURE Addactivityinsteadofpresence @StudentID      INT,
                                              @MeetingID      INT,
                                              @ActivityID     INT,
                                              @TypeOfActivity INT
AS
  BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM   users
                     WHERE  userid = @StudentID)
        BEGIN
            PRINT 'Student o podanym StudentID nie istnieje.';

            RETURN;
        END

      IF NOT EXISTS (SELECT 1
                     FROM   studymeetings
                     WHERE  meetingid = @MeetingID)
        BEGIN
            PRINT 'Spotkanie o podanym MeetingID nie istnieje.';

            RETURN;
        END

      IF NOT EXISTS (SELECT 1
                     FROM   studymeetingpresence
                     WHERE  studentid = @StudentID
                            AND studymeetingid = @MeetingID
                            AND presence = 0)
        BEGIN
            PRINT 'Student nie ma nieobecności na to spotkanie.';

            RETURN;
        END

      IF NOT EXISTS (SELECT 1
                     FROM   studymeetings
                     WHERE  meetingid = @ActivityID)
        BEGIN
            PRINT 'Odrabiana aktywność o podanym ActivityID nie istnieje.';

            RETURN;
        END

      IF EXISTS (SELECT 1
                 FROM   activityinsteadofabsence
                 WHERE  meetingid = @MeetingID
                        AND studentid = @StudentID
                        AND activityid = @ActivityID)
        BEGIN
            PRINT
        'Odrabianie dla tego spotkania i studenta zostało już dodane.'
            ;

            RETURN;
        END

      INSERT INTO activityinsteadofabsence
                  (meetingid,
                   studentid,
                   activityid,
                   typeofactivity)
      VALUES      (@MeetingID,
                   @StudentID,
                   @ActivityID,
                   @TypeOfActivity);

      PRINT 'Odrabianie zostało pomyślnie dodane.';
  END;

CREATE type activitylisttype AS TABLE ( activityid INT, typeofactivity INT );

CREATE PROCEDURE Addorderwithdetails @UserID       INT,
                                     @ActivityList ACTIVITYLISTTYPE readonly
AS
  BEGIN
      DECLARE @OrderID INT;
      DECLARE @ActivityID INT;
      DECLARE @TypeOfActivity INT;
      DECLARE @Price DECIMAL(18, 2);
      DECLARE @DetailID INT;
      DECLARE @OrderDate DATETIME = Getdate();
      DECLARE @PaymentLink VARCHAR(255) = NULL;
      DECLARE @PaymentDeferred  BIT = 0;

      INSERT INTO orders
                  (studentid,
                   orderdate, paymentDeferred)
      VALUES      (@UserID,
                   @OrderDate, @PaymentDeferred);

      SET @OrderID = Scope_identity();

      DECLARE activitycursor CURSOR FOR
        SELECT activityid,
               typeofactivity
        FROM   @ActivityList;

      OPEN activitycursor;

      FETCH next FROM activitycursor INTO @ActivityID, @TypeOfActivity;

      WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @TypeOfActivity = 2
              SELECT @Price = courseprice
              FROM   courses
              WHERE  courseid = @ActivityID;
            ELSE IF @TypeOfActivity = 3
              SELECT @Price = studyprice
              FROM   studies
              WHERE  studiesid = @ActivityID;
            ELSE IF @TypeOfActivity = 4
              SELECT @Price = meetingpriceforothers
              FROM   studymeetings
              WHERE  meetingid = @ActivityID;
            ELSE IF @TypeOfActivity = 1
              SELECT @Price = price
              FROM   webinars
              WHERE  webinarid = @ActivityID;

            

            INSERT INTO orderdetails
                        (orderid,
                         activityid,
                         typeofactivity,
                         price,
                         paiddate,
                         paymentstatus)
            VALUES      (@OrderID,
                         @ActivityID,
                         @TypeOfActivity,
                         @Price,
                         NULL,
                         NULL);
            
            SET @DetailID = Scope_identity();

            IF @TypeOfActivity = 2
              BEGIN
                  DECLARE @AdvancePrice DECIMAL(18, 2) = @Price * 0.10;

                  INSERT INTO paymentsadvances
                              (detailid,
                               advanceprice,
                               advancepaiddate,
                               advancepaymentstatus)
                  VALUES      (@DetailID,
                               @AdvancePrice,
                               NULL,
                               NULL);
              END

            IF @TypeOfActivity = 3
              BEGIN
                  DECLARE @MeetingID INT;
                  DECLARE @MeetingPrice DECIMAL(18, 2);
                  DECLARE meetingcursor CURSOR FOR
                    SELECT meetingid,
                           meetingprice
                    FROM   studymeetings
                    WHERE  meetingid = @ActivityID;

                  OPEN meetingcursor;

                  FETCH next FROM meetingcursor INTO @MeetingID, @MeetingPrice;

                  WHILE @@FETCH_STATUS = 0
                    BEGIN
                        INSERT INTO studymeetingpayment
                                    (detailid,
                                     meetingid,
                                     price,
                                     paiddate,
                                     paymentstatus)
                        VALUES      (@DetailID,
                                     @MeetingID,
                                     @MeetingPrice,
                                     NULL,
                                     NULL);

                        FETCH next FROM meetingcursor INTO @MeetingID,
                        @MeetingPrice;
                    END

                  CLOSE meetingcursor;

                  DEALLOCATE meetingcursor;
              END

            FETCH next FROM activitycursor INTO @ActivityID, @TypeOfActivity;
        END

      CLOSE activitycursor;

      DEALLOCATE activitycursor;

      COMMIT TRANSACTION;
  END

CREATE PROCEDURE Modifyorder @OrderID         INT,
                             @NewUserID       INT = NULL,
                             @PaymentDeferred BIT = NULL,
                             @DeferredDate    DATETIME = NULL,
                             @PaymentLink     VARCHAR(255) = NULL
AS
  BEGIN
      BEGIN TRANSACTION;

      UPDATE orders
      SET    studentid = Isnull(@NewUserID, studentid),
             paymentdeferred = Isnull(@PaymentDeferred, paymentdeferred),
             deferreddate = Isnull(@DeferredDate, deferreddate),
             paymentlink = Isnull(@PaymentLink, paymentlink)
      WHERE  orderid = @OrderID;

      IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR ('Zamówienie o podanym ID nie istnieje.',16,1);

            ROLLBACK TRANSACTION;

            RETURN;
        END

      COMMIT TRANSACTION;
  END;

CREATE PROCEDURE Deleteorder @OrderID INT
AS
  BEGIN
      BEGIN TRANSACTION;

      DELETE FROM orderdetails
      WHERE  orderid = @OrderID;

      DELETE FROM orders
      WHERE  orderid = @OrderID;

      IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR ('Zamówienie o podanym ID nie istnieje.',16,1);

            ROLLBACK TRANSACTION;

            RETURN;
        END

      COMMIT TRANSACTION;
  END;

CREATE PROCEDURE Modifyorderdetail @DetailID          INT,
                                   @NewActivityID     INT = NULL,
                                   @NewTypeOfActivity INT = NULL,
                                   @NewPrice          DECIMAL(18, 2) = NULL,
                                   @NewPaymentStatus  BIT = NULL
AS
  BEGIN
      BEGIN TRANSACTION;

      DECLARE @PaidStatus BIT;

      SELECT @PaidStatus = paymentstatus
      FROM   orderdetails
      WHERE  detailid = @DetailID;

      IF @PaidStatus = 1
        BEGIN
            RAISERROR (
'Nie można zmodyfikować aktywności, która została opłacona. Usuń ją i dodaj nową.'
,16,1);

    ROLLBACK TRANSACTION;

    RETURN;
END

    UPDATE orderdetails
    SET    activityid = Isnull(@NewActivityID, activityid),
           typeofactivity = Isnull(@NewTypeOfActivity, typeofactivity),
           price = Isnull(@NewPrice, price),
           paymentstatus = Isnull(@NewPaymentStatus, paymentstatus)
    WHERE  detailid = @DetailID;

    IF @@ROWCOUNT = 0
      BEGIN
          RAISERROR ('Szczegóły zamówienia o podanym ID nie istnieją.',16,1)
          ;

          ROLLBACK TRANSACTION;

          RETURN;
      END

    COMMIT TRANSACTION;
END;

CREATE PROCEDURE Deleteorderdetail @DetailID INT
AS
  BEGIN
      BEGIN TRANSACTION;

      DELETE FROM orderdetails
      WHERE  detailid = @DetailID;

      IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR ('Szczegóły zamówienia o podanym ID nie istnieją.',16,
                       1)
            ;

            ROLLBACK TRANSACTION;

            RETURN;
        END

      COMMIT TRANSACTION;
  END;

CREATE PROCEDURE Modifyuserrole @UserID    INT,
                                @NewRoleID INT
AS
  BEGIN
      SET nocount ON;

      IF EXISTS (SELECT 1
                 FROM   usersroles
                 WHERE  userid = @UserID)
        BEGIN
            UPDATE usersroles
            SET    roleid = @NewRoleID
            WHERE  userid = @UserID;
        END
      ELSE
        BEGIN
            INSERT INTO usersroles
                        (userid,
                         roleid)
            VALUES      (@UserID,
                         @NewRoleID);
        END
  END;

go

CREATE PROCEDURE Deleteuserrole @UserID INT
AS
  BEGIN
      SET nocount ON;

      DELETE FROM usersroles
      WHERE  userid = @UserID;
  END;

go

CREATE PROCEDURE Modifystudiesresult @StudentID INT,
                                     @StudiesID INT,
                                     @GradeID   INT
AS
  BEGIN
      SET nocount ON;

      IF EXISTS (SELECT 1
                 FROM   studiesresults
                 WHERE  studentid = @StudentID
                        AND studiesid = @StudiesID)
        BEGIN
            UPDATE studiesresults
            SET    gradeid = @GradeID
            WHERE  studentid = @StudentID
                   AND studiesid = @StudiesID;
        END
      ELSE
        BEGIN
            INSERT INTO studiesresults
                        (studentid,
                         studiesid,
                         gradeid)
            VALUES      (@StudentID,
                         @StudiesID,
                         @GradeID);
        END
  END;

CREATE PROCEDURE Deletestudiesresult @StudentID INT,
                                     @StudiesID INT
AS
  BEGIN
      SET nocount ON;

      DELETE FROM studiesresults
      WHERE  studentid = @StudentID
             AND studiesid = @StudiesID;
  END;

CREATE PROCEDURE Modifysubjectresult @StudentID INT,
                                     @SubjectID INT,
                                     @GradeID   INT
AS
  BEGIN
      SET nocount ON;

      IF EXISTS (SELECT 1
                 FROM   subjectsresults
                 WHERE  studentid = @StudentID
                        AND subjectid = @SubjectID)
        BEGIN
            UPDATE subjectsresults
            SET    gradeid = @GradeID
            WHERE  studentid = @StudentID
                   AND subjectid = @SubjectID;
        END
      ELSE
        BEGIN
            INSERT INTO subjectsresults
                        (studentid,
                         subjectid,
                         gradeid)
            VALUES      (@StudentID,
                         @SubjectID,
                         @GradeID);
        END
  END;

CREATE PROCEDURE Deletesubjectresult @StudentID INT,
                                     @SubjectID INT
AS
  BEGIN
      SET nocount ON;

      DELETE FROM subjectsresults
      WHERE  studentid = @StudentID
             AND subjectid = @SubjectID;
  END;

CREATE PROCEDURE Modifyinternshipresult @StudentID    INT,
                                        @InternshipID INT,
                                        @Passed       BIT
AS
  BEGIN
      SET nocount ON;

      IF EXISTS (SELECT 1
                 FROM   internshippassed
                 WHERE  studentid = @StudentID
                        AND internshipid = @InternshipID)
        BEGIN
            UPDATE internshippassed
            SET    passed = @Passed
            WHERE  studentid = @StudentID
                   AND internshipid = @InternshipID;
        END
      ELSE
        BEGIN
            INSERT INTO internshippassed
                        (studentid,
                         internshipid,
                         passed)
            VALUES      (@StudentID,
                         @InternshipID,
                         @Passed);
        END
  END;

CREATE PROCEDURE Deleteinternshipresult @StudentID    INT,
                                        @InternshipID INT
AS
  BEGIN
      SET nocount ON;

      DELETE FROM internshippassed
      WHERE  studentid = @StudentID
             AND internshipid = @InternshipID;
  END;

CREATE PROCEDURE Modifystudymeetingpresence @StudentID INT,
                                            @MeetingID INT,
                                            @Present   BIT
AS
  BEGIN
      SET nocount ON;

      IF EXISTS (SELECT 1
                 FROM   studymeetingpresence
                 WHERE  studentid = @StudentID
                        AND studymeetingid = @MeetingID)
        BEGIN
            UPDATE studymeetingpresence
            SET    presence = @Present
            WHERE  studentid = @StudentID
                   AND studymeetingid = @MeetingID;
        END
      ELSE
        BEGIN
            INSERT INTO studymeetingpresence
                        (studentid,
                         studymeetingid,
                         presence)
            VALUES      (@StudentID,
                         @MeetingID,
                         @Present);
        END
  END;

CREATE PROCEDURE Deletestudymeetingpresence @StudentID INT,
                                            @MeetingID INT
AS
  BEGIN
      SET nocount ON;

      DELETE FROM studymeetingpresence
      WHERE  studentid = @StudentID
             AND studymeetingid = @MeetingID;
  END;

CREATE PROCEDURE Modifyactivityinsteadofabsence @StudentID             INT,
                                                @AbsenceMeetingID      INT,
                                                @ReplacementActivityID INT,
                                                @TypeOfActivity        INT
AS
  BEGIN
      SET nocount ON;

      IF NOT EXISTS (SELECT 1
                     FROM   activitiestypes
                     WHERE  activitytypeid = @TypeOfActivity)
        BEGIN
            RAISERROR('Nieprawidłowy typ aktywności.',16,1);

            RETURN;
        END

      IF EXISTS (SELECT 1
                 FROM   activityinsteadofabsence
                 WHERE  studentid = @StudentID
                        AND meetingid = @AbsenceMeetingID)
        BEGIN
            UPDATE activityinsteadofabsence
            SET    activityid = @ReplacementActivityID
            WHERE  studentid = @StudentID
                   AND meetingid = @AbsenceMeetingID;
        END
      ELSE
        BEGIN
            INSERT INTO activityinsteadofabsence
                        (studentid,
                         meetingid,
                         activityid,
                         typeofactivity)
            VALUES      (@StudentID,
                         @AbsenceMeetingID,
                         @ReplacementActivityID,
                         @TypeOfActivity);
        END
  END;

CREATE PROCEDURE Activatedeactivateuser (@UserId   INT,
                                         @Activate BIT)
AS
  BEGIN
      IF EXISTS (SELECT 1
                 FROM   users
                 WHERE  userid = @UserId)
        BEGIN
            DECLARE @CurrentStatus BIT;

            SELECT @CurrentStatus = active
            FROM   users
            WHERE  userid = @UserId;

            IF @CurrentStatus <> @Activate
              BEGIN
                  UPDATE users
                  SET    active = @Activate
                  WHERE  userid = @UserId;

                  IF @Activate = 1
                    BEGIN
                        PRINT 'User account activated.';
                    END
                  ELSE
                    BEGIN
                        PRINT 'User account deactivated.';
                    END
              END
            ELSE
              BEGIN
                  IF @Activate = 1
                    THROW 50002, 'User account is already active.', 1;
                  ELSE
                    THROW 50003, 'User account is already deactivated.', 1;
              END
        END
      ELSE
        BEGIN
            THROW 50001, 'User does not exist.', 1;
        END
  END;  