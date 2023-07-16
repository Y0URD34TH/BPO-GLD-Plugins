local http = require("curl")
local json = require("json")

local headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

local query_fixed = string.gsub(Query, "%s", "-")

local regex = "<a href%s*=%s*\"(/torrent/[^\"]+)\""
local magnetRegex = "href%s*=%s*\"(magnet:[^\"]+)\""


    local function request1337xNUC()
        local gamename = query_fixed

        if not gamename then
            print("Error: Failed to retrieve game name.")
            return
        end

        local urlrequest = "https://www.1377x.to/category-search/" .. tostring(gamename) .. "/Games/1/"
        urlrequest = urlrequest:gsub(" ", "%%20")

        local htmlContent = http.request(urlrequest, "GET", headers)
        if not htmlContent then
            print("Error: Failed to retrieve HTML content for URL: " .. urlrequest)
            return
        end

        local results = {}
        local searchResult -- Declare the searchResult variable outside the loop

        for match in htmlContent:gmatch(regex) do
            local url = "https://1377x.to" .. match
            local torrentName = url:match("/([^/]+)/$")
            if not torrentName then
                print("Error: Failed to extract torrent name from URL: " .. url)
                break
            end

            local htmlContent2 = http.request(url, "GET", headers)
            if not htmlContent2 then
                print("Error: Failed to retrieve HTML content for URL: " .. url)
                break
            end

            searchResult = {
                name = torrentName,
                links = {}            }

            for magnetMatch in htmlContent2:gmatch(magnetRegex) do
                searchResult.links[#searchResult.links + 1] = {
                    name = "Download",
                    link = magnetMatch,
                }
                -- No need to continue the loop if a magnet link is found
                break
            end

            if next(searchResult.links) == nil then
                searchResult.links[#searchResult.links + 1] = {
                    name = "Download",
                    link = url
                }
            end

            results[#results + 1] = searchResult
        end

        if next(results) ~= nil then
            PluginReturn = json.encode(results)
        else
            print("No results found.")
        end
    end
request1337xNUC()
