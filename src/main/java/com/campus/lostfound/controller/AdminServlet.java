package com.campus.lostfound.controller;

import com.campus.lostfound.bean.User;
import com.campus.lostfound.dao.ClaimDAO;
import com.campus.lostfound.dao.ItemDAO;
import com.campus.lostfound.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Set;

/**
 * All administrator operations. Only users with role ADMIN can enter.
 *  GET  /admin                  -> dashboard summary
 *  GET  /admin?view=items       -> all reports (with search / filter)
 *  GET  /admin?view=claims      -> all ownership claims
 *  POST /admin action=status | delete | decide
 */
@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    /** Allowed values of items.status (PRD 8.5). */
    private static final Set<String> STATUSES = Set.of("Open", "Claim Pending", "Closed");

    private final ItemDAO itemDAO = new ItemDAO();
    private final ClaimDAO claimDAO = new ClaimDAO();

    private boolean isAdmin(HttpServletRequest request) {
        User u = SessionUtil.currentUser(request);
        return u != null && u.isAdmin();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Administrators only");
            return;
        }
        String view = request.getParameter("view");
        String page;
        if ("items".equals(view)) {
            String kw = request.getParameter("keyword");
            String cat = request.getParameter("category");
            String type = request.getParameter("type");
            request.setAttribute("items", (kw == null && cat == null && type == null)
                    ? itemDAO.allItems() : itemDAO.search(kw, cat, type));
            page = "items.jsp";
        } else if ("claims".equals(view)) {
            request.setAttribute("claims", claimDAO.allClaims());
            page = "claims.jsp";
        } else {
            request.setAttribute("summary", itemDAO.summary());
            request.setAttribute("recentItems", itemDAO.recentItems(5));
            page = "dashboard.jsp";
        }
        request.getRequestDispatcher("/WEB-INF/views/admin/" + page).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Administrators only");
            return;
        }
        String action = request.getParameter("action");
        if ("status".equals(action)) {
            String status = request.getParameter("status");
            if (!STATUSES.contains(status)) {                     // PRD 8.5: allowed values only
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown status");
                return;
            }
            itemDAO.updateStatus(SessionUtil.toInt(request.getParameter("itemId")), status);
            response.sendRedirect("admin?view=items&msg=updated");
        } else if ("delete".equals(action)) {
            itemDAO.deleteItem(SessionUtil.toInt(request.getParameter("itemId")));
            response.sendRedirect("admin?view=items&msg=deleted");
        } else if ("decide".equals(action)) {
            String status = "Approved".equals(request.getParameter("decision")) ? "Approved" : "Rejected";
            claimDAO.decideClaim(SessionUtil.toInt(request.getParameter("claimId")), status,
                                 request.getParameter("remarks"));
            response.sendRedirect("admin?view=claims&msg=" + status.toLowerCase());
        } else {
            response.sendRedirect("admin");
        }
    }
}
