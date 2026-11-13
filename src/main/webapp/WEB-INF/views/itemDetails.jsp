<%@ page contentType="text/html;charset=UTF-8" language="java" errorPage="/error.jsp" %>
<%@ page import="java.util.List, com.campus.lostfound.bean.*, com.campus.lostfound.util.HtmlUtil" %>
<jsp:include page="/includes/header.jsp" />
<%
    Item it = (Item) request.getAttribute("item");
    List<Claim> claims = (List<Claim>) request.getAttribute("claims");
    User me = (User) session.getAttribute("user");
    boolean mine = it.getUserId() == me.getUserId();
    Claim myClaim = null;
    for (Claim c : claims) if (c.getUserId() == me.getUserId()) myClaim = c;
    String error = request.getParameter("error");
    String statusCls = it.getStatus().replace(" ", "-").toLowerCase();
%>
<div class="page-head">
    <div>
        <a class="small" href="<%= response.encodeURL(me.isAdmin() ? "admin?view=items" : "search") %>">&larr; Back to <%= me.isAdmin() ? "all reports" : "search" %></a>
        <h1><%= HtmlUtil.esc(it.getItemName()) %></h1>
    </div>
</div>

<% if ("notallowed".equals(error)) { %>
    <p class="alert error" role="alert">You can't claim this item. It may be your own report, already closed, or you've claimed it before.</p>
<% } else if ("short".equals(error)) { %>
    <p class="alert error" role="alert">Your claim needs more proof. Write at least 15 characters about what makes it yours.</p>
<% } %>

<div class="detail">
    <article class="tag-card">
        <div class="row">
            <span class="ref">LF-<%= String.format("%04d", it.getItemId()) %></span>
            <span class="pill <%= it.getReportType().toLowerCase() %>"><%= it.getReportType() %></span>
        </div>
        <dl class="facts">
            <div><dt>Category</dt><dd><%= HtmlUtil.esc(it.getCategory()) %></dd></div>
            <div><dt>Status</dt><dd><span class="status <%= statusCls %>"><%= it.getStatus() %></span></dd></div>
            <div><dt><%= it.getReportType() %> at</dt><dd><%= HtmlUtil.esc(it.getLocation()) %></dd></div>
            <div><dt>Date</dt><dd><%= it.getReportDate() %></dd></div>
            <div class="full"><dt>Description</dt><dd><%= HtmlUtil.esc(it.getDescription()) %></dd></div>
            <div class="full"><dt>Reported by</dt><dd><%= HtmlUtil.esc(it.getReporterName()) %><%= mine ? " (you)" : "" %></dd></div>
        </dl>
    </article>

    <aside class="stack">
    <% if (me.isAdmin()) { %>
        <div class="panel">
            <h3>Claims on this item</h3>
            <% if (claims.isEmpty()) { %>
                <p class="muted">No one has claimed this item yet.</p>
            <% } else { for (Claim c : claims) { %>
                <div class="row">
                    <span><%= HtmlUtil.esc(c.getClaimantName()) %> <span class="muted small">&middot; <%= c.getClaimDate() %></span></span>
                    <span class="status <%= c.getClaimStatus().toLowerCase() %>"><%= c.getClaimStatus() %></span>
                </div>
            <% } } %>
            <a class="btn ghost" href="<%= response.encodeURL("admin?view=claims") %>">Review claims</a>
        </div>
    <% } else if (mine) { %>
        <div class="panel">
            <h3>This is your report</h3>
            <p class="muted"><%= claims.isEmpty() ? "No claims yet. The office will contact you when someone claims it."
                                                  : claims.size() + " claim(s) submitted. The office is reviewing them." %></p>
            <a class="btn ghost" href="<%= response.encodeURL("myReports") %>">View my reports</a>
        </div>
    <% } else if (myClaim != null) { %>
        <div class="panel">
            <h3>Your claim</h3>
            <div class="row">
                <span class="muted small">Submitted <%= myClaim.getClaimDate() %></span>
                <span class="status <%= myClaim.getClaimStatus().toLowerCase() %>"><%= myClaim.getClaimStatus() %></span>
            </div>
            <% if (myClaim.getAdminRemarks() != null) { %><p class="remarks"><b>Remarks:</b> <%= HtmlUtil.esc(myClaim.getAdminRemarks()) %></p><% } %>
            <a class="btn ghost" href="<%= response.encodeURL("claims") %>">View my claims</a>
        </div>
    <% } else if ("Closed".equals(it.getStatus())) { %>
        <div class="panel">
            <h3>Returned to its owner</h3>
            <p class="muted">This item has been recovered, so it can't be claimed any more.</p>
        </div>
    <% } else { %>
        <form class="panel" action="claims" method="post" onsubmit="return validateClaim(this)" novalidate>
            <div>
                <h3>Is this yours?</h3>
                <p class="muted small">Tell the office something only the owner would know. They check it before handing the item over.</p>
            </div>
            <p class="form-error alert error" role="alert" hidden></p>
            <input type="hidden" name="itemId" value="<%= it.getItemId() %>">
            <div class="field">
                <label for="ownershipDetails">Proof of ownership</label>
                <textarea id="ownershipDetails" name="ownershipDetails" rows="5" required
                    placeholder="Hidden marks, contents, serial number, where you bought it&hellip;"></textarea>
                <small class="hint">At least 15 characters.</small>
            </div>
            <button type="submit" class="btn block">Submit claim</button>
        </form>
    <% } %>
    </aside>
</div>
<%@ include file="/includes/footer.jsp" %>
