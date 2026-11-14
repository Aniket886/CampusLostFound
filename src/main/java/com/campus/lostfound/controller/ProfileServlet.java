package com.campus.lostfound.controller;

import com.campus.lostfound.bean.Claim;
import com.campus.lostfound.bean.User;
import com.campus.lostfound.dao.ClaimDAO;
import com.campus.lostfound.dao.ItemDAO;
import com.campus.lostfound.dao.UserDAO;
import com.campus.lostfound.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.regex.Pattern;

/**
 * Profile settings (GET /profile shows the page).
 * POST action=details updates name, email and mobile; POST action=password changes the password.
 * Every POST ends with Post-Redirect-Get, so a refresh never submits the form twice.
 */
@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private static final Pattern EMAIL = Pattern.compile("^\\S+@\\S+\\.\\S+$");
    private static final Pattern MOBILE = Pattern.compile("^[0-9]{10}$");

    private final UserDAO userDAO = new UserDAO();
    private final ItemDAO itemDAO = new ItemDAO();
    private final ClaimDAO claimDAO = new ClaimDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = SessionUtil.currentUser(request);
        if (user == null) { response.sendRedirect("login"); return; }

        // Read the latest values from the database so the page never shows stale data
        User fresh = userDAO.findById(user.getUserId());
        if (fresh == null) {                                      // account was removed
            request.getSession().invalidate();
            response.sendRedirect("login");
            return;
        }
        copyDetails(fresh, user);

        List<Claim> claims = claimDAO.claimsByUser(user.getUserId());
        long pending = claims.stream().filter(c -> "Pending".equals(c.getClaimStatus())).count();

        request.setAttribute("profile", fresh);
        request.setAttribute("reportCount", itemDAO.itemsByUser(user.getUserId()).size());
        request.setAttribute("claimCount", claims.size());
        request.setAttribute("pendingCount", (int) pending);
        request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = SessionUtil.currentUser(request);
        if (user == null) { response.sendRedirect("login"); return; }

        String action = request.getParameter("action");
        String result;
        if ("details".equals(action)) {
            result = updateDetails(request, user);
        } else if ("password".equals(action)) {
            result = changePassword(request, user);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        response.sendRedirect(response.encodeRedirectURL("profile?" + result));
    }

    /** Returns the query string for the redirect: msg=... on success, error=... otherwise. */
    private String updateDetails(HttpServletRequest request, User user) {
        String name = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email")).toLowerCase();
        String mobile = trim(request.getParameter("mobile"));

        // Server-side validation (same rules as validateProfile() in validate.js)
        if (name.length() < 3 || name.length() > 100 || email.length() > 100
                || !EMAIL.matcher(email).matches() || !MOBILE.matcher(mobile).matches()) {
            return "error=invalid#details";
        }

        User changed = new User();
        changed.setUserId(user.getUserId());
        changed.setFullName(name);
        changed.setEmail(email);
        changed.setMobile(mobile);
        if (!userDAO.updateProfile(changed)) return "error=exists#details";

        copyDetails(changed, user);                               // keep the session bean in sync
        return "msg=saved";
    }

    private String changePassword(HttpServletRequest request, User user) {
        String current = nullToEmpty(request.getParameter("currentPassword"));
        String next = nullToEmpty(request.getParameter("newPassword"));
        String confirm = nullToEmpty(request.getParameter("confirmPassword"));

        // Server-side validation (same rules as validatePassword() in validate.js)
        if (current.isEmpty() || next.length() < 6 || !next.equals(confirm)) return "error=pwinvalid#security";
        if (next.equals(current)) return "error=pwsame#security";
        if (!userDAO.changePassword(user.getUserId(), current, next)) return "error=pwwrong#security";
        return "msg=password";
    }

    private static void copyDetails(User from, User to) {
        to.setFullName(from.getFullName());
        to.setEmail(from.getEmail());
        to.setMobile(from.getMobile());
    }

    private static String trim(String s) { return s == null ? "" : s.trim(); }

    private static String nullToEmpty(String s) { return s == null ? "" : s; }
}
