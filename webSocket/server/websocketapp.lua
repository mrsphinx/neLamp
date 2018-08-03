local module = {}

local function decode(chunk)
  if #chunk < 2 then
    return
  end
  local second = string.byte(chunk, 2)
  local len = bit.band(second, 0x7f)
  local offset
  if len == 126 then
    if #chunk < 4 then
      return
    end
    len = bit.bor(bit.lshift(string.byte(chunk, 3), 8), string.byte(chunk, 4))
    offset = 4
  elseif len == 127 then
    if #chunk < 10 then
      return
    end
    len =
      bit.bor(
      -- Ignore lengths longer than 32bit
      bit.lshift(string.byte(chunk, 7), 24),
      bit.lshift(string.byte(chunk, 8), 16),
      bit.lshift(string.byte(chunk, 9), 8),
      string.byte(chunk, 10)
    )
    offset = 10
  else
    offset = 2
  end
  local mask = bit.band(second, 0x80) > 0
  if mask then
    offset = offset + 4
  end
  if #chunk < offset + len then
    return
  end

  local first = string.byte(chunk, 1)
  local payload = string.sub(chunk, offset + 1, offset + len)
  assert(#payload == len, "Length mismatch")
  if mask then
    payload = crypto.mask(payload, string.sub(chunk, offset - 3, offset))
  end
  local extra = string.sub(chunk, offset + len + 1)
  local opcode = bit.band(first, 0xf)
  return extra, payload, opcode
end

local function encode(payload, opcode)
  opcode = opcode or 2
  assert(type(opcode) == "number", "opcode must be number")

  assert(type(payload) == "string", "payload must be string")
  local len = #payload
  local head = string.char(bit.bor(0x80, opcode), len < 126 and len or (len < 0x10000) and 126 or 127)
  if len >= 0x10000 then
    head =
      head ..
      string.char(
        0,
        0,
        0,
        0, -- 32 bit length is plenty, assume zero for rest
        bit.band(bit.rshift(len, 24), 0xff),
        bit.band(bit.rshift(len, 16), 0xff),
        bit.band(bit.rshift(len, 8), 0xff),
        bit.band(len, 0xff)
      )
  elseif len >= 126 then
    head = head .. string.char(bit.band(bit.rshift(len, 8), 0xff), bit.band(len, 0xff))
  end
  return head .. payload
end

local guid = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
local function acceptKey(key)
  return crypto.toBase64(crypto.sha1(key .. guid))
end

function module.createServer(callback)
  print("start webserver module\n")
  n = net.createServer(net.TCP)
  n:listen(
    config.PORT,
    function(conn)
      local buffer = false
      local socket = {}
      function socket.send(...)
        return conn:send(encode(...))
      end

      conn:on(
        "receive",
        function(_, chunk)
          -- print("DATA:" .. chunk)

          if buffer then
            buffer = buffer .. chunk
            while true do
              local extra, payload, opcode = decode(buffer)
              if not extra then
                return
              end
              buffer = extra
              socket.onmessage(payload, opcode)
              print("\n\textra:" .. extra .. "\n\tpayload:" .. payload .. "\n\topcode" .. opcode)
            end
          end
          local _, e, method = string.find(chunk, "([A-Z]+) /[^\r]* HTTP/%d%.%d\r\n")
          local key, name, value
          while true do
            _, e, name, value = string.find(chunk, "([^ ]+): *([^\r]+)\r\n", e + 1)
            if not e then
              break
            end
            if string.lower(name) == "sec-websocket-key" then
              key = value
            end
          end
          if method == "GET" and key then
            conn:send(
              "HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: " ..
                acceptKey(key) .. "\r\n\r\n"
            )
            buffer = ""
            callback(socket)
          else
            conn:send("HTTP/1.1 404 Not Found\r\nConnection: Close\r\n\r\n")
            conn:on("sent", conn.close)
          end
        end
      )
      conn:on(
        "connection",
        function(sck)
          print("Connected:")
        end
      )
    end
  )
end

function module.start()
  module.createServer(
    function(socket)
      -- local data
      -- node.output(function (msg)
      --   return socket.send(msg, 1)
      -- end, 1)
      print("New websocket client connected")
      function socket.onmessage(payload, opcode)
        if opcode == 1 then
          local id, k, v = string.match(payload, "^(.+):(.+):(.+)$")
          events.switch(id,k,v,socket)
          print("socket")
          print(socket)
          
        end
        print("\n\tONMESSAGE:" .. payload, opcode)
      end
    end
  )
end

return module
