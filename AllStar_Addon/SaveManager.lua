local httpService = game:GetService('HttpService')
local SaveManager = {} do
	SaveManager.Folder = 'RoyxHub';
    SaveManager.File = 'Basic_Setting';
	SaveManager.Ignore = {};
	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = 'Toggle', idx = idx, value = object.Value } 
			end,
			Load = function(idx, data)
				if Toggles[idx] then 
					Toggles[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = 'Slider', idx = idx, value = tostring(object.Value) }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = 'Dropdown', idx = idx, value = object.Value, mutli = object.Multi }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		},
		ColorPicker = {
			Save = function(idx, object)
				return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex() }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValueRGB(Color3.fromHex(data.value))
				end
			end,
		},
		KeyPicker = {
			Save = function(idx, object)
				return { type = 'KeyPicker', idx = idx, mode = object.Mode, key = object.Value }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue({ data.key, data.mode })
				end
			end,
		},
		Input = {
			Save = function(idx, object)
				return { type = 'Input', idx = idx, value = object.Value }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		}
	}

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end
    
	function SaveManager:SetFile(file)
		self.File = file;
		self:BuildFolderTree();
	end

	function SaveManager:Save()
		wait(0.1)
		local fullPath = self.Folder .. '/settings/' .. self.File .. '.json'

		local data = {
			objects = {}
		}

		for idx, toggle in next, Toggles do
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
		end

		for idx, option in next, Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end	

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return false, 'failed to encode data'
		end

		writefile(fullPath, encoded)
		return true
	end

	function SaveManager:SpecificSave(main, type, idx)
		local file = self.Folder .. '/settings/' .. self.File .. '.json'
		if not isfile(file) then return false, 'invalid file' end

		local success, lastData = pcall(function()
			local str = string.format('return %s["%s"]', main, idx);
			local data = loadstring(str)();
			return data;
		end)
		if not success then return false, 'invalid format' end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file));
        if not success then return false, 'failed to encode data' end;

        local modedData = table.clone(decoded);
        modedData.objects = {};
		for _, option in next, decoded.objects do
            if option.type == type and option.idx == idx then
                option = self.Parser[option.type].Save(option.idx, lastData);
            end
            table.insert(modedData.objects, option);
        end

		local success, encoded = pcall(httpService.JSONEncode, httpService, modedData)
		if not success then
			return false, 'failed to encode data'
		end

		writefile(file, encoded)
		return true
	end

	function SaveManager:Load(name)
		local file = self.Folder .. '/settings/' .. self.File .. '.json'
		if not isfile(file) then return false, 'invalid file' end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then return false, 'decode error' end

		for _, option in next, decoded.objects do
			if self.Parser[option.type] then
				self.Parser[option.type].Load(option.idx, option)
			end
		end

		return true
	end

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", "ThemeManager_ThemeList", 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName' })
	end

	function SaveManager:BuildFolderTree()
		local paths = {
			self.Folder,
			self.Folder .. '/themes',
			self.Folder .. '/settings'
		}

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

    function SaveManager:AutoSave()
        task.spawn(function()
            while task.wait(1) do
                if Toggles["AutoSave"] and Toggles["AutoSave"].Value then
                    self:Save();
                end
            end
        end);
    end
    SaveManager:BuildFolderTree()
end

return SaveManager