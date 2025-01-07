Transit App - README
----------------------
Setting Up the Project

1.Database Initialization:
- Run the provided FinalTransitDatbase.sql file in SQL Workbench to set up the database structure and populate it with initial data.

2. Database Connection:
- Navigate to: path_to_project\Transit-App\transitProject\src\main\java\transit\DatabaseConnection.java
Update the 'user' and 'password' instance variables with your database credentials to ensure the application connects to your local database. 

3. Server Configuration: 
- Recommended server: Apache Tomcat Server v11.0 (included in Eclipse IDE for Enterprise Java and Web Developers 2024-09).
- The application has also been tested with Tomcat Server v8.5.99.

4. Login Credentials (username, password): 

Customers: (johndoe, 123), (mark, 123), (ap2043, 123), (jane, 123)
Customer-Representatives: (bobbrown, rep), (EditTest, rep), (DeleteTest, rep)
Managers/Admins: (alicejohnson, admin)
----------------------
Application Features

Browsing and Searching:
- When you launch the app you can browse schedules for the current day and the next two days.
- At the initial launch, the app generates schedules for the current day and the subsequent two days.
-  Daily trips are created for each transit line, which may make the browsing and searching functionalities for train schedule to take some time to load.

Reservations: 
- You can browse and search for trips to reserve.
- If round trips are available for a selected schedule, dropdowns will display available returning trip options. The first selected schedule will be the incoming and the second selected schedule will be the returning.
- If no returning trip is available for selected schedule, round trip tickets cannot be purchased.

Ticket Types:
- Options include adult, child, senior, and disabled tickets.
- You can select one-way or round-trip tickets for each reservation. Round trip as long as you select a returning trip from the available option. 
- Can select the quantity of tickets you want. 

Cancellations:
- Only future reservations can be canceled. Ongoing and past reservations cannot.

Customer Support
- Post Questions: Customers can post questions visible to other customers.
- Employee Responses: Employees can reply to questions. Customers cannot comment on others' posts, but they can add follow-ups to their own.

Modifying Schedules
- The available schedules for modifications are only the ones that haven't been reserved by customers. This allows database constraints to be followed. 
- You can modify train schedules using existing trains, stations, and transit lines.
- Can modify their arrival and departure times from the origin to destination as well as the intermediate stops at other stations. 







