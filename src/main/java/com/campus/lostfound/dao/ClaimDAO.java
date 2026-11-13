package com.campus.lostfound.dao;

import com.campus.lostfound.bean.Claim;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/** Database operations for the claims table. */
public class ClaimDAO {

    private static final String SELECT_JOIN =
        "SELECT c.*, i.item_name, u.full_name FROM claims c "
      + "JOIN items i ON c.item_id = i.item_id JOIN users u ON c.user_id = u.user_id ";

    /** Saves a claim and marks the item as 'Claim Pending' in ONE transaction. */
    public boolean addClaim(Claim c) {
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);                       // start transaction

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO claims (item_id, user_id, ownership_details, claim_date, claim_status) VALUES (?, ?, ?, CURDATE(), 'Pending')");
            ps.setInt(1, c.getItemId());
            ps.setInt(2, c.getUserId());
            ps.setString(3, c.getOwnershipDetails());
            ps.executeUpdate();

            PreparedStatement ps2 = con.prepareStatement(
                "UPDATE items SET status = 'Claim Pending' WHERE item_id = ? AND status = 'Open'");
            ps2.setInt(1, c.getItemId());
            ps2.executeUpdate();

            con.commit();                                   // both succeed together
            return true;
        } catch (SQLException e) {
            rollback(con);                                  // or both are cancelled
            throw new RuntimeException("Claim failed: " + e.getMessage(), e);
        } finally {
            close(con);
        }
    }

    /** Admin decision. Approve closes the item and rejects other pending claims. */
    public boolean decideClaim(int claimId, String status, String remarks) {
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            PreparedStatement ps = con.prepareStatement(
                "UPDATE claims SET claim_status = ?, admin_remarks = ? WHERE claim_id = ?");
            ps.setString(1, status);
            ps.setString(2, remarks);
            ps.setInt(3, claimId);
            ps.executeUpdate();

            int itemId = itemIdOf(con, claimId);
            if ("Approved".equals(status)) {
                exec(con, "UPDATE items SET status = 'Closed' WHERE item_id = ?", itemId);
                PreparedStatement ps3 = con.prepareStatement(
                    "UPDATE claims SET claim_status = 'Rejected', admin_remarks = 'Another claim was approved' "
                  + "WHERE item_id = ? AND claim_id <> ? AND claim_status = 'Pending'");
                ps3.setInt(1, itemId);
                ps3.setInt(2, claimId);
                ps3.executeUpdate();
            } else {
                // reopen the item when no other claim is waiting
                exec(con, "UPDATE items SET status = 'Open' WHERE item_id = ? AND status = 'Claim Pending' "
                        + "AND NOT EXISTS (SELECT 1 FROM claims WHERE item_id = items.item_id AND claim_status = 'Pending')", itemId);
            }
            con.commit();
            return true;
        } catch (SQLException e) {
            rollback(con);
            throw new RuntimeException("Claim update failed: " + e.getMessage(), e);
        } finally {
            close(con);
        }
    }

    /** True when this user already has a claim on this item (any status). */
    public boolean hasClaimed(int itemId, int userId) {
        String sql = "SELECT 1 FROM claims WHERE item_id = ? AND user_id = ? LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, itemId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) {
            throw new RuntimeException("Claim check failed: " + e.getMessage(), e);
        }
    }

    public List<Claim> claimsByUser(int userId) {
        return query(SELECT_JOIN + "WHERE c.user_id = " + userId + " ORDER BY c.claim_id DESC");
    }

    public List<Claim> claimsByItem(int itemId) {
        return query(SELECT_JOIN + "WHERE c.item_id = " + itemId + " ORDER BY c.claim_id DESC");
    }

    public List<Claim> allClaims() {
        return query(SELECT_JOIN + "ORDER BY FIELD(c.claim_status, 'Pending') DESC, c.claim_id DESC");
    }

    // ---------- helpers ----------

    private List<Claim> query(String sql) {
        List<Claim> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Claim c = new Claim();
                c.setClaimId(rs.getInt("claim_id"));
                c.setItemId(rs.getInt("item_id"));
                c.setUserId(rs.getInt("user_id"));
                c.setOwnershipDetails(rs.getString("ownership_details"));
                c.setClaimDate(rs.getString("claim_date"));
                c.setClaimStatus(rs.getString("claim_status"));
                c.setAdminRemarks(rs.getString("admin_remarks"));
                c.setItemName(rs.getString("item_name"));
                c.setClaimantName(rs.getString("full_name"));
                list.add(c);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Query failed: " + e.getMessage(), e);
        }
        return list;
    }

    private int itemIdOf(Connection con, int claimId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("SELECT item_id FROM claims WHERE claim_id = ?")) {
            ps.setInt(1, claimId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : 0; }
        }
    }

    private void exec(Connection con, String sql, int id) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private void rollback(Connection con) {
        try { if (con != null) con.rollback(); } catch (SQLException ignored) { }
    }

    private void close(Connection con) {
        try { if (con != null) con.close(); } catch (SQLException ignored) { }
    }
}
