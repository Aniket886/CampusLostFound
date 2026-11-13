<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.lostfound.util.HtmlUtil" %>
<%
    // read the "lastEmail" cookie to pre-fill the email box
    String lastEmail = "";
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie c : cookies) {
            if ("lastEmail".equals(c.getName())) lastEmail = c.getValue();
        }
    }
    String msg = request.getParameter("msg");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Log in - Campus Lost &amp; Found Portal</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Manrope:wght@700;800&display=swap">
    <link rel="stylesheet" href="css/style.css">
    <link rel="icon" type="image/png" href="img/favicon.png">
    <script src="js/validate.js" defer></script>
</head>
<body class="auth">
<aside class="auth-side">
    <span class="brand">
        <img class="brand-mark" src="img/gmu-logo.png" alt="GM University logo" width="36" height="36">
        Campus Lost &amp; Found
    </span>
    <span class="eyebrow">GM University &middot; Faculty of Computing &amp; IT</span>
    <h1>Lost something on campus? Let's get it back.</h1>
    <ol class="how">
        <li><span><b>Report</b> what you lost or found, with where and when.</span></li>
        <li><span><b>Search</b> every report by keyword and category.</span></li>
        <li><span><b>Claim</b> it with proof. The lost-and-found office checks it and returns the item.</span></li>
    </ol>
</aside>

<main class="auth-main">
    <section class="auth-card">
        <div>
            <h2>Log in</h2>
            <p class="muted">Use your campus email to continue.</p>
        </div>

        <% if ("registered".equals(msg)) { %><p class="alert success">Account created. Log in to continue.</p><% } %>
        <% if ("logout".equals(msg)) { %><p class="alert success">You've been logged out.</p><% } %>
        <% if (error != null) { %><p class="alert error" role="alert"><%= HtmlUtil.esc(error) %></p><% } %>

        <form action="login" method="post" onsubmit="return validateLogin(this)" novalidate>
            <p class="form-error alert error" role="alert" hidden></p>
            <div class="field">
                <label for="email">Email</label>
                <input id="email" type="email" name="email" autocomplete="username"
                       value="<%= HtmlUtil.esc(lastEmail) %>" placeholder="you@campus.edu" required>
            </div>
            <div class="field">
                <label for="password">Password</label>
                <input id="password" type="password" name="password" autocomplete="current-password" required>
            </div>
            <button type="submit" class="btn block">Log in</button>
        </form>

        <p class="demo">Demo accounts: <b>admin@campus.edu</b> / admin123 &middot; <b>student@campus.edu</b> / user123</p>
        <p class="switch">New here? <a href="register.html">Create an account</a></p>
        <a class="signature" href="https://github.com/Aniket886" target="_blank" rel="noopener noreferrer" title="Aniket Tegginamath on GitHub">
            <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" aria-hidden="true"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z"/></svg>
            <span>Developed by <b>Aniket Tegginamath</b></span>
        </a>
    </section>
</main>
</body>
</html>
