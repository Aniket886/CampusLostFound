package com.campus.lostfound.controller;

import com.campus.lostfound.bean.User;
import com.campus.lostfound.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/** Handles the registration form (POST /register). */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User u = new User();
        u.setFullName(request.getParameter("fullName").trim());
        u.setEmail(request.getParameter("email").trim().toLowerCase());
        u.setMobile(request.getParameter("mobile").trim());
        u.setPassword(request.getParameter("password"));

        // server-side check (client-side check is in validate.js)
        if (u.getFullName().isEmpty() || u.getPassword().length() < 6) {
            response.sendRedirect("register.html?error=invalid");
        } else if (userDAO.register(u)) {
            response.sendRedirect("login?msg=registered");
        } else {
            response.sendRedirect("register.html?error=exists");
        }
    }
}
