local url = "https://raw.githubusercontent.com/NightsTimeZ/RoyxBF/main/Main.lua"
if type(_G.KaitunConfig) == "table" or _G.KaitunMode then
	url = "https://raw.githubusercontent.com/NightsTimeZ/RoyxBF/main/Kaitun.lua"
end

if type(_G.V4Config) == "table" then
	url = "https://raw.githubusercontent.com/NightsTimeZ/RoyxBF/main/V4.lua"
end

if type(_G.BountyConfig) == "table" or _G.BountyMode then
	url = "https://raw.githubusercontent.com/NightsTimeZ/RoyxBF/main/Bounty.lua"
end

loadstring(game:HttpGet(url))()
