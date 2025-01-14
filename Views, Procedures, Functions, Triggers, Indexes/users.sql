CREATE ROLE admin;
GRANT BACKUP DATABASE TO admin;
GRANT BACKUP LOG TO admin;




CREATE ROLE director;
GRANT SELECT ON bilocation_report TO director;
GRANT SELECT ON defferedPayments TO director;
GRANT SELECT ON VW_allOrderedActivities TO director;
GRANT SELECT ON VW_allPastUsersWebinars TO director;
GRANT SELECT ON VW_allUsersCourseMeetings TO director;
GRANT SELECT ON VW_allUsersCurrentCourseMeetings TO director;
GRANT SELECT ON VW_allUsersCurrentMeetings TO director;
GRANT SELECT ON VW_allUsersCurrentStudyMeetings TO director;
GRANT SELECT ON VW_allUsersCurrentWebinars TO director;
GRANT SELECT ON VW_allUsersFutureCourseMeetings TO director;
GRANT SELECT ON VW_allUsersFutureMeetings TO director;
GRANT SELECT ON VW_allUsersFutureStudyMeetings TO director;
GRANT SELECT ON VW_allUsersFutureWebinars TO director;
GRANT SELECT ON VW_allUsersMeetings TO director;
GRANT SELECT ON VW_allUsersPastCourseMeetings TO director;
GRANT SELECT ON VW_allUsersPastMeetings TO director;
GRANT SELECT ON VW_allUsersPastStudyMeetings TO director;
GRANT SELECT ON VW_allUsersStationaryMeetingsWithRoomAndAddresses TO director;
GRANT SELECT ON VW_allUsersStudyMeetings TO director;
GRANT SELECT ON VW_allUsersWebinars TO director;
GRANT SELECT ON VW_BilocationBetweenAllActivities TO director;
GRANT SELECT ON vw_CourseCoordinators TO director;
GRANT SELECT ON vw_CourseModulesLanguages TO director;
GRANT SELECT ON VW_CourseModulesPassed TO director;
GRANT SELECT ON vw_CoursesCertificates TO director;
GRANT SELECT ON vw_CoursesCertificatesAddresses TO director;
GRANT SELECT ON VW_CoursesCoordinators TO director;
GRANT SELECT ON vw_CoursesLecturers TO director;
GRANT SELECT ON VW_CoursesStartDateEndDate TO director;
GRANT SELECT ON vw_CoursesWithModules TO director;
GRANT SELECT ON VW_CurrentCoursesPassed TO director;
GRANT SELECT ON vw_Debtors TO director;
GRANT SELECT ON vw_EmployeeDegrees TO director;
GRANT SELECT ON VW_EmployeesFunctionsAndSeniority TO director;
GRANT SELECT ON VW_IncomeFromAllFormOfEducation TO director;
GRANT SELECT ON VW_IncomeFromCourses TO director;
GRANT SELECT ON VW_IncomeFromStudies TO director;
GRANT SELECT ON VW_IncomeFromWebinars TO director;
GRANT SELECT ON vw_InternshipCoordinators TO director;
GRANT SELECT ON vw_InternshipDetails TO director;
GRANT SELECT ON vw_InternshipsParticipants TO director;
GRANT SELECT ON VW_LanguagesAndTranslatorsOnCourses TO director;
GRANT SELECT ON VW_LanguagesAndTranslatorsOnStudies TO director;
GRANT SELECT ON VW_LanguagesAndTranslatorsOnWebinars TO director;
GRANT SELECT ON vw_LecturerMeetings TO director;
GRANT SELECT ON vw_Lecturers TO director;
GRANT SELECT ON vw_MeetingsWithAbsences TO director;
GRANT SELECT ON vw_NumberOfHoursOfWOrkForAllEmployees TO director;
GRANT SELECT ON VW_NumberOfStudentsSignUpForFutureAllFormOfEducation TO director;
GRANT SELECT ON VW_NumberOfStudentsSignUpForFutureCourses TO director;
GRANT SELECT ON VW_NumberOfStudentsSignUpForFutureStudyMeetings TO director;
GRANT SELECT ON VW_NumberOfStudentsSignUpForFutureWebinars TO director;
GRANT SELECT ON vw_OrdersWithDetails TO director;
GRANT SELECT ON vw_PresenceOnPastStudyMeeting TO director;
GRANT SELECT ON VW_RoomsAvailability TO director;
GRANT SELECT ON vw_Students TO director;
GRANT SELECT ON vw_StudentsAttendanceAtSubjects TO director;
GRANT SELECT ON vw_StudentsDiplomas TO director;
GRANT SELECT ON vw_StudentsGradesWithSubjects TO director;
GRANT SELECT ON VW_StudentsPlaceOfLive TO director;
GRANT SELECT ON VW_StudiesCoordinators TO director;
GRANT SELECT ON VW_StudiesStartDateEndDate TO director;
GRANT SELECT ON vw_StudyCoordinator TO director;
GRANT SELECT ON VW_StudyMeetingDurationTimeNumberOfStudents TO director;
GRANT SELECT ON vw_StudyMeetings TO director;
GRANT SELECT ON VW_StudyMeetingsPresenceWithFirstNameLastNameDate TO director;
GRANT SELECT ON vw_SubjectsEachGradesNumber TO director;
GRANT SELECT ON vw_TranslatorsWithLanguages TO director;
GRANT SELECT ON VW_UsersDiplomasAddresses TO director;
GRANT SELECT ON VW_UsersPersonalData TO director;
GRANT SELECT ON vw_UsersWithRoles TO director;
GRANT SELECT ON vw_WebinarsLanguages TO director;
GRANT SELECT ON vw_WebinarsWithDetails TO director;
GRANT SELECT ON vw_WebinarTeachers TO director;

GRANT EXECUTE ON ActivateDeactivateUser TO director;
GRANT EXECUTE ON AddCity TO director;
GRANT EXECUTE ON AddCountry TO director;
GRANT EXECUTE ON AddCourseMeeting TO director;
GRANT EXECUTE ON AddCourseModule TO director;
GRANT EXECUTE ON AddEmployee TO director;
GRANT EXECUTE ON AddInternship TO director;
GRANT EXECUTE ON AddLanguage TO director;
GRANT EXECUTE ON AddNewCourse TO director;
GRANT EXECUTE ON AddNewStudy TO director;
GRANT EXECUTE ON AddNewSubject TO director;
GRANT EXECUTE ON AddNewWebinar TO director;
GRANT EXECUTE ON AddOrderWithDetails TO director;
GRANT EXECUTE ON AddRoom TO director;
GRANT EXECUTE ON AddStudyResult TO director;
GRANT EXECUTE ON AddSubjectMeeting TO director;
GRANT EXECUTE ON AddSubjectResult TO director;
GRANT EXECUTE ON AddTranslatedLanguage TO director;
GRANT EXECUTE ON AddUser TO director;
GRANT EXECUTE ON AddUserRole TO director;
GRANT EXECUTE ON AddUserWithRoleAndEmployee TO director;
GRANT EXECUTE ON DeleteCourse TO director;
GRANT EXECUTE ON DeleteCourseMeeting TO director;
GRANT EXECUTE ON DeleteCourseModule TO director;
GRANT EXECUTE ON DeleteEmployee TO director;
GRANT EXECUTE ON DeleteInternship TO director;
GRANT EXECUTE ON DeleteInternshipResult TO director;
GRANT EXECUTE ON DeleteLanguageFromTranslatedLanguage TO director;
GRANT EXECUTE ON DeleteOrder TO director;
GRANT EXECUTE ON DeleteOrderDetail TO director;
GRANT EXECUTE ON DeleteStudiesResult TO director;
GRANT EXECUTE ON DeleteStudy TO director;
GRANT EXECUTE ON DeleteStudyMeeting TO director;
GRANT EXECUTE ON DeleteSubject TO director;
GRANT EXECUTE ON DeleteSubjectResult TO director;
GRANT EXECUTE ON DeleteTranslatedLanguage TO director;
GRANT EXECUTE ON DeleteUser TO director;
GRANT EXECUTE ON DeleteUserRole TO director;
GRANT EXECUTE ON DeleteWebinar TO director;
GRANT EXECUTE ON GetRemainingSeats TO director;
GRANT EXECUTE ON ModifyInternshipResult TO director;
GRANT EXECUTE ON ModifyOrder TO director;
GRANT EXECUTE ON ModifyOrderDetail TO director;
GRANT EXECUTE ON ModifyStudiesResult TO director;
GRANT EXECUTE ON ModifySubjectResult TO director;
GRANT EXECUTE ON ModifyUserRole TO director;
GRANT EXECUTE ON UpdateCity TO director;
GRANT EXECUTE ON UpdateCountry TO director;
GRANT EXECUTE ON UpdateCourse TO director;
GRANT EXECUTE ON UpdateCourseModule TO director;
GRANT EXECUTE ON UpdateCourseModuleMeeting TO director;
GRANT EXECUTE ON UpdateEmployee TO director;
GRANT EXECUTE ON UpdateInternship TO director;
GRANT EXECUTE ON UpdateLanguage TO director;
GRANT EXECUTE ON UpdateRoom TO director;
GRANT EXECUTE ON UpdateStudies TO director;
GRANT EXECUTE ON UpdateStudyMeeting TO director;
GRANT EXECUTE ON UpdateSubject TO director;
GRANT EXECUTE ON UpdateTranslatedLanguage TO director;
GRANT EXECUTE ON UpdateUser TO director;
GRANT EXECUTE ON UpdateWebinar TO director;

GRANT EXECUTE ON CheckIfStudentPassed TO director;
GRANT EXECUTE ON CheckIfStudentPassedCourse TO director;
GRANT EXECUTE ON CheckStudentPresenceOnActivity TO director;
GRANT EXECUTE ON fn_diagramobjects TO director;
GRANT SELECT ON GetAvailableRooms TO director;
GRANT SELECT ON GetCourseModulesPassed TO director;
GRANT SELECT ON GetCurrentMeetingsForStudent TO director;
GRANT SELECT ON GetFutureMeetingsForStudent TO director;
GRANT SELECT ON GetMeetingsInCity TO director;
GRANT SELECT ON GetNumberOfHoursOfWorkForAllEmployees TO director;
GRANT SELECT ON GetProductsFromOrder TO director;
GRANT SELECT ON GetStudentOrders TO director;
GRANT SELECT ON GetStudentResultsFromStudies TO director;
GRANT SELECT ON GetUserDiplomasAndCertificates TO director;



CREATE ROLE study_coordinator;
GRANT SELECT ON VW_allUsersCurrentStudyMeetings TO study_coordinator;
GRANT SELECT ON VW_allUsersFutureStudyMeetings TO study_coordinator;
GRANT SELECT ON VW_allUsersPastStudyMeetings TO study_coordinator;
GRANT SELECT ON vw_InternshipCoordinators TO study_coordinator;
GRANT SELECT ON vw_InternshipDetails TO study_coordinator;
GRANT SELECT ON vw_InternshipsParticipants TO study_coordinator;
GRANT SELECT ON VW_LanguagesAndTranslatorsOnStudies TO study_coordinator;
GRANT SELECT ON vw_LecturerMeetings TO study_coordinator;
GRANT SELECT ON vw_Lecturers TO study_coordinator;
GRANT SELECT ON vw_MeetingsWithAbsences TO study_coordinator;
GRANT SELECT ON VW_NumberOfStudentsSignUpForFutureStudyMeetings TO study_coordinator;
GRANT SELECT ON vw_PresenceOnPastStudyMeeting TO study_coordinator;
GRANT SELECT ON VW_RoomsAvailability TO study_coordinator;
GRANT SELECT ON vw_Students TO study_coordinator;
GRANT SELECT ON vw_StudentsAttendanceAtSubjects TO study_coordinator;
GRANT SELECT ON vw_StudentsDiplomas TO study_coordinator;
GRANT SELECT ON vw_StudentsGradesWithSubjects TO study_coordinator;
GRANT SELECT ON VW_StudentsPlaceOfLive TO study_coordinator;
GRANT SELECT ON VW_StudiesStartDateEndDate TO study_coordinator;
GRANT SELECT ON VW_StudyMeetingDurationTimeNumberOfStudents TO study_coordinator;
GRANT SELECT ON vw_StudyMeetings TO study_coordinator;
GRANT SELECT ON VW_StudyMeetingsPresenceWithFirstNameLastNameDate TO study_coordinator;
GRANT SELECT ON vw_SubjectsEachGradesNumber TO study_coordinator;
GRANT SELECT ON vw_TranslatorsWithLanguages TO study_coordinator;
GRANT SELECT ON VW_UsersDiplomasAddresses TO study_coordinator;

GRANT EXECUTE ON AddStudyResult TO study_coordinator;
GRANT EXECUTE ON AddSubjectMeeting TO study_coordinator;
GRANT EXECUTE ON DeleteStudyMeeting TO study_coordinator;
GRANT EXECUTE ON ModifyStudiesResult TO study_coordinator;
GRANT EXECUTE ON UpdateInternship TO study_coordinator;
GRANT EXECUTE ON UpdateStudies TO study_coordinator;
GRANT EXECUTE ON UpdateStudyMeeting TO study_coordinator;
GRANT EXECUTE ON UpdateSubject TO study_coordinator;
GRANT EXECUTE ON AddStudyResult TO study_coordinator;
GRANT EXECUTE ON DeleteStudiesResult TO study_coordinator;

GRANT EXECUTE ON CheckStudentPresenceOnActivity TO study_coordinator;
GRANT SELECT ON GetAvailableRooms TO study_coordinator;


CREATE ROLE course_coordinator;
GRANT SELECT ON VW_allUsersCourseMeetings TO course_coordinator;
GRANT SELECT ON VW_allUsersCurrentCourseMeetings TO course_coordinator;
GRANT SELECT ON VW_allUsersFutureCourseMeetings TO course_coordinator;
GRANT SELECT ON VW_allUsersPastCourseMeetings TO course_coordinator;
GRANT SELECT ON vw_CourseCoordinators TO course_coordinator;
GRANT SELECT ON vw_CourseModulesLanguages TO course_coordinator;
GRANT SELECT ON VW_CourseModulesPassed TO course_coordinator;
GRANT SELECT ON vw_CoursesCertificates TO course_coordinator;
GRANT SELECT ON vw_CoursesCertificatesAddresses TO course_coordinator;
GRANT SELECT ON VW_CoursesCoordinators TO course_coordinator;
GRANT SELECT ON vw_CoursesLecturers TO course_coordinator;
GRANT SELECT ON VW_CoursesStartDateEndDate TO course_coordinator;
GRANT SELECT ON vw_CoursesWithModules TO course_coordinator;
GRANT SELECT ON VW_CurrentCoursesPassed TO course_coordinator;
GRANT SELECT ON VW_LanguagesAndTranslatorsOnCourses TO course_coordinator;
GRANT SELECT ON VW_NumberOfStudentsSignUpForFutureCourses TO course_coordinator;
GRANT SELECT ON vw_TranslatorsWithLanguages TO course_coordinator;

GRANT EXECUTE ON UpdateCourse TO course_coordinator;
GRANT EXECUTE ON UpdateCourseModule TO course_coordinator;
GRANT EXECUTE ON UpdateCourseModuleMeeting TO course_coordinator;
GRANT EXECUTE ON UpdateCourseModulePassed TO course_coordinator;

GRANT SELECT ON GetAvailableRooms TO course_coordinator;
GRANT SELECT ON GetCourseModulesPassed TO course_coordinator;




CREATE ROLE webinars_coordinator;
GRANT SELECT ON VW_allPastUsersWebinars TO webinars_coordinator;
GRANT SELECT ON VW_allUsersCurrentWebinars TO webinars_coordinator;
GRANT SELECT ON VW_allUsersFutureWebinars TO webinars_coordinator;
GRANT SELECT ON VW_allUsersWebinars TO webinars_coordinator;
GRANT SELECT ON VW_LanguagesAndTranslatorsOnWebinars TO webinars_coordinator;
GRANT SELECT ON vw_Lecturers TO webinars_coordinator;
GRANT SELECT ON VW_NumberOfStudentsSignUpForFutureWebinars TO webinars_coordinator;
GRANT SELECT ON vw_TranslatorsWithLanguages TO webinars_coordinator;
GRANT SELECT ON vw_WebinarsLanguages TO webinars_coordinator;
GRANT SELECT ON vw_WebinarsWithDetails TO webinars_coordinator;
GRANT SELECT ON vw_WebinarTeachers TO webinars_coordinator;

GRANT EXECUTE ON UpdateWebinar TO webinars_coordinator;





CREATE ROLE acountant;
GRANT SELECT ON defferedPayments TO acountant;
GRANT SELECT ON vw_Debtors TO acountant;
GRANT SELECT ON VW_IncomeFromCourses TO acountant;
GRANT SELECT ON VW_IncomeFromStudies TO acountant;
GRANT SELECT ON VW_IncomeFromWebinars TO acountant;
GRANT SELECT ON vw_NumberOfHoursOfWOrkForAllEmployees TO acountant;
GRANT SELECT ON vw_OrdersWithDetails TO acountant;
GRANT SELECT ON vw_Students TO acountant;

GRANT SELECT ON GetNumberOfHoursOfWorkForAllEmployees TO acountant;



CREATE ROLE secretary;
GRANT SELECT ON bilocation_report TO secretary;
GRANT SELECT ON defferedPayments TO secretary;
GRANT SELECT ON VW_allOrderedActivities TO secretary;
GRANT SELECT ON VW_allPastUsersWebinars TO secretary;
GRANT SELECT ON VW_allUsersCourseMeetings TO secretary;
GRANT SELECT ON VW_allUsersCurrentCourseMeetings TO secretary;
GRANT SELECT ON VW_allUsersCurrentMeetings TO secretary;
GRANT SELECT ON VW_allUsersCurrentStudyMeetings TO secretary;
GRANT SELECT ON VW_allUsersCurrentWebinars TO secretary;
GRANT SELECT ON VW_allUsersFutureCourseMeetings TO secretary;
GRANT SELECT ON VW_allUsersFutureMeetings TO secretary;
GRANT SELECT ON VW_allUsersFutureStudyMeetings TO secretary;
GRANT SELECT ON VW_allUsersFutureWebinars TO secretary;
GRANT SELECT ON VW_allUsersMeetings TO secretary;
GRANT SELECT ON VW_allUsersPastCourseMeetings TO secretary;
GRANT SELECT ON VW_allUsersPastMeetings TO secretary;
GRANT SELECT ON VW_allUsersPastStudyMeetings TO secretary;
GRANT SELECT ON VW_allUsersStationaryMeetingsWithRoomAndAddresses TO secretary;
GRANT SELECT ON VW_allUsersStudyMeetings TO secretary;
GRANT SELECT ON VW_allUsersWebinars TO secretary;
GRANT SELECT ON VW_BilocationBetweenAllActivities TO secretary;
GRANT SELECT ON vw_CourseCoordinators TO secretary;
GRANT SELECT ON vw_CourseModulesLanguages TO secretary;
GRANT SELECT ON VW_CourseModulesPassed TO secretary;
GRANT SELECT ON vw_CoursesCertificates TO secretary;
GRANT SELECT ON vw_CoursesCertificatesAddresses TO secretary;
GRANT SELECT ON VW_CoursesCoordinators TO secretary;
GRANT SELECT ON vw_CoursesLecturers TO secretary;
GRANT SELECT ON VW_CoursesStartDateEndDate TO secretary;
GRANT SELECT ON vw_CoursesWithModules TO secretary;
GRANT SELECT ON VW_CurrentCoursesPassed TO secretary;
GRANT SELECT ON vw_Debtors TO secretary;
GRANT SELECT ON vw_EmployeeDegrees TO secretary;
GRANT SELECT ON VW_EmployeesFunctionsAndSeniority TO secretary;
GRANT SELECT ON vw_InternshipCoordinators TO secretary;
GRANT SELECT ON vw_InternshipDetails TO secretary;
GRANT SELECT ON vw_InternshipsParticipants TO secretary;
GRANT SELECT ON VW_LanguagesAndTranslatorsOnCourses TO secretary;
GRANT SELECT ON VW_LanguagesAndTranslatorsOnStudies TO secretary;
GRANT SELECT ON VW_LanguagesAndTranslatorsOnWebinars TO secretary;
GRANT SELECT ON vw_LecturerMeetings TO secretary;
GRANT SELECT ON vw_Lecturers TO secretary;
GRANT SELECT ON vw_MeetingsWithAbsences TO secretary;
GRANT SELECT ON VW_NumberOfStudentsSignUpForFutureAllFormOfEducation TO secretary;
GRANT SELECT ON VW_NumberOfStudentsSignUpForFutureCourses TO secretary;
GRANT SELECT ON VW_NumberOfStudentsSignUpForFutureStudyMeetings TO secretary;
GRANT SELECT ON VW_NumberOfStudentsSignUpForFutureWebinars TO secretary;
GRANT SELECT ON vw_PresenceOnPastStudyMeeting TO secretary;
GRANT SELECT ON VW_RoomsAvailability TO secretary;
GRANT SELECT ON vw_Students TO secretary;
GRANT SELECT ON vw_StudentsAttendanceAtSubjects TO secretary;
GRANT SELECT ON vw_StudentsDiplomas TO secretary;
GRANT SELECT ON vw_StudentsGradesWithSubjects TO secretary;
GRANT SELECT ON VW_StudentsPlaceOfLive TO secretary;
GRANT SELECT ON VW_StudiesCoordinators TO secretary;
GRANT SELECT ON VW_StudiesStartDateEndDate TO secretary;
GRANT SELECT ON vw_StudyCoordinator TO secretary;
GRANT SELECT ON VW_StudyMeetingDurationTimeNumberOfStudents TO secretary;
GRANT SELECT ON vw_StudyMeetings TO secretary;
GRANT SELECT ON VW_StudyMeetingsPresenceWithFirstNameLastNameDate TO secretary;
GRANT SELECT ON vw_SubjectsEachGradesNumber TO secretary;
GRANT SELECT ON vw_TranslatorsWithLanguages TO secretary;
GRANT SELECT ON VW_UsersDiplomasAddresses TO secretary;
GRANT SELECT ON VW_UsersPersonalData TO secretary;
GRANT SELECT ON vw_UsersWithRoles TO secretary;
GRANT SELECT ON vw_WebinarsLanguages TO secretary;
GRANT SELECT ON vw_WebinarsWithDetails TO secretary;
GRANT SELECT ON vw_WebinarTeachers TO secretary;

GRANT EXECUTE ON ActivateDeactivateUser TO secretary;
GRANT EXECUTE ON AddActivityInsteadOfPresence TO secretary;
GRANT EXECUTE ON GetRemainingSeats TO secretary;
GRANT EXECUTE ON ModifyActivityInsteadOfAbsence TO secretary;

GRANT EXECUTE ON CheckIfStudentPassed TO secretary;
GRANT EXECUTE ON CheckIfStudentPassedCourse TO secretary;
GRANT EXECUTE ON CheckStudentPresenceOnActivity TO secretary;
GRANT EXECUTE ON fn_diagramobjects TO secretary;
GRANT SELECT ON GetAvailableRooms TO secretary;
GRANT SELECT ON GetCourseModulesPassed TO secretary;
GRANT SELECT ON GetCurrentMeetingsForStudent TO secretary;
GRANT SELECT ON GetFutureMeetingsForStudent TO secretary;
GRANT SELECT ON GetMeetingsInCity TO secretary;
GRANT SELECT ON GetProductsFromOrder TO secretary;
GRANT SELECT ON GetStudentOrders TO secretary;
GRANT SELECT ON GetStudentResultsFromStudies TO secretary;
GRANT SELECT ON GetUserDiplomasAndCertificates TO secretary;

CREATE ROLE lecturer;
GRANT EXECUTE ON AddStudyMeetingPresence TO lecturer;
GRANT EXECUTE ON DeleteStudyMeetingPresence TO lecturer;
GRANT EXECUTE ON ModifyStudyMeetingPresence TO lecturer;
GRANT EXECUTE ON ModifySubjectResult TO lecturer;
GRANT EXECUTE ON AddSubjectResult TO lecturer;
GRANT EXECUTE ON DeleteSubjectResult TO lecturer;



CREATE ROLE internship_coordinator;
GRANT EXECUTE ON AddInternshipResult TO internship_coordinator;
GRANT EXECUTE ON DeleteInternshipResult TO internship_coordinator;
GRANT EXECUTE ON ModifyInternshipResult TO internship_coordinator;



CREATE ROLE translator;





CREATE ROLE student;
GRANT EXECUTE ON AddOrderWithDetails TO student;
GRANT EXECUTE ON DeleteOrder TO student;
GRANT EXECUTE ON DeleteOrderDetail TO student;
GRANT EXECUTE ON ModifyOrderDetail TO student;

GRANT EXECUTE ON CheckIfStudentPassed TO student;
GRANT EXECUTE ON CheckIfStudentPassedCourse TO student;
GRANT EXECUTE ON CheckStudentPresenceOnActivity TO student;
GRANT SELECT ON GetCurrentMeetingsForStudent TO student;
GRANT SELECT ON GetFutureMeetingsForStudent TO student;
GRANT SELECT ON GetProductsFromOrder TO student;
GRANT SELECT ON GetStudentOrders TO student;
GRANT SELECT ON GetStudentResultsFromStudies TO student;
GRANT SELECT ON GetCourseModulesPassed TO student;
GRANT SELECT ON GetStudentResultsFromStudies TO student;



CREATE ROLE guest;
GRANT EXECUTE ON AddUser TO guest;




CREATE ROLE payment_system;
GRANT EXECUTE ON ModifyOrder TO payment_system;