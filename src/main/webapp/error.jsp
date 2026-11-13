<%@ page isErrorPage="true" contentType="text/html;charset=UTF-8" %>
<%@ page import="com.campus.lostfound.util.HtmlUtil" %>
<%
    Integer code = (Integer) request.getAttribute("jakarta.servlet.error.status_code");
    String reason = "", hint = "";
    if (exception != null) {                 // implicit object: exception (only in error pages)
        application.log("Application error", exception);
        Throwable root = exception;          // find the real cause (e.g. the SQLException)
        while (root.getCause() != null) root = root.getCause();
        reason = root.getClass().getSimpleName() + ": " + root.getMessage();
        String m = String.valueOf(root.getMessage());
        if (m.contains("Access denied"))
            hint = "Wrong MySQL user name or password. Change USER and PASSWORD in DBConnection.java and run the project again.";
        else if (m.contains("Unknown database"))
            hint = "The database is missing. Run database/campus_lost_found.sql in MySQL first.";
        else if (m.contains("Communications link failure") || m.contains("Connection refused"))
            hint = "MySQL is not running (or not on port 3306). Start the MySQL server and try again.";
        else if (m.contains("doesn't exist"))
            hint = "A table is missing. Run database/campus_lost_found.sql again.";
        else if (m.contains("Data too long"))
            hint = "One of the values is too long. Please enter shorter text.";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Error - Campus Lost &amp; Found Portal</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Manrope:wght@700;800&display=swap">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <link rel="icon" type="image/png" href="<%= request.getContextPath() %>/img/favicon.png">
</head>
<body class="auth">
<aside class="auth-side">
    <span class="brand">
        <img class="brand-mark" src="<%= request.getContextPath() %>/img/gmu-logo.png" alt="GM University logo" width="36" height="36">
        Campus Lost &amp; Found
    </span>
    <h1><%= code != null && code == 403 ? "This page is for administrators."
          : code != null && code == 404 ? "We couldn't find that page."
          : "Something went wrong." %></h1>
    <% if (code != null) { %><p class="eyebrow">HTTP status <%= code %></p><% } %>
</aside>
<main class="auth-main">
    <section class="auth-card">
        <h2><%= code != null && code == 403 ? "Access denied" : code != null && code == 404 ? "Not found" : "Error" %></h2>
    <% if (code != null && code == 403) { %>
        <p class="alert error">Only the lost-and-found office (administrator account) can open this page.</p>
    <% } else if (code != null && code == 404) { %>
        <p class="alert error">The page or item you asked for doesn't exist. It may have been removed as a duplicate.</p>
    <% } else if (code != null && code == 400) { %>
        <p class="alert error">The request had a value the portal doesn't accept. Go back and try again.</p>
    <% } else { %>
        <p class="alert error">Something went wrong: <%= exception != null ? exception.getClass().getSimpleName() : "Unknown error" %></p>
        <% if (!hint.isEmpty()) { %><p class="alert success"><span><b>How to fix:</b> <%= HtmlUtil.esc(hint) %></span></p><% } %>
        <% if (!reason.isEmpty()) { %><p class="muted small"><b>Details:</b> <%= HtmlUtil.esc(reason) %></p><% } %>
    <% } %>
        <a class="btn block" href="<%= request.getContextPath() %>/home">Go to home</a>
        <a class="signature" href="https://github.com/Aniket886" target="_blank" rel="noopener noreferrer" title="Aniket Tegginamath on GitHub">
            <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" aria-hidden="true"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z"/></svg>
            <span>Developed by <b>Aniket Tegginamath</b></span>
        </a>
    </section>
</main>
</body>
</html>
