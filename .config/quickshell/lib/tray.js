.pragma library

// DBusMenu labels mark the keyboard mnemonic with "_" ("_Library"); "__" is a literal underscore.
function stripMnemonic(label) {
    return label.replace(/__|_/g, m => m === "__" ? "_" : "")
}
