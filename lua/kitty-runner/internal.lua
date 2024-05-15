--
-- KITTY RUNNER
--

local M = {}
require("kitty-runner.config").update()
vim.g.kitty_runner = vim.g.kitty_runner
-- but will also allow a user to relaunch vim and reconnect to the same runner
local kitty_runner_persistance_env
if vim.g.kitty_runner["persist_across_vim_relaunch"] == true then
	kitty_runner_persistance_env = "KITTY_RUNNER=" .. vim.fn.getcwd()
else
	-- get uuid
	local function get_uuid()
		local uuid_handle = io.popen([[uuidgen]])
		if not uuid_handle then
			vim.notify("could not launch uuidgen", vim.log.levels.ERROR)
			return vim.fn.getcwd()
		else
			local uuid = uuid_handle:read("*l")
			uuid_handle:close()
			return uuid
		end
	end

	kitty_runner_persistance_env = "KITTY_RUNNER=" .. vim.fn.getcwd() .. "-" .. get_uuid()
end

function M.retrieve_command_from_buf_text(region)
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

function M.signal_child_cmd(signal)
	local args = { "kitty", "@" }
	table.insert(args, "signal-child")
	table.insert(args, "--match")
	table.insert(args, "env:" .. kitty_runner_persistance_env)
	if vim.g.kitty_runner["use_password"] == true then
		table.insert(args, "--password=" .. vim.g.kitty_runner["kitty_password"])
	end

	table.insert(args, signal)
	return args
end

function M.send_text_cmd(text, execute_on_send)
	local args = { "kitty", "@" }
	table.insert(args, "send-text")
	table.insert(args, "--match")
	table.insert(args, "env:" .. kitty_runner_persistance_env)
	if vim.g.kitty_runner["use_password"] == true then
		table.insert(args, "--password=" .. vim.g.kitty_runner["kitty_password"])
	end
	-- strip the trailing \r from text
	table.insert(args, text)
	if execute_on_send then
		table.insert(args, "\r")
	end
	return args
end

function M.set_user_var_cmd(var, value)
	local args = { "kitty", "@", "set_user_vars" }
	table.insert(args, var .. "=" .. value)
end

function M.launch_runner_cmd()
	vim.notify("config: " .. vim.inspect(vim.g.kitty_runner))
	local args = { "kitty", "@" }
	table.insert(args, "launch")
	table.insert(args, "--type=" .. vim.g.kitty_runner["mode"])
	table.insert(args, "--title=" .. vim.g.kitty_runner["runner_name"])
	table.insert(args, "--cwd=" .. vim.fn.getcwd())
	table.insert(args, "--keep-focus")
	table.insert(args, "--env=" .. kitty_runner_persistance_env)

	if vim.g.kitty_runner["use_password"] == true then
		table.insert(args, "--password=" .. vim.g.kitty_runner["kitty_password"])
	end
	table.insert(args, "--hold")

	return args
end

function M.check_if_runner_is_active()
	local args = { "kitten", "@", "ls", "--match", "env:" .. kitty_runner_persistance_env }
	local response = vim.system(args, { text = true }):wait()
	if response.code == 0 then
		return true
	else
		return false
	end
end

function M.get_runner_pid()
	local args = { "kitten", "@", "ls", "--match", "env:" .. kitty_runner_persistance_env }
	local response = vim.system(args, { text = true }):wait()
	if response.code == 0 then
		local ls = vim.json.decode(response.stdout)
		local pid = ls[1].tabs[1].windows[1].foreground_processes[1].pid
		if pid == nil then
			vim.notify("could not obtain pid from runner\n" .. response.stdout, vim.log.levels.ERROR)
			return false
		else
			return pid
		end
	else
		return false
	end
end

function M.focus_runner_cmd()
	local args = { "kitty", "@" }
	table.insert(args, "focus-window")
	table.insert(args, "--match=title:" .. vim.g.kitty_runner["runner_name"])
	return args
end

function M.open_runner_and_or_send_command(command, execute_cmd)
	if M.check_if_runner_is_active() == true then
		vim.system(M.send_text_cmd(command, execute_cmd), nil, function(send_text_response)
			if send_text_response.code ~= 0 then
				vim.notify(send_text_response.stderr, vim.log.levels.ERROR)
			end
		end)
	else
		-- don't send the command with the runner, so it gets printed out nicely after the command prompt is printed
		vim.system(M.launch_runner_cmd(), nil, function(launch_response)
			if launch_response.code == 0 then
				vim.system(M.send_text_cmd(command, execute_cmd), nil, function(send_text_response)
					if send_text_response.code ~= 0 then
					else
						vim.notify(send_text_response.stderr, vim.log.levels.ERROR)
					end
				end)
				vim.notify(launch_response.stderr, vim.log.levels.ERROR)
			end
		end)
	end
end

function M.open_and_or_send_command_return_pid(command)
	local command_text
	if M.check_if_runner_is_active() == true then
		command_text = M.send_text_cmd(command)
	else
		command_text = M.launch_runner_cmd()
		table.insert(command_text, command)
	end

	local response = vim.system(command_text):wait()
	if response.code ~= 0 then
		vim.notify(response.stderr, vim.log.levels.ERROR)
	else
		return M.get_runner_pid()
	end
end

function M.send_close_window()
	local close_window = { "kitty", "@", "close-window", "--match", "env:" .. kitty_runner_persistance_env }
	vim.system(close_window, nil, function(response)
		if response.code ~= 0 then
			vim.notify(response.stderr, vim.log.levels.WARN)
		end
	end)
end

return M
