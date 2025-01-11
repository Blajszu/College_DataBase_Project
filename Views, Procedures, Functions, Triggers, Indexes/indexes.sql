CREATE UNIQUE INDEX IDX_ActivitiesTypes_TypeName
ON ActivitiesTypes (TypeName);

CREATE UNIQUE INDEX IDX_Cities_CityName_CountryID
ON Cities (CityName, CountryID);

CREATE UNIQUE INDEX IDX_Countries_CountryName
ON Countries (CountryName);

CREATE UNIQUE INDEX IDX_Degrees_DegreeName
ON Degrees (DegreeName);

CREATE UNIQUE INDEX IDX_FormOfActivity_TypeName
ON FormOfActivity (TypeName);

CREATE UNIQUE INDEX IDX_Grades_GradeName
ON Grades (GradeName);

CREATE UNIQUE INDEX IDX_Languages_LanguageName
ON Languages (LanguageName);

CREATE UNIQUE INDEX IDX_Roles_RoleName
ON Roles (RoleName);
CREATE UNIQUE INDEX IDX_Users_Email
ON Users (Email);
CREATE INDEX IDX_Users_CityID
ON Users (CityID);

CREATE INDEX IDX_Employees_DegreeID
ON Employees (DegreeID);
CREATE INDEX IDX_Employees_EmployeeID
ON Employees (EmployeeID);

CREATE INDEX IDX_Courses_CourseCoordinatorID
ON Courses (CourseCoordinatorID);
CREATE INDEX IDX_Courses_CoursePrice
ON Courses (CoursePrice);

CREATE INDEX IDX_Studies_StudiesCoordinatorID
ON Studies (StudiesCoordinatorID);
CREATE INDEX IDX_Studies_StudyPrice
ON Studies (StudyPrice);

CREATE INDEX IDX_Subjects_TeacherID
ON Subjects (TeacherID);
CREATE INDEX IDX_Subjects_StudiesID
ON Subjects (StudiesID);

CREATE INDEX IDX_StudyMeetings_LecturerID
ON StudyMeetings (LecturerID);
CREATE INDEX IDX_StudyMeetings_TranslatorID
ON StudyMeetings (TranslatorID);
CREATE INDEX IDX_StudyMeetings_SubjectID
ON StudyMeetings (SubjectID);

CREATE INDEX IDX_StudyMeetingPresence_StudentID
ON StudyMeetingPresence (StudentID);
CREATE INDEX IDX_StudyMeetingPresence_StudyMeetingID
ON StudyMeetingPresence (StudyMeetingID);

CREATE INDEX IDX_CourseModules_CourseID
ON CourseModules (CourseID);
CREATE INDEX IDX_CourseModules_LecturerID
ON CourseModules (LecturerID);
CREATE INDEX IDX_CourseModules_TranslatorID
ON CourseModules (TranslatorID);

CREATE INDEX IDX_CourseModulesPassed_ModuleID
ON CourseModulesPassed (ModuleID);
CREATE INDEX IDX_CourseModulesPassed_StudentID
ON CourseModulesPassed (StudentID);

CREATE INDEX IDX_Internship_InternshipCoordinatorID
ON Internship (InternshipCoordinatorID);
CREATE INDEX IDX_Internship_StudiesID
ON Internship (StudiesID);

CREATE INDEX IDX_InternshipPassed_InternshipID
ON InternshipPassed (InternshipID);
CREATE INDEX IDX_InternshipPassed_StudentID
ON InternshipPassed (StudentID);

CREATE INDEX IDX_OrderDetails_OrderID
ON OrderDetails (OrderID);
CREATE INDEX IDX_OrderDetails_TypeOfActivity
ON OrderDetails (TypeOfActivity);

CREATE INDEX IDX_Orders_StudentID
ON Orders (StudentID);

CREATE INDEX IDX_PaymentsAdvances_DetailID
ON PaymentsAdvances (DetailID);

CREATE INDEX IDX_Rooms_CityID
ON Rooms (CityID);

CREATE INDEX IDX_StationaryMeetings_RoomID
ON StationaryMeetings (RoomID);
CREATE INDEX IDX_StationaryMeetings_MeetingID
ON StationaryMeetings (MeetingID);

CREATE INDEX IDX_StationaryCourseMeeting_ModuleID
ON StationaryCourseMeeting (ModuleID);
CREATE INDEX IDX_StationaryCourseMeeting_RoomID
ON StationaryCourseMeeting (RoomID);

CREATE INDEX IDX_Webinars_TeacherID
ON Webinars (TeacherID);
CREATE INDEX IDX_Webinars_TranslatorID
ON Webinars (TranslatorID);
CREATE INDEX IDX_Webinars_LanguageID
ON Webinars (LanguageID);

CREATE INDEX IDX_UsersRoles_UserID
ON UsersRoles (UserID);
CREATE INDEX IDX_UsersRoles_RoleID
ON UsersRoles (RoleID);
