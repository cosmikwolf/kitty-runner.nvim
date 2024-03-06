--
-- KITTY RUNNER | INIT
--
local M = {}

local Config = require("kitty-runner.config")
local commands = require("kitty-runner.commands")

vim.g.kitty_runner = vim.g.kitty_runner

local function initialize_commands()
	vim.api.nvim_create_user_command(
		"KittyReRunCommand",
		"lua require('kitty-runner.commands').re_run_command()",
		{ bang = true }
	)
	vim.api.nvim_create_user_command(
		"KittySendText",
		'lua require("kitty-runner.commands").send_text_from_region(vim.region(0, vim.fn.getpos("\'<"), vim.fn.getpos("\'>"), "l", false)[0], false)',
		{ bang = true, range = 1 }
	)
	vim.api.nvim_create_user_command(
		"KittyRunText",
		'lua require("kitty-runner.commands").send_text_from_region(vim.region(0, vim.fn.getpos("\'<"), vim.fn.getpos("\'>"), "l", false)[0], true)',
		{ bang = true, range = 1 }
	)
	vim.api.nvim_create_user_command(
		"KittyRunCommand",
		"lua require('kitty-runner.commands').prompt_run_command()",
		{ bang = true }
	)

	vim.api.nvim_create_user_command(
		"KittyClearRunner",
		"lua require('kitty-runner.commands').clear_runner()",
		{ bang = true }
	)
	vim.api.nvim_create_user_command(
		"KittyOpenRunner",
		"lua require('kitty-runner.commands').open_runner()",
		{ bang = true }
	)
	vim.api.nvim_create_user_command(
		"KittyCloseRunner",
		"lua require('kitty-runner.commands').close_runner()",
		{ bang = true }
	)
	vim.api.nvim_create_user_command(
		"KittySendTextPrompt",
		"lua require('kitty-runner.commands').prompt_send_text()",
		{ bang = true }
	)
end

local function initialize(opts)
	-- update config
	Config.update(opts)

	-- setting up keymaps
	if vim.g.kitty_runner["use_keymaps"] == true then
		Config.define_keymaps()
	end
	-- vim.notify(vim.inspect(vim.g.kitty_runner))
	-- setting up commands
	initialize_commands()
end

initialize(vim.g.kitty_runner)
return M
