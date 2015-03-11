local url_count = 0
local tries = 0


wget.callbacks.httploop_result = function(url, err, http_stat)
  local status_code = http_stat["statcode"]

  url_count = url_count + 1
  io.stdout:write(url_count .. ": " .. status_code .. " " .. url["url"] .. "\n")
  io.stdout:flush()

  if status_code == 0 or status_code >= 500 or
  (status_code >= 400 and status_code ~= 404) then
    io.stdout:write("\nServer returned "..http_stat.statcode..". Sleeping.\n")
    io.stdout:flush()

    os.execute("sleep 10")

    tries = tries + 1

    if tries >= 2 and string.match(url["url"], 'googleusercontent') and status_code == 403 then
      tries = 0
      io.stdout:write("\nI can't seem to download this file. Ignoring it.\n")
      io.stdout:flush()
      return wget.actions.EXIT
    elseif tries >= 20 then
      io.stdout:write("\nI give up... Please report this item to the admins.\n")
      io.stdout:flush()
      return wget.actions.ABORT
    else
      return wget.actions.CONTINUE
    end
  end

  tries = 0

  -- We're okay; sleep a bit (if we have to) and continue
  local sleep_time = math.random(100, 2000) / 1000.0

  if string.match(url["host"], "googleusercontent") or
          string.match(url["host"], "googleapis") or
          string.match(url["path"], "%.jpg") or
          string.match(url["path"], "%.png") or
          string.match(url["path"], "%.js") or
          string.match(url["path"], "%.css")
  then
    -- We should be able to go fast on images since that's what a web browser does
    sleep_time = 0
  end

  if sleep_time > 0.001 then
    os.execute("sleep " .. sleep_time)
  end

  return wget.actions.NOTHING
end
