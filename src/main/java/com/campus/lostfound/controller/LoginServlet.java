package com.campus.lostfound.controller;

import com.campus.lostfound.bean.User;
import com.campus.lostfound.dao.UserDAO;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * Login controller. Mapped in web.xml (not by annotation) so that it can
 * demonstrate the Servlet lifecycle and ServletConfig init parameters.
 */
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO;
    private int sessionTimeout;

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);                                         // lifecycle step 1
        userDAO = new UserDAO();
        sessionTimeout = Integer.parseInt(config.getInitParameter("sessionTimeoutMinutes"));
        System.out.println("[LoginServlet] init() called - servlet loaded");
    }

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        System.out.println("[LoginServlet] service() -> " + req.getMethod());   // lifecycle step 2
        super.service(req, res);                                     // calls doGet / doPost
    }

    /** GET: show the login page. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    /** POST: check email and password. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email").trim().toLowerCase();
        String password = request.getParameter("password");

        User user = userDAO.login(email, password);
        if (user == null) {
            request.setAttribute("error", "Invalid email or password");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        HttpSession old = request.getSession(false);
        if (old != null) old.invalidate();                          // new session after login

        HttpSession session = request.getSession(true);
        session.setAttribute("user", user);
        session.setMaxInactiveInterval(sessionTimeout * 60);

        Cookie cookie = new Cookie("lastEmail", email);            // remember email for 7 days
        cookie.setMaxAge(7 * 24 * 60 * 60);
        cookie.setHttpOnly(true);
        response.addCookie(cookie);

        response.sendRedirect(response.encodeRedirectURL(user.isAdmin() ? "admin" : "home"));
    }

    @Override
    public void destroy() {
        System.out.println("[LoginServlet] destroy() called - servlet unloaded");  // lifecycle step 3
    }
}
