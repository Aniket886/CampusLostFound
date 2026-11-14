// Light / dark theme switch.
// Loaded in <head> WITHOUT "defer", so the saved theme is applied before the page is painted
// (no flash of the wrong colours). The choice is kept in localStorage:
//   "light" or "dark" = the user's choice, nothing saved = follow the system setting.
(function () {
    var KEY = "clf-theme";
    var root = document.documentElement;
    var media = window.matchMedia ? window.matchMedia("(prefers-color-scheme: dark)") : null;

    function saved() {
        try { var v = localStorage.getItem(KEY); return v === "light" || v === "dark" ? v : "system"; }
        catch (e) { return "system"; }
    }

    function resolved(pref) {
        if (pref === "light" || pref === "dark") return pref;
        return media && media.matches ? "dark" : "light";
    }

    // Update every toggle button and the radio buttons on the profile page
    function sync() {
        var pref = saved(), theme = resolved(pref);
        var next = theme === "dark" ? "light" : "dark";
        var buttons = document.querySelectorAll("[data-theme-toggle]");
        for (var i = 0; i < buttons.length; i++) {
            buttons[i].setAttribute("aria-label", "Switch to " + next + " theme");
            buttons[i].setAttribute("title", "Switch to " + next + " theme");
        }
        var radios = document.querySelectorAll("input[name='themePref']");
        for (var j = 0; j < radios.length; j++) radios[j].checked = radios[j].value === pref;
    }

    function apply() {
        root.setAttribute("data-theme", resolved(saved()));
        sync();
    }

    // pref: "light", "dark" or "system"
    window.setTheme = function (pref) {
        try {
            if (pref === "light" || pref === "dark") localStorage.setItem(KEY, pref);
            else localStorage.removeItem(KEY);
        } catch (e) { /* storage blocked: the choice lasts for this page only */ }
        root.setAttribute("data-theme", resolved(pref));
        sync();
    };

    document.addEventListener("click", function (e) {
        var btn = e.target.closest && e.target.closest("[data-theme-toggle]");
        if (btn) window.setTheme(root.getAttribute("data-theme") === "dark" ? "light" : "dark");
    });
    document.addEventListener("change", function (e) {
        if (e.target.name === "themePref") window.setTheme(e.target.value);
    });

    // When following the system, react to the OS switching between light and dark
    if (media) {
        var onSystemChange = function () { if (saved() === "system") apply(); };
        if (media.addEventListener) media.addEventListener("change", onSystemChange);
        else if (media.addListener) media.addListener(onSystemChange);
    }

    // Another tab changed the theme
    window.addEventListener("storage", function (e) { if (e.key === KEY) apply(); });

    apply();                                                    // before first paint
    document.addEventListener("DOMContentLoaded", sync);        // buttons exist now
})();
