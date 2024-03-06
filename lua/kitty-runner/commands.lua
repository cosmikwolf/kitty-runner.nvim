local Kv = require("kitty-runner.internal") -- local kitty_runner = require("kitty-runner")

local M = {}
local last_command
-- -- get all functions that we need to run the various commands
-- for name, command in pairs(kitty_runner) do
-- 	M[name] = command
-- end
function M.open_runner()
	local launch_cmd = Kv.launch_runner()
	local focus_cmd = Kv.focus_runner()
	vim.system(focus_cmd, function(focus_response)
		if focus_response.code ~= 0 then
			vim.system(launch_cmd, function(launch_response)
				if launch_response.code ~= 0 then
					vim.notify(launch_response.stderr, "error")
				end
			end)
		end
	end)
end

function M.run_command_get_pid(command)
	command = command .. "\r"
	local pid = Kv.open_and_or_send_command_return_pid(command)
	return pid
end

function M.send_text_to_runner(command)
	command = command .. "\r"
	Kv.open_runner_and_or_send_command(command, false)
end

function M.run_command(command)
	command = command .. "\r"
	Kv.open_runner_and_or_send_command(command, true)
end

function M.run_command_from_buftext(region)
	Kv.last_command = Kv.retrieve_command_from_buf_text(region)
	vim.cmd([[delm <>]])
	Kv.open_runner_and_or_send_command(last_command, true)
end

function M.re_run_command()
	if last_command then
		Kv.open_runner_and_or_send_command(last_command, true)
	end
end

function M.send_text_from_region(region, execute_on_send)
	local command = Kv.retrieve_command_from_buf_text(region)
	Kv.open_runner_and_or_send_command(command, execute_on_send)
end

function M.prompt_send_text()
	vim.fn.inputsave()
	last_command = vim.fn.input("Command: ")
	vim.fn.inputrestore()
	Kv.open_runner_and_or_send_command(last_command, false)
end

function M.prompt_run_command()
	vim.fn.inputsave()
	last_command = vim.fn.input("Command: ")
	vim.fn.inputrestore()
	Kv.open_runner_and_or_send_command(last_command, true)
end

function M.close_runner()
	Kv.send_close_window()
end

function M.clear_runner()
	vim.system(Kv.send_text_cmd("clear", true), function(send_text_response)
		if send_text_response.code ~= 0 then
			vim.notify(send_text_response.stderr, "error")
		end
	end)
end

return M
