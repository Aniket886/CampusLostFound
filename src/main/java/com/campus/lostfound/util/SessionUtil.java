package com.campus.lostfound.util;

import com.campus.lostfound.bean.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

/** Small helper to read the logged-in user from HttpSession. */
public class SessionUtil {

    /** Returns the logged-in user, or null if there is no valid session. */
    public static User currentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);   // do not create a new session
        return (session == null) ? null : (User) session.getAttribute("user");
    }

    /** Converts a request parameter to int, returns 0 when missing or invalid. */
    public static int toInt(String value) {
        try { return Integer.parseInt(value); } catch (Exception e) { return 0; }
    }
}
