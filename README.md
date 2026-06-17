# CIS 350 Project

## OG Cleaning Scheduler

---

## Team Members

- Juan Rios
- Juan Gonzalez
- Jessa Gibson

---

## Course Information

**Course:** CIS 350 – Software Engineering  
**Semester:** Summer 2026  
**Project:** OG Cleaning Scheduler

---

## Important Links



### [JIRA Board](https://your-jira-linkruh-roh)

### [Video Demonstration](https://video-here-lmao)



---

# 1. Abstract

Scheduling employees is one of the most important jobs for businesses that use a shift-based system. Most businesses are still using spreadsheets, text messages or even paper schedules to manage employee shifts, causing some problems as confusion and missed shifts and lack of communication between manager and employee.

**OG Cleaning Scheduler** is a centralized system which makes it possible for employees to see their schedules as it gives manager ability to generate, edit and manage all employee shifts. It also enables employees to punch in and out with location verification so that employee is in the work site before punching in for the work.

---

# 2. Introduction

It can be progressively hard to schedule shifts as a company grows and availability of staff shifts. Staff members need to know what their next scheduled shifts are going to be while managers need to efficiently allocate shifts to their staff and fill their staff needs.

The **OG Cleaning Scheduler** has been built in Flutter allowing the ability for this application to run across any mobile devices. With role based permissions the staff members have the ability to view schedules and time of work and managers can edit, add and delete their own work shifts.

This project is being implemented to make scheduling simple and easy for all users.

---

# 3. Architectural Design

The system follows a client-server architecture. Users interact with the mobile application which communicates with a backend server through REST API requests. Scheduling data is stored centrally and updated in real time.

### Figure 1: Architecture Diagram

**[PLACEHOLDER – INSERT SYSTEM ARCHITECTURE DIAGRAM HERE]**

---

## 3.1 Class Diagram

The class diagram illustrates the relationships between the primary objects in the application.

Major classes include:

- Employee
- Manager
- Shift
- Schedule
- PunchRecord
- AuthenticationService

### Figure 2: Class Diagram

**[PLACEHOLDER – INSERT CLASS DIAGRAM HERE]**

---

## 3.2 Use Case Diagram

The system contains two primary actors:

### Employee

- Login
- View Schedule
- View Shift Details
- Punch In
- Punch Out

### Manager

- Login
- Create Shift
- Modify Shift
- Delete Shift
- View Employee Status

### Figure 3: Use Case Diagram

**[PLACEHOLDER – INSERT USE CASE DIAGRAM HERE]**

---

## 3.3 Sequence Diagram

The primary workflows include:

### Employee Punch-In

1. Employee selects Punch In.
2. Application verifies GPS location.
3. Request is sent to the server.
4. Punch record is created.
5. Confirmation is returned to the employee.

### Manager Schedule Modification

1. Manager selects a shift.
2. Shift information is updated.
3. Changes are submitted.
4. Database is updated.
5. Updated schedule is displayed.

### Figure 4: Sequence Diagram

**[PLACEHOLDER – INSERT SEQUENCE DIAGRAM HERE]**

---

## 3.4 Communication Diagram

Communication diagrams illustrate how system components exchange information during scheduling and punch operations.

### Figure 5: Communication Diagram

**[PLACEHOLDER – INSERT COMMUNICATION DIAGRAM HERE]**

---

# 4. User Guide / Implementation

## 4.1 Login Page

Users begin by logging into the system using their employee credentials.

### Figure 6: Login Screen

**[PLACEHOLDER – INSERT LOGIN SCREENSHOT HERE]**

---

## 4.2 Employee Dashboard

The dashboard provides employees with access to their schedules and punch functions.

### Features

- View Weekly Schedule
- View Upcoming Shifts
- Punch In
- Punch Out

### Figure 7: Employee Dashboard

**[PLACEHOLDER – INSERT DASHBOARD SCREENSHOT HERE]**

---

## 4.3 Punch System

The punch system records employee attendance and verifies that the employee is physically located at the assigned worksite.

### Punch In Process

- Verify GPS location
- Record start time
- Update employee status

### Punch Out Process

- Record end time
- Calculate hours worked
- Save attendance record

### Figure 8: Punch System

**[PLACEHOLDER – INSERT PUNCH SYSTEM SCREENSHOT HERE]**

---

## 4.4 Schedule Management

Managers have access to scheduling controls that allow them to maintain employee schedules.

### Create Shift

Managers can create new shifts and assign employees.

### Edit Shift

Managers can modify dates, times, and assignments.

### Delete Shift

Managers can remove unnecessary or canceled shifts.

### Figure 9: Schedule Management

**[PLACEHOLDER – INSERT SCHEDULE MANAGEMENT SCREENSHOT HERE]**

---

# 5. Risk Analysis and Retrospective

Several risks were identified during development.

## Security Risks

- Unauthorized access to scheduling functions
- Improper user authentication
- Exposure of employee scheduling information

## Technical Risks

- GPS location inaccuracies
- Server communication failures
- Mobile device compatibility issues

## Mitigation Strategies

- Role-based access control
- Authentication validation
- Error handling and recovery mechanisms
- Secure API communication

## Future Improvements

- Push notifications
- Shift swap requests
- Employee messaging system
- Timecard reporting
- Payroll integration
- Administrative analytics dashboard

---

# 6. Conclusion

The OG Cleaning Scheduler successfully provides a centralized scheduling solution for employees and managers. The system simplifies schedule management, improves communication, and introduces location-verified attendance tracking.

Future development will focus on additional reporting tools, enhanced communication features, and cloud-based scalability.

---

# 7. Walkthrough

### Video Demonstration

[INSERT VIDEO LINK HERE]

---

# Technologies Used

- Flutter
- Dart
- REST API
- Geolocator
- HTTP
- Google Fonts

---

# Repository Structure

```text
lib/
├── components/
│   ├── ChangeScheduleButton.dart
│   ├── EmployeeStatusList.dart
│   ├── PunchButton.dart
│   ├── SignInButton.dart
│   └── WeekScheduleLayout.dart
│
├── pages/
│   ├── login.dart
│   ├── punch.dart
│   ├── modifyschedule.dart
│   └── Locationpopup.dart
│
├── shift_model.dart
└── main.dart
```