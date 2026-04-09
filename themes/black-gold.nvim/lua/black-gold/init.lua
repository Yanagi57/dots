local M = {}

local p = {
	base      = "#222222",
	surface   = "#2A2A2A",
	elevated  = "#333333",
	border    = "#3D3D3D",
	gold      = "#FFD700",
	gold_dim  = "#C9A800",
	teal      = "#4DD9C0",
	teal_dim  = "#2AA38E",
	primary   = "#F5F5F5",
	secondary = "#BBBBBB",
	tertiary  = "#777777",
	error     = "#FF5555",
	warning   = "#FFB86C",
}

local function hi(name, opts)
	vim.api.nvim_set_hl(0, name, opts)
end

function M.setup()
	-- Core UI
	hi("Normal",          { fg = p.primary,   bg = p.base })
	hi("NormalFloat",     { fg = p.primary,   bg = p.surface })
	hi("NormalNC",        { fg = p.secondary, bg = p.base })
	hi("ColorColumn",     { bg = p.surface })
	hi("CursorLine",      { bg = p.surface })
	hi("CursorColumn",    { bg = p.surface })
	hi("CursorLineNr",    { fg = p.gold,      bold = true })
	hi("LineNr",          { fg = p.tertiary })
	hi("SignColumn",      { fg = p.tertiary,  bg = p.base })
	hi("FoldColumn",      { fg = p.tertiary,  bg = p.base })
	hi("Folded",          { fg = p.secondary, bg = p.surface })
	hi("VertSplit",       { fg = p.border,    bg = p.base })
	hi("WinSeparator",    { fg = p.border,    bg = p.base })
	hi("EndOfBuffer",     { fg = p.border })
	hi("NonText",         { fg = p.border })
	hi("SpecialKey",      { fg = p.border })
	hi("Conceal",         { fg = p.tertiary })
	hi("Whitespace",      { fg = p.border })

	-- Selection & search
	hi("Visual",          { bg = p.elevated })
	hi("VisualNOS",       { bg = p.elevated })
	hi("Search",          { fg = p.base,      bg = p.gold })
	hi("IncSearch",       { fg = p.base,      bg = p.gold_dim })
	hi("CurSearch",       { fg = p.base,      bg = p.gold })
	hi("MatchParen",      { fg = p.gold,      bold = true, underline = true })
	hi("Substitute",      { fg = p.base,      bg = p.gold })

	-- Menus & popups
	hi("Pmenu",           { fg = p.primary,   bg = p.surface })
	hi("PmenuSel",        { fg = p.base,      bg = p.gold,   bold = true })
	hi("PmenuSbar",       { bg = p.elevated })
	hi("PmenuThumb",      { bg = p.secondary })
	hi("PmenuExtra",      { fg = p.secondary, bg = p.surface })
	hi("PmenuExtraSel",   { fg = p.base,      bg = p.gold })
	hi("WildMenu",        { fg = p.base,      bg = p.gold })

	-- Status & tab line
	hi("StatusLine",      { fg = p.primary,   bg = p.surface })
	hi("StatusLineNC",    { fg = p.tertiary,  bg = p.surface })
	hi("TabLine",         { fg = p.secondary, bg = p.surface })
	hi("TabLineSel",      { fg = p.gold,      bg = p.elevated, bold = true })
	hi("TabLineFill",     { bg = p.base })

	-- Messages
	hi("ModeMsg",         { fg = p.gold,      bold = true })
	hi("MoreMsg",         { fg = p.teal })
	hi("ErrorMsg",        { fg = p.error })
	hi("WarningMsg",      { fg = p.warning })
	hi("Question",        { fg = p.teal })

	-- Diff
	hi("DiffAdd",         { fg = p.teal,      bg = p.surface })
	hi("DiffChange",      { fg = p.gold,      bg = p.surface })
	hi("DiffDelete",      { fg = p.error,     bg = p.surface })
	hi("DiffText",        { fg = p.gold,      bg = p.elevated, bold = true })
	hi("Added",           { fg = p.teal })
	hi("Changed",         { fg = p.gold })
	hi("Removed",         { fg = p.error })

	-- Spell
	hi("SpellBad",        { sp = p.error,     undercurl = true })
	hi("SpellCap",        { sp = p.warning,   undercurl = true })
	hi("SpellRare",       { sp = p.teal,      undercurl = true })
	hi("SpellLocal",      { sp = p.gold_dim,  undercurl = true })

	-- Quickfix
	hi("QuickFixLine",    { bg = p.surface })
	hi("Directory",       { fg = p.gold })
	hi("Title",           { fg = p.gold,      bold = true })

	-- Floats / borders
	hi("FloatBorder",     { fg = p.border,    bg = p.surface })
	hi("FloatTitle",      { fg = p.gold,      bg = p.surface, bold = true })
	hi("FloatFooter",     { fg = p.tertiary,  bg = p.surface })

	-- Syntax: base groups
	hi("Comment",         { fg = p.tertiary,  italic = true })
	hi("Constant",        { fg = p.teal_dim })
	hi("String",          { fg = p.teal })
	hi("Character",       { fg = p.teal })
	hi("Number",          { fg = p.teal_dim })
	hi("Boolean",         { fg = p.teal_dim })
	hi("Float",           { fg = p.teal_dim })
	hi("Identifier",      { fg = p.primary })
	hi("Function",        { fg = p.gold })
	hi("Statement",       { fg = p.gold })
	hi("Conditional",     { fg = p.gold })
	hi("Repeat",          { fg = p.gold })
	hi("Label",           { fg = p.gold })
	hi("Operator",        { fg = p.secondary })
	hi("Keyword",         { fg = p.gold })
	hi("Exception",       { fg = p.gold })
	hi("PreProc",         { fg = p.gold })
	hi("Include",         { fg = p.gold })
	hi("Define",          { fg = p.gold })
	hi("Macro",           { fg = p.gold })
	hi("PreCondit",       { fg = p.gold })
	hi("Type",            { fg = p.primary })
	hi("StorageClass",    { fg = p.gold })
	hi("Structure",       { fg = p.primary })
	hi("Typedef",         { fg = p.primary })
	hi("Special",         { fg = p.secondary })
	hi("SpecialChar",     { fg = p.teal })
	hi("Tag",             { fg = p.gold })
	hi("Delimiter",       { fg = p.secondary })
	hi("SpecialComment",  { fg = p.tertiary,  italic = true })
	hi("Debug",           { fg = p.error })
	hi("Underlined",      { underline = true })
	hi("Ignore",          { fg = p.tertiary })
	hi("Error",           { fg = p.error })
	hi("Todo",            { fg = p.base,      bg = p.gold,   bold = true })

	-- Diagnostics
	hi("DiagnosticError",              { fg = p.error })
	hi("DiagnosticWarn",               { fg = p.warning })
	hi("DiagnosticInfo",               { fg = p.teal })
	hi("DiagnosticHint",               { fg = p.secondary })
	hi("DiagnosticOk",                 { fg = p.teal })
	hi("DiagnosticVirtualTextError",   { fg = p.error,     bg = p.surface, italic = true })
	hi("DiagnosticVirtualTextWarn",    { fg = p.warning,   bg = p.surface, italic = true })
	hi("DiagnosticVirtualTextInfo",    { fg = p.teal,      bg = p.surface, italic = true })
	hi("DiagnosticVirtualTextHint",    { fg = p.secondary, bg = p.surface, italic = true })
	hi("DiagnosticUnderlineError",     { sp = p.error,     undercurl = true })
	hi("DiagnosticUnderlineWarn",      { sp = p.warning,   undercurl = true })
	hi("DiagnosticUnderlineInfo",      { sp = p.teal,      undercurl = true })
	hi("DiagnosticUnderlineHint",      { sp = p.secondary, undercurl = true })
	hi("DiagnosticFloatingError",      { fg = p.error })
	hi("DiagnosticFloatingWarn",       { fg = p.warning })
	hi("DiagnosticFloatingInfo",       { fg = p.teal })
	hi("DiagnosticFloatingHint",       { fg = p.secondary })
	hi("DiagnosticSignError",          { fg = p.error })
	hi("DiagnosticSignWarn",           { fg = p.warning })
	hi("DiagnosticSignInfo",           { fg = p.teal })
	hi("DiagnosticSignHint",           { fg = p.secondary })

	-- Treesitter
	hi("@comment",                     { link = "Comment" })
	hi("@comment.documentation",       { fg = p.tertiary, italic = true })
	hi("@keyword",                     { fg = p.gold })
	hi("@keyword.function",            { fg = p.gold })
	hi("@keyword.operator",            { fg = p.secondary })
	hi("@keyword.return",              { fg = p.gold })
	hi("@keyword.import",              { fg = p.gold })
	hi("@keyword.modifier",            { fg = p.gold })
	hi("@keyword.repeat",              { fg = p.gold })
	hi("@keyword.conditional",         { fg = p.gold })
	hi("@keyword.exception",           { fg = p.gold })
	hi("@keyword.directive",           { fg = p.gold })
	hi("@function",                    { fg = p.gold })
	hi("@function.call",               { fg = p.gold })
	hi("@function.builtin",            { fg = p.gold })
	hi("@function.method",             { fg = p.gold })
	hi("@function.method.call",        { fg = p.gold })
	hi("@function.macro",              { fg = p.gold })
	hi("@constructor",                 { fg = p.primary })
	hi("@variable",                    { fg = p.primary })
	hi("@variable.builtin",            { fg = p.gold_dim })
	hi("@variable.parameter",         { fg = p.secondary })
	hi("@variable.member",             { fg = p.primary })
	hi("@parameter",                   { fg = p.secondary })
	hi("@property",                    { fg = p.primary })
	hi("@field",                       { fg = p.primary })
	hi("@string",                      { fg = p.teal })
	hi("@string.escape",               { fg = p.teal_dim })
	hi("@string.special",              { fg = p.teal_dim })
	hi("@string.regex",                { fg = p.teal_dim })
	hi("@string.documentation",        { fg = p.teal })
	hi("@number",                      { fg = p.teal_dim })
	hi("@number.float",                { fg = p.teal_dim })
	hi("@float",                       { fg = p.teal_dim })
	hi("@boolean",                     { fg = p.teal_dim })
	hi("@constant",                    { fg = p.teal_dim })
	hi("@constant.builtin",            { fg = p.teal_dim })
	hi("@constant.macro",              { fg = p.teal_dim })
	hi("@type",                        { fg = p.primary })
	hi("@type.builtin",                { fg = p.primary })
	hi("@type.definition",             { fg = p.primary })
	hi("@type.qualifier",              { fg = p.gold })
	hi("@operator",                    { fg = p.secondary })
	hi("@punctuation.delimiter",       { fg = p.secondary })
	hi("@punctuation.bracket",         { fg = p.secondary })
	hi("@punctuation.special",         { fg = p.secondary })
	hi("@label",                       { fg = p.gold })
	hi("@namespace",                   { fg = p.primary })
	hi("@module",                      { fg = p.primary })
	hi("@module.builtin",              { fg = p.gold_dim })
	hi("@attribute",                   { fg = p.teal_dim })
	hi("@tag",                         { fg = p.gold })
	hi("@tag.attribute",               { fg = p.teal })
	hi("@tag.delimiter",               { fg = p.secondary })
	hi("@markup.heading",              { fg = p.gold,     bold = true })
	hi("@markup.raw",                  { fg = p.teal })
	hi("@markup.link",                 { fg = p.teal,     underline = true })
	hi("@markup.link.label",           { fg = p.gold })
	hi("@markup.link.url",             { fg = p.teal,     underline = true })
	hi("@markup.list",                 { fg = p.gold_dim })
	hi("@markup.strong",               { bold = true })
	hi("@markup.italic",               { italic = true })
	hi("@markup.strikethrough",        { strikethrough = true })
	hi("@markup.quote",                { fg = p.tertiary, italic = true })
	hi("@diff.plus",                   { fg = p.teal })
	hi("@diff.minus",                  { fg = p.error })
	hi("@diff.delta",                  { fg = p.gold })

	-- LSP semantic tokens
	hi("@lsp.type.function",           { link = "@function" })
	hi("@lsp.type.method",             { link = "@function.method" })
	hi("@lsp.type.parameter",          { link = "@variable.parameter" })
	hi("@lsp.type.variable",           { link = "@variable" })
	hi("@lsp.type.property",           { link = "@property" })
	hi("@lsp.type.type",               { link = "@type" })
	hi("@lsp.type.class",              { link = "@type" })
	hi("@lsp.type.interface",          { link = "@type" })
	hi("@lsp.type.struct",             { link = "@type" })
	hi("@lsp.type.enum",               { link = "@type" })
	hi("@lsp.type.enumMember",         { link = "@constant" })
	hi("@lsp.type.keyword",            { link = "@keyword" })
	hi("@lsp.type.modifier",           { link = "@keyword.modifier" })
	hi("@lsp.type.namespace",          { link = "@namespace" })
	hi("@lsp.type.macro",              { link = "@function.macro" })
	hi("@lsp.type.comment",            { link = "@comment" })
	hi("@lsp.type.string",             { link = "@string" })
	hi("@lsp.type.number",             { link = "@number" })
	hi("@lsp.type.operator",           { link = "@operator" })
	hi("@lsp.type.decorator",          { link = "@attribute" })
	hi("@lsp.mod.readonly",            { fg = p.teal_dim })
	hi("@lsp.mod.static",              { fg = p.gold_dim })
	hi("@lsp.mod.deprecated",          { strikethrough = true })

	-- Gitsigns
	hi("GitSignsAdd",                  { fg = p.teal })
	hi("GitSignsChange",               { fg = p.gold })
	hi("GitSignsDelete",               { fg = p.error })
	hi("GitSignsAddNr",                { fg = p.teal })
	hi("GitSignsChangeNr",             { fg = p.gold })
	hi("GitSignsDeleteNr",             { fg = p.error })
	hi("GitSignsAddLn",                { bg = p.surface })
	hi("GitSignsChangeLn",             { bg = p.surface })

	-- Indent blankline
	hi("IblIndent",                    { fg = p.border })
	hi("IblScope",                     { fg = p.tertiary })

	-- Which-key
	hi("WhichKey",                     { fg = p.gold })
	hi("WhichKeyGroup",                { fg = p.teal })
	hi("WhichKeyDesc",                 { fg = p.primary })
	hi("WhichKeySeparator",            { fg = p.tertiary })
	hi("WhichKeyFloat",                { bg = p.surface })
	hi("WhichKeyBorder",               { fg = p.border, bg = p.surface })

	-- fzf-lua
	hi("FzfLuaNormal",                 { fg = p.primary,   bg = p.surface })
	hi("FzfLuaBorder",                 { fg = p.border,    bg = p.surface })
	hi("FzfLuaTitle",                  { fg = p.gold,      bg = p.surface, bold = true })
	hi("FzfLuaCursorLine",             { bg = p.elevated })
	hi("FzfLuaMatch",                  { fg = p.gold,      bold = true })

	-- Blink.cmp
	hi("BlinkCmpMenu",                 { fg = p.primary,   bg = p.surface })
	hi("BlinkCmpMenuBorder",           { fg = p.border,    bg = p.surface })
	hi("BlinkCmpMenuSelection",        { fg = p.base,      bg = p.gold })
	hi("BlinkCmpLabel",                { fg = p.primary })
	hi("BlinkCmpLabelMatch",           { fg = p.gold,      bold = true })
	hi("BlinkCmpKind",                 { fg = p.teal })
	hi("BlinkCmpDoc",                  { fg = p.primary,   bg = p.surface })
	hi("BlinkCmpDocBorder",            { fg = p.border,    bg = p.surface })

	-- Fidget
	hi("FidgetTitle",                  { fg = p.gold })
	hi("FidgetTask",                   { fg = p.tertiary })

	-- Terminal colors
	vim.g.terminal_color_0  = p.base
	vim.g.terminal_color_1  = p.error
	vim.g.terminal_color_2  = p.teal
	vim.g.terminal_color_3  = p.gold
	vim.g.terminal_color_4  = p.gold_dim
	vim.g.terminal_color_5  = p.gold
	vim.g.terminal_color_6  = p.teal
	vim.g.terminal_color_7  = p.primary
	vim.g.terminal_color_8  = p.tertiary
	vim.g.terminal_color_9  = p.error
	vim.g.terminal_color_10 = p.teal
	vim.g.terminal_color_11 = p.gold
	vim.g.terminal_color_12 = p.gold_dim
	vim.g.terminal_color_13 = p.gold
	vim.g.terminal_color_14 = p.teal_dim
	vim.g.terminal_color_15 = p.secondary
end

return M
