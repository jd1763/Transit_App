# Online Railway Booking System

## Overview

This project implements an **Online Railway Booking System** using a **MySQL database**, a **JSP-based web interface**, and **Java with JDBC** for backend connectivity. The system is designed to support operations such as **train schedule browsing**, **reservation management**, and **user interactions for customers, customer representatives, and admin users**. It provides robust data management and user access control.

For a visual representation of the project watch this video attached: [DEMO](https://drive.google.com/file/d/13RjDz6MZJtdsJKhQ3lYS9Wm-TSdW2zn2/view?usp=sharing)

---

## Collaborators
- **Jorgeluis Done**
- **Anthony Paulino**

## Features

### Customer Features
- **Account Management**:
  - Register as a new customer.
  - Login and logout functionality.
- **Train Browsing and Searching**:
  - Search for train schedules by origin, destination, and travel date.
  - View all train stops, departure/arrival times, and fares.
  - Sort schedules by criteria like fare, departure time, or arrival time.
- **Reservation Management**:
  - Book one-way or round-trip reservations.
  - Apply discounts for children, seniors, and disabled passengers.
  - Cancel reservations (only future reservations).
  - View current and past reservations, categorized appropriately.
- **Customer Support**:
  - Submit questions to customer support.
  - Search existing questions by keywords.
  - Browse answers to questions.

### Customer Representative Features
- **Train Schedule Management**:
  - Edit and delete unreserved train schedules.
  - View train schedules for a specific station (as origin or destination).
- **Customer Management**:
  - View all customers who have reservations for a given transit line and date.
- **Customer Support**:
  - Respond to customer questions via the support portal.

### Admin Features
- **Manage Customer Representatives**:
  - Add, edit, and delete customer representative accounts.
- **Reporting**:
  - Generate sales reports by month.
  - View reservations by transit line or customer name.
  - Generate revenue reports by transit line or customer.
  - Identify the "best customer" based on total spending and number of reservations.
  - List the top 5 most active transit lines based on reservations.

---

## Installation Instructions

### Prerequisites
- **MySQL Workbench**
- **Tomcat Server (v11.0 recommended)**
- **Eclipse IDE for Enterprise Java and Web Developers** (2024-09 or newer)

### Steps
1. **Run SQL Dump**:
   - Import the provided `FinalTransitDatbase.sql` dump file into **MySQL Workbench** to set up the database schema and initial data.
   
2. **Configure Database Connection**:
   - Navigate to `Transit-App\transitProject\src\main\java\transit\DatabaseConnection.java`.
   - Update the database connection credentials (username, password, and URL) to match your local database setup.

3. **Set Up Tomcat Server**:
   - Install and configure Apache Tomcat Server.
   - Deploy the project using **Eclipse IDE**.

---

## Database Details

### Key Tables
- **Trains**: Stores train IDs.
- **Stations**: Contains station details (name, city, state).
- **Transit Lines**: Represents routes and their details (origin, destination, fare, etc.).
- **Train Schedules**: Stores schedule data (departure/arrival times, stops).
- **Reservations**: Manages customer reservations.
- **Tickets**: Links reservations to schedules and specifies ticket type.
- **Customers**: Stores customer account details.
- **Employees**: Stores admin and customer representative accounts.

### Relationships
- A **reservation** links to at least one train schedule (for one-way trips) and at most two schedules (for round trips).
- **Tickets** are linked to reservations and specify travel details (e.g., origin, destination, fare, and type).

---

## Usage Notes

1. **Browsing and Searching**:
   - Browse schedules only for the current day and future dates.
   - Schedules are generated dynamically for the current and next two days.

2. **Reservations**:
   - One-way and round-trip reservations are supported.
   - Reservations can only be canceled if they are for future trips.

3. **Schedule Management**:
   - Schedules can be edited or deleted if no reservations exist for them.
   - Modifying a schedule updates all related stops.

4. **Customer Support**:
   - Customers can post and search questions.
   - Customer representatives can respond to questions.

---

## Checklist

### Core Functionality
- [✔] Customer registration, login, and logout.
- [✔] Browsing and searching for train schedules.
- [✔] Making and canceling reservations.
- [✔] Customer support interaction (questions and responses).

### Admin Functionality
- [✔] Manage customer representatives.
- [✔] Generate reports (sales, reservations, revenue).
- [✔] Identify best customers and most active transit lines.

### Customer Representative Functionality
- [✔] Modify train schedules.
- [✔] View reservations for specific transit lines and dates.
