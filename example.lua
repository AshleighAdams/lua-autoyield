#!/usr/bin/env lua
coroutine.autoyield = require("autoyield").autoyield

local socket = require("socket")

local server = socket.bind("*", 5555)

local function send_data(threadid)
	while true do
		local cl
		while not cl do
			server:settimeout(0)
			cl = server:accept() -- TODO: make all C calls "auto yield until they returned"
		end
		
		print("got: " .. threadid)
		while true do
			if cl:receive("*l") == "" then
				break
			end
		end
	
		local data = string.format("Hello, %d\n", threadid)
		local headers = {}
		headers["Content-Type"] = "text/plain"
		headers["Content-Length"] = data:len()
		headers["Connection"] = "close"
		
		local buff = {}
		table.insert(buff, "HTTP/1.1 200 OK\r\n")
		table.insert(buff, table.concat(headers, "\r\n"))
		table.insert(buff, "\r\n")
		table.insert(buff, data)
		
		server:settimeout(-1)
		cl:send(table.concat(buff))
		cl:close()
	end
end

--send_data(1)

local threads = {}
for i = 1, 10 do
	local co = coroutine.create(send_data)
	coroutine.autoyield(co, 100)
	coroutine.resume(co, i)
	table.insert(threads, co)
end

while true do
	for k,co in pairs(threads) do
		local suc, err = coroutine.resume(co)
		if not suc then
			print(err, debug.traceback(co))
			os.exit(1)
		end
	end
end
