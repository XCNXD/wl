if _G.VersionControl == "Pre-release" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KangKung02/royxGameLoader/refs/heads/main/AAnormal.lua"))()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KangKung02/royxGameLoader/refs/heads/main/AAOld.lua"))()
end