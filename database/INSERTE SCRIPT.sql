-- Capstone Phase 3
-- Platform: MySQL
-- Database: college_sis
-- Script 2 of 2: INSERT (minimum 5 rows per table)
-- Run college_sis_create.sql first.

USE college_sis;

INSERT INTO Department (DepartmentID, DepartmentName, OfficeLocation, Phone) VALUES
(1, 'Computer Science', 'Tech 210', '561-555-0101'),
(2, 'Business', 'Admin 105', '561-555-0102'),
(3, 'Mathematics', 'Science 320', '561-555-0103'),
(4, 'English', 'Arts 140', '561-555-0104'),
(5, 'Nursing', 'Health 401', '561-555-0105');

INSERT INTO Program (ProgramID, ProgramName, DegreeType, DepartmentID) VALUES
(1, 'Database Analytics', 'BS', 1),
(2, 'Software Development', 'AS', 1),
(3, 'Business Administration', 'BS', 2),
(4, 'Applied Mathematics', 'AS', 3),
(5, 'Registered Nursing', 'AS', 5);

INSERT INTO Course (CourseID, CourseName, Credits, CourseDescription, DepartmentID) VALUES
(1, 'Database Design', 3, 'Relational modeling, keys, and normalization', 1),
(2, 'SQL Programming', 3, 'Queries, joins, and data manipulation', 1),
(3, 'Intro to Business', 3, 'Foundations of business operations', 2),
(4, 'College Algebra', 3, 'Functions, equations, and graphs', 3),
(5, 'Anatomy and Physiology', 4, 'Human body systems for health majors', 5);

INSERT INTO Instructor (InstructorID, FirstName, LastName, Email, Phone, DepartmentID) VALUES
(1, 'Maria', 'Santos', 'msantos@college.edu', '561-555-1101', 1),
(2, 'James', 'Cole', 'jcole@college.edu', '561-555-1102', 1),
(3, 'Aisha', 'Rahman', 'arahman@college.edu', '561-555-1103', 2),
(4, 'David', 'Nguyen', 'dnguyen@college.edu', '561-555-1104', 3),
(5, 'Elena', 'Brooks', 'ebrooks@college.edu', '561-555-1105', 5);

INSERT INTO InstructorProgram (InstructorProgramID, InstructorID, ProgramID, Role) VALUES
(1, 1, 1, 'Coordinator'),
(2, 2, 2, 'Faculty'),
(3, 3, 3, 'Advisor'),
(4, 4, 4, 'Faculty'),
(5, 5, 5, 'Coordinator');

INSERT INTO Term (TermID, TermName, StartDate, EndDate) VALUES
(1, 'Fall 2025', '2025-08-25', '2025-12-12'),
(2, 'Spring 2026', '2026-01-12', '2026-05-08'),
(3, 'Summer 2026', '2026-05-18', '2026-08-07'),
(4, 'Fall 2026', '2026-08-24', '2026-12-11'),
(5, 'Spring 2027', '2027-01-11', '2027-05-07');

INSERT INTO Classroom (ClassroomID, BuildingName, RoomNumber, Capacity) VALUES
(1, 'Tech', '101', 32),
(2, 'Tech', '205', 28),
(3, 'Admin', '110', 40),
(4, 'Science', '214', 30),
(5, 'Health', '305', 24);

INSERT INTO Section (SectionID, SectionNumber, MeetingDays, MeetingTime, CourseID, TermID, ClassroomID, InstructorID) VALUES
(1, '001', 'MW', '09:00-10:15', 1, 4, 1, 1),
(2, '002', 'TR', '11:00-12:15', 2, 4, 2, 2),
(3, '001', 'MW', '13:00-14:15', 3, 4, 3, 3),
(4, '001', 'TR', '08:00-09:15', 4, 4, 4, 4),
(5, '001', 'MW', '10:30-12:20', 5, 4, 5, 5);

INSERT INTO Student (StudentID, FirstName, LastName, DateOfBirth, Email, Phone, ProgramID) VALUES
(1, 'Liam', 'Carter', '2004-03-14', 'lcarter@student.edu', '561-555-2101', 1),
(2, 'Sofia', 'Patel', '2003-11-02', 'spatel@student.edu', '561-555-2102', 1),
(3, 'Noah', 'Bennett', '2005-06-21', 'nbennett@student.edu', '561-555-2103', 2),
(4, 'Emma', 'Garcia', '2002-09-09', 'egarcia@student.edu', '561-555-2104', 3),
(5, 'Omar', 'Hassan', '2004-01-28', 'ohassan@student.edu', '561-555-2105', 5);

INSERT INTO Enrollment (EnrollmentID, StudentID, SectionID, EnrollmentDate, Grade) VALUES
(1, 1, 1, '2026-08-20', 'A'),
(2, 2, 1, '2026-08-20', 'B'),
(3, 3, 2, '2026-08-21', 'A'),
(4, 4, 3, '2026-08-19', 'B'),
(5, 5, 5, '2026-08-22', 'IP');

INSERT INTO Payment (PaymentID, StudentID, PaymentDate, Amount, PaymentMethod, PaymentStatus) VALUES
(1, 1, '2026-08-15', 1450.00, 'Card', 'Paid'),
(2, 2, '2026-08-16', 1450.00, 'Aid', 'Paid'),
(3, 3, '2026-08-18', 980.00, 'Card', 'Paid'),
(4, 4, '2026-08-17', 1200.00, 'Cash', 'Pending'),
(5, 5, '2026-08-19', 1600.00, 'Aid', 'Paid');

INSERT INTO Payroll (PayrollID, InstructorID, PayDate, PayPeriod, GrossPay, TaxAmount, NetPay) VALUES
(1, 1, '2026-09-15', '2026-09', 4200.00, 840.00, 3360.00),
(2, 2, '2026-09-15', '2026-09', 3900.00, 780.00, 3120.00),
(3, 3, '2026-09-15', '2026-09', 4100.00, 820.00, 3280.00),
(4, 4, '2026-09-15', '2026-09', 3800.00, 760.00, 3040.00),
(5, 5, '2026-09-15', '2026-09', 4500.00, 900.00, 3600.00);
