package com.campus.lostfound.controller;

import com.campus.lostfound.bean.Item;
import com.campus.lostfound.bean.User;
import com.campus.lostfound.dao.ItemDAO;
import com.campus.lostfound.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.util.Set;

/** GET /report?type=Lost|Found shows the form, POST saves the report. */
@WebServlet("/report")
public class ReportItemServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (SessionUtil.currentUser(request) == null) { response.sendRedirect("login"); return; }
        String type = "Found".equals(request.getParameter("type")) ? "Found" : "Lost";
        request.setAttribute("type", type);
        request.getRequestDispatcher("/WEB-INF/views/reportItem.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = SessionUtil.currentUser(request);
        if (user == null) { response.sendRedirect("login"); return; }

        String type = "Found".equals(request.getParameter("reportType")) ? "Found" : "Lost";
        String name = trim(request.getParameter("itemName"));
        String category = request.getParameter("category");
        String description = trim(request.getParameter("description"));
        String location = trim(request.getParameter("location"));
        String date = request.getParameter("reportDate");

        // Server-side validation (the same rules as validate.js, in case JavaScript is off)
        if (name.length() < 2 || !CATEGORIES.contains(category) || location.isEmpty() || !validPastDate(date)) {
            response.sendRedirect("report?type=" + type + "&error=invalid");
            return;
        }

        Item it = new Item();
        it.setUserId(user.getUserId());
        it.setItemName(name);
        it.setCategory(category);
        it.setDescription(description);
        it.setReportType(type);
        it.setLocation(location);
        it.setReportDate(date);

        itemDAO.addItem(it);
        response.sendRedirect("myReports?msg=saved");
    }

    /** Categories from IM-02 (same list as the drop-down in reportItem.jsp). */
    private static final Set<String> CATEGORIES = Set.of(
            "Electronics", "Books", "Identity Cards", "Accessories", "Personal Belongings", "Others");

    private static String trim(String s) { return s == null ? "" : s.trim(); }

    /** True when the text is a yyyy-MM-dd date that is not in the future. */
    private static boolean validPastDate(String s) {
        try {
            return !LocalDate.parse(s).isAfter(LocalDate.now());
        } catch (Exception e) {
            return false;
        }
    }
}
