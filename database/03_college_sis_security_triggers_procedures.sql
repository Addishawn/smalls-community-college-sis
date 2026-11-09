USE college_sis;

-- =============================================
-- 1. USER ROLES AND PERMISSIONS
-- =============================================

CREATE ROLE IF NOT EXISTS admin_role;
CREATE ROLE IF NOT EXISTS registrar_role;
CREATE ROLE IF NOT EXISTS instructor_role;
CREATE ROLE IF NOT EXISTS student_role;

GRANT ALL PRIVILEGES ON college_sis.*
TO admin_role;

-- Registrar permissions
GRANT SELECT, INSERT, UPDATE, DELETE
ON college_sis.Student TO registrar_role;

GRANT SELECT, INSERT, UPDATE, DELETE
ON college_sis.Enrollment TO registrar_role;

GRANT SELECT, INSERT, UPDATE, DELETE
ON college_sis.Payment TO registrar_role;

GRANT SELECT, INSERT, UPDATE
ON college_sis.`Section` TO registrar_role;

GRANT SELECT ON college_sis.Course TO registrar_role;
GRANT SELECT ON college_sis.Program TO registrar_role;
GRANT SELECT ON college_sis.Term TO registrar_role;
GRANT SELECT ON college_sis.Classroom TO registrar_role;
GRANT SELECT ON college_sis.Instructor TO registrar_role;

-- Instructor permissions
GRANT SELECT ON college_sis.Course TO instructor_role;
GRANT SELECT ON college_sis.`Section` TO instructor_role;
GRANT SELECT ON college_sis.Student TO instructor_role;
GRANT SELECT ON college_sis.Enrollment TO instructor_role;

-- Allow instructors to change grades only
GRANT UPDATE (Grade)
ON college_sis.Enrollment TO instructor_role;

GRANT SELECT ON college_sis.Term TO instructor_role;
GRANT SELECT ON college_sis.Classroom TO instructor_role;

-- Student permissions: general academic catalog
GRANT SELECT ON college_sis.Course TO student_role;
GRANT SELECT ON college_sis.`Section` TO student_role;
GRANT SELECT ON college_sis.Term TO student_role;
GRANT SELECT ON college_sis.Program TO student_role;

-- Replace placeholder passwords before execution.
-- Restrict the host (%) in production environments.
CREATE USER IF NOT EXISTS 'admin_user'@'%'
IDENTIFIED BY 'REPLACE_WITH_SECURE_ADMIN_PASSWORD';

CREATE USER IF NOT EXISTS 'registrar_user'@'%'
IDENTIFIED BY 'REPLACE_WITH_SECURE_REGISTRAR_PASSWORD';

CREATE USER IF NOT EXISTS 'instructor_user'@'%'
IDENTIFIED BY 'REPLACE_WITH_SECURE_INSTRUCTOR_PASSWORD';

CREATE USER IF NOT EXISTS 'student_user'@'%'
IDENTIFIED BY 'REPLACE_WITH_SECURE_STUDENT_PASSWORD';

GRANT admin_role TO 'admin_user'@'%';
GRANT registrar_role TO 'registrar_user'@'%';
GRANT instructor_role TO 'instructor_user'@'%';
GRANT student_role TO 'student_user'@'%';

SET DEFAULT ROLE ALL TO 'admin_user'@'%';
SET DEFAULT ROLE ALL TO 'registrar_user'@'%';
SET DEFAULT ROLE ALL TO 'instructor_user'@'%';
SET DEFAULT ROLE ALL TO 'student_user'@'%';


-- =============================================
-- 2. TRIGGERS
-- =============================================

DELIMITER $$

-- Trigger 1: Check classroom capacity
DROP TRIGGER IF EXISTS trg_enrollment_capacity$$

CREATE TRIGGER trg_enrollment_capacity
BEFORE INSERT ON Enrollment
FOR EACH ROW
BEGIN
    DECLARE v_capacity INT DEFAULT NULL;
    DECLARE v_current INT DEFAULT 0;

    SELECT c.Capacity INTO v_capacity
    FROM `Section` s
    JOIN Classroom c
        ON s.ClassroomID = c.ClassroomID
    WHERE s.SectionID = NEW.SectionID;

    IF v_capacity IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Classroom capacity not found.';
    END IF;

    SELECT COUNT(*) INTO v_current
    FROM Enrollment
    WHERE SectionID = NEW.SectionID;

    IF v_current >= v_capacity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Section is full. Cannot enroll.';
    END IF;
END$$


-- Trigger 2a: Calculate net pay on insertion
DROP TRIGGER IF EXISTS trg_payroll_netpay$$

CREATE TRIGGER trg_payroll_netpay
BEFORE INSERT ON Payroll
FOR EACH ROW
BEGIN
    SET NEW.NetPay = NEW.GrossPay - NEW.TaxAmount;
END$$


-- Trigger 2b: Recalculate net pay on updates
DROP TRIGGER IF EXISTS trg_payroll_netpay_update$$

CREATE TRIGGER trg_payroll_netpay_update
BEFORE UPDATE ON Payroll
FOR EACH ROW
BEGIN
    SET NEW.NetPay = NEW.GrossPay - NEW.TaxAmount;
END$$


-- Trigger 3: Protect students with enrollments
DROP TRIGGER IF EXISTS trg_student_delete_protect$$

CREATE TRIGGER trg_student_delete_protect
BEFORE DELETE ON Student
FOR EACH ROW
BEGIN
    DECLARE v_count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_count
    FROM Enrollment
    WHERE StudentID = OLD.StudentID;

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Cannot delete student with existing enrollments.';
    END IF;
END$$


-- Trigger 4a: Validate grades on insertion
DROP TRIGGER IF EXISTS trg_enrollment_valid_grade$$

CREATE TRIGGER trg_enrollment_valid_grade
BEFORE INSERT ON Enrollment
FOR EACH ROW
BEGIN
    IF NEW.Grade IS NOT NULL
       AND NEW.Grade NOT IN ('A','B','C','D','F','W','IP')
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid grade value.';
    END IF;
END$$


-- Trigger 4b: Validate grades on updates
DROP TRIGGER IF EXISTS trg_enrollment_valid_grade_update$$

CREATE TRIGGER trg_enrollment_valid_grade_update
BEFORE UPDATE ON Enrollment
FOR EACH ROW
BEGIN
    IF NEW.Grade IS NOT NULL
       AND NEW.Grade NOT IN ('A','B','C','D','F','W','IP')
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid grade value.';
    END IF;
END$$


-- =============================================
-- 3. STORED PROCEDURES
-- =============================================

-- Procedure 1: Enroll a student
DROP PROCEDURE IF EXISTS sp_EnrollStudent$$

CREATE PROCEDURE sp_EnrollStudent(
    IN p_StudentID INT,
    IN p_SectionID INT
)
BEGIN
    INSERT INTO Enrollment
        (StudentID, SectionID, EnrollmentDate, Grade)
    VALUES
        (p_StudentID, p_SectionID, CURDATE(), NULL);
END$$


-- Procedure 2: Get a student's schedule
DROP PROCEDURE IF EXISTS sp_GetStudentSchedule$$

CREATE PROCEDURE sp_GetStudentSchedule(
    IN p_StudentID INT
)
BEGIN
    SELECT
        s.StudentID,
        s.FirstName,
        s.LastName,
        sec.SectionNumber,
        c.CourseName,
        sec.MeetingDays,
        sec.MeetingTime,
        t.TermName,
        cl.BuildingName,
        cl.RoomNumber,
        e.Grade
    FROM Student s
    JOIN Enrollment e
        ON s.StudentID = e.StudentID
    JOIN `Section` sec
        ON e.SectionID = sec.SectionID
    JOIN Course c
        ON sec.CourseID = c.CourseID
    JOIN Term t
        ON sec.TermID = t.TermID
    JOIN Classroom cl
        ON sec.ClassroomID = cl.ClassroomID
    WHERE s.StudentID = p_StudentID
    ORDER BY t.TermName, c.CourseName;
END$$


-- Procedure 3: Update a grade
DROP PROCEDURE IF EXISTS sp_UpdateGrade$$

CREATE PROCEDURE sp_UpdateGrade(
    IN p_EnrollmentID INT,
    IN p_Grade VARCHAR(5)
)
BEGIN
    UPDATE Enrollment
    SET Grade = p_Grade
    WHERE EnrollmentID = p_EnrollmentID;
END$$


-- Procedure 4: Record a payment
DROP PROCEDURE IF EXISTS sp_ProcessPayment$$

CREATE PROCEDURE sp_ProcessPayment(
    IN p_StudentID INT,
    IN p_Amount DECIMAL(10,2),
    IN p_Method VARCHAR(30)
)
BEGIN
    IF p_Amount IS NULL OR p_Amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment amount must be positive.';
    END IF;

    IF p_Method IS NULL OR TRIM(p_Method) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment method is required.';
    END IF;

    INSERT INTO Payment
        (StudentID, PaymentDate, Amount,
         PaymentMethod, PaymentStatus)
    VALUES
        (p_StudentID, CURDATE(), p_Amount,
         p_Method, 'Paid');
END$$

DELIMITER ;


-- =============================================
-- 4. PROCEDURE EXECUTION PERMISSIONS
-- =============================================

GRANT EXECUTE ON PROCEDURE college_sis.sp_EnrollStudent
TO registrar_role;

GRANT EXECUTE ON PROCEDURE college_sis.sp_GetStudentSchedule
TO registrar_role;

GRANT EXECUTE ON PROCEDURE college_sis.sp_GetStudentSchedule
TO instructor_role;

GRANT EXECUTE ON PROCEDURE college_sis.sp_UpdateGrade
TO instructor_role;

GRANT EXECUTE ON PROCEDURE college_sis.sp_ProcessPayment
TO registrar_role;

-- =============================================
-- 5. DATABASE USER PASSWORD CONFIGURATION
-- =============================================

ALTER USER 'admin_user'@'%'
IDENTIFIED BY 'AdminPass2026!';

ALTER USER 'registrar_user'@'%'
IDENTIFIED BY 'RegistrarPass2026!';

ALTER USER 'instructor_user'@'%'
IDENTIFIED BY 'InstructorPass2026!';

ALTER USER 'student_user'@'%'
IDENTIFIED BY 'StudentPass2026!';