
local url_count = 0
local tries = 0


wget.callbacks.download_child_p = function(urlpos, parent, depth, start_url_parsed, iri, verdict, reason)

  if start_url_parsed["host"] == urlpos["url"]["host"] then

	return verdict
  end

  if not verdict and reason == "DOMAIN_NOT_ACCEPTED" then

	if urlpos["link_inline_p"] == 1 then
	-- get inline links from other hosts
		return true

	end

	return verdict
  end

return verdict

end

wget.callbacks.httploop_result = function(url, err, http_stat)
  -- NEW for 2014: Slightly more verbose messages because people keep
  -- complaining that it's not moving or not working
  local status_code = http_stat["statcode"]
  
  url_count = url_count + 1
  io.stdout:write(url_count .. "=" .. status_code .. " " .. url["url"] .. ".  \n")
  io.stdout:flush()


   if status_code >= 500 or
    (status_code == 403 and string.match(url["url"], url_name)) or
    (status_code >= 400 and status_code ~= 404 and status_code ~= 403) then
   io.stdout:write("\nServer returned "..http_stat.statcode..". Sleeping.\n")
    io.stdout:flush()

    os.execute("sleep 1")

    tries = tries + 1

    if tries >= 20 then
      io.stdout:write("\nI give up...\n")
      io.stdout:flush()
      return wget.actions.ABORT
    else
      return wget.actions.CONTINUE
    end

end -- if status_code >=500

  if status_code == 0 then
    io.stdout:write("\nServer returned "..http_stat.statcode..". Probably site is password protected.\n")
    io.stdout:flush()

    os.execute("sleep 5")

    tries = tries + 1

    if tries >= 2 then
      io.stdout:write("\nI give up...\n")
      io.stdout:flush()
      return wget.actions.NOTHING
    else
      return wget.actions.CONTINUE
    end
  end

  tries = 0

  -- We're okay; sleep a bit (if we have to) and continue
  local sleep_time = 0.1 * (math.random(75, 1000) / 100.0)

  --  if string.match(url["host"], "cdn") or string.match(url["host"], "media") then
  --    -- We should be able to go fast on images since that's what a web browser does
  --    sleep_time = 0
  --  end

  if sleep_time > 0.001 then
    os.execute("sleep " .. sleep_time)
  end

  return wget.actions.NOTHING
end

