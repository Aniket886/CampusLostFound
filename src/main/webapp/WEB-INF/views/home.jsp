<%@ page contentType="text/html;charset=UTF-8" language="java" errorPage="/error.jsp" %>
<%@ page import="java.util.List, com.campus.lostfound.bean.*, com.campus.lostfound.util.HtmlUtil" %>
<%!
    // JSP DECLARATIONS: a field and lifecycle methods of the generated servlet
    private int pageVisits = 0;

    public void jspInit()    { System.out.println("[home.jsp] jspInit() called"); }
    public void jspDestroy() { System.out.println("[home.jsp] jspDestroy() called"); }

    private String badge(String status) {
        return "<span class='status " + status.replace(" ", "-").toLowerCase() + "'>" + status + "</span>";
    }

    private String greeting() {
        int h = java.time.LocalTime.now().getHour();
        return h < 12 ? "Good morning" : h < 17 ? "Good afternoon" : "Good evening";
    }
%>
<jsp:include page="/includes/header.jsp" />
<%
    pageVisits++;
    User user = (User) session.getAttribute("user");
    List<Item> items = (List<Item>) request.getAttribute("recentItems");
    String firstName = user.getFullName().trim().split("\\s+")[0];
    String[] cats = {"Electronics", "Books", "Identity Cards", "Accessories", "Personal Belongings", "Others"};
%>
<section class="hero">
    <div>
        <span class="eyebrow">Campus Lost &amp; Found</span>
        <h1><%= greeting() %>, <%= HtmlUtil.esc(firstName) %></h1>
        <p>Lost something on campus, or found someone else's belongings? Post a report and help it get back to its owner.</p>
    </div>
    <div class="actions">
        <a class="btn" href="<%= response.encodeURL("report?type=Lost") %>">Report lost item</a>
        <a class="btn found" href="<%= response.encodeURL("report?type=Found") %>">Report found item</a>
    </div>
</section>

<!-- GET form: the search appears in the URL so it can be bookmarked -->
<form class="searchbar" action="search" method="get" role="search">
    <label class="visually-hidden" for="q">Keyword</label>
    <input id="q" type="text" name="keyword" placeholder="Search &ldquo;ID card&rdquo;, &ldquo;charger&rdquo;, &ldquo;library&rdquo;&hellip;">
    <label class="visually-hidden" for="qc">Category</label>
    <select id="qc" name="category">
        <option value="">All categories</option>
        <% for (String c : cats) { %><option><%= c %></option><% } %>
    </select>
    <label class="visually-hidden" for="qt">Type</label>
    <select id="qt" name="type">
        <option value="">Lost &amp; found</option>
        <option>Lost</option>
        <option>Found</option>
    </select>
    <button type="submit">Search</button>
</form>

<section class="stack">
    <div class="panel-head">
        <h2>Recently reported</h2>
        <a href="<%= response.encodeURL("search") %>">See all reports &rarr;</a>
    </div>
<% if (items.isEmpty()) { %>
    <div class="empty">
        <b>No items reported yet</b>
        <span>When someone posts a lost or found item, it shows up here.</span>
        <a class="btn" href="report?type=Lost">Post the first report</a>
    </div>
<% } else { %>
    <div class="card-grid">
    <% for (Item it : items) { %>
        <a class="tag-card" href="<%= response.encodeURL("item?id=" + it.getItemId()) %>">
            <div class="row">
                <span class="ref">LF-<%= String.format("%04d", it.getItemId()) %></span>
                <span class="pill <%= it.getReportType().toLowerCase() %>"><%= it.getReportType() %></span>
            </div>
            <h3><%= HtmlUtil.esc(it.getItemName()) %></h3>
            <p><%= HtmlUtil.esc(it.getCategory()) %> &middot; <%= HtmlUtil.esc(it.getLocation()) %></p>
            <div class="row">
                <time class="muted small" datetime="<%= it.getReportDate() %>"><%= it.getReportDate() %></time>
                <%= badge(it.getStatus()) %>
            </div>
        </a>
    <% } %>
    </div>
<% } %>
</section>
<p class="muted small">Page served <%= pageVisits %> time(s) since <%= config.getServletName() %> was loaded.</p>
<%@ include file="/includes/footer.jsp" %>
