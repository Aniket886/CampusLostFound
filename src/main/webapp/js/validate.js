// Client-side validation (Assignment PDF 6A).
// Each validateX(form) function returns false to stop the form from submitting.
// Messages are shown inside the form's ".form-error" box next to the field; pages
// without that box fall back to alert(). The server repeats every check.

function fail(f, field, msg) {
    var marked = f.querySelectorAll("[aria-invalid]");
    for (var i = 0; i < marked.length; i++) marked[i].removeAttribute("aria-invalid");

    var box = f.querySelector(".form-error");
    if (box) { box.textContent = msg; box.hidden = false; } else { alert(msg); }

    if (field && f[field]) {
        f[field].setAttribute("aria-invalid", "true");
        f[field].focus();
    }
    return false;
}

function today() {
    var d = new Date();                       // local date, yyyy-MM-dd
    return d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, "0") + "-" + String(d.getDate()).padStart(2, "0");
}

function validateRegister(f) {
    if (f.fullName.value.trim().length < 3)    return fail(f, "fullName", "Enter your full name (at least 3 letters).");
    if (!/^\S+@\S+\.\S+$/.test(f.email.value.trim())) return fail(f, "email", "Enter a valid email address.");
    if (!/^[0-9]{10}$/.test(f.mobile.value))    return fail(f, "mobile",   "Mobile number must be exactly 10 digits.");
    if (f.password.value.length < 6)           return fail(f, "password", "Use a password of at least 6 characters.");
    if (f.password.value !== f.confirm.value)   return fail(f, "confirm",  "The two passwords don't match.");
    return true;
}

function validateLogin(f) {
    if (f.email.value.trim() === "") return fail(f, "email",    "Enter your email address.");
    if (f.password.value === "")     return fail(f, "password", "Enter your password.");
    return true;
}

function validateItem(f) {
    if (f.itemName.value.trim().length < 2) return fail(f, "itemName",    "Enter the item name (at least 2 letters).");
    if (f.category.value === "")            return fail(f, "category",    "Choose a category.");
    if (f.reportDate.value === "")          return fail(f, "reportDate",  "Pick the date.");
    if (f.reportDate.value > today())       return fail(f, "reportDate",  "The date can't be in the future.");
    if (f.location.value.trim() === "")     return fail(f, "location",    "Say where on campus.");
    if (f.description.value.trim() === "")  return fail(f, "description", "Add a short description.");
    return true;
}

function validateClaim(f) {
    if (f.ownershipDetails.value.trim().length < 15) {
        return fail(f, "ownershipDetails", "Add more proof (at least 15 characters): marks, contents or a serial number.");
    }
    return true;
}

function validateProfile(f) {
    if (f.fullName.value.trim().length < 3)    return fail(f, "fullName", "Enter your full name (at least 3 letters).");
    if (!/^\S+@\S+\.\S+$/.test(f.email.value.trim())) return fail(f, "email", "Enter a valid email address.");
    if (!/^[0-9]{10}$/.test(f.mobile.value.trim())) return fail(f, "mobile", "Mobile number must be exactly 10 digits.");
    return true;
}

function validatePassword(f) {
    if (f.currentPassword.value === "")         return fail(f, "currentPassword", "Enter your current password.");
    if (f.newPassword.value.length < 6)         return fail(f, "newPassword", "Use a new password of at least 6 characters.");
    if (f.newPassword.value === f.currentPassword.value)
                                                return fail(f, "newPassword", "The new password must be different from the current one.");
    if (f.newPassword.value !== f.confirmPassword.value)
                                                return fail(f, "confirmPassword", "The two new passwords don't match.");
    return true;
}

// Clear a field's red outline as soon as the user edits it
document.addEventListener("input", function (e) {
    if (e.target.hasAttribute && e.target.hasAttribute("aria-invalid")) e.target.removeAttribute("aria-invalid");
});
