-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2024-12-10 19:05:19.129

-- tables
-- Table: ActivitiesTypes
CREATE TABLE ActivitiesTypes (
    ActivityTypeID int  NOT NULL,
    TypeName varchar  NOT NULL,
    CONSTRAINT ActivitiesTypes_pk PRIMARY KEY  (ActivityTypeID)
);

-- Table: Cities
CREATE TABLE Cities (
    CityID int  NOT NULL,
    CityName varchar  NOT NULL,
    CountryID int  NOT NULL,
    CONSTRAINT Cities_pk PRIMARY KEY  (CityID)
);

-- Table: Countries
CREATE TABLE Countries (
    CountryID int  NOT NULL,
    CountryName varchar  NOT NULL,
    CONSTRAINT Countries_pk PRIMARY KEY  (CountryID)
);

-- Table: CourseSegment
CREATE TABLE CourseSegment (
    SegmentID int  NOT NULL,
    CourseID int  NOT NULL,
    SegmentName varchar  NOT NULL,
    SegmentType int  NOT NULL,
    LecturerID int  NOT NULL,
    StartDate datetime  NOT NULL,
    EndDate datetime  NOT NULL,
    LanguageID int  NOT NULL,
    TranslatorID int  NULL,
    CONSTRAINT CourseSegment_pk PRIMARY KEY  (SegmentID)
);

-- Table: CourseSegmentDetails
CREATE TABLE CourseSegmentDetails (
    SegmentID int  NOT NULL,
    SegmentType int  NOT NULL,
    SegmentDescription varchar  NULL,
    RoomID int  NOT NULL,
    NumberOfStudentsLimit int  NULL,
    Link varchar  NULL,
    CONSTRAINT CourseSegmentDetails_pk PRIMARY KEY  (SegmentID)
);

-- Table: CourseSegmentPresence
CREATE TABLE CourseSegmentPresence (
    SegmentID int  NOT NULL,
    UserID int  NOT NULL,
    Presence bit  NOT NULL,
    CONSTRAINT CourseSegmentPresence_pk PRIMARY KEY  (SegmentID,UserID)
);

-- Table: Courses
CREATE TABLE Courses (
    CourseID int  NOT NULL,
    CourseName varchar  NOT NULL,
    CourseCoordinatorID int  NOT NULL,
    CourseDescription varchar  NOT NULL,
    CoursePrice money  NOT NULL,
    CONSTRAINT Courses_pk PRIMARY KEY  (CourseID)
);

-- Table: Degrees
CREATE TABLE Degrees (
    DegreeID int  NOT NULL,
    DegreeName varchar  NOT NULL,
    CONSTRAINT Degrees_pk PRIMARY KEY  (DegreeID)
);

-- Table: EmployeeRoles
CREATE TABLE EmployeeRoles (
    EmployeeID int  NOT NULL,
    RoleID int  NOT NULL,
    CONSTRAINT EmployeeRoles_pk PRIMARY KEY  (EmployeeID,RoleID)
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
    ActivityTypeID int  NOT NULL,
    TypeName varchar  NOT NULL,
    CONSTRAINT FormOfActivity_pk PRIMARY KEY  (ActivityTypeID)
);

-- Table: Grades
CREATE TABLE Grades (
    GradeID int  NOT NULL,
    GradeName varchar  NOT NULL,
    CONSTRAINT Grades_pk PRIMARY KEY  (GradeID)
);

-- Table: Internship
CREATE TABLE Internship (
    InternshipID int  NOT NULL,
    StudiesID int  NOT NULL,
    InternshipCoordinatorID int  NOT NULL,
    StartDate date  NOT NULL,
    EndDate date  NOT NULL,
    NumerOfHours int  NOT NULL,
    Term int  NOT NULL,
    CONSTRAINT Internship_pk PRIMARY KEY  (InternshipID)
);

-- Table: InternshipPresence
CREATE TABLE InternshipPresence (
    PresenceID int  NOT NULL,
    InternshipID int  NOT NULL,
    StudentID int  NOT NULL,
    Date date  NOT NULL,
    Presence bit  NOT NULL,
    CONSTRAINT InternshipPresence_pk PRIMARY KEY  (PresenceID)
);

-- Table: Languages
CREATE TABLE Languages (
    LanguageID int  NOT NULL,
    LanguageName varchar  NOT NULL,
    CONSTRAINT Languages_pk PRIMARY KEY  (LanguageID)
);

-- Table: MeetingDetails
CREATE TABLE MeetingDetails (
    MeetingID int  NOT NULL,
    MeetingType int  NOT NULL,
    MeetingDescription varchar  NULL,
    RoomID int  NOT NULL,
    NumberOfStudentsLimit int  NULL,
    Link varchar  NULL,
    CONSTRAINT MeetingDetails_pk PRIMARY KEY  (MeetingID)
);

-- Table: OrderDetails
CREATE TABLE OrderDetails (
    DetailID int  NOT NULL,
    OrderID int  NOT NULL,
    ActivityID int  NOT NULL,
    TypeOfActivity int  NOT NULL,
    Price money  NOT NULL,
    Paid bit  NOT NULL,
    CONSTRAINT OrderDetails_pk PRIMARY KEY  (DetailID)
);

-- Table: Orders
CREATE TABLE Orders (
    OrderID int  NOT NULL,
    StudentID int  NOT NULL,
    OrderDate datetime  NOT NULL,
    EntryFeePaid date  NULL,
    PaymentDeferred bit  NOT NULL,
    DeferredDate date  NULL,
    PaymentLink varchar  NULL,
    PaymentStatus varchar  NULL,
    CONSTRAINT Orders_pk PRIMARY KEY  (OrderID)
);

-- Table: Roles
CREATE TABLE Roles (
    RoleID int  NOT NULL,
    RoleName varchar  NOT NULL,
    CONSTRAINT Roles_pk PRIMARY KEY  (RoleID)
);

-- Table: Rooms
CREATE TABLE Rooms (
    RoomID int  NOT NULL,
    RoomName varchar  NOT NULL,
    Street varchar  NOT NULL,
    PostalCode varchar(6)  NOT NULL,
    CityID int  NOT NULL,
    Limit int  NOT NULL,
    CONSTRAINT Rooms_pk PRIMARY KEY  (RoomID)
);

-- Table: Studies
CREATE TABLE Studies (
    StudiesID int  NOT NULL,
    StudiesCoordinatorID int  NOT NULL,
    StudyName varchar  NOT NULL,
    StudyPrice money  NOT NULL,
    StudyDescription varchar  NOT NULL,
    NumberOfTerms int  NOT NULL,
    CONSTRAINT Studies_pk PRIMARY KEY  (StudiesID)
);

-- Table: StudiesResults
CREATE TABLE StudiesResults (
    StudiesID int  NOT NULL,
    StudentID int  NOT NULL,
    GradeID int  NOT NULL,
    CONSTRAINT StudiesResults_pk PRIMARY KEY  (StudiesID,StudentID)
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
    MeetingID int  NOT NULL,
    SubjectID int  NOT NULL,
    LecturerID int  NOT NULL,
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
    SubjectID int  NOT NULL,
    StudiesID int  NOT NULL,
    TeacherID int  NOT NULL,
    SubjectName varchar  NOT NULL,
    SubjectDescription varchar  NOT NULL,
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
    UserID int  NOT NULL,
    FirstName varchar  NOT NULL,
    LastName varchar  NOT NULL,
    Street varchar  NOT NULL,
    PostalCode varchar(6)  NOT NULL,
    CityID int  NOT NULL,
    Email varchar  NOT NULL,
    Phone varchar  NOT NULL,
    DateOfBirth date  NOT NULL,
    CONSTRAINT Users_pk PRIMARY KEY  (UserID)
);

-- Table: Webinars
CREATE TABLE Webinars (
    WebinarID int  NOT NULL,
    WebinarName varchar  NOT NULL,
    WebinarDescription varchar  NOT NULL,
    TeacherID int  NOT NULL,
    Price money  NOT NULL,
    LanguageID int  NOT NULL,
    TranslatorID int  NULL,
    StartDate datetime  NOT NULL,
    EndDate datetime  NOT NULL,
    VideoLink varchar  NULL,
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

-- Reference: CourseSegmentDetails_CourseSegment (table: CourseSegmentDetails)
ALTER TABLE CourseSegmentDetails ADD CONSTRAINT CourseSegmentDetails_CourseSegment
    FOREIGN KEY (SegmentID)
    REFERENCES CourseSegment (SegmentID);

-- Reference: CourseSegmentPresence_CourseSegment (table: CourseSegmentPresence)
ALTER TABLE CourseSegmentPresence ADD CONSTRAINT CourseSegmentPresence_CourseSegment
    FOREIGN KEY (SegmentID)
    REFERENCES CourseSegment (SegmentID);

-- Reference: CourseSegmentPresence_Users (table: CourseSegmentPresence)
ALTER TABLE CourseSegmentPresence ADD CONSTRAINT CourseSegmentPresence_Users
    FOREIGN KEY (UserID)
    REFERENCES Users (UserID);

-- Reference: CourseSegment_Courses (table: CourseSegment)
ALTER TABLE CourseSegment ADD CONSTRAINT CourseSegment_Courses
    FOREIGN KEY (CourseID)
    REFERENCES Courses (CourseID);

-- Reference: CourseSegment_Employees (table: CourseSegment)
ALTER TABLE CourseSegment ADD CONSTRAINT CourseSegment_Employees
    FOREIGN KEY (LecturerID)
    REFERENCES Employees (EmployeeID);

-- Reference: CourseSegment_Employees_1 (table: CourseSegment)
ALTER TABLE CourseSegment ADD CONSTRAINT CourseSegment_Employees_1
    FOREIGN KEY (TranslatorID)
    REFERENCES Employees (EmployeeID);

-- Reference: Courses_Employees (table: Courses)
ALTER TABLE Courses ADD CONSTRAINT Courses_Employees
    FOREIGN KEY (CourseCoordinatorID)
    REFERENCES Employees (EmployeeID);

-- Reference: EmployeeRoles_Employees (table: EmployeeRoles)
ALTER TABLE EmployeeRoles ADD CONSTRAINT EmployeeRoles_Employees
    FOREIGN KEY (EmployeeID)
    REFERENCES Employees (EmployeeID);

-- Reference: EmployeeRoles_Roles (table: EmployeeRoles)
ALTER TABLE EmployeeRoles ADD CONSTRAINT EmployeeRoles_Roles
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

-- Reference: FormOfActivity_CourseSegmentDetails (table: CourseSegmentDetails)
ALTER TABLE CourseSegmentDetails ADD CONSTRAINT FormOfActivity_CourseSegmentDetails
    FOREIGN KEY (SegmentType)
    REFERENCES FormOfActivity (ActivityTypeID);

-- Reference: InternshipPresence_Users (table: InternshipPresence)
ALTER TABLE InternshipPresence ADD CONSTRAINT InternshipPresence_Users
    FOREIGN KEY (StudentID)
    REFERENCES Users (UserID);

-- Reference: Internship_Employees (table: Internship)
ALTER TABLE Internship ADD CONSTRAINT Internship_Employees
    FOREIGN KEY (InternshipCoordinatorID)
    REFERENCES Employees (EmployeeID);

-- Reference: Internship_InternshipPresence (table: InternshipPresence)
ALTER TABLE InternshipPresence ADD CONSTRAINT Internship_InternshipPresence
    FOREIGN KEY (InternshipID)
    REFERENCES Internship (InternshipID);

-- Reference: Internship_Studies (table: Internship)
ALTER TABLE Internship ADD CONSTRAINT Internship_Studies
    FOREIGN KEY (StudiesID)
    REFERENCES Studies (StudiesID);

-- Reference: Languages_CourseSegment (table: CourseSegment)
ALTER TABLE CourseSegment ADD CONSTRAINT Languages_CourseSegment
    FOREIGN KEY (LanguageID)
    REFERENCES Languages (LanguageID);

-- Reference: MeetingDetails_StudyMeetings (table: MeetingDetails)
ALTER TABLE MeetingDetails ADD CONSTRAINT MeetingDetails_StudyMeetings
    FOREIGN KEY (MeetingID)
    REFERENCES StudyMeetings (MeetingID);

-- Reference: MeetingTypes_MeetingDetails (table: MeetingDetails)
ALTER TABLE MeetingDetails ADD CONSTRAINT MeetingTypes_MeetingDetails
    FOREIGN KEY (MeetingType)
    REFERENCES FormOfActivity (ActivityTypeID);

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

-- Reference: Rooms_Cities (table: Rooms)
ALTER TABLE Rooms ADD CONSTRAINT Rooms_Cities
    FOREIGN KEY (CityID)
    REFERENCES Cities (CityID);

-- Reference: Rooms_CourseSegmentDetails (table: CourseSegmentDetails)
ALTER TABLE CourseSegmentDetails ADD CONSTRAINT Rooms_CourseSegmentDetails
    FOREIGN KEY (RoomID)
    REFERENCES Rooms (RoomID);

-- Reference: Rooms_MeetingDetails (table: MeetingDetails)
ALTER TABLE MeetingDetails ADD CONSTRAINT Rooms_MeetingDetails
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

-- End of file.

