# Campus Lost-and-Found Portal — Eclipse Dynamic Web Project (Tomcat 11)

Works with: **Eclipse IDE for Enterprise Java and Web Developers**, **Apache Tomcat v11.0**, **JDK 17 or newer**, **MySQL 8**.
(Tomcat 10.1 also works: see the end of this file.)

## 1. Database
Run `database/campus_lost_found.sql` in MySQL Workbench.
If your MySQL password is not `root`, change it in `src/main/java/com/campus/lostfound/dao/DBConnection.java`.

## 2. Import
File -> Import -> General -> **Existing Projects into Workspace** -> select this `CampusLostFound` folder -> Finish.
(If an old CampusLostFound project is already in the workspace, delete it first: right-click -> Delete.)

## 3. Check the Tomcat runtime
Right-click project -> Properties -> **Targeted Runtimes** -> tick **Apache Tomcat v11.0** -> Apply and Close.
Red marks on `jakarta.servlet` disappear after this.
Also check: Window -> Preferences -> Server -> Runtime Environments -> Apache Tomcat v11.0 -> Edit -> **JRE must be JDK 17 or newer**.

## 4. Run
Right-click the project -> Run As -> **Run on Server** -> Tomcat v11.0 -> Finish.
Open http://localhost:8080/CampusLostFound/

| Role  | Email              | Password |
|-------|--------------------|----------|
| Admin | admin@campus.edu   | admin123 |
| User  | student@campus.edu | user123  |

## If "Server Tomcat v11.0 failed to start"
Open the **Console** tab: the first red line tells the real reason. Common fixes:
1. **Port 8080 busy** (another Tomcat, XAMPP, Jenkins): double-click the server in the *Servers* tab -> Ports -> change HTTP/1.1 to 8081, then open http://localhost:8081/CampusLostFound/
2. **Old Tomcat still running**: Servers tab -> Stop; or in Task Manager end the `java.exe` that started from the Tomcat folder.
3. **Wrong Java**: Tomcat 11 needs JDK 17+. Double-click the server -> Overview -> Runtime Environment -> JRE -> pick a JDK 17+.
4. **Broken server entry**: Servers tab -> right-click server -> Delete (tick "delete runtime configuration"). Delete the `Servers` project too. Then Run on Server again and add Tomcat v11.0 fresh.
5. **Timeout**: double-click server -> Timeouts -> Start = 120 seconds.
6. Project -> Clean, then Server -> Clean... and Run again.

## Quick way that does not need the Eclipse server
Copy `deploy/CampusLostFound.war` into `<tomcat>/webapps`, run `bin/startup.bat`, and open http://localhost:8080/CampusLostFound/

## Using Tomcat 10.1 instead
Replace `Apache Tomcat v11.0` with `Apache Tomcat v10.1` in `.classpath` and in `.settings/org.eclipse.wst.common.project.facet.core.xml`, or just tick Tomcat 10.1 in Targeted Runtimes.
Tomcat 9 needs `javax.servlet` instead of `jakarta.servlet` in the Java files.

## Version 2 changes (UI redesign + validation)
- **New look ("Campus Ledger")**: `css/style.css` is a token-based design system (colours, type, spacing) with dark mode and a phone layout. Items are shown as lost-and-found tag cards with a reference number `LF-0001`.
- **Server-side checks** (the same rules as `validate.js`, so they hold even with JavaScript off):
  - `ClaimServlet`: one claim per user per item, admins cannot claim, proof needs 15+ characters.
  - `AdminServlet`: status must be Open, Claim Pending or Closed (otherwise HTTP 400).
  - `ReportItemServlet`: required fields, a known category, and a date that isn't in the future.
- **Database**: `claims` now has `UNIQUE (item_id, user_id)`. Re-run `database/campus_lost_found.sql` (this resets the data), or keep your data and run:
  `ALTER TABLE claims ADD CONSTRAINT uq_claim_once UNIQUE (item_id, user_id);`
- **Fonts** load from Google Fonts. Without internet the pages fall back to Segoe UI and still work.
- **Maven (optional)**: `pom.xml` lets you run without Eclipse: `mvn jetty:run`, or `mvn clean package` and copy `target/CampusLostFound.war` to Tomcat.
- The previous version is saved next to this folder as `CampusLostFound_v1_backup`.

## If creating an account / login shows "Something went wrong: RuntimeException"
The page now also shows **How to fix** and **Details** with the real reason. The usual causes:
1. **MySQL password is different** -> "Access denied": open `src/main/java/com/campus/lostfound/dao/DBConnection.java`, set `USER` and `PASSWORD` to your MySQL login, save, and run again.
2. **Database not created** -> "Unknown database": run `database/campus_lost_found.sql` in MySQL Workbench (File -> Open SQL Script -> run all).
3. **MySQL not running** -> "Connection refused": start the MySQL service (Windows: Services -> MySQL80 -> Start).
