<%@ page contentType="text/html;charset=UTF-8" language="java" errorPage="/error.jsp" %>
<%@ page import="java.util.List, com.campus.lostfound.bean.Claim, com.campus.lostfound.util.HtmlUtil" %>
<jsp:include page="/includes/header.jsp" />
<%
    List<Claim> claims = (List<Claim>) request.getAttribute("claims");
    String msg = request.getParameter("msg");
    int pending = 0;
    for (Claim c : claims) if ("Pending".equals(c.getClaimStatus())) pending++;
%>
<div class="page-head">
    <div>
        <span class="eyebrow">Administrator</span>
        <h1>Ownership claims</h1>
        <p class="muted"><b class="num"><%= pending %></b> waiting for review. Approving a claim closes the item and rejects any other pending claims on it.</p>
    </div>
</div>

<% if ("approved".equals(msg)) { %>
    <p class="alert success" role="status">Claim approved. The item is now closed.</p>
<% } else if ("rejected".equals(msg)) { %>
    <p class="alert success" role="status">Claim rejected. The claimant can see your remarks.</p>
<% } %>

<% if (claims.isEmpty()) { %>
    <div class="empty"><b>No claims yet</b><span>When someone claims an item, it appears here for verification.</span></div>
<% } else { %>
<div class="claim-list">
<% for (Claim c : claims) { boolean isPending = "Pending".equals(c.getClaimStatus()); %>
    <article class="claim-card <%= isPending ? "is-pending" : "" %>">
        <div>
            <div class="row">
                <span class="ref">CLAIM #<%= c.getClaimId() %> &middot; LF-<%= String.format("%04d", c.getItemId()) %></span>
                <span class="status <%= c.getClaimStatus().toLowerCase() %>"><%= c.getClaimStatus() %></span>
            </div>
            <h3><a href="<%= response.encodeURL("item?id=" + c.getItemId()) %>"><%= HtmlUtil.esc(c.getItemName()) %></a>
                <small>Claimed by <%= HtmlUtil.esc(c.getClaimantName()) %> on <%= c.getClaimDate() %></small></h3>
            <blockquote class="evidence"><%= HtmlUtil.esc(c.getOwnershipDetails()) %></blockquote>
        </div>
        <% if (isPending) { %>
        <form class="claim-decide" action="admin" method="post">
            <input type="hidden" name="action" value="decide">
            <input type="hidden" name="claimId" value="<%= c.getClaimId() %>">
            <div class="field">
                <label for="remarks-<%= c.getClaimId() %>">Verification remarks</label>
                <textarea id="remarks-<%= c.getClaimId() %>" name="remarks" rows="2" required
                          placeholder="What did you check? e.g. card number matched the student register"></textarea>
            </div>
            <div class="actions">
                <button type="submit" name="decision" value="Approved">Approve &amp; close item</button>
                <button type="submit" name="decision" value="Rejected" class="danger">Reject</button>
            </div>
        </form>
        <% } else { %>
        <p class="remarks"><b>Remarks:</b> <%= c.getAdminRemarks() == null ? "None" : HtmlUtil.esc(c.getAdminRemarks()) %></p>
        <% } %>
    </article>
<% } %>
</div>
<% } %>
<%@ include file="/includes/footer.jsp" %>
