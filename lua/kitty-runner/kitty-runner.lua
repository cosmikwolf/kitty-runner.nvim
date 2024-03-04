--
-- KITTY RUNNER
--

local config = require("kitty-runner.config")
local fn = vim.fn
local M = {}

local whole_command
local runner_is_open = false

local function receive_command_to_send(region)
	local lines
	if region[1] == 0 then
		lines = vim.api.nvim_buf_get_lines(
			0,
			vim.api.nvim_win_get_cursor(0)[1] - 1,
			vim.api.nvim_win_get_cursor(0)[1],
			true
		)
	else
		lines = vim.api.nvim_buf_get_lines(0, region[1] - 1, region[2], true)
	end
	local command = table.concat(lines, "\r")
	return "\\e[200~" .. command .. "\\e[201~" .. "\r"
end

local function append_command_args(args, command)
	command = string.gsub(command, "\r$", "")
	for word in string.gmatch(command, "%S+") do
		table.insert(args, word)
	end
	return args
end

local function send_text()
	local args = { "kitty", "@" }
	table.insert(args, "send-text")
	table.insert(args, "--match=title:" .. config["runner_name"])
	if config["use_password"] == true then
		table.insert(args, "--password=" .. config["kitty_password"])
	end
	return args
end

local function launch_runner()
	local args = { "kitty", "@" }
	table.insert(args, "launch")
	if config["mode"] == "os-window" then
		table.insert(args, "--type=os-window")
	elseif config["mode"] == "window" then
		table.insert(args, "--type=window")
	end
	table.insert(args, "--title=" .. config["runner_name"])
	table.insert(args, "--cwd=" .. vim.fn.getcwd())
	-- table.insert(args, "--title=" .. config["runner_name"])
	table.insert(args, "--cwd=" .. vim.fn.getcwd())
	table.insert(args, "--keep-focus")

	if config["use_password"] == true then
		table.insert(args, "--password=" .. config["kitty_password"])
	end
	table.insert(args, "--hold")

	return args
end

local function focus_runner()
	local args = { "kitty", "@" }
	table.insert(args, "focus-window")
	table.insert(args, "--match=title:" .. config["runner_name"])
	return args
end

local function send_command(command)
	print("send_command", command)
	local send_text_cmd = send_text()
	local launch_runner_cmd = launch_runner()
	table.insert(send_text_cmd, command)
	table.insert(launch_runner_cmd, command)

	vim.system(send_text_cmd, function(send_text_response)
		if send_text_response.code ~= 0 then
			vim.system(launch_runner_cmd, function(launch_response)
				if launch_response.code ~= 0 then
					error("Failed to launch kitty runner", launch_response.stderr)
				end
			end)
		end
	end)
end

local function send_close_window()
	local args = { "kitty", "@", "close-window", "--match=title:" .. config["runner_name"] }
	return args
end

function M.open_runner()
	local launch_cmd = launch_runner()
	local focus_cmd = focus_runner()
	vim.system(focus_cmd, function(obj)
		if obj.code ~= 0 then
			vim.system(launch_cmd, function(focus_response)
				if obj.code ~= 0 then
					error("Failed to focus or launch kitty runner", focus_response.stderr)
				end
			end)
		end
	end)
end

function M.run_command(region)
	whole_command = receive_command_to_send(region)
	-- delete visual selection marks
	print("whole_command", whole_command)
	vim.cmd([[delm <>]])
	send_command(whole_command)
end

function M.re_run_command()
	if whole_command then
		send_command(whole_command)
	end
end

function M.prompt_run_command()
	fn.inputsave()
	local command = fn.input("Command: ")
	fn.inputrestore()
	whole_command = command .. "\r"
end

function M.kill_runner()
	if runner_is_open == true then
		send_close_window()
		runner_is_open = false
	end
end

function M.clear_runner()
	if runner_is_open == true then
		send_close_window()
	end
end

return M
