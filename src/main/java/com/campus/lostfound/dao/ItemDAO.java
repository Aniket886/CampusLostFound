package com.campus.lostfound.dao;

import com.campus.lostfound.bean.Item;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/** Database operations for the items table. */
public class ItemDAO {

    private static final String SELECT_JOIN =
        "SELECT i.*, u.full_name FROM items i JOIN users u ON i.user_id = u.user_id ";

    /** INSERT a lost or found report. */
    public boolean addItem(Item it) {
        String sql = "INSERT INTO items (user_id, item_name, category, description, report_type, location, report_date, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, 'Open')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, it.getUserId());
            ps.setString(2, it.getItemName());
            ps.setString(3, it.getCategory());
            ps.setString(4, it.getDescription());
            ps.setString(5, it.getReportType());
            ps.setString(6, it.getLocation());
            ps.setDate(7, Date.valueOf(it.getReportDate()));
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Could not save item: " + e.getMessage(), e);
        }
    }

    /** SELECT the latest reports for the home page. */
    public List<Item> recentItems(int limit) {
        return query(SELECT_JOIN + "ORDER BY i.item_id DESC LIMIT " + limit);
    }

    /** SELECT using keyword, category and type (all optional). */
    public List<Item> search(String keyword, String category, String type) {
        StringBuilder sql = new StringBuilder(SELECT_JOIN + "WHERE (i.item_name LIKE ? OR i.description LIKE ? OR i.location LIKE ?)");
        if (!isEmpty(category)) sql.append(" AND i.category = ?");
        if (!isEmpty(type))     sql.append(" AND i.report_type = ?");
        sql.append(" ORDER BY i.item_id DESC");

        List<Item> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            String like = "%" + (keyword == null ? "" : keyword.trim()) + "%";
            int i = 1;
            ps.setString(i++, like);
            ps.setString(i++, like);
            ps.setString(i++, like);
            if (!isEmpty(category)) ps.setString(i++, category);
            if (!isEmpty(type))     ps.setString(i++, type);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Search failed: " + e.getMessage(), e);
        }
        return list;
    }

    /** SELECT one item by id. */
    public Item getById(int itemId) {
        List<Item> list = query(SELECT_JOIN + "WHERE i.item_id = " + itemId);
        return list.isEmpty() ? null : list.get(0);
    }

    /** SELECT the reports created by one user. */
    public List<Item> itemsByUser(int userId) {
        return query(SELECT_JOIN + "WHERE i.user_id = " + userId + " ORDER BY i.item_id DESC");
    }

    /** SELECT all reports (admin). Uses a plain Statement. */
    public List<Item> allItems() {
        return query(SELECT_JOIN + "ORDER BY i.item_id DESC");
    }

    /** UPDATE the status of an item. */
    public boolean updateStatus(int itemId, String status) {
        String sql = "UPDATE items SET status = ? WHERE item_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, itemId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Status update failed: " + e.getMessage(), e);
        }
    }

    /** DELETE a duplicate or inappropriate report (claims are removed by ON DELETE CASCADE). */
    public boolean deleteItem(int itemId) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM items WHERE item_id = ?")) {
            ps.setInt(1, itemId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Delete failed: " + e.getMessage(), e);
        }
    }

    /** Calls the stored procedure sp_item_summary using CallableStatement.
     *  Returns {total, lost, found, closed, pendingClaims}. */
    public int[] summary() {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call sp_item_summary(?, ?, ?, ?, ?)}")) {
            for (int i = 1; i <= 5; i++) cs.registerOutParameter(i, Types.INTEGER);
            cs.execute();
            return new int[] { cs.getInt(1), cs.getInt(2), cs.getInt(3), cs.getInt(4), cs.getInt(5) };
        } catch (SQLException e) {
            throw new RuntimeException("Summary failed: " + e.getMessage(), e);
        }
    }

    // ---------- helpers ----------

    /** Runs a SELECT with a simple Statement and converts rows into Item beans. */
    private List<Item> query(String sql) {
        List<Item> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            throw new RuntimeException("Query failed: " + e.getMessage(), e);
        }
        return list;
    }

    private Item map(ResultSet rs) throws SQLException {
        Item it = new Item();
        it.setItemId(rs.getInt("item_id"));
        it.setUserId(rs.getInt("user_id"));
        it.setItemName(rs.getString("item_name"));
        it.setCategory(rs.getString("category"));
        it.setDescription(rs.getString("description"));
        it.setReportType(rs.getString("report_type"));
        it.setLocation(rs.getString("location"));
        it.setReportDate(rs.getString("report_date"));
        it.setStatus(rs.getString("status"));
        it.setReporterName(rs.getString("full_name"));
        return it;
    }

    private boolean isEmpty(String s) { return s == null || s.trim().isEmpty(); }
}
