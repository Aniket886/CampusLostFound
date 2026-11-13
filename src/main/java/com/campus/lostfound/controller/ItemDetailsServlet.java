package com.campus.lostfound.controller;

import com.campus.lostfound.bean.Item;
import com.campus.lostfound.dao.ClaimDAO;
import com.campus.lostfound.dao.ItemDAO;
import com.campus.lostfound.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/** Shows one item with its claim form (GET /item?id=5). */
@WebServlet("/item")
public class ItemDetailsServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();
    private final ClaimDAO claimDAO = new ClaimDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (SessionUtil.currentUser(request) == null) { response.sendRedirect("login"); return; }

        Item item = itemDAO.getById(SessionUtil.toInt(request.getParameter("id")));
        if (item == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Item not found");
            return;
        }
        request.setAttribute("item", item);
        request.setAttribute("claims", claimDAO.claimsByItem(item.getItemId()));
        request.getRequestDispatcher("/WEB-INF/views/itemDetails.jsp").forward(request, response);
    }
}
