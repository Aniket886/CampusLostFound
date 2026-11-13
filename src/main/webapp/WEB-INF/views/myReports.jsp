<%@ page contentType="text/html;charset=UTF-8" language="java" errorPage="/error.jsp" %>
<%@ page import="java.util.List, com.campus.lostfound.bean.Item, com.campus.lostfound.util.HtmlUtil" %>
<jsp:include page="/includes/header.jsp" />
<% List<Item> items = (List<Item>) request.getAttribute("items"); %>

<div class="page-head">
    <div>
        <span class="eyebrow">My reports</span>
        <h1>Items you've reported</h1>
    </div>
    <div class="actions">
        <a class="btn" href="<%= response.encodeURL("report?type=Lost") %>">Report lost</a>
        <a class="btn found" href="<%= response.encodeURL("report?type=Found") %>">Report found</a>
    </div>
</div>

<% if ("saved".equals(request.getParameter("msg"))) { %>
    <p class="alert success" role="status">Report posted. It's now visible to everyone who searches.</p>
<% } %>

<% if (items.isEmpty()) { %>
    <div class="empty">
        <b>You haven't reported anything yet</b>
        <span>Reports you post appear here with their current status.</span>
    </div>
<% } else { %>
<div class="table-wrap">
<table class="stack-sm">
    <thead>
        <tr><th>Ref</th><th>Item</th><th>Type</th><th>Location</th><th>Date</th><th>Status</th></tr>
    </thead>
    <tbody>
    <% for (Item it : items) { %>
    <tr>
        <td data-label="Ref"><span class="ref">LF-<%= String.format("%04d", it.getItemId()) %></span></td>
        <td data-label="Item">
            <a class="cell-title" href="<%= response.encodeURL("item?id=" + it.getItemId()) %>"><%= HtmlUtil.esc(it.getItemName()) %></a>
            <span class="cell-sub"><%= HtmlUtil.esc(it.getCategory()) %></span>
        </td>
        <td data-label="Type"><span class="pill <%= it.getReportType().toLowerCase() %>"><%= it.getReportType() %></span></td>
        <td data-label="Location"><%= HtmlUtil.esc(it.getLocation()) %></td>
        <td data-label="Date" class="num"><%= it.getReportDate() %></td>
        <td data-label="Status"><span class="status <%= it.getStatus().replace(" ", "-").toLowerCase() %>"><%= it.getStatus() %></span></td>
    </tr>
    <% } %>
    </tbody>
</table>
</div>
<% } %>
<%@ include file="/includes/footer.jsp" %>
