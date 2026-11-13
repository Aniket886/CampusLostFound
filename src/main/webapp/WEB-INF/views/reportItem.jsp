<%@ page contentType="text/html;charset=UTF-8" language="java" errorPage="/error.jsp" %>
<jsp:include page="/includes/header.jsp" />
<%
    String type = (String) request.getAttribute("type");          // "Lost" or "Found", whitelisted by the servlet
    boolean lost = "Lost".equals(type);
    String[] categories = {"Electronics", "Books", "Identity Cards", "Accessories", "Personal Belongings", "Others"};
%>
<div class="page-head">
    <div>
        <span class="eyebrow">New report</span>
        <h1><%= lost ? "Report a lost item" : "Report a found item" %></h1>
        <p class="muted"><%= lost ? "Tell us what you lost and where. Anyone who finds it can match it to your report."
                                  : "Tell us what you found and where, so the owner can recognise it." %></p>
    </div>
    <nav class="segmented" aria-label="Report type">
        <a href="<%= response.encodeURL("report?type=Lost") %>" class="<%= lost ? "on lost" : "" %>">I lost something</a>
        <a href="<%= response.encodeURL("report?type=Found") %>" class="<%= lost ? "" : "on found" %>">I found something</a>
    </nav>
</div>

<% if ("invalid".equals(request.getParameter("error"))) { %>
    <p class="alert error" role="alert">Some details weren't valid. Fill every field, pick a category, and use a date that isn't in the future.</p>
<% } %>

<form class="panel narrow form-grid" action="report" method="post" onsubmit="return validateItem(this)" novalidate>
    <p class="form-error alert error span-2" role="alert" hidden></p>
    <input type="hidden" name="reportType" value="<%= type %>">

    <div class="field span-2">
        <label for="itemName">Item name</label>
        <input id="itemName" type="text" name="itemName" maxlength="100" placeholder="e.g. Black HP laptop bag" required>
    </div>
    <div class="field">
        <label for="category">Category</label>
        <select id="category" name="category" required>
            <option value="">Choose a category</option>
            <% for (String c : categories) { %><option><%= c %></option><% } %>
        </select>
    </div>
    <div class="field">
        <label for="reportDate">Date <%= type.toLowerCase() %></label>
        <input id="reportDate" type="date" name="reportDate" max="<%= java.time.LocalDate.now() %>" required>
    </div>
    <div class="field span-2">
        <label for="location">Where on campus?</label>
        <input id="location" type="text" name="location" maxlength="150" placeholder="e.g. Central Library, Main Canteen, MCA Lab 2" required>
    </div>
    <div class="field span-2">
        <label for="description">Description</label>
        <textarea id="description" name="description" rows="4" required
            placeholder="<%= lost ? "Colour, brand, marks, what was inside" : "What it looks like. Keep one detail back so the real owner can prove it." %>"></textarea>
        <small class="hint"><%= lost ? "The more detail you give, the easier it is to match." : "After posting, please hand the item to the lost-and-found office." %></small>
    </div>
    <div class="actions span-2">
        <button type="submit" class="btn <%= lost ? "" : "found" %>">Post <%= type.toLowerCase() %> report</button>
        <a class="btn ghost" href="<%= response.encodeURL("home") %>">Cancel</a>
    </div>
</form>
<%@ include file="/includes/footer.jsp" %>
