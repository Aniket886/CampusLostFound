<%@ page contentType="text/html;charset=UTF-8" language="java" errorPage="/error.jsp" %>
<%@ page import="java.util.List, com.campus.lostfound.bean.Claim, com.campus.lostfound.util.HtmlUtil" %>
<jsp:include page="/includes/header.jsp" />
<% List<Claim> claims = (List<Claim>) request.getAttribute("claims"); %>

<div class="page-head">
    <div>
        <span class="eyebrow">My claims</span>
        <h1>Ownership claims you've made</h1>
    </div>
</div>

<% if ("submitted".equals(request.getParameter("msg"))) { %>
    <p class="alert success" role="status">Claim submitted. The lost-and-found office will check it, and the decision will appear here.</p>
<% } %>

<% if (claims.isEmpty()) { %>
    <div class="empty">
        <b>No claims yet</b>
        <span>Found your item in the search results? Open it and use "Is this yours?" to claim it.</span>
        <a class="btn" href="<%= response.encodeURL("search") %>">Search items</a>
    </div>
<% } else { %>
<div class="claim-list">
    <% for (Claim c : claims) { %>
    <article class="claim-card <%= "Pending".equals(c.getClaimStatus()) ? "is-pending" : "" %>">
        <div>
            <div class="row">
                <span class="ref">CLAIM #<%= c.getClaimId() %> &middot; LF-<%= String.format("%04d", c.getItemId()) %></span>
                <span class="status <%= c.getClaimStatus().toLowerCase() %>"><%= c.getClaimStatus() %></span>
            </div>
            <h3><a href="<%= response.encodeURL("item?id=" + c.getItemId()) %>"><%= HtmlUtil.esc(c.getItemName()) %></a>
                <small>Submitted <%= c.getClaimDate() %></small></h3>
            <blockquote class="evidence"><%= HtmlUtil.esc(c.getOwnershipDetails()) %></blockquote>
        </div>
        <p class="remarks">
        <% if ("Pending".equals(c.getClaimStatus())) { %>
            Waiting for the office to verify your proof.
        <% } else { %>
            <b>Office remarks:</b> <%= c.getAdminRemarks() == null ? "None" : HtmlUtil.esc(c.getAdminRemarks()) %>
        <% } %>
        </p>
    </article>
    <% } %>
</div>
<% } %>
<%@ include file="/includes/footer.jsp" %>
