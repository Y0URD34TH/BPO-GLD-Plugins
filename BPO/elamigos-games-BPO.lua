local http = require("curl")
local json = require("json")

local function webScrapeElAmigosGamesNUC(gameName)
    local searchUrl = "https://www.elamigos-games.com/?q=" .. gameName
    searchUrl = searchUrl:gsub(" ", "%%20")

    local headers = {
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }

    local responseBody = http.request(searchUrl, "GET", headers)

    local gameNames = {}
    local gameLinks = {}

    for link, name in responseBody:gmatch('<h6 class="card%-title">.-<a href="(.-)">(.-)</a>') do
        table.insert(gameNames, name)
        table.insert(gameLinks, link)
    end

    local gameResults = {}

    for i = 1, #gameNames do
        local gameResponseBody = http.request(gameLinks[i], "GET", headers)

        if gameResponseBody then
            local downloadServersSection = gameResponseBody:match('<h3 class="my%-4">Download servers<hr></h3>.-</div>%s-</div>')
            if downloadServersSection then
                local gameResult = {
                    name = gameNames[i],
                    links = {}
        }

                local serverName = downloadServersSection:gmatch('<a href="(.-)".->(.-)</a>')
                    if not (serverName:find("<img") or serverName:find("comments powered by Disqus.")) then
                        table.insert(gameResult.links, { name = serverName, link = serverLink })
                    end

                table.insert(gameResults, gameResult)
            else
            end
        else
        end
    end

    return gameResults
end

local function elamigosNUC()
local query_fixed = string.gsub(Query, "%s", "-")
local gamenameNUC = query_fixed
local resultsNUC = webScrapeElAmigosGamesNUC(gamenameNUC)
PluginReturn = json.encode(resultsNUC)
end
