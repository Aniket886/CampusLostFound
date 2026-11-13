package com.campus.lostfound.bean;

import java.io.Serializable;

/** JavaBean (Model) for one row of the claims table. */
public class Claim implements Serializable {
    private static final long serialVersionUID = 1L;

    private int claimId;
    private int itemId;
    private int userId;
    private String ownershipDetails;
    private String claimDate;
    private String claimStatus;   // Pending, Approved, Rejected
    private String adminRemarks;
    private String itemName;      // filled by JOIN, only for display
    private String claimantName;  // filled by JOIN, only for display

    public Claim() { }

    public int getClaimId() { return claimId; }
    public void setClaimId(int claimId) { this.claimId = claimId; }

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getOwnershipDetails() { return ownershipDetails; }
    public void setOwnershipDetails(String ownershipDetails) { this.ownershipDetails = ownershipDetails; }

    public String getClaimDate() { return claimDate; }
    public void setClaimDate(String claimDate) { this.claimDate = claimDate; }

    public String getClaimStatus() { return claimStatus; }
    public void setClaimStatus(String claimStatus) { this.claimStatus = claimStatus; }

    public String getAdminRemarks() { return adminRemarks; }
    public void setAdminRemarks(String adminRemarks) { this.adminRemarks = adminRemarks; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public String getClaimantName() { return claimantName; }
    public void setClaimantName(String claimantName) { this.claimantName = claimantName; }
}
