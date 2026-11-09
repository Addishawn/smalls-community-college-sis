-- Capstone Phase 3
-- Platform: MySQL
-- Database: college_sis
-- Script 1 of 2: CREATE DATABASE and CREATE TABLE

DROP DATABASE IF EXISTS college_sis;
CREATE DATABASE college_sis;
USE college_sis;

CREATE TABLE Department (
    DepartmentID INT(11) NOT NULL AUTO_INCREMENT,
    DepartmentName VARCHAR(50) NOT NULL,
    OfficeLocation VARCHAR(50),
    Phone VARCHAR(15),
    PRIMARY KEY (DepartmentID),
    UNIQUE (DepartmentName)
);

CREATE TABLE Program (
    ProgramID INT(11) NOT NULL AUTO_INCREMENT,
    ProgramName VARCHAR(100) NOT NULL,
    DegreeType VARCHAR(50) NOT NULL,
    DepartmentID INT(11) NOT NULL,
    PRIMARY KEY (ProgramID),
    CONSTRAINT fk_program_department
        FOREIGN KEY (DepartmentID) REFERENCES Department (DepartmentID)
);

CREATE TABLE Course (
    CourseID INT(11) NOT NULL AUTO_INCREMENT,
    CourseName VARCHAR(100) NOT NULL,
    Credits INT(11) NOT NULL,
    CourseDescription VARCHAR(255),
    DepartmentID INT(11) NOT NULL,
    PRIMARY KEY (CourseID),
    CONSTRAINT fk_course_department
        FOREIGN KEY (DepartmentID) REFERENCES Department (DepartmentID)
);

CREATE TABLE Instructor (
    InstructorID INT(11) NOT NULL AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Phone VARCHAR(15),
    DepartmentID INT(11) NOT NULL,
    PRIMARY KEY (InstructorID),
    UNIQUE (Email),
    CONSTRAINT fk_instructor_department
        FOREIGN KEY (DepartmentID) REFERENCES Department (DepartmentID)
);

CREATE TABLE InstructorProgram (
    InstructorProgramID INT(11) NOT NULL AUTO_INCREMENT,
    InstructorID INT(11) NOT NULL,
    ProgramID INT(11) NOT NULL,
    Role VARCHAR(50),
    PRIMARY KEY (InstructorProgramID),
    UNIQUE (InstructorID, ProgramID),
    CONSTRAINT fk_ip_instructor
        FOREIGN KEY (InstructorID) REFERENCES Instructor (InstructorID),
    CONSTRAINT fk_ip_program
        FOREIGN KEY (ProgramID) REFERENCES Program (ProgramID)
);

CREATE TABLE Term (
    TermID INT(11) NOT NULL AUTO_INCREMENT,
    TermName VARCHAR(30) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    PRIMARY KEY (TermID),
    UNIQUE (TermName)
);

CREATE TABLE Classroom (
    ClassroomID INT(11) NOT NULL AUTO_INCREMENT,
    BuildingName VARCHAR(50) NOT NULL,
    RoomNumber VARCHAR(10) NOT NULL,
    Capacity INT(11) NOT NULL,
    PRIMARY KEY (ClassroomID),
    UNIQUE (BuildingName, RoomNumber)
);

CREATE TABLE Section (
    SectionID INT(11) NOT NULL AUTO_INCREMENT,
    SectionNumber VARCHAR(10) NOT NULL,
    MeetingDays VARCHAR(20),
    MeetingTime VARCHAR(20),
    CourseID INT(11) NOT NULL,
    TermID INT(11) NOT NULL,
    ClassroomID INT(11) NOT NULL,
    InstructorID INT(11) NOT NULL,
    PRIMARY KEY (SectionID),
    CONSTRAINT fk_section_course
        FOREIGN KEY (CourseID) REFERENCES Course (CourseID),
    CONSTRAINT fk_section_term
        FOREIGN KEY (TermID) REFERENCES Term (TermID),
    CONSTRAINT fk_section_classroom
        FOREIGN KEY (ClassroomID) REFERENCES Classroom (ClassroomID),
    CONSTRAINT fk_section_instructor
        FOREIGN KEY (InstructorID) REFERENCES Instructor (InstructorID)
);

CREATE TABLE Student (
    StudentID INT(11) NOT NULL AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE,
    Email VARCHAR(100) NOT NULL,
    Phone VARCHAR(15),
    ProgramID INT(11) NOT NULL,
    PRIMARY KEY (StudentID),
    UNIQUE (Email),
    CONSTRAINT fk_student_program
        FOREIGN KEY (ProgramID) REFERENCES Program (ProgramID)
);

CREATE TABLE Enrollment (
    EnrollmentID INT(11) NOT NULL AUTO_INCREMENT,
    StudentID INT(11) NOT NULL,
    SectionID INT(11) NOT NULL,
    EnrollmentDate DATE NOT NULL,
    Grade VARCHAR(5),
    PRIMARY KEY (EnrollmentID),
    UNIQUE (StudentID, SectionID),
    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (StudentID) REFERENCES Student (StudentID),
    CONSTRAINT fk_enrollment_section
        FOREIGN KEY (SectionID) REFERENCES Section (SectionID)
);

CREATE TABLE Payment (
    PaymentID INT(11) NOT NULL AUTO_INCREMENT,
    StudentID INT(11) NOT NULL,
    PaymentDate DATE NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentMethod VARCHAR(30) NOT NULL,
    PaymentStatus VARCHAR(20) NOT NULL,
    PRIMARY KEY (PaymentID),
    CONSTRAINT fk_payment_student
        FOREIGN KEY (StudentID) REFERENCES Student (StudentID)
);

CREATE TABLE Payroll (
    PayrollID INT(11) NOT NULL AUTO_INCREMENT,
    InstructorID INT(11) NOT NULL,
    PayDate DATE NOT NULL,
    PayPeriod VARCHAR(20) NOT NULL,
    GrossPay DECIMAL(10,2) NOT NULL,
    TaxAmount DECIMAL(10,2) NOT NULL,
    NetPay DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (PayrollID),
    CONSTRAINT fk_payroll_instructor
        FOREIGN KEY (InstructorID) REFERENCES Instructor (InstructorID)
);
