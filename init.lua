print("OMMEL/Mod %VERSION% ACTIVE!")
local ffi = require("ffi")
local is_unix = os.getenv("OMMEL_UNIX") ~= nil

if is_unix then
	print("OMMEL: Running in Unix/native mono mode.")
else
	print("OMMEL: Running in Windows mode.")
end

local appdata_path = os.getenv("OMMEL_APPDATA_PATH")
if (appdata_path == nil and is_unix) then
	error("OMMEL: Must specify OMMEL_APPDATA_PATH alongside OMMEL_UNIX variable!")
	return
end

trigger = true

while trigger do
	trigger = false
	if is_unix then
		os.execute([[set pathext=%pathext%;. & Z:\usr\bin\mono mods/ommel/ommel/Ommel.exe -noita-path . -noita-appdata-path "]] .. appdata_path .. [[" -dont-launch -compat-generate -compat-mod-dir ommel -compat-custom-metadata -use-update-info-file -use-lock-file]])

		-- It appears that launching Mono through Wine
		-- does not actually block the thread, meaning that we could
		-- theoretically be late with the data/ directory
		-- to solve this, we make Ommel.exe maintain an ommel.lock file
		-- while it's running with the -use-lock-file option
		-- and we block here in Lua until the file is gone
		print("OMMEL: Blocking thread until Ommel is finished")

		local started = false
		while (true) do
			-- easy way to check if a file exists
			local exists = os.rename("ommel.lock", "ommel.lock")

			-- since the file isn't created instantenously, we wait until Ommel starts
			if (exists) then started = true end

			-- and once the file is gone (and we know that ommel *had* already been started), we can leave the loop and continue loading
			if ((not exists) and started) then break end
		end
	else
		os.execute("mods\\ommel\\ommel\\Ommel.exe -noita-path . -dont-launch -compat-generate -compat-mod-dir ommel -compat-custom-metadata -use-update-info-file")
	end

	if (os.rename(".ommel-update-done", ".ommel-update-done")) then
		print("OMMEL: Just updated, restarting Ommel")
		trigger = true
	end
end

print("OMMEL: Done")
