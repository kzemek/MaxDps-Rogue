local _, addonTable = ...;

--- @type MaxDps
if not MaxDps then return end

local MaxDps = MaxDps;
local UnitPower = UnitPower;
local UnitPowerMax = UnitPowerMax;
local GetPowerRegen = GetPowerRegen;
local InCombatLockdown = InCombatLockdown;
local ComboPoints = Enum.PowerType.ComboPoints;
local Energy = Enum.PowerType.Energy;
local Rogue = addonTable.Rogue;

local SB = {
	DeeperStratagem      	= 193531,
	ShadowFocus		= 108209,
	
	Shadowstrike		= 185438,
	Stealth			= 1784,
	SliceAndDice		= 315496,
	Rupture			= 1943,
	Eviscerate		= 196819,
	Backstab		= 53,
	ShadowDance		= 185313,
	ShadowDanceBuff		= 185422,
	SymbolsOfDeath		= 212283,
	ShurikenStorm		= 197835,
	MarkedForDeath		= 137619,
	Vanish               	= 1856,
	BlackPowder		= 319175,
	
	-- Covenant Abilities
	Sepsis               = 328305,
	SepsisAura           = 347037
};

setmetatable(SB, Rogue.spellMeta);

function Rogue:Subtlety()
	local fd = MaxDps.FrameData;
	local cooldown, buff, debuff, talents, azerite, currentSpell, gcd =
	fd.cooldown, fd.buff, fd.debuff, fd.talents, fd.azerite, fd.currentSpell, fd.gcd;

	local energy = UnitPower('player', 3);
	local energyMax = UnitPowerMax('player', 3);
	local energyDeficit = energyMax - energy;
	local energyRegen = GetPowerRegen();
	local energyTimeToMax = (energyMax - energy) / energyRegen;
	local combo = UnitPower('player', 4);
	local comboMax = UnitPowerMax('player', 4);
	local comboDeficit = comboMax - combo;
	local targets = MaxDps:SmartAoe();

	MaxDps:GlowEssences();

	if targets >= 4 then
		return Rogue:SubtletyAOE();
	end
	
	return Rogue:SubtletySingle();
	
end

function Rogue:SubtletySingle()
	local fd = MaxDps.FrameData;
	local cooldown = fd.cooldown;
	local buff = fd.buff;
	local debuff = fd.debuff;
	local covenantId = fd.covenant.covenantId;
	local conduit = fd.covenant.soulbindConduits;
	local currentSpell = fd.currentSpell;
	local talents = fd.talents;
	local targets = MaxDps:SmartAoe();
	local energy = UnitPower('player', 3);
	local energyRegen = GetPowerRegen();
	local combo = UnitPower('player', 4);
	local comboMax = UnitPowerMax('player', 4);
	local comboDeficit = comboMax - combo;
	local stealthEnergyModifier = 1
	
	if talents[SB.MarkedForDeath] and buff[SB.Stealth].up then
		stealthEnergyModifier = 0.8;
	end
	
	if talents[SB.MarkedForDeath] and buff[SB.ShadowDanceBuff].up then
		stealthEnergyModifier = 0.8;
	end 
	
	if buff[SB.Stealth].up and energy >= 40 * stealthEnergyModifier then
		return SB.Shadowstrike;
	end
	
	if talents[SB.MarkedForDeath] and cooldown[SB.MarkedForDeath].ready and energy >= 40 * stealthEnergyModifier then
		return SB.MarkedForDeath;
	end
	
	if buff[SB.SliceAndDice].refreshable and comboDeficit == 0 and energy >= 25 * stealthEnergyModifier then
		return SB.SliceAndDice;
	end
	
	if debuff[SB.Rupture].refreshable and comboDeficit == 0 and energy >= 25 * stealthEnergyModifier then
		return SB.Rupture;
	end

	if comboDeficit == 0 and energy >= 35 * stealthEnergyModifier then
		return SB.Eviscerate;
	end	
	
	if cooldown[SB.ShadowDance].ready and not buff[SB.ShadowDanceBuff].up then
		return SB.ShadowDance;
	end	
	
	if buff[SB.ShadowDanceBuff].up and cooldown[SB.SymbolsOfDeath].ready then
		return SB.SymbolsOfDeath;
	end
	
	if buff[SB.ShadowDanceBuff].up and energy >= 40 * stealthEnergyModifier then
		return SB.Shadowstrike;
	end
	
	if comboDeficit >= 1 and covenantId == Enum.CovenantType.NightFae and cooldown[SB.Sepsis].ready then
		return SB.Sepsis;
	end	
	
	if comboDeficit > 0 and energy >= 35 * stealthEnergyModifier then
		return SB.Backstab;
	end
	
end

function Rogue:SubtletyAOE()
	local fd = MaxDps.FrameData;
	local cooldown = fd.cooldown;
	local buff = fd.buff;
	local debuff = fd.debuff;
	local currentSpell = fd.currentSpell;
	local talents = fd.talents;
	local targets = MaxDps:SmartAoe();
	local energy = UnitPower('player', 3);
	local energyRegen = GetPowerRegen();
	local combo = UnitPower('player', 4);
	local comboMax = UnitPowerMax('player', 4);
	local comboDeficit = comboMax - combo;
	
	if buff[SB.SliceAndDice].refreshable and comboDeficit == 0 and energy >= 25 then
		return SB.SliceAndDice;
	end
	
	if targets >=4 and cooldown[SB.SymbolsOfDeath].ready then
		return SB.SymbolsOfDeath;
	end
	
	if comboDeficit == 0 and energy >= 35 then
		return SB.BlackPowder;
	end	
	
	if energy > 35 then
		return SB.ShurikenStorm;
	end

end
