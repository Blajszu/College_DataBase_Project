-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2024-12-17 08:35:43.981

-- tables
-- Table: ActivitiesTypes
CREATE TABLE ActivitiesTypes (
    ActivityTypeID int  NOT NULL IDENTITY(1,1),
    TypeName varchar(40)  NOT NULL,
    CONSTRAINT ActivitiesTypes_pk PRIMARY KEY  (ActivityTypeID)
);

-- Table: Cities
CREATE TABLE Cities (
    CityID int  NOT NULL IDENTITY(1,1),
    CityName varchar(40)  NOT NULL,
    CountryID int  NOT NULL,
    CONSTRAINT Cities_pk PRIMARY KEY  (CityID)
);

-- Table: Countries
CREATE TABLE Countries (
    CountryID int  NOT NULL IDENTITY(1,1),
    CountryName varchar(40)  NOT NULL,
    CONSTRAINT Countries_pk PRIMARY KEY  (CountryID)
);

-- Table: CourseModules
CREATE TABLE CourseModules (
    ModuleID int  NOT NULL IDENTITY(1,1),
    CourseID int  NOT NULL,
    ModuleName varchar(40)  NOT NULL,
    ModuleType int  NOT NULL,
    LecturerID int  NOT NULL,
    LanguageID int  NOT NULL,
    TranslatorID int  NULL,
    CONSTRAINT CourseSegment_pk PRIMARY KEY  (ModuleID)
);

-- Table: CourseModulesPassed
CREATE TABLE CourseModulesPassed (
    ModuleID int  NOT NULL,
    StudentID int  NOT NULL,
    Passed bit  NOT NULL,
    CONSTRAINT CourseModulesPassed_pk PRIMARY KEY  (ModuleID,StudentID)
);

-- Table: Courses
CREATE TABLE Courses (
    CourseID int  NOT NULL IDENTITY(1,1),
    CourseName varchar(40)  NOT NULL,
    CourseCoordinatorID int  NOT NULL,
    CourseDescription varchar(255)  NOT NULL,
    CoursePrice money  NOT NULL,
    StudentLimit int  NULL,
    CONSTRAINT Courses_pk PRIMARY KEY  (CourseID)
);

-- Table: Degrees
CREATE TABLE Degrees (
    DegreeID int  NOT NULL IDENTITY(1,1),
    DegreeName varchar(40)  NOT NULL,
    CONSTRAINT Degrees_pk PRIMARY KEY  (DegreeID)
);

-- Table: Employees
CREATE TABLE Employees (
    EmployeeID int  NOT NULL,
    HireDate date  NOT NULL,
    DegreeID int  NULL,
    CONSTRAINT Employees_pk PRIMARY KEY  (EmployeeID)
);

-- Table: FormOfActivity
CREATE TABLE FormOfActivity (
    ActivityTypeID int  NOT NULL IDENTITY(1,1),
    TypeName varchar(40)  NOT NULL,
    CONSTRAINT FormOfActivity_pk PRIMARY KEY  (ActivityTypeID)
);

-- Table: Grades
CREATE TABLE Grades (
    GradeID int  NOT NULL IDENTITY(1,1),
    GradeName varchar(40)  NOT NULL,
    CONSTRAINT Grades_pk PRIMARY KEY  (GradeID)
);

-- Table: Internship
CREATE TABLE Internship (
    InternshipID int  NOT NULL IDENTITY(1,1),
    StudiesID int  NOT NULL,
    InternshipCoordinatorID int  NOT NULL,
    StartDate date  NOT NULL,
    EndDate date  NOT NULL,
    NumerOfHours int  NOT NULL,
    Term int  NOT NULL,
    CONSTRAINT Internship_pk PRIMARY KEY  (InternshipID)
);

-- Table: InternshipPassed
CREATE TABLE InternshipPassed (
    InternshipID int  NOT NULL,
    StudentID int  NOT NULL,
    Passed bit  NOT NULL,
    CONSTRAINT InternshipPresence_pk PRIMARY KEY  (InternshipID,StudentID)
);

-- Table: Languages
CREATE TABLE Languages (
    LanguageID int  NOT NULL IDENTITY(1,1),
    LanguageName varchar(40)  NOT NULL,
    CONSTRAINT Languages_pk PRIMARY KEY  (LanguageID)
);

-- Table: OnlineCourseMeeting
CREATE TABLE OnlineCourseMeeting (
    MeetingID int  NOT NULL,
    ModuleID int  NOT NULL,
    StartDate datetime  NOT NULL,
    EndDate datetime  NOT NULL,
    MeetingLink varchar(255)  NULL,
    VideoLink varchar(255)  NULL,
    CONSTRAINT OnlineCourseMeeting_pk PRIMARY KEY  (MeetingID)
);

-- Table: OnlineMeetings
CREATE TABLE OnlineMeetings (
    MeetingID int  NOT NULL,
    MeetingLink varchar(255)  NULL,
    StudentLimit int  NOT NULL,
    CONSTRAINT OnlineMeetings_pk PRIMARY KEY  (MeetingID)
);

-- Table: OrderDetails
CREATE TABLE OrderDetails (
    DetailID int  NOT NULL IDENTITY(1,1),
    OrderID int  NOT NULL,
    ActivityID int  NOT NULL,
    TypeOfActivity int  NOT NULL,
    Price money  NOT NULL,
    PaidDate datetime  NULL,
    PaymentStatus varchar(40)  NULL,
    CONSTRAINT OrderDetails_pk PRIMARY KEY  (DetailID)
);

-- Table: Orders
CREATE TABLE Orders (
    OrderID int  NOT NULL IDENTITY(1,1),
    StudentID int  NOT NULL,
    OrderDate datetime  NOT NULL,
    PaymentDeferred bit  NOT NULL,
    DeferredDate date  NULL,
    PaymentLink varchar(255)  NULL,
    CONSTRAINT Orders_pk PRIMARY KEY  (OrderID)
);

-- Table: PaymentsAdvances
CREATE TABLE PaymentsAdvances (
    DetailID int  NOT NULL,
    AdvancePrice money  NOT NULL,
    AdvancePaidDate datetime  NULL,
    AdvancePaymentStatus varchar(40)  NULL,
    CONSTRAINT PaymentsAdvances_pk PRIMARY KEY  (DetailID)
);

-- Table: Roles
CREATE TABLE Roles (
    RoleID int  NOT NULL IDENTITY(1,1),
    RoleName varchar(40)  NOT NULL,
    CONSTRAINT Roles_pk PRIMARY KEY  (RoleID)
);

-- Table: Rooms
CREATE TABLE Rooms (
    RoomID int  NOT NULL IDENTITY(1,1),
    RoomName varchar(40)  NOT NULL,
    Street varchar(40)  NOT NULL,
    PostalCode varchar(6)  NOT NULL,
    CityID int  NOT NULL,
    Limit int  NOT NULL,
    CONSTRAINT Rooms_pk PRIMARY KEY  (RoomID)
);

-- Table: StationaryCourseMeeting
CREATE TABLE StationaryCourseMeeting (
    MeetingID int  NOT NULL,
    ModuleID int  NOT NULL,
    RoomID int  NOT NULL,
    StartDate datetime  NOT NULL,
    EndDate datetime  NOT NULL,
    CONSTRAINT StationaryCourseMeeting_pk PRIMARY KEY  (MeetingID)
);

-- Table: StationaryMeetings
CREATE TABLE StationaryMeetings (
    MeetingID int  NOT NULL,
    RoomID int  NOT NULL,
    StudentLimit int  NOT NULL,
    CONSTRAINT StationaryMeetings_pk PRIMARY KEY  (MeetingID)
);

-- Table: Studies
CREATE TABLE Studies (
    StudiesID int  NOT NULL IDENTITY(1,1),
    StudiesCoordinatorID int  NOT NULL,
    StudyName varchar(40)  NOT NULL,
    StudyPrice money  NOT NULL,
    StudyDescription varchar(255)  NOT NULL,
    NumberOfTerms int  NOT NULL,
    StudentLimit int  NOT NULL,
    CONSTRAINT Studies_pk PRIMARY KEY  (StudiesID)
);

-- Table: StudiesResults
CREATE TABLE StudiesResults (
    StudiesID int  NOT NULL,
    StudentID int  NOT NULL,
    GradeID int  NOT NULL,
    CONSTRAINT StudiesResults_pk PRIMARY KEY  (StudiesID,StudentID)
);

-- Table: StudyMeetingPayment
CREATE TABLE StudyMeetingPayment (
    DetailID int  NOT NULL,
    MeetingID int  NOT NULL,
    Price money  NOT NULL,
    PaidDate datetime  NULL,
    PaymentStatus varchar(40)  NULL,
    CONSTRAINT StudyMeetingPayment_pk PRIMARY KEY  (DetailID)
);

-- Table: StudyMeetingPresence
CREATE TABLE StudyMeetingPresence (
    StudyMeetingID int  NOT NULL,
    StudentID int  NOT NULL,
    Presence bit  NOT NULL,
    CONSTRAINT StudyMeetingPresence_pk PRIMARY KEY  (StudyMeetingID,StudentID)
);

-- Table: StudyMeetings
CREATE TABLE StudyMeetings (
    MeetingID int  NOT NULL IDENTITY(1,1),
    SubjectID int  NOT NULL,
    LecturerID int  NOT NULL,
    MeetingType int  NOT NULL,
    MeetingPrice money  NOT NULL,
    MeetingPriceForOthers money  NOT NULL,
    StartTime datetime  NOT NULL,
    EndTime datetime  NOT NULL,
    LanguageID int  NOT NULL,
    TranslatorID int  NULL,
    CONSTRAINT StudyMeetings_pk PRIMARY KEY  (MeetingID)
);

-- Table: Subjects
CREATE TABLE Subjects (
    SubjectID int  NOT NULL IDENTITY(1,1),
    StudiesID int  NOT NULL,
    TeacherID int  NOT NULL,
    SubjectName varchar(40)  NOT NULL,
    SubjectDescription varchar(255)  NOT NULL,
    NumberOfHoursInTerm int  NOT NULL,
    Term int  NOT NULL,
    CONSTRAINT Subjects_pk PRIMARY KEY  (SubjectID)
);

-- Table: SubjectsResults
CREATE TABLE SubjectsResults (
    SubjectID int  NOT NULL,
    StudentID int  NOT NULL,
    GradeID int  NOT NULL,
    CONSTRAINT SubjectsResults_pk PRIMARY KEY  (SubjectID,StudentID)
);

-- Table: TranslatedLanguage
CREATE TABLE TranslatedLanguage (
    TranslatorID int  NOT NULL,
    LanguageID int  NOT NULL,
    CONSTRAINT TranslatedLanguage_pk PRIMARY KEY  (LanguageID,TranslatorID)
);

-- Table: Users
CREATE TABLE Users (
    UserID int  NOT NULL IDENTITY(1,1),
    FirstName varchar(40)  NOT NULL,
    LastName varchar(40)  NOT NULL,
    Street varchar(40)  NOT NULL,
    PostalCode varchar(6)  NOT NULL,
    CityID int  NOT NULL,
    Email varchar(40)  NOT NULL,
    Phone varchar(40)  NOT NULL,
    DateOfBirth date  NOT NULL,
    CONSTRAINT Users_pk PRIMARY KEY  (UserID)
);

-- Table: UsersRoles
CREATE TABLE UsersRoles (
    UserID int  NOT NULL,
    RoleID int  NOT NULL,
    CONSTRAINT EmployeeRoles_pk PRIMARY KEY  (UserID,RoleID)
);

-- Table: Webinars
CREATE TABLE Webinars (
    WebinarID int  NOT NULL IDENTITY(1,1),
    WebinarName varchar(40)  NOT NULL,
    WebinarDescription varchar(255)  NOT NULL,
    TeacherID int  NOT NULL,
    Price money  NULL,
    LanguageID int  NOT NULL,
    TranslatorID int  NULL,
    StartDate datetime  NOT NULL,
    EndDate datetime  NOT NULL,
    VideoLink varchar(255)  NULL,
    MeetingLink varchar(255)  NULL,
    CONSTRAINT Webinars_pk PRIMARY KEY  (WebinarID)
);

-- foreign keys
-- Reference: City_User (table: Users)
ALTER TABLE Users ADD CONSTRAINT City_User
    FOREIGN KEY (CityID)
    REFERENCES Cities (CityID);

-- Reference: Country_City (table: Cities)
ALTER TABLE Cities ADD CONSTRAINT Country_City
    FOREIGN KEY (CountryID)
    REFERENCES Countries (CountryID);

-- Reference: CourseModulesPassed_CourseModules (table: CourseModulesPassed)
ALTER TABLE CourseModulesPassed ADD CONSTRAINT CourseModulesPassed_CourseModules
    FOREIGN KEY (ModuleID)
    REFERENCES CourseModules (ModuleID);

-- Reference: CourseModulesPassed_Users (table: CourseModulesPassed)
ALTER TABLE CourseModulesPassed ADD CONSTRAINT CourseModulesPassed_Users
    FOREIGN KEY (StudentID)
    REFERENCES Users (UserID);

-- Reference: CourseSegment_Courses (table: CourseModules)
ALTER TABLE CourseModules ADD CONSTRAINT CourseSegment_Courses
    FOREIGN KEY (CourseID)
    REFERENCES Courses (CourseID);

-- Reference: CourseSegment_Employees (table: CourseModules)
ALTER TABLE CourseModules ADD CONSTRAINT CourseSegment_Employees
    FOREIGN KEY (LecturerID)
    REFERENCES Employees (EmployeeID);

-- Reference: CourseSegment_Employees_1 (table: CourseModules)
ALTER TABLE CourseModules ADD CONSTRAINT CourseSegment_Employees_1
    FOREIGN KEY (TranslatorID)
    REFERENCES Employees (EmployeeID);

-- Reference: Courses_Employees (table: Courses)
ALTER TABLE Courses ADD CONSTRAINT Courses_Employees
    FOREIGN KEY (CourseCoordinatorID)
    REFERENCES Employees (EmployeeID);

-- Reference: EmployeeRoles_Roles (table: UsersRoles)
ALTER TABLE UsersRoles ADD CONSTRAINT EmployeeRoles_Roles
    FOREIGN KEY (RoleID)
    REFERENCES Roles (RoleID);

-- Reference: Employees_Degrees (table: Employees)
ALTER TABLE Employees ADD CONSTRAINT Employees_Degrees
    FOREIGN KEY (DegreeID)
    REFERENCES Degrees (DegreeID);

-- Reference: Employees_Users (table: Employees)
ALTER TABLE Employees ADD CONSTRAINT Employees_Users
    FOREIGN KEY (EmployeeID)
    REFERENCES Users (UserID);

-- Reference: FormOfActivity_CourseModules (table: CourseModules)
ALTER TABLE CourseModules ADD CONSTRAINT FormOfActivity_CourseModules
    FOREIGN KEY (ModuleType)
    REFERENCES FormOfActivity (ActivityTypeID);

-- Reference: FormOfActivity_StudyMeetings (table: StudyMeetings)
ALTER TABLE StudyMeetings ADD CONSTRAINT FormOfActivity_StudyMeetings
    FOREIGN KEY (MeetingType)
    REFERENCES FormOfActivity (ActivityTypeID);

-- Reference: InternshipPresence_Users (table: InternshipPassed)
ALTER TABLE InternshipPassed ADD CONSTRAINT InternshipPresence_Users
    FOREIGN KEY (StudentID)
    REFERENCES Users (UserID);

-- Reference: Internship_Employees (table: Internship)
ALTER TABLE Internship ADD CONSTRAINT Internship_Employees
    FOREIGN KEY (InternshipCoordinatorID)
    REFERENCES Employees (EmployeeID);

-- Reference: Internship_InternshipPresence (table: InternshipPassed)
ALTER TABLE InternshipPassed ADD CONSTRAINT Internship_InternshipPresence
    FOREIGN KEY (InternshipID)
    REFERENCES Internship (InternshipID);

-- Reference: Internship_Studies (table: Internship)
ALTER TABLE Internship ADD CONSTRAINT Internship_Studies
    FOREIGN KEY (StudiesID)
    REFERENCES Studies (StudiesID);

-- Reference: Languages_CourseSegment (table: CourseModules)
ALTER TABLE CourseModules ADD CONSTRAINT Languages_CourseSegment
    FOREIGN KEY (LanguageID)
    REFERENCES Languages (LanguageID);

-- Reference: OnlineMeetings_StudyMeetings (table: OnlineMeetings)
ALTER TABLE OnlineMeetings ADD CONSTRAINT OnlineMeetings_StudyMeetings
    FOREIGN KEY (MeetingID)
    REFERENCES StudyMeetings (MeetingID);

-- Reference: OnlineModules_CourseModules (table: OnlineCourseMeeting)
ALTER TABLE OnlineCourseMeeting ADD CONSTRAINT OnlineModules_CourseModules
    FOREIGN KEY (ModuleID)
    REFERENCES CourseModules (ModuleID);

-- Reference: OrderDetails_ActivitiesTypes (table: OrderDetails)
ALTER TABLE OrderDetails ADD CONSTRAINT OrderDetails_ActivitiesTypes
    FOREIGN KEY (TypeOfActivity)
    REFERENCES ActivitiesTypes (ActivityTypeID);

-- Reference: OrderDetails_Courses (table: OrderDetails)
ALTER TABLE OrderDetails ADD CONSTRAINT OrderDetails_Courses
    FOREIGN KEY (ActivityID)
    REFERENCES Courses (CourseID);

-- Reference: OrderDetails_Studies (table: OrderDetails)
ALTER TABLE OrderDetails ADD CONSTRAINT OrderDetails_Studies
    FOREIGN KEY (ActivityID)
    REFERENCES Studies (StudiesID);

-- Reference: OrderDetails_StudyMeetingPayment (table: StudyMeetingPayment)
ALTER TABLE StudyMeetingPayment ADD CONSTRAINT OrderDetails_StudyMeetingPayment
    FOREIGN KEY (DetailID)
    REFERENCES OrderDetails (DetailID);

-- Reference: OrderDetails_StudyMeetings (table: OrderDetails)
ALTER TABLE OrderDetails ADD CONSTRAINT OrderDetails_StudyMeetings
    FOREIGN KEY (ActivityID)
    REFERENCES StudyMeetings (MeetingID);

-- Reference: OrderDetails_Webinars (table: OrderDetails)
ALTER TABLE OrderDetails ADD CONSTRAINT OrderDetails_Webinars
    FOREIGN KEY (ActivityID)
    REFERENCES Webinars (WebinarID);

-- Reference: Orders_OrderDetails (table: OrderDetails)
ALTER TABLE OrderDetails ADD CONSTRAINT Orders_OrderDetails
    FOREIGN KEY (OrderID)
    REFERENCES Orders (OrderID);

-- Reference: PaymentsAdvances_OrderDetails (table: PaymentsAdvances)
ALTER TABLE PaymentsAdvances ADD CONSTRAINT PaymentsAdvances_OrderDetails
    FOREIGN KEY (DetailID)
    REFERENCES OrderDetails (DetailID);

-- Reference: Rooms_Cities (table: Rooms)
ALTER TABLE Rooms ADD CONSTRAINT Rooms_Cities
    FOREIGN KEY (CityID)
    REFERENCES Cities (CityID);

-- Reference: StationaryMeetings_Rooms (table: StationaryMeetings)
ALTER TABLE StationaryMeetings ADD CONSTRAINT StationaryMeetings_Rooms
    FOREIGN KEY (RoomID)
    REFERENCES Rooms (RoomID);

-- Reference: StationaryMeetings_StudyMeetings (table: StationaryMeetings)
ALTER TABLE StationaryMeetings ADD CONSTRAINT StationaryMeetings_StudyMeetings
    FOREIGN KEY (MeetingID)
    REFERENCES StudyMeetings (MeetingID);

-- Reference: StationaryModules_CourseModules (table: StationaryCourseMeeting)
ALTER TABLE StationaryCourseMeeting ADD CONSTRAINT StationaryModules_CourseModules
    FOREIGN KEY (ModuleID)
    REFERENCES CourseModules (ModuleID);

-- Reference: StationaryModules_Rooms (table: StationaryCourseMeeting)
ALTER TABLE StationaryCourseMeeting ADD CONSTRAINT StationaryModules_Rooms
    FOREIGN KEY (RoomID)
    REFERENCES Rooms (RoomID);

-- Reference: StudiesResults_Grades (table: StudiesResults)
ALTER TABLE StudiesResults ADD CONSTRAINT StudiesResults_Grades
    FOREIGN KEY (GradeID)
    REFERENCES Grades (GradeID);

-- Reference: StudiesResults_Studies (table: StudiesResults)
ALTER TABLE StudiesResults ADD CONSTRAINT StudiesResults_Studies
    FOREIGN KEY (StudiesID)
    REFERENCES Studies (StudiesID);

-- Reference: Studies_Employees (table: Studies)
ALTER TABLE Studies ADD CONSTRAINT Studies_Employees
    FOREIGN KEY (StudiesCoordinatorID)
    REFERENCES Employees (EmployeeID);

-- Reference: StudyMeetingPresence_Users (table: StudyMeetingPresence)
ALTER TABLE StudyMeetingPresence ADD CONSTRAINT StudyMeetingPresence_Users
    FOREIGN KEY (StudentID)
    REFERENCES Users (UserID);

-- Reference: StudyMeetings_Employees (table: StudyMeetings)
ALTER TABLE StudyMeetings ADD CONSTRAINT StudyMeetings_Employees
    FOREIGN KEY (TranslatorID)
    REFERENCES Employees (EmployeeID);

-- Reference: StudyMeetings_Employees_00 (table: StudyMeetings)
ALTER TABLE StudyMeetings ADD CONSTRAINT StudyMeetings_Employees_00
    FOREIGN KEY (LecturerID)
    REFERENCES Employees (EmployeeID);

-- Reference: StudyMeetings_Languages (table: StudyMeetings)
ALTER TABLE StudyMeetings ADD CONSTRAINT StudyMeetings_Languages
    FOREIGN KEY (LanguageID)
    REFERENCES Languages (LanguageID);

-- Reference: StudyMeetings_Presence (table: StudyMeetingPresence)
ALTER TABLE StudyMeetingPresence ADD CONSTRAINT StudyMeetings_Presence
    FOREIGN KEY (StudyMeetingID)
    REFERENCES StudyMeetings (MeetingID);

-- Reference: StudyMeetings_StudyMeetingPayment (table: StudyMeetingPayment)
ALTER TABLE StudyMeetingPayment ADD CONSTRAINT StudyMeetings_StudyMeetingPayment
    FOREIGN KEY (MeetingID)
    REFERENCES StudyMeetings (MeetingID);

-- Reference: StudyMeetings_Subjects (table: StudyMeetings)
ALTER TABLE StudyMeetings ADD CONSTRAINT StudyMeetings_Subjects
    FOREIGN KEY (SubjectID)
    REFERENCES Subjects (SubjectID);

-- Reference: SubjectsResults_Grades (table: SubjectsResults)
ALTER TABLE SubjectsResults ADD CONSTRAINT SubjectsResults_Grades
    FOREIGN KEY (GradeID)
    REFERENCES Grades (GradeID);

-- Reference: SubjectsResults_Subjects (table: SubjectsResults)
ALTER TABLE SubjectsResults ADD CONSTRAINT SubjectsResults_Subjects
    FOREIGN KEY (SubjectID)
    REFERENCES Subjects (SubjectID);

-- Reference: Subjects_Employees (table: Subjects)
ALTER TABLE Subjects ADD CONSTRAINT Subjects_Employees
    FOREIGN KEY (TeacherID)
    REFERENCES Employees (EmployeeID);

-- Reference: Subjects_Studies (table: Subjects)
ALTER TABLE Subjects ADD CONSTRAINT Subjects_Studies
    FOREIGN KEY (StudiesID)
    REFERENCES Studies (StudiesID);

-- Reference: TranslatedLanguage_Employees (table: TranslatedLanguage)
ALTER TABLE TranslatedLanguage ADD CONSTRAINT TranslatedLanguage_Employees
    FOREIGN KEY (TranslatorID)
    REFERENCES Employees (EmployeeID);

-- Reference: TranslatedLanguage_Languages (table: TranslatedLanguage)
ALTER TABLE TranslatedLanguage ADD CONSTRAINT TranslatedLanguage_Languages
    FOREIGN KEY (LanguageID)
    REFERENCES Languages (LanguageID);

-- Reference: UsersRoles_Users (table: UsersRoles)
ALTER TABLE UsersRoles ADD CONSTRAINT UsersRoles_Users
    FOREIGN KEY (UserID)
    REFERENCES Users (UserID);

-- Reference: Users_Orders (table: Orders)
ALTER TABLE Orders ADD CONSTRAINT Users_Orders
    FOREIGN KEY (StudentID)
    REFERENCES Users (UserID);

-- Reference: Users_StudiesResults (table: StudiesResults)
ALTER TABLE StudiesResults ADD CONSTRAINT Users_StudiesResults
    FOREIGN KEY (StudentID)
    REFERENCES Users (UserID);

-- Reference: Users_SubjectsResults (table: SubjectsResults)
ALTER TABLE SubjectsResults ADD CONSTRAINT Users_SubjectsResults
    FOREIGN KEY (StudentID)
    REFERENCES Users (UserID);

-- Reference: Webinars_Employees (table: Webinars)
ALTER TABLE Webinars ADD CONSTRAINT Webinars_Employees
    FOREIGN KEY (TranslatorID)
    REFERENCES Employees (EmployeeID);

-- Reference: Webinars_Employees_01 (table: Webinars)
ALTER TABLE Webinars ADD CONSTRAINT Webinars_Employees_01
    FOREIGN KEY (TeacherID)
    REFERENCES Employees (EmployeeID);

-- Reference: Webinars_Languages (table: Webinars)
ALTER TABLE Webinars ADD CONSTRAINT Webinars_Languages
    FOREIGN KEY (LanguageID)
    REFERENCES Languages (LanguageID);

-- Dodanie ograniczeń integralnościowych dla tabel

-- ActivitiesTypes
ALTER TABLE ActivitiesTypes ADD CONSTRAINT UQ_ActivitiesTypes_TypeName UNIQUE (TypeName);

-- Cities
ALTER TABLE Cities ADD CONSTRAINT UQ_Cities_CityName_CountryID UNIQUE (CityName, CountryID);

-- Countries
ALTER TABLE Countries ADD CONSTRAINT UQ_Countries_CountryName UNIQUE (CountryName);

-- StationaryCourseMeeting
ALTER TABLE StationaryCourseMeeting ADD CONSTRAINT CHK_StationaryCourseMeeting_StartEndDates CHECK (StartDate < EndDate);

-- OnlineCourseMeeting
ALTER TABLE OnlineCourseMeeting ADD CONSTRAINT CHK_OnlineCourseMeeting_StartEndDates CHECK (StartDate < EndDate);

-- Courses
ALTER TABLE Courses ADD CONSTRAINT CHK_Courses_CoursePrice CHECK (CoursePrice >= 0);
ALTER TABLE Courses ADD CONSTRAINT CHK_Courses_NumberOfStudentsLimit CHECK (StudentLimit > 0 OR StudentLimit IS NULL);

-- Degrees
ALTER TABLE Degrees ADD CONSTRAINT UQ_Degrees_DegreeName UNIQUE (DegreeName);

-- Employees
ALTER TABLE Employees ADD CONSTRAINT CHK_Employees_HireDate CHECK (HireDate <= GETDATE());

-- FormOfActivity
ALTER TABLE FormOfActivity ADD CONSTRAINT UQ_FormOfActivity_TypeName UNIQUE (TypeName);

-- Grades
ALTER TABLE Grades ADD CONSTRAINT UQ_Grades_GradeName UNIQUE (GradeName);

-- Internship
ALTER TABLE Internship ADD CONSTRAINT CHK_Internship_StartEndDates CHECK (StartDate < EndDate);
ALTER TABLE Internship ADD CONSTRAINT CHK_Internship_NumerOfHours CHECK (NumerOfHours > 0);

-- Languages
ALTER TABLE Languages ADD CONSTRAINT UQ_Languages_LanguageName UNIQUE (LanguageName);

-- StationaryMeetings
ALTER TABLE StationaryMeetings ADD CONSTRAINT CHK_StationaryMeetings_StudentLimit CHECK (StudentLimit > 0);

-- OnlineMeetings
ALTER TABLE OnlineMeetings ADD CONSTRAINT CHK_OnlineMeetings_StudentLimit CHECK (StudentLimit > 0 OR StudentLimit IS NULL);

-- OrderDetails
ALTER TABLE OrderDetails ADD CONSTRAINT CHK_OrderDetails_Price CHECK (Price >= 0);

-- Roles
ALTER TABLE Roles ADD CONSTRAINT UQ_Roles_RoleName UNIQUE (RoleName);

-- Rooms
ALTER TABLE Rooms ADD CONSTRAINT CHK_Rooms_Limit CHECK (Limit > 0);

-- Studies
ALTER TABLE Studies ADD CONSTRAINT CHK_Studies_StudyPrice CHECK (StudyPrice >= 0);
ALTER TABLE Studies ADD CONSTRAINT CHK_Studies_NumberOfTerms CHECK (NumberOfTerms > 0);

-- StudyMeetings
ALTER TABLE StudyMeetings ADD CONSTRAINT CHK_StudyMeetings_StartEndTimes CHECK (StartTime < EndTime);
ALTER TABLE StudyMeetings ADD CONSTRAINT CHK_StudyMeetings_Price CHECK (MeetingPrice >= 0);
ALTER TABLE StudyMeetings ADD CONSTRAINT CHK_StudyMeetings_PriceForOthers CHECK (MeetingPriceForOthers >= 0);

-- Subjects
ALTER TABLE Subjects ADD CONSTRAINT CHK_Subjects_NumberOfHoursInTerm CHECK (NumberOfHoursInTerm > 0);

-- Users
ALTER TABLE Users ADD CONSTRAINT CHK_Users_DateOfBirth CHECK (DateOfBirth < GETDATE());
ALTER TABLE Users ADD CONSTRAINT CHK_Users_Email_LIKE CHECK (Email LIKE '%@%.%');
ALTER TABLE Users ADD CONSTRAINT UQ_Users_Email UNIQUE (Email);

-- Webinars
ALTER TABLE Webinars ADD CONSTRAINT CHK_Webinars_StartEndDates CHECK (StartDate < EndDate);
ALTER TABLE Webinars ADD CONSTRAINT CHK_Webinars_Price CHECK (Price >= 0);

-- PaymentsAdvances
ALTER TABLE PaymentsAdvances
ADD CONSTRAINT CHK_PaymentsAdvances_AdvancePrice CHECK (AdvancePrice >= 0);

-- End of file.