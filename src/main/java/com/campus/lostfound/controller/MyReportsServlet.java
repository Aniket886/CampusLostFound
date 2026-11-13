package com.campus.lostfound.controller;

import com.campus.lostfound.bean.User;
import com.campus.lostfound.dao.ItemDAO;
import com.campus.lostfound.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/** Lists the lost and found reports of the logged-in user (GET /myReports). */
@WebServlet("/myReports")
public class MyReportsServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = SessionUtil.currentUser(request);
        if (user == null) { response.sendRedirect("login"); return; }
        request.setAttribute("items", itemDAO.itemsByUser(user.getUserId()));
        request.getRequestDispatcher("/WEB-INF/views/myReports.jsp").forward(request, response);
    }
}
