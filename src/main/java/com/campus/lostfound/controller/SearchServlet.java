package com.campus.lostfound.controller;

import com.campus.lostfound.dao.ItemDAO;
import com.campus.lostfound.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/** Search by keyword, category and type. Uses GET so the search URL can be bookmarked. */
@WebServlet("/search")
public class SearchServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (SessionUtil.currentUser(request) == null) { response.sendRedirect("login"); return; }

        String keyword  = request.getParameter("keyword");
        String category = request.getParameter("category");
        String type     = request.getParameter("type");

        request.setAttribute("results", itemDAO.search(keyword, category, type));
        request.getRequestDispatcher("/WEB-INF/views/search.jsp").forward(request, response);
    }
}
