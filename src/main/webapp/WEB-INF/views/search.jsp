<%@ page contentType="text/html;charset=UTF-8" language="java" errorPage="/error.jsp" %>
<%@ page import="java.util.List, com.campus.lostfound.bean.Item, com.campus.lostfound.util.HtmlUtil" %>
<jsp:include page="/includes/header.jsp" />
<%
    List<Item> results = (List<Item>) request.getAttribute("results");
    String kw  = HtmlUtil.esc(request.getParameter("keyword"));
    String cat = request.getParameter("category") == null ? "" : request.getParameter("category");
    String typ = request.getParameter("type") == null ? "" : request.getParameter("type");
    String[] cats = {"Electronics", "Books", "Identity Cards", "Accessories", "Personal Belongings", "Others"};
%>
<div class="page-head">
    <div>
        <span class="eyebrow">Search</span>
        <h1>Find a lost or found item</h1>
    </div>
</div>

<!-- GET form: values appear in the URL, e.g. search?keyword=bag&category=Accessories -->
<form class="searchbar" action="search" method="get" role="search">
    <label class="visually-hidden" for="keyword">Keyword</label>
    <input id="keyword" type="text" name="keyword" value="<%= kw %>" placeholder="Item name, description or place">
    <label class="visually-hidden" for="category">Category</label>
    <select id="category" name="category">
        <option value="">All categories</option>
        <% for (String c : cats) { %>
            <option <%= c.equals(cat) ? "selected" : "" %>><%= c %></option>
        <% } %>
    </select>
    <label class="visually-hidden" for="type">Type</label>
    <select id="type" name="type">
        <option value="">Lost &amp; found</option>
        <option <%= "Lost".equals(typ) ? "selected" : "" %>>Lost</option>
        <option <%= "Found".equals(typ) ? "selected" : "" %>>Found</option>
    </select>
    <button type="submit">Search</button>
</form>

<p class="muted"><b class="num"><%= results.size() %></b> item(s) match<%= kw.isEmpty() ? "" : " &ldquo;" + kw + "&rdquo;" %></p>

<% if (results.isEmpty()) { %>
    <div class="empty">
        <b>Nothing matches yet</b>
        <span>Try a shorter keyword or another category. If you lost it, post a report so the finder can reach you.</span>
        <a class="btn" href="report?type=Lost">Report a lost item</a>
    </div>
<% } else { %>
<div class="card-grid">
    <% for (Item it : results) { %>
    <a class="tag-card" href="<%= response.encodeURL("item?id=" + it.getItemId()) %>">
        <div class="row">
            <span class="ref">LF-<%= String.format("%04d", it.getItemId()) %></span>
            <span class="pill <%= it.getReportType().toLowerCase() %>"><%= it.getReportType() %></span>
        </div>
        <h3><%= HtmlUtil.esc(it.getItemName()) %></h3>
        <p><%= HtmlUtil.esc(it.getCategory()) %> &middot; <%= HtmlUtil.esc(it.getLocation()) %></p>
        <div class="row">
            <time class="muted small"><%= it.getReportDate() %></time>
            <span class="status <%= it.getStatus().replace(" ", "-").toLowerCase() %>"><%= it.getStatus() %></span>
        </div>
    </a>
    <% } %>
</div>
<% } %>
<%@ include file="/includes/footer.jsp" %>
