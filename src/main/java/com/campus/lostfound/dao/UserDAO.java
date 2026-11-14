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
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Login failed: " + e.getMessage(), e);
        }
        return null;
    }

    /** Returns the user with this id (without the password hash), or null. */
    public User findById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Could not load the profile: " + e.getMessage(), e);
        }
    }

    /** Updates name, email and mobile. Returns false if the new email belongs to another account. */
    public boolean updateProfile(User u) {
        String sql = "UPDATE users SET full_name = ?, email = ?, mobile = ? WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getMobile());
            ps.setInt(4, u.getUserId());
            return ps.executeUpdate() == 1;
        } catch (SQLIntegrityConstraintViolationException e) {
            return false;                         // email already used by another account
        } catch (SQLException e) {
            throw new RuntimeException("Profile update failed: " + e.getMessage(), e);
        }
    }

    /**
     * Replaces the password only when the current password is correct.
     * Returns false when the current password does not match.
     */
    public boolean changePassword(int userId, String currentPassword, String newPassword) {
        String sql = "UPDATE users SET password = ? WHERE user_id = ? AND password = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, PasswordUtil.hash(newPassword));
            ps.setInt(2, userId);
            ps.setString(3, PasswordUtil.hash(currentPassword));
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Password change failed: " + e.getMessage(), e);
        }
    }

    /** Converts the current ResultSet row into a User bean. The password hash is never copied. */
    private static User map(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setMobile(rs.getString("mobile"));
        u.setUserRole(rs.getString("user_role"));
        return u;
    }
}
