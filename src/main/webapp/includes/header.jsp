<%@ page import="com.campus.lostfound.bean.User, com.campus.lostfound.util.HtmlUtil" %>
<%!
    // JSP DECLARATION: helper that builds one navigation link and marks the current page
    private String link(HttpServletResponse res, String ctx, String target, String label, String current) {
        String cls = target.equals(current) ? " class=\"active\" aria-current=\"page\"" : "";
        return "<a href=\"" + res.encodeURL(ctx + target) + "\"" + cls + ">" + label + "</a>";
    }

    // JSP DECLARATION: light / dark switch button (js/theme.js handles the click)
    private String themeButton(String extraClass) {
        return "<button type=\"button\" class=\"theme-toggle" + extraClass + "\" data-theme-toggle"
             + " aria-label=\"Switch theme\" title=\"Switch theme\">"
             + "<svg class=\"icon-moon\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\"><path d=\"M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z\"/></svg>"
             + "<svg class=\"icon-sun\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\"><circle cx=\"12\" cy=\"12\" r=\"4\"/><path d=\"M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41\"/></svg>"
             + "</button>";
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
    <script src="<%= ctx %>/js/theme.js"></script>   <!-- not deferred: sets the theme before the page paints -->
    <script src="<%= ctx %>/js/validate.js" defer></script>
</head>
<body>
<header class="topbar">
    <a class="brand" href="<%= response.encodeURL(ctx + (u != null && u.isAdmin() ? "/admin" : "/home")) %>">
        <img class="brand-mark" src="<%= ctx %>/img/gmu-logo.png" alt="GM University logo" width="36" height="36">
        <%= application.getInitParameter("appName") %>
    </a>
    <%-- Guests: the switch sits in the top bar. Signed in: a top-bar copy is shown only on phones,
         because there the menu (with the desktop copy) is collapsed. --%>
    <%= themeButton(u == null ? "" : " mobile-only") %>
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
            <%= themeButton(" desktop-only") %>
            <a class="user-chip<%= "/profile".equals(current) ? " active" : "" %>" href="<%= response.encodeURL(ctx + "/profile") %>"
               title="Profile settings"<%= "/profile".equals(current) ? " aria-current=\"page\"" : "" %>>
                <span class="avatar" aria-hidden="true"><%= HtmlUtil.esc(initials.toUpperCase()) %></span>
                <%= HtmlUtil.esc(u.getFullName()) %>
                <% if (u.isAdmin()) { %><span class="role">Admin</span><% } %>
            </a>
            <a class="btn ghost small" href="<%= ctx %>/logout">Log out</a>
        </span>
    </nav>
    <% } %>
</header>
<main class="container">
