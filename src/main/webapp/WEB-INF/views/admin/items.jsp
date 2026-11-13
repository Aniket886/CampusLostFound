<%@ page contentType="text/html;charset=UTF-8" language="java" errorPage="/error.jsp" %>
<%@ page import="java.util.List, com.campus.lostfound.bean.Item, com.campus.lostfound.util.HtmlUtil" %>
<jsp:include page="/includes/header.jsp" />
<%
    List<Item> items = (List<Item>) request.getAttribute("items");
    String msg = request.getParameter("msg");
    String[] statuses = {"Open", "Claim Pending", "Closed"};
    String[] cats = {"Electronics", "Books", "Identity Cards", "Accessories", "Personal Belongings", "Others"};
    String cat = request.getParameter("category") == null ? "" : request.getParameter("category");
    String typ = request.getParameter("type") == null ? "" : request.getParameter("type");
%>
<div class="page-head">
    <div>
        <span class="eyebrow">Administrator</span>
        <h1>All lost &amp; found reports</h1>
        <p class="muted">Change a status from its drop-down, or remove duplicate and inappropriate reports.</p>
    </div>
</div>

<% if (msg != null) { %>
    <p class="alert success" role="status">Report <%= "deleted".equals(msg) ? "removed" : "status updated" %>.</p>
<% } %>

<form class="searchbar" action="admin" method="get" role="search">
    <input type="hidden" name="view" value="items">
    <label class="visually-hidden" for="keyword">Keyword</label>
    <input id="keyword" type="text" name="keyword" value="<%= HtmlUtil.esc(request.getParameter("keyword")) %>" placeholder="Item name, description or place">
    <label class="visually-hidden" for="category">Category</label>
    <select id="category" name="category">
        <option value="">All categories</option>
        <% for (String c : cats) { %><option <%= c.equals(cat) ? "selected" : "" %>><%= c %></option><% } %>
    </select>
    <label class="visually-hidden" for="type">Type</label>
    <select id="type" name="type">
        <option value="">Lost &amp; found</option>
        <option <%= "Lost".equals(typ) ? "selected" : "" %>>Lost</option>
        <option <%= "Found".equals(typ) ? "selected" : "" %>>Found</option>
    </select>
    <button type="submit">Filter</button>
</form>

<p class="muted"><b class="num"><%= items.size() %></b> report(s)</p>

<% if (items.isEmpty()) { %>
    <div class="empty"><b>No reports match</b><span>Clear the filters to see every report.</span>
        <a class="btn ghost" href="<%= response.encodeURL("admin?view=items") %>">Clear filters</a></div>
<% } else { %>
<div class="table-wrap">
<table class="stack-sm">
    <thead>
        <tr><th>Ref</th><th>Item</th><th>Type</th><th>Location</th><th>Date</th><th>Reported by</th><th>Status</th><th><span class="visually-hidden">Remove</span></th></tr>
    </thead>
    <tbody>
    <% for (Item it : items) { %>
    <tr>
        <td data-label="Ref"><span class="ref">LF-<%= String.format("%04d", it.getItemId()) %></span></td>
        <td data-label="Item"><a class="cell-title" href="<%= response.encodeURL("item?id=" + it.getItemId()) %>"><%= HtmlUtil.esc(it.getItemName()) %></a>
            <span class="cell-sub"><%= HtmlUtil.esc(it.getCategory()) %></span></td>
        <td data-label="Type"><span class="pill <%= it.getReportType().toLowerCase() %>"><%= it.getReportType() %></span></td>
        <td data-label="Location"><%= HtmlUtil.esc(it.getLocation()) %></td>
        <td data-label="Date" class="num"><%= it.getReportDate() %></td>
        <td data-label="Reported by"><%= HtmlUtil.esc(it.getReporterName()) %></td>
        <td data-label="Status">
            <form class="inline" action="admin" method="post">
                <input type="hidden" name="action" value="status">
                <input type="hidden" name="itemId" value="<%= it.getItemId() %>">
                <label class="visually-hidden" for="st-<%= it.getItemId() %>">Status</label>
                <select id="st-<%= it.getItemId() %>" name="status" onchange="this.form.submit()">
                    <% for (String st : statuses) { %>
                        <option <%= st.equals(it.getStatus()) ? "selected" : "" %>><%= st %></option>
                    <% } %>
                </select>
            </form>
        </td>
        <td data-label="Remove">
            <form class="inline" action="admin" method="post"
                  onsubmit="return confirm('Remove LF-<%= String.format("%04d", it.getItemId()) %>? Its claims will be deleted too.')">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="itemId" value="<%= it.getItemId() %>">
                <button class="danger small" type="submit">Delete</button>
            </form>
        </td>
    </tr>
    <% } %>
    </tbody>
</table>
</div>
<% } %>
<%@ include file="/includes/footer.jsp" %>
