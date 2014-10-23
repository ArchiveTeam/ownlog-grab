dofile("urlcode.lua")
dofile("table_show.lua")
JSON = (loadfile "JSON.lua")()

local url_count = 0
local tries = 0
local item_type = os.getenv('item_type')
local item_value = os.getenv('item_value')

local downloaded = {}
local external_resources = {}

load_json_file = function(file)
  if file then
    local f = io.open(file)
    local data = f:read("*all")
    f:close()
    return JSON:decode(data)
  else
    return nil
  end
end

read_file = function(file)
  if file then
    local f = assert(io.open(file))
    local data = f:read("*all")
    f:close()
    return data
  else
    return ""
  end
end

wget.callbacks.download_child_p = function(urlpos, parent, depth, start_url_parsed, iri, verdict, reason)
  local url = urlpos["url"]["url"]
  local html = urlpos["link_expect_html"]
  local parenturl = parent["url"]
  local html = nil
  
  if downloaded[url] == true then
    return false
  end
  
  if item_type == "ownlog" then

      -- download all external files refenrenced in a blog - usually photos from other sites

      if urlpos["link_inline_p"] == 1 and reason == "DOMAIN_NOT_ACCEPTED" then
          external_resources[url] = true
        return true
      else
        return verdict

      end


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


  if err == "AUTHFAILED" then
      io.stdout:write("Authentication required for " .. url["url"] .. "....ignoring\n")
      io.stdout:flush()

      if string.match(url.url, "https://") then
        local newurl = string.gsub(url.url, "https://", "http://")
        downloaded[newurl] = true
      else
        downloaded[url.url] = true
      end

      return wget.actions.NOTHING
  end

-- ignore errors related to external resources

  if (status_code == 0 or status_code >= 500 or (status_code >= 400 and status_code ~= 404 and status_code ~= 403))
          and external_resources[url["url"]] == true then

      io.stdout:write("Error for external resource " .. url["url"] .. "....ignoring\n")

      if status_code == 0 then
          io.stdout:write("Error code: " .. err .. "\n")
      end
      io.stdout:flush()

      if string.match(url.url, "https://") then
        local newurl = string.gsub(url.url, "https://", "http://")
        downloaded[newurl] = true
      else
        downloaded[url.url] = true
      end

      return wget.actions.EXIT
  end

  
  if (status_code >= 200 and status_code <= 399) or status_code == 403 then
    if string.match(url.url, "https://") then
      local newurl = string.gsub(url.url, "https://", "http://")
      downloaded[newurl] = true
    else
      downloaded[url.url] = true
    end
  end
  
  if status_code >= 500 or
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

  elseif status_code == 0 then
    io.stdout:write("\nServer returned "..http_stat.statcode..". Sleeping.\n")
    io.stdout:flush()

    os.execute("sleep 10")

    tries = tries + 1

    if tries >= 10 then
      io.stdout:write("\nI give up...\n")
      io.stdout:flush()
      return wget.actions.ABORT
    else
      return wget.actions.CONTINUE
    end
  end

  tries = 0

  -- We're okay; sleep a bit (if we have to) and continue
  -- local sleep_time = 0.1 * (math.random(75, 1000) / 100.0)
  local sleep_time = 0

  --  if string.match(url["host"], "cdn") or string.match(url["host"], "media") then
  --    -- We should be able to go fast on images since that's what a web browser does
  --    sleep_time = 0
  --  end

  if sleep_time > 0.001 then
    os.execute("sleep " .. sleep_time)
  end

  return wget.actions.NOTHING
end
