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
	wk.add({
		{ "<leader>k", group = "Kitty Runner" },
		{ "<leader>ko", "<cmd>KittyOpenRunner<cr>", desc = "Open a Kitty runner" },
		{ "<leader>kr", "<cmd>KittyRunCommand<cr>", desc = "Prompt for command in runner" },
		{ "<leader>kl", "<cmd>KittyReRunCommand<cr>", desc = "Re-run last sent command in runner" },
		{ "<leader>kk", "<cmd>KittySendSigterm<cr>", desc = "Send SIGTERM to runner" },
		{ "<leader>kc", "<cmd>KittyCloseRunner<cr>", desc = "Close runner" },
		{ "<leader>ks", "<cmd>KittySendText<cr>", desc = "Prompt for text to send to runner" },
		{ "<leader>kr", "<cmd>KittyRunText<cr>", desc = "Prompt for text to send to runner" },
	}, { prefix = "<leader>k", name = "Kitty Runner", mode = "v" })
end

return M
