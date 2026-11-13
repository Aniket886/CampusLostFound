package com.campus.lostfound.bean;

import java.io.Serializable;

/** JavaBean (Model) for one row of the items table. */
public class Item implements Serializable {
    private static final long serialVersionUID = 1L;

    private int itemId;
    private int userId;
    private String itemName;
    private String category;
    private String description;
    private String reportType;   // Lost or Found
    private String location;
    private String reportDate;   // yyyy-MM-dd
    private String status;       // Open, Claim Pending, Closed
    private String reporterName; // filled by JOIN, only for display

    public Item() { }

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getReportType() { return reportType; }
    public void setReportType(String reportType) { this.reportType = reportType; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getReportDate() { return reportDate; }
    public void setReportDate(String reportDate) { this.reportDate = reportDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getReporterName() { return reporterName; }
    public void setReporterName(String reporterName) { this.reporterName = reporterName; }
}
