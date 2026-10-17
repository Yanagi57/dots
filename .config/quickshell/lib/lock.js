.pragma library

// PAM result name → text under the password field ("" on success).
function resultMessage(result) {
    if (result === "Success") return ""
    if (result === "Failed") return "Incorrect password"
    if (result === "MaxTries") return "Too many attempts, try again later"
    return "Authentication error"
}

// Remove the last character, keeping surrogate pairs (emoji, CJK ext.) whole.
function backspace(text) {
    if (text === "") return ""
    const last = text.charCodeAt(text.length - 1)
    const pair = last >= 0xDC00 && last <= 0xDFFF && text.length >= 2
    return text.slice(0, pair ? -2 : -1)
}
