local plrs = game:GetService("Players")
local reps = game:GetService("ReplicatedStorage")
local http = game:GetService("HttpService")

local lp = plrs.LocalPlayer
local lps = lp.PlayerScripts
local ctrls = lps.Controllers
local rmods = reps.Modules

local elib = require(rmods:WaitForChild("EnumLibrary", 10))
if elib then elib:WaitForEnumBuilder() end
local clib = require(rmods:WaitForChild("CosmeticLibrary", 10))
local ilib = require(rmods:WaitForChild("ItemLibrary", 10))
local dctrl = require(ctrls:WaitForChild("PlayerDataController", 10))
local coss = clib.Cosmetics

local cdata = dctrl.CurrentData
if not cdata then
	task.spawn(function()
		repeat task.wait() until dctrl.CurrentData
		cdata = dctrl.CurrentData
	end)
end

local equip, favs = {}, {}
local cwep, vprof, lwep
local lpname = lp.Name
local fcache = {}

local function banned(n)
	if type(n) ~= "string" then return true end
	return n:find("MISSING_") or n:find("Bubblegum") or n:find("Ragdoll") or n:find("Fall Apart") or n:find("Every Finisher Ever")
end

local function toenum(n)
	if not elib then return nil end
	local ok, id = pcall(elib.ToEnum, elib, n)
	return ok and id or nil
end

local function clonecos(name, ctype, inv, favonly)
	if banned(name) then return nil end
	local base = coss[name]
	if not base then return nil end
	local d = table.clone(base)
	d.Name = name
	d.Type = d.Type or ctype
	d.Seed = d.Seed or math.random(1, 1000000)
	local eid = toenum(name)
	if eid then d.Enum = eid d.ObjectID = d.ObjectID or eid end
	if inv ~= nil then d.Inverted = inv end
	if favonly ~= nil then d.OnlyUseFavorites = favonly end
	return d
end

local savef = "unlockall/config.json"

local function savecfg()
	if not writefile then return end
	pcall(function()
		local cfg = { equipped = {}, favorites = favs }
		for wep, cos in equip do
			local slot = {}
			cfg.equipped[wep] = slot
			for ct, cd in cos do
				if cd and cd.Name and not banned(cd.Name) then
					slot[ct] = { name = cd.Name, seed = cd.Seed, inverted = cd.Inverted }
				end
			end
		end
		makefolder("unlockall")
		writefile(savef, http:JSONEncode(cfg))
	end)
end

local function loadcfg()
	if not readfile or not isfile or not isfile(savef) then return end
	pcall(function()
		local cfg = http:JSONDecode(readfile(savef))
		if cfg.equipped then
			for wep, cos in cfg.equipped do
				equip[wep] = {}
				for ct, cd in cos do
					if not banned(cd.name) then
						local cl = clonecos(cd.name, ct, cd.inverted)
						if cl then
							cl.Seed = cd.seed
							equip[wep][ct] = cl
						end
					end
				end
			end
		end
		favs = cfg.favorites or {}
	end)
end

local finv = {}
local function rebuildinv()
	table.clear(finv)
	for name in coss do
		if not banned(name) then finv[name] = true end
	end
	for _, cos in equip do
		for _, cd in cos do
			if cd and cd.Name and not banned(cd.Name) then finv[cd.Name] = true end
		end
	end
end

rebuildinv()

local oget = dctrl.Get
dctrl.Get = function(self, key)
	local data = oget(self, key)
	if key == "CosmeticInventory" then
		local proxy = {}
		if data then for k, v in data do if not banned(k) then proxy[k] = v end end end
		for name in finv do proxy[name] = true end
		return proxy
	end
	if key == "FavoritedCosmetics" then
		local res = data and table.clone(data) or {}
		for wep, fv in favs do
			local slot = res[wep] or {}
			res[wep] = slot
			for name, isfav in fv do
				if not banned(name) then slot[name] = isfav end
			end
		end
		return res
	end
	return data
end

local ogetwep = dctrl.GetWeaponData
dctrl.GetWeaponData = function(self, wname)
	local data = ogetwep(self, wname)
	if not data then return nil end
	local merged = table.clone(data)
	merged.Name = wname
	local weq = equip[wname]
	if weq then for ct, cd in weq do merged[ct] = cd end end
	return merged
end

local function saferep(key)
	pcall(function()
		if not cdata and dctrl.CurrentData then cdata = dctrl.CurrentData end
		if cdata then cdata:Replicate(key) end
	end)
end

local fctrl
pcall(function() fctrl = require(ctrls:WaitForChild("FighterController", 10)) end)

local function getewep()
	if not fctrl then return nil end
	local fighter = fctrl:GetFighter(lp)
	if not fighter or not fighter.Items then return nil end
	for _, item in fighter.Items do
		if item.IsEquipped then return item.Name end
	end
	return nil
end

if hookmetamethod then
	local rems = reps:FindFirstChild("Remotes")
	local drems = rems and rems:FindFirstChild("Data")
	local eqrem = drems and drems:FindFirstChild("EquipCosmetic")
	local favrem = drems and drems:FindFirstChild("FavoriteCosmetic")
	local rrems = rems and rems:FindFirstChild("Replication")
	local frems = rrems and rrems:FindFirstChild("Fighter")
	local uirem = frems and frems:FindFirstChild("UseItem")

	if eqrem then
		local oncall
		oncall = hookmetamethod(game, "__namecall", function(self, ...)
			if getnamecallmethod() ~= "FireServer" then return oncall(self, ...) end
			local args = { ... }

			if uirem and self == uirem and fctrl then
				pcall(function()
					local fighter = fctrl:GetFighter(lp)
					if fighter and fighter.Items then
						local oid = args[1]
						for _, item in fighter.Items do
							if item:Get("ObjectID") == oid then
								lwep = item.Name
								break
							end
						end
					end
				end)
			end

			if self == eqrem then
				local wname, ctype, cname, opts = args[1], args[2], args[3], args[4] or {}
				if not cname or cname == "None" or cname == "" then
					equip[wname] = equip[wname] or {}
					equip[wname][ctype] = nil
					if not next(equip[wname]) then equip[wname] = nil end
					rebuildinv()
					task.defer(function()
						saferep("WeaponInventory")
						task.wait(0.2)
						savecfg()
					end)
					return oncall(self, ...)
				end
				if banned(cname) then return oncall(self, ...) end
				local rdata = oget(dctrl, "CosmeticInventory")
				if rdata and type(rdata[cname]) ~= "boolean" and rdata[cname] ~= nil then
					return oncall(self, ...)
				end
				equip[wname] = equip[wname] or {}
				local cloned = clonecos(cname, ctype, opts.IsInverted, opts.OnlyUseFavorites)
				if cloned then equip[wname][ctype] = cloned end
				if ctype == "Finisher" then fcache[wname] = cname end
				rebuildinv()
				task.defer(function()
					saferep("WeaponInventory")
					task.wait(0.2)
					savecfg()
				end)
				return
			end

			if self == favrem then
				local fwep, fname, fstate = args[1], args[2], args[3]
				if not fname or fname == "None" or fname == "" then return oncall(self, ...) end
				if banned(fname) then return oncall(self, ...) end
				favs[fwep] = favs[fwep] or {}
				favs[fwep][fname] = fstate or nil
				savecfg()
				task.spawn(saferep, "FavoritedCosmetics")
				return
			end

			return oncall(self, ...)
		end)
	end
end

local citem
pcall(function() citem = require(lps.Modules.ClientReplicatedClasses.ClientFighter.ClientItem) end)

if citem and citem._CreateViewModel then
	local ocvm = citem._CreateViewModel
	citem._CreateViewModel = function(self, vmref)
		local wname = self.Name
		local wplr = self.ClientFighter and self.ClientFighter.Player
		cwep = (wplr == lp) and wname or nil
		if wplr == lp and equip[wname] and equip[wname].Skin and vmref then
			local skin = equip[wname].Skin
			local dk = self:ToEnum("Data")
			if vmref[dk] then
				vmref[dk][self:ToEnum("Skin")] = skin
				vmref[dk][self:ToEnum("Name")] = skin.Name
			elseif vmref.Data then
				vmref.Data.Skin = skin
				vmref.Data.Name = skin.Name
			end
		end
		local res = ocvm(self, vmref)
		cwep = nil
		return res
	end
end

local vmmod = lps.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
if vmmod then
	local cvm = require(vmmod)
	if cvm.GetWrap then
		local ogw = cvm.GetWrap
		cvm.GetWrap = function(self)
			local ci = self.ClientItem
			local wname = ci and ci.Name
			local wplr = ci and ci.ClientFighter and ci.ClientFighter.Player
			local weq = wname and wplr == lp and equip[wname]
			return (weq and weq.Wrap) or ogw(self)
		end
	end
	local onew = cvm.new
	cvm.new = function(rdata, cliitm)
		local wplr = cliitm.ClientFighter and cliitm.ClientFighter.Player
		local wname = cwep or cliitm.Name
		if wplr == lp and equip[wname] then
			local rcls = require(reps.Modules.ReplicatedClass)
			local dk = rcls:ToEnum("Data")
			rdata[dk] = rdata[dk] or {}
			local cos = equip[wname]
			local slot = rdata[dk]
			if cos.Skin then slot[rcls:ToEnum("Skin")] = cos.Skin end
			if cos.Wrap then slot[rcls:ToEnum("Wrap")] = cos.Wrap end
			if cos.Charm then slot[rcls:ToEnum("Charm")] = cos.Charm end
		end
		local res = onew(rdata, cliitm)
		if wplr == lp and equip[wname] and equip[wname].Wrap and res._UpdateWrap then
			res:_UpdateWrap()
			task.delay(0.1, function() if not res._destroyed then res:_UpdateWrap() end end)
		end
		return res
	end
end

local ogvi = ilib.GetViewModelImageFromWeaponData
ilib.GetViewModelImageFromWeaponData = function(self, wdata, hires)
	if not wdata then return ogvi(self, wdata, hires) end
	local wname = wdata.Name
	local weq = equip[wname]
	if weq and weq.Skin and (wdata.Skin == weq.Skin or vprof == lp) then
		local sinfo = self.ViewModels[weq.Skin.Name]
		if sinfo then return sinfo[hires and "ImageHighResolution" or "Image"] or sinfo.Image end
	end
	return ogvi(self, wdata, hires)
end

pcall(function()
	local vpmod = require(lps.Modules.Pages.ViewProfile)
	if vpmod and vpmod.Fetch then
		local ofetch = vpmod.Fetch
		vpmod.Fetch = function(self, tplr)
			vprof = tplr
			return ofetch(self, tplr)
		end
	end
end)

local cent
pcall(function() cent = require(lps.Modules.ClientReplicatedClasses.ClientEntity) end)

if cent and cent._PlayFinisher then
	local ofin = cent._PlayFinisher
	cent._PlayFinisher = function(self, fname, ...)
		local ewep = getewep()
		local tfin = ewep and (fcache[ewep] or (equip[ewep] and equip[ewep].Finisher and equip[ewep].Finisher.Name))
		return ofin(self, tfin or fname, ...)
	end
end

loadcfg()
rebuildinv()

for wname, wdata in equip do
	if wdata.Finisher and wdata.Finisher.Name then
		fcache[wname] = wdata.Finisher.Name
	end
end
