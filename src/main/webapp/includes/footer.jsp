<%
    // Static include: this code is pasted into each view, so the names are prefixed to avoid clashes
    com.campus.lostfound.bean.User ftUser = (com.campus.lostfound.bean.User) session.getAttribute("user");
    String ftCtx = request.getContextPath();
%>
</main>
<footer class="site-footer">
    <div class="footer-inner">
        <div class="footer-brand">
            <div class="footer-logo">
                <img src="<%= ftCtx %>/img/gmu-logo.png" alt="GM University logo" width="44" height="44">
                <div>
                    <b>Campus Lost &amp; Found Portal</b>
                    <span>GM University &middot; Faculty of Computing &amp; IT</span>
                </div>
            </div>
            <p>Helping students, faculty and visitors return lost belongings to their owners across campus.</p>
        </div>

        <nav class="footer-col" aria-label="Footer">
            <h4>Portal</h4>
            <% if (ftUser != null && ftUser.isAdmin()) { %>
                <a href="<%= response.encodeURL(ftCtx + "/admin") %>">Dashboard</a>
                <a href="<%= response.encodeURL(ftCtx + "/admin?view=items") %>">All reports</a>
                <a href="<%= response.encodeURL(ftCtx + "/admin?view=claims") %>">Ownership claims</a>
            <% } else { %>
                <a href="<%= response.encodeURL(ftCtx + "/search") %>">Search items</a>
                <a href="<%= response.encodeURL(ftCtx + "/report?type=Lost") %>">Report a lost item</a>
                <a href="<%= response.encodeURL(ftCtx + "/report?type=Found") %>">Report a found item</a>
                <a href="<%= response.encodeURL(ftCtx + "/claims") %>">My claims</a>
            <% } %>
        </nav>

        <div class="footer-col">
            <h4>About this project</h4>
            <span>Advanced Java Programming</span>
            <span>MCA &middot; Semester I &middot; Assignment-1</span>
            <span class="footer-stack">Servlets &middot; JSP &middot; JavaBeans &middot; JDBC &middot; MySQL</span>
        </div>
    </div>

    <div class="footer-bottom">
        <span>&copy; <%= java.time.Year.now() %> Campus Lost &amp; Found Portal &middot; For academic use</span>
        <a class="signature" href="https://github.com/Aniket886" target="_blank" rel="noopener noreferrer"
           title="Aniket Tegginamath on GitHub">
            <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" aria-hidden="true"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z"/></svg>
            <span>Developed by <b>Aniket Tegginamath</b></span>
        </a>
    </div>
</footer>
</body>
</html>
