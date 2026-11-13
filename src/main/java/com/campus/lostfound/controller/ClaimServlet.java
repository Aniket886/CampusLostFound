package com.campus.lostfound.controller;

import com.campus.lostfound.bean.Claim;
import com.campus.lostfound.bean.Item;
import com.campus.lostfound.bean.User;
import com.campus.lostfound.dao.ClaimDAO;
import com.campus.lostfound.dao.ItemDAO;
import com.campus.lostfound.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/** GET /claims lists my claims, POST /claims submits a new claim. */
@WebServlet("/claims")
public class ClaimServlet extends HttpServlet {

    private final ClaimDAO claimDAO = new ClaimDAO();
    private final ItemDAO itemDAO = new ItemDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = SessionUtil.currentUser(request);
        if (user == null) { response.sendRedirect("login"); return; }
        request.setAttribute("claims", claimDAO.claimsByUser(user.getUserId()));
        request.getRequestDispatcher("/WEB-INF/views/myClaims.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = SessionUtil.currentUser(request);
        if (user == null) { response.sendRedirect("login"); return; }

        int itemId = SessionUtil.toInt(request.getParameter("itemId"));
        Item item = itemDAO.getById(itemId);
        String details = request.getParameter("ownershipDetails");
        details = (details == null) ? "" : details.trim();

        // Business rules (PRD 6.3): admins review claims instead of filing them; nobody can claim
        // their own report or a closed item; and each user can claim an item only once.
        boolean notAllowed = item == null
                || user.isAdmin()
                || item.getUserId() == user.getUserId()
                || "Closed".equals(item.getStatus())
                || claimDAO.hasClaimed(itemId, user.getUserId());
        if (notAllowed) {
            response.sendRedirect("item?id=" + itemId + "&error=notallowed");
            return;
        }

        // CM-02: server-side copy of the 15-character rule in validate.js
        if (details.length() < 15) {
            response.sendRedirect("item?id=" + itemId + "&error=short");
            return;
        }

        Claim c = new Claim();
        c.setItemId(itemId);
        c.setUserId(user.getUserId());
        c.setOwnershipDetails(details);
        claimDAO.addClaim(c);
        response.sendRedirect("claims?msg=submitted");
    }
}
