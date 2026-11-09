# Small's Community College Student Information System

## Project Overview

The Small's Community College Student Information System is a capstone project designed to demonstrate the development of a relational database system for managing college operations.

The system organizes student, academic, financial, instructor, classroom, and enrollment information within a structured database. It also includes a Streamlit-based interface for interacting with selected records and Power BI reporting for analyzing college-level data.

## Technologies Used

- MySQL
- MySQL Workbench
- Python
- Streamlit
- Pandas
- Power BI
- GitHub

## Database Features

The database includes tables for:

- Students
- Programs
- Departments
- Courses
- Instructors
- Instructor Programs
- Terms
- Classrooms
- Sections
- Enrollments
- Payments
- Payroll

Primary keys and foreign keys are used to maintain relationships between the tables and support data integrity.

## Application Interface

The Python Streamlit interface provides a simple manager and data-entry system.

The interface currently supports:

- Viewing student records
- Adding new students
- Viewing enrollment records
- Adding student enrollments
- Viewing payment information
- Recording payments
- Viewing course sections and classroom information

The application reads and writes data using CSV files located in the `data` directory.

## Database Scripts

The `database` folder contains SQL scripts used to:

- Create the `college_sis` database and tables
- Insert initial sample data
- Configure database roles and permissions
- Create triggers and stored procedures
- Add additional sample data for reporting and analysis

## Data Analytics

Power BI was used to demonstrate how information stored in the database could support college-level decision making.

Examples include:

- Students by academic program
- Payments by academic program
- Paid versus pending payment amounts
- Classroom capacity versus section enrollment

## Scalability

The current project uses a relatively small sample dataset, but the relational database design allows the system to grow without redesigning the overall structure.

Additional students, programs, courses, sections, instructors, classrooms, enrollments, and payment records can be added as the college grows.

The database structure can also support future improvements such as:

- Online student registration
- Student and faculty portals
- Additional financial reporting
- Financial aid integration
- Expanded Power BI dashboards
- Cloud database hosting
- Additional authentication and security controls

## Repository Structure

```text
smalls-community-college-sis/
├── app.py
├── requirements.txt
├── README.md
├── data/
│   └── CSV database files
└── database/
    └── MySQL database scripts
```

## Running the Interface

Install the required Python packages:

```bash
py -m pip install -r requirements.txt
```

Run the Streamlit application:

```bash
py -m streamlit run app.py
```

Then open the local Streamlit address shown in the terminal, normally:

```text
http://localhost:8501
```

## Project Purpose

This project demonstrates how relational database design, database administration, application development, and data visualization can work together to support the information needs of a small community college.
