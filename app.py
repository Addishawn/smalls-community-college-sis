import streamlit as st
import pandas as pd
import os

st.set_page_config(
    page_title="College SIS Manager",
    layout="wide"
)

DATA_DIR = "data"


# =========================================================
# DATA FUNCTIONS
# =========================================================

@st.cache_data
def load_table(name):
    path = os.path.join(DATA_DIR, f"{name}.csv")

    if os.path.exists(path):
        return pd.read_csv(path)

    return pd.DataFrame()


def save_table(name, df):
    path = os.path.join(DATA_DIR, f"{name}.csv")
    df.to_csv(path, index=False)

    # Clear cached CSV data after changes are saved
    st.cache_data.clear()


# =========================================================
# PAGE HEADER
# =========================================================

st.title("College Student Information System")
st.caption("Manager / Data Entry Interface")


# =========================================================
# TABS
# =========================================================

tab1, tab2, tab3, tab4 = st.tabs(
    ["Students", "Enrollments", "Payments", "Sections"]
)


# =========================================================
# STUDENTS TAB
# =========================================================

with tab1:

    st.subheader("Students")

    students = load_table("Student")
    programs = load_table("Program")

    if not students.empty:

        if not programs.empty:
            display = students.merge(
                programs[["ProgramID", "ProgramName"]],
                on="ProgramID",
                how="left"
            )
        else:
            display = students

        st.dataframe(
            display,
            use_container_width=True
        )

    else:
        st.info("No student records found.")

    # -----------------------------------------------------
    # ADD STUDENT
    # -----------------------------------------------------

    with st.expander("Add New Student"):

        with st.form("add_student"):

            col1, col2 = st.columns(2)

            first = col1.text_input("First Name")
            last = col2.text_input("Last Name")

            email = col1.text_input("Email")
            phone = col2.text_input("Phone")

            dob = col1.date_input("Date of Birth")

            if not programs.empty:
                prog = col2.selectbox(
                    "Program",
                    programs["ProgramName"].tolist()
                )
            else:
                prog = None
                col2.warning("No programs available.")

            submitted = st.form_submit_button("Add Student")

            if submitted:

                if not first or not last or not email:
                    st.error(
                        "First name, last name, and email are required."
                    )

                elif prog is None:
                    st.error(
                        "A program must be available before adding a student."
                    )

                elif not students.empty and email in students["Email"].values:
                    st.error(
                        "A student with this email already exists."
                    )

                else:

                    new_id = (
                        int(students["StudentID"].max()) + 1
                        if not students.empty
                        else 1
                    )

                    prog_id = int(
                        programs.loc[
                            programs["ProgramName"] == prog,
                            "ProgramID"
                        ].iloc[0]
                    )

                    new_row = {
                        "StudentID": new_id,
                        "FirstName": first,
                        "LastName": last,
                        "DateOfBirth": str(dob),
                        "Email": email,
                        "Phone": phone,
                        "ProgramID": prog_id
                    }

                    students = pd.concat(
                        [
                            students,
                            pd.DataFrame([new_row])
                        ],
                        ignore_index=True
                    )

                    save_table(
                        "Student",
                        students
                    )

                    st.success(
                        f"Student {first} {last} added."
                    )

                    st.rerun()


# =========================================================
# ENROLLMENTS TAB
# =========================================================

with tab2:

    st.subheader("Enrollments")

    enrollments = load_table("Enrollment")
    students = load_table("Student")
    sections = load_table("Section")
    courses = load_table("Course")

    # -----------------------------------------------------
    # DISPLAY ENROLLMENTS
    # -----------------------------------------------------

    if not enrollments.empty:

        display = enrollments.copy()

        if not students.empty:
            display = display.merge(
                students[
                    [
                        "StudentID",
                        "FirstName",
                        "LastName"
                    ]
                ],
                on="StudentID",
                how="left"
            )

        if not sections.empty:
            display = display.merge(
                sections[
                    [
                        "SectionID",
                        "CourseID",
                        "SectionNumber"
                    ]
                ],
                on="SectionID",
                how="left"
            )

        if not courses.empty:
            display = display.merge(
                courses[
                    [
                        "CourseID",
                        "CourseName"
                    ]
                ],
                on="CourseID",
                how="left"
            )

        st.dataframe(
            display,
            use_container_width=True
        )

    else:
        st.info("No enrollment records found.")

    # -----------------------------------------------------
    # ADD ENROLLMENT
    # -----------------------------------------------------

    with st.expander("Add Enrollment"):

        with st.form("add_enrollment"):

            if not students.empty:
                student_names = (
                    students["FirstName"].astype(str)
                    + " "
                    + students["LastName"].astype(str)
                ).tolist()
            else:
                student_names = []

            section_labels = []
            section_lookup = pd.DataFrame()

            if not sections.empty and not courses.empty:

                section_lookup = sections.merge(
                    courses[
                        [
                            "CourseID",
                            "CourseName"
                        ]
                    ],
                    on="CourseID",
                    how="left"
                )

                # FIX:
                # Convert SectionNumber to text before combining it
                # with CourseName.
                section_lookup["SectionLabel"] = (
                    section_lookup["CourseName"].astype(str)
                    + " - "
                    + section_lookup["SectionNumber"]
                    .astype(str)
                    .str.zfill(3)
                )

                section_labels = (
                    section_lookup["SectionLabel"].tolist()
                )

            stu = st.selectbox(
                "Student",
                student_names
            )

            sec_choice = st.selectbox(
                "Section",
                section_labels
            )

            grade = st.text_input(
                "Grade (optional)",
                value="IP"
            )

            submitted = st.form_submit_button(
                "Add Enrollment"
            )

            if submitted:

                if not stu:
                    st.error(
                        "Please select a student."
                    )

                elif not sec_choice:
                    st.error(
                        "Please select a section."
                    )

                else:

                    stu_id = int(
                        students.loc[
                            (
                                students["FirstName"].astype(str)
                                + " "
                                + students["LastName"].astype(str)
                            )
                            == stu,
                            "StudentID"
                        ].iloc[0]
                    )

                    # FIX:
                    # Use the previously created text SectionLabel
                    # instead of combining string + integer again.
                    sec_id = int(
                        section_lookup.loc[
                            section_lookup["SectionLabel"]
                            == sec_choice,
                            "SectionID"
                        ].iloc[0]
                    )

                    # Prevent duplicate enrollment
                    duplicate = False

                    if not enrollments.empty:

                        duplicate = (
                            (
                                enrollments["StudentID"]
                                == stu_id
                            )
                            &
                            (
                                enrollments["SectionID"]
                                == sec_id
                            )
                        ).any()

                    if duplicate:

                        st.error(
                            "This student is already enrolled "
                            "in this section."
                        )

                    else:

                        new_id = (
                            int(
                                enrollments[
                                    "EnrollmentID"
                                ].max()
                            ) + 1
                            if not enrollments.empty
                            else 1
                        )

                        new_row = {
                            "EnrollmentID": new_id,
                            "StudentID": stu_id,
                            "SectionID": sec_id,
                            "EnrollmentDate":
                                pd.Timestamp.now().strftime(
                                    "%Y-%m-%d"
                                ),
                            "Grade": grade
                        }

                        enrollments = pd.concat(
                            [
                                enrollments,
                                pd.DataFrame([new_row])
                            ],
                            ignore_index=True
                        )

                        save_table(
                            "Enrollment",
                            enrollments
                        )

                        st.success(
                            "Enrollment added."
                        )

                        st.rerun()


# =========================================================
# PAYMENTS TAB
# =========================================================

with tab3:

    st.subheader("Payments")

    payments = load_table("Payment")
    students = load_table("Student")

    # -----------------------------------------------------
    # DISPLAY PAYMENTS
    # -----------------------------------------------------

    if not payments.empty:

        if not students.empty:

            display = payments.merge(
                students[
                    [
                        "StudentID",
                        "FirstName",
                        "LastName"
                    ]
                ],
                on="StudentID",
                how="left"
            )

        else:
            display = payments

        st.dataframe(
            display,
            use_container_width=True
        )

        total = payments["Amount"].sum()

        st.metric(
            "Total Payment Activity",
            f"${total:,.2f}"
        )

        if "PaymentStatus" in payments.columns:

            paid_total = payments.loc[
                payments["PaymentStatus"] == "Paid",
                "Amount"
            ].sum()

            pending_total = payments.loc[
                payments["PaymentStatus"] == "Pending",
                "Amount"
            ].sum()

            col1, col2 = st.columns(2)

            col1.metric(
                "Paid Amount",
                f"${paid_total:,.2f}"
            )

            col2.metric(
                "Pending Amount",
                f"${pending_total:,.2f}"
            )

    else:
        st.info("No payment records found.")

    # -----------------------------------------------------
    # RECORD PAYMENT
    # -----------------------------------------------------

    with st.expander("Record Payment"):

        with st.form("add_payment"):

            if not students.empty:

                student_names = (
                    students["FirstName"].astype(str)
                    + " "
                    + students["LastName"].astype(str)
                ).tolist()

            else:
                student_names = []

            stu = st.selectbox(
                "Student",
                student_names
            )

            amount = st.number_input(
                "Amount",
                min_value=0.0,
                step=50.0
            )

            method = st.selectbox(
                "Method",
                [
                    "Card",
                    "Cash",
                    "Aid",
                    "ACH",
                    "Check"
                ]
            )

            status = st.selectbox(
                "Status",
                [
                    "Paid",
                    "Pending"
                ]
            )

            submitted = st.form_submit_button(
                "Record Payment"
            )

            if submitted:

                if not stu:
                    st.error(
                        "Please select a student."
                    )

                elif amount <= 0:
                    st.error(
                        "Payment amount must be greater than zero."
                    )

                else:

                    stu_id = int(
                        students.loc[
                            (
                                students["FirstName"].astype(str)
                                + " "
                                + students["LastName"].astype(str)
                            )
                            == stu,
                            "StudentID"
                        ].iloc[0]
                    )

                    new_id = (
                        int(
                            payments["PaymentID"].max()
                        ) + 1
                        if not payments.empty
                        else 1
                    )

                    new_row = {
                        "PaymentID": new_id,
                        "StudentID": stu_id,
                        "PaymentDate":
                            pd.Timestamp.now().strftime(
                                "%Y-%m-%d"
                            ),
                        "Amount": amount,
                        "PaymentMethod": method,
                        "PaymentStatus": status
                    }

                    payments = pd.concat(
                        [
                            payments,
                            pd.DataFrame([new_row])
                        ],
                        ignore_index=True
                    )

                    save_table(
                        "Payment",
                        payments
                    )

                    st.success(
                        "Payment recorded."
                    )

                    st.rerun()


# =========================================================
# SECTIONS TAB
# =========================================================

with tab4:

    st.subheader("Sections")

    sections = load_table("Section")
    courses = load_table("Course")
    classrooms = load_table("Classroom")

    if not sections.empty:

        display = sections.copy()

        if not courses.empty:

            display = display.merge(
                courses[
                    [
                        "CourseID",
                        "CourseName"
                    ]
                ],
                on="CourseID",
                how="left"
            )

        if not classrooms.empty:

            display = display.merge(
                classrooms[
                    [
                        "ClassroomID",
                        "BuildingName",
                        "RoomNumber",
                        "Capacity"
                    ]
                ],
                on="ClassroomID",
                how="left"
            )

        # Make section numbers display as 001, 002, etc.
        if "SectionNumber" in display.columns:

            display["SectionNumber"] = (
                display["SectionNumber"]
                .astype(str)
                .str.zfill(3)
            )

        st.dataframe(
            display,
            use_container_width=True
        )

    else:

        st.info(
            "No section records found."
        )