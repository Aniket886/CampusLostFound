package com.campus.lostfound.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/** Gives a JDBC Connection to the campus_lost_found database. */
public class DBConnection {

    // Change USER and PASSWORD to match your MySQL installation
    private static final String URL =
        "jdbc:mysql://localhost:3306/campus_lost_found?useSSL=false&allowPublicKeyRetrieval=true";
    private static final String USER = "root";
    private static final String PASSWORD = "root";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");   // Step 1: register the driver
        } catch (ClassNotFoundException e) {
            System.out.println("MySQL JDBC driver not found: " + e.getMessage());
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);  // Step 2: open connection
    }
}
