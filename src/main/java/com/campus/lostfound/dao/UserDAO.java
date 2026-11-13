package com.campus.lostfound.dao;

import com.campus.lostfound.bean.User;
import com.campus.lostfound.util.PasswordUtil;
import java.sql.*;

/** Database operations for the users table. */
public class UserDAO {

    /** Inserts a new user. Returns false if the email already exists. */
    public boolean register(User u) {
        String sql = "INSERT INTO users (full_name, email, password, mobile, user_role) VALUES (?, ?, ?, ?, 'USER')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, PasswordUtil.hash(u.getPassword()));
            ps.setString(4, u.getMobile());
            return ps.executeUpdate() == 1;
        } catch (SQLIntegrityConstraintViolationException e) {
            return false;                         // duplicate email
        } catch (SQLException e) {
            throw new RuntimeException("Registration failed: " + e.getMessage(), e);
        }
    }

    /** Returns the user when email and password match, otherwise null. */
    public User login(String email, String password) {
        String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, PasswordUtil.hash(password));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setFullName(rs.getString("full_name"));
                    u.setEmail(rs.getString("email"));
                    u.setMobile(rs.getString("mobile"));
                    u.setUserRole(rs.getString("user_role"));
                    return u;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Login failed: " + e.getMessage(), e);
        }
        return null;
    }
}
