--
-- KITTY RUNNER | CONFIG
--
local M = {}

-- default configulation values
-- config.mode controls the behavior of kitty when a new runner is created
-- -- the value is passed through to the @ launch command.
-- -- see kitty documentation for details:
-- -- https://sw.kovidgoyal.net/kitty/remote-control/#cmdoption-kitten-launch-type
-- Default: window Choices: background, clipboard, os-window, overlay, overlay-main, primary, tab, window

local default_config = {
	runner_name = "Kittenvim",
	persist_across_vim_relaunch = true,
	focus_on_send = true,
	use_keymaps = true,
	use_password = false,
	kitty_password = "",
	mode = "window",
}

-- M = vim.deepcopy(default_config)
-- M.default_config = default_config

-- configuration update function
M.update = function(opts)
	vim.g.kitty_runner = vim.tbl_deep_extend("force", default_config, opts or {})
end

M.define_keymaps = function()
	local wk = require("which-key")
	wk.register({
		o = {
			"<cmd>KittyOpenRunner<cr>",
			"Open a Kitty runner",
		},
		r = {
			"<cmd>KittyRunCommand<cr>",
			"Prompt for command in runner",
		},
		l = {
			"<cmd>KittyReRunCommand<cr>",
			"Re-run last sent command in runner",
		},
		k = {
			"<cmd>KittyCloseRunner<cr>",
			"Close runner",
		},
	}, { prefix = "<leader>k", name = "Kitty Runner" })
	wk.register({
		s = {
			"<cmd>KittySendText<cr>",
			"Prompt for text to send to runner",
		},
		r = {
			"<cmd>KittyRunText<cr>",
			"Prompt for text to send to runner",
		},
	}, { prefix = "<leader>k", name = "Kitty Runner", mode = "v" })
end

return M
