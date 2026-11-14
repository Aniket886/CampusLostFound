<%@ page contentType="text/html;charset=UTF-8" language="java" errorPage="/error.jsp" %>
<%@ page import="com.campus.lostfound.bean.User, com.campus.lostfound.util.HtmlUtil" %>
<jsp:include page="/includes/header.jsp" />
<%
    User p = (User) request.getAttribute("profile");             // fresh copy loaded by ProfileServlet
    int reportCount = (Integer) request.getAttribute("reportCount");
    int claimCount = (Integer) request.getAttribute("claimCount");
    int pendingCount = (Integer) request.getAttribute("pendingCount");
    String msg = request.getParameter("msg");
    String error = request.getParameter("error");

    String initials = "";
    for (String part : p.getFullName().trim().split("\\s+")) {
        if (!part.isEmpty() && initials.length() < 2) initials += part.charAt(0);
    }
    String mobile = p.getMobile() == null ? "" : p.getMobile();
%>
<div class="page-head">
    <div>
        <span class="eyebrow">Account</span>
        <h1>Profile settings</h1>
        <p class="muted">Keep your contact details up to date so the lost-and-found office can reach you about a claim.</p>
    </div>
</div>

<% if ("saved".equals(msg)) { %>
    <p class="alert success" role="status">Your details have been saved.</p>
<% } else if ("password".equals(msg)) { %>
    <p class="alert success" role="status">Your password has been changed. Use the new password next time you log in.</p>
<% } %>

<div class="profile-layout">
    <!-- Summary card -->
    <aside class="panel profile-card" aria-label="Account summary">
        <span class="avatar lg" aria-hidden="true"><%= HtmlUtil.esc(initials.toUpperCase()) %></span>
        <div class="stack" style="gap:4px">
            <h2><%= HtmlUtil.esc(p.getFullName()) %></h2>
            <span class="muted"><%= HtmlUtil.esc(p.getEmail()) %></span>
        </div>
        <span class="role"><%= p.isAdmin() ? "Administrator" : "Student / Visitor" %></span>

        <% if (!p.isAdmin()) { %>
        <div class="mini-stats">
            <a href="<%= response.encodeURL("myReports") %>"><b><%= reportCount %></b>Reports</a>
            <a href="<%= response.encodeURL("claims") %>"><b><%= claimCount %></b>Claims</a>
            <a href="<%= response.encodeURL("claims") %>"><b><%= pendingCount %></b>Pending</a>
        </div>
        <% } %>

        <dl class="facts">
            <div><dt>Member ID</dt><dd class="ref">USR-<%= String.format("%04d", p.getUserId()) %></dd></div>
            <div><dt>Mobile</dt><dd><%= mobile.isEmpty() ? "<span class=\"muted\">Not added</span>" : HtmlUtil.esc(mobile) %></dd></div>
            <div><dt>Session</dt><dd>Signs out after <%= session.getMaxInactiveInterval() / 60 %> minutes of inactivity</dd></div>
        </dl>
    </aside>

    <div class="stack">
        <!-- Personal details -->
        <form id="details" class="panel form-grid" action="<%= response.encodeURL("profile") %>" method="post"
              onsubmit="return validateProfile(this)" novalidate>
            <div class="panel-head span-2">
                <h2>Personal details</h2>
                <p class="muted small">Your name is shown on your reports and claims. Your email is also your login.</p>
            </div>
            <% if ("invalid".equals(error)) { %>
                <p class="alert error span-2" role="alert">Some details weren't valid. Use your full name, a valid email and a 10-digit mobile number.</p>
            <% } else if ("exists".equals(error)) { %>
                <p class="alert error span-2" role="alert">That email is already used by another account. Choose a different one.</p>
            <% } %>
            <p class="form-error alert error span-2" role="alert" hidden></p>
            <input type="hidden" name="action" value="details">

            <div class="field span-2">
                <label for="fullName">Full name</label>
                <input id="fullName" type="text" name="fullName" maxlength="100" autocomplete="name"
                       value="<%= HtmlUtil.esc(p.getFullName()) %>" required>
            </div>
            <div class="field">
                <label for="email">Email</label>
                <input id="email" type="email" name="email" maxlength="100" autocomplete="email"
                       value="<%= HtmlUtil.esc(p.getEmail()) %>" required>
            </div>
            <div class="field">
                <label for="mobile">Mobile number</label>
                <input id="mobile" type="tel" name="mobile" maxlength="10" inputmode="numeric" autocomplete="tel"
                       value="<%= HtmlUtil.esc(mobile) %>" placeholder="10-digit number" required>
            </div>
            <div class="field span-2">
                <label for="role">Account type</label>
                <input id="role" type="text" class="readonly" value="<%= p.isAdmin() ? "Administrator" : "Student / Visitor" %>" readonly>
                <small class="hint">Only the lost-and-found office can change the account type.</small>
            </div>
            <div class="actions span-2">
                <button type="submit" class="btn">Save details</button>
                <button type="reset" class="btn ghost">Undo changes</button>
            </div>
        </form>

        <!-- Password -->
        <form id="security" class="panel form-grid" action="<%= response.encodeURL("profile") %>" method="post"
              onsubmit="return validatePassword(this)" novalidate>
            <div class="panel-head span-2">
                <h2>Change password</h2>
                <p class="muted small">Enter your current password, then choose a new one of at least 6 characters.</p>
            </div>
            <% if ("pwwrong".equals(error)) { %>
                <p class="alert error span-2" role="alert">Your current password isn't correct.</p>
            <% } else if ("pwsame".equals(error)) { %>
                <p class="alert error span-2" role="alert">The new password must be different from the current one.</p>
            <% } else if ("pwinvalid".equals(error)) { %>
                <p class="alert error span-2" role="alert">Use at least 6 characters, and type the same new password twice.</p>
            <% } %>
            <p class="form-error alert error span-2" role="alert" hidden></p>
            <input type="hidden" name="action" value="password">
            <input type="text" name="username" value="<%= HtmlUtil.esc(p.getEmail()) %>" autocomplete="username" hidden>

            <div class="field span-2">
                <label for="currentPassword">Current password</label>
                <input id="currentPassword" type="password" name="currentPassword" autocomplete="current-password" required>
            </div>
            <div class="field">
                <label for="newPassword">New password</label>
                <input id="newPassword" type="password" name="newPassword" autocomplete="new-password" required>
            </div>
            <div class="field">
                <label for="confirmPassword">Confirm new password</label>
                <input id="confirmPassword" type="password" name="confirmPassword" autocomplete="new-password" required>
            </div>
            <div class="actions span-2">
                <button type="submit" class="btn">Change password</button>
            </div>
        </form>

        <!-- Appearance: handled in the browser by js/theme.js -->
        <section class="panel" aria-labelledby="appearance-title">
            <div class="panel-head">
                <h2 id="appearance-title">Appearance</h2>
                <p class="muted small">Saved in this browser. You can also switch with the moon / sun button in the top bar.</p>
            </div>
            <fieldset class="theme-choice">
                <legend class="visually-hidden">Theme</legend>
                <label><span class="swatch system" aria-hidden="true"></span><input type="radio" name="themePref" value="system">System</label>
                <label><span class="swatch light" aria-hidden="true"></span><input type="radio" name="themePref" value="light">Light</label>
                <label><span class="swatch dark" aria-hidden="true"></span><input type="radio" name="themePref" value="dark">Dark</label>
            </fieldset>
        </section>
    </div>
</div>
<%@ include file="/includes/footer.jsp" %>
