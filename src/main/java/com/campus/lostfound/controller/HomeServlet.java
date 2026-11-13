package com.campus.lostfound.controller;

import com.campus.lostfound.dao.ItemDAO;
import com.campus.lostfound.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/** Home page: shows recently reported items (GET /home). */
@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (SessionUtil.currentUser(request) == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        request.setAttribute("recentItems", itemDAO.recentItems(8));
        request.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(request, response);
    }
}
