<%@ page contentType="text/html;charset=UTF-8" language="java" errorPage="/error.jsp" %>
<%@ page import="java.util.List, com.campus.lostfound.bean.Item, com.campus.lostfound.util.HtmlUtil" %>
<%!
    // JSP declaration: share of the total as a whole percentage, for the bar under each tile
    private int pct(int part, int total) { return total == 0 ? 0 : Math.round(part * 100f / total); }
%>
<jsp:include page="/includes/header.jsp" />
<%
    int[] s = (int[]) request.getAttribute("summary");   // {total, lost, found, closed, pendingClaims} from sp_item_summary
    List<Item> recent = (List<Item>) request.getAttribute("recentItems");
    int total = s[0];
%>
<div class="page-head">
    <div>
        <span class="eyebrow">Administrator</span>
        <h1>Dashboard</h1>
        <p class="muted"><b class="num"><%= pct(s[3], total) %>%</b> of all reported items have been recovered and closed.</p>
    </div>
    <div class="actions">
        <a class="btn" href="<%= response.encodeURL("admin?view=claims") %>">Review claims<%= s[4] > 0 ? " (" + s[4] + ")" : "" %></a>
        <a class="btn ghost" href="<%= response.encodeURL("admin?view=items") %>">All reports</a>
    </div>
</div>

<div class="stats">
    <div class="stat"><b><%= s[0] %></b><span>Total reports</span><div class="bar"><i style="width:100%"></i></div></div>
    <div class="stat lost"><b><%= s[1] %></b><span>Lost items</span><div class="bar"><i style="width:<%= pct(s[1], total) %>%"></i></div></div>
    <div class="stat found"><b><%= s[2] %></b><span>Found items</span><div class="bar"><i style="width:<%= pct(s[2], total) %>%"></i></div></div>
    <div class="stat found"><b><%= s[3] %></b><span>Recovered (closed)</span><div class="bar"><i style="width:<%= pct(s[3], total) %>%"></i></div></div>
    <div class="stat pending"><b><%= s[4] %></b><span>Claims waiting for review</span><div class="bar"><i style="width:<%= s[4] > 0 ? 100 : 0 %>%"></i></div></div>
</div>

<section class="stack">
    <div class="panel-head">
        <h2>Latest reports</h2>
        <a href="<%= response.encodeURL("admin?view=items") %>">Manage all &rarr;</a>
    </div>
    <% if (recent.isEmpty()) { %>
        <div class="empty"><b>No reports yet</b><span>New lost and found reports will appear here.</span></div>
    <% } else { %>
    <div class="table-wrap">
    <table class="stack-sm">
        <thead><tr><th>Ref</th><th>Item</th><th>Type</th><th>Reported by</th><th>Date</th><th>Status</th></tr></thead>
        <tbody>
        <% for (Item it : recent) { %>
        <tr>
            <td data-label="Ref"><span class="ref">LF-<%= String.format("%04d", it.getItemId()) %></span></td>
            <td data-label="Item"><a class="cell-title" href="<%= response.encodeURL("item?id=" + it.getItemId()) %>"><%= HtmlUtil.esc(it.getItemName()) %></a>
                <span class="cell-sub"><%= HtmlUtil.esc(it.getLocation()) %></span></td>
            <td data-label="Type"><span class="pill <%= it.getReportType().toLowerCase() %>"><%= it.getReportType() %></span></td>
            <td data-label="Reported by"><%= HtmlUtil.esc(it.getReporterName()) %></td>
            <td data-label="Date" class="num"><%= it.getReportDate() %></td>
            <td data-label="Status"><span class="status <%= it.getStatus().replace(" ", "-").toLowerCase() %>"><%= it.getStatus() %></span></td>
        </tr>
        <% } %>
        </tbody>
    </table>
    </div>
    <% } %>
</section>
<%@ include file="/includes/footer.jsp" %>
