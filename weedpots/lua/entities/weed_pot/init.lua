AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("Weed_Open_Menu")
util.AddNetworkString("Seed_Purchase")
util.AddNetworkString("Weed_Finished")

function ENT:Initialize()
	self:SetModel("models/nater/weedplant_pot.mdl") -- Initial Model
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
	end
	self.IsGrowing = false
	self.HasSeed = false
	self.GrowTime = 0
	self.Finished = false
end

function ENT:Use(a,c)
	if self.Finished == false and self.HasSeed == false then
		net.Start("Weed_Open_Menu")
		net.WriteEntity(c)
		net.Send(c)
	end
	net.Receive("Seed_Purchase", function()
		local seed = net.ReadString()
		local time = net.ReadInt(32)
		sellMin = net.ReadInt(32)
		sellMax = net.ReadInt(32)
		price = net.ReadInt(32)
		if self.HasSeed == false then
			a:addMoney(-price)
			self.HasSeed = true
			self.IsGrowing = true
			self.GrowTime = CurTime() + time
			self:SetModel("models/nater/weedplant_pot_planted.mdl") -- Stage 1
		end
		timer.Simple(time * 0.10, function()
			if (!IsValid(self)) then return end
			if self.IsGrowing == false then return end
			self:SetModel("models/nater/weedplant_pot_growing1.mdl") -- Stage 2
		end)
		timer.Simple(time * 0.20, function()
			if (!IsValid(self)) then return end
			if self.IsGrowing == false then return end
			self:SetModel("models/nater/weedplant_pot_growing2.mdl") -- Stage 3
		end)
		timer.Simple(time * 0.40, function()
			if (!IsValid(self)) then return end
			if self.IsGrowing == false then return end
			self:SetModel("models/nater/weedplant_pot_growing3.mdl") -- Stage 4
		end)
		timer.Simple(time * 0.60, function()
			if (!IsValid(self)) then return end
			if self.IsGrowing == false then return end
			self:SetModel("models/nater/weedplant_pot_growing4.mdl") -- Stage 5
		end)
		timer.Simple(time * 0.80, function()
			if (!IsValid(self)) then return end
			if self.IsGrowing == false then return end
			self:SetModel("models/nater/weedplant_pot_growing5.mdl") -- Stage 6
		end)
		timer.Simple(time * 0.95, function()
			if (!IsValid(self)) then return end
			if self.IsGrowing == false then return end
			self:SetModel("models/nater/weedplant_pot_growing6.mdl") -- Stage 6
		end)
	end)

	if self.Finished == true then
		self:SetModel("models/nater/weedplant_pot.mdl") -- Reset Model
		self.HasSeed = false
		self.Finished = false
		DarkRP.createMoneyBag(self:GetPos() + Vector(0,0,25), math.random(sellMin, sellMax))
	end
end

function ENT:Think()
	if self.IsGrowing == true then
		if self.GrowTime <= CurTime() then
			self.Finished = true
			self.IsGrowing = false
			self:SetModel("models/nater/weedplant_pot_growing7.mdl")	 -- Final Stage
		end
	end
	if self:WaterLevel() == 3 then
		self:SetModel("models/nater/weedplant_pot.mdl") -- Reset Model
		self.HasSeed = false
		self.Finished = false
		self.IsGrowing = false
	end
end

function ENT:OnTakeDamage(dmg)
	self:TakePhysicsDamage(dmg)

	self.PotHealth = self.PotHealth - dmg:GetDamage()
	if self.PotHealth <= 0 then
		self:Remove()
	end
end