<%@ page import="com.campus.lostfound.bean.User, com.campus.lostfound.util.HtmlUtil" %>
<%!
    // JSP DECLARATION: helper that builds one navigation link and marks the current page
    private String link(HttpServletResponse res, String ctx, String target, String label, String current) {
        String cls = target.equals(current) ? " class=\"active\" aria-current=\"page\"" : "";
        return "<a href=\"" + res.encodeURL(ctx + target) + "\"" + cls + ">" + label + "</a>";
    }
%>
<%
    User u = (User) session.getAttribute("user");          // implicit object: session
    String ctx = request.getContextPath();                  // implicit object: request

    // This page is included after a forward, so read the ORIGINAL servlet path from the forward attribute
    String current = (String) request.getAttribute("jakarta.servlet.forward.servlet_path");
    if (current == null) current = request.getServletPath();
    String view = request.getParameter("view");
    if (view != null) current = current + "?view=" + view;

    String initials = "";
    if (u != null) {
        for (String part : u.getFullName().trim().split("\\s+")) {
            if (!part.isEmpty() && initials.length() < 2) initials += part.charAt(0);
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%= application.getInitParameter("appName") %></title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Manrope:wght@700;800&family=JetBrains+Mono:wght@600&display=swap">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
    <link rel="icon" type="image/png" href="<%= ctx %>/img/favicon.png">
    <script src="<%= ctx %>/js/validate.js" defer></script>
</head>
<body>
<header class="topbar">
    <a class="brand" href="<%= response.encodeURL(ctx + (u != null && u.isAdmin() ? "/admin" : "/home")) %>">
        <img class="brand-mark" src="<%= ctx %>/img/gmu-logo.png" alt="GM University logo" width="36" height="36">
        <%= application.getInitParameter("appName") %>
    </a>
    <% if (u != null) { %>
    <input type="checkbox" id="nav-toggle" class="nav-toggle" aria-label="Show menu">
    <label for="nav-toggle" class="nav-burger" title="Menu"><span></span></label>
    <nav class="nav" aria-label="Main">
        <% if (u.isAdmin()) { %>
            <%= link(response, ctx, "/admin", "Dashboard", current) %>
            <%= link(response, ctx, "/admin?view=items", "All reports", current) %>
            <%= link(response, ctx, "/admin?view=claims", "Claims", current) %>
        <% } else { %>
            <%= link(response, ctx, "/home", "Home", current) %>
            <%= link(response, ctx, "/search", "Search", current) %>
            <%= link(response, ctx, "/report", "Report item", current) %>
            <%= link(response, ctx, "/myReports", "My reports", current) %>
            <%= link(response, ctx, "/claims", "My claims", current) %>
        <% } %>
        <span class="nav-end">
            <span class="user-chip">
                <span class="avatar" aria-hidden="true"><%= HtmlUtil.esc(initials.toUpperCase()) %></span>
                <%= HtmlUtil.esc(u.getFullName()) %>
                <% if (u.isAdmin()) { %><span class="role">Admin</span><% } %>
            </span>
            <a class="btn ghost small" href="<%= ctx %>/logout">Log out</a>
        </span>
    </nav>
    <% } %>
</header>
<main class="container">
