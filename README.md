
## Project Overview
This project delivers a functional database system for a company offering various types of courses and training programs.

Realized as part of the Database Basics course at AGH University of Krakow by:
- Jagoda Kurosad [jagodakurosad](https://github.com/jagodakurosad)
- Katarzyna Bęben [kasiabeben10](https://github.com/kasiabeben10)
- Oskar Blajsz [Blajszu](https://github.com/Blajszu)

## Implemented Services

1. **Webinars**
   - Live sessions hosted on popular cloud platforms, recorded, and made available for participants for 30 days.
   - No binary data is stored in the database; recordings are stored externally.
   - Webinars can be free or paid, and access requires a registered account and payment confirmation for paid webinars.
   - Webinars remain available indefinitely unless deleted by an administrator.

2. **Courses**
   - Short training programs lasting a few days, available only as paid courses.
   - Completion requires passing at least 80% of the modules.
   - Implemented module types:
     - **On-site**: Attendance-based completion.
     - **Online synchronous**: Live webinars recorded externally, attendance-based completion.
     - **Online asynchronous**: Completion based on viewing a provided recording (automatic verification).
     - **Hybrid**: Combination of online and on-site components (e.g., two recordings and two on-site days).

3. **Study Programs**
   - Long-term (multi-year) educational programs, consisting of both online and on-site meetings.
   - Require completion of internships (twice per year) and a final exam.
   - Syllabus is predefined and immutable.
   - Semester schedules are predefined with flexibility for necessary adjustments.
   - Participation in at least 80% of sessions is required, with makeup options for missed sessions.
   - Internships last 14 days and require 100% attendance.
   - Individual study program sessions can be attended separately at different pricing for external participants.

## Payment System Integration
- The system integrates with an external payment provider.
- Users can add multiple products to their cart, and a payment link is generated for each order.
- Paid webinars grant access upon successful payment.
- Course enrollment requires a deposit and full payment at least three days before the start.
- Study programs require an enrollment fee and per-session payments at least three days before each session.
- The School Director can grant exceptions (e.g., deferred payments for long-term clients).

## Reporting Features
The system includes database views for generating essential reports. Some implemented reports:
1. **Financial Reports**: Revenue summaries for each webinar, course, and study program.
2. **Debtors List**: Users who attended services but failed to complete payment.
3. **Enrollment Overview**: Number of registered participants for upcoming events, categorized by format.
4. **Attendance Reports**: Summary of attendance for completed events.
5. **Attendance Lists**: Training session records including date, name, surname, and attendance status.
6. **Double-Booking Report**: Users enrolled in overlapping future training sessions.

## Additional Features
- All educational activities are conducted by assigned lecturers in a specific language (typically Polish).
- Some sessions include live translation into Polish, with translator details stored in the database.
- Webinars and online courses have no participant limits; hybrid and on-site courses have specific capacity constraints.
- Study programs have participant limits based on session availability.
- Participants receive a diploma upon completion, sent via traditional mail.

## Technical Implementation

### Database Schema
![Image](https://github.com/user-attachments/assets/98526965-c013-4dce-a60e-b9289da072c2)

### System Functionalities
- User roles and corresponding privileges are defined.
- Database design and implementation completed.
- The database is populated with generated data.
- Integrity constraints enforced:
  - Default values, valid ranges, unique fields, required fields.
  - Complex integrity conditions ensuring business logic compliance.

### Database Views
- Views facilitate data access for users.
- Reports are implemented as predefined views for financial, attendance, and enrollment tracking.

### Data Operations
- Stored procedures implemented for data insertion and configuration changes.
- Functions provide key quantitative insights.
- Triggers enforce data consistency and business rules.

### Indexing & Permissions
- Indexes optimize query performance.
- Roles and access privileges are established for database operations, views, and stored procedures.

This system successfully delivers a structured, scalable, and efficient database solution for managing online and on-site educational services.

>[!NOTE]
> The database system has been designed and implemented for Microsoft SQL Server and is fully compatible with SQL Server Management Studio (SSMS).
>Deployment on other database management systems (e.g., MySQL, PostgreSQL) would require modifications.

Very basic documentation (in Polish) available [here](https://github.com/blajszu/DataBasesProject/tree/main/documentation.pdf).


