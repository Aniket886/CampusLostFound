package com.campus.lostfound.util;

/** Escapes user text before printing it in a JSP (stops HTML/script injection). */
public class HtmlUtil {

    public static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
}
