local _, addonTable = ...;

--- @type MaxDps
if not MaxDps then
	return
end

local MaxDps = MaxDps;
local Rogue = addonTable.Rogue;

local OL = {
	Stealth              = 1784,
	MarkedForDeath       = 137619,
	LoadedDice           = 256170,
	SnakeEyes            = 275863,
	GhostlyStrike        = 196937,
	DeeperStratagem      = 193531,

	-- Roll the Bones buffs
	SkullAndCrossbones   = 199603,
	TrueBearing          = 193359,
	RuthlessPrecision    = 193357,
	GrandMelee           = 193358,
	BuriedTreasure       = 199600,
	Broadside            = 193356,

	BladeFlurry          = 13877,
	Opportunity          = 195627,
	QuickDraw            = 196938,
	PistolShot           = 185763,
	KeepYourWitsAboutYou = 288988,
	Deadshot             = 272940,
	SinisterStrike       = 193315,
	KillingSpree         = 51690,
	BladeRush            = 271877,
	Vanish               = 1856,
	Ambush               = 8676,
	AdrenalineRush       = 13750,
	RollTheBones         = 315508,
	SliceAndDice         = 315496,
	BetweenTheEyes       = 315341,
	Dispatch             = 2098,

	StealthAura          = 1784,
	VanishAura           = 11327,
	InstantPoison        = 315584,

	-- Covenant Abilities
	Sepsis               = 328305,
	SepsisAura           = 347037
};

local Conduits = {
	SleightOfHand = 244
}

local A = {
	Deadshot        = 272935,
	AceUpYourSleeve = 278676,
	SnakeEyes       = 275846,

};

setmetatable(OL, Rogue.spellMeta);
setmetatable(A, Rogue.spellMeta);

local Rtb = { 'Broadside', 'GrandMelee', 'RuthlessPrecision', 'TrueBearing', 'SkullAndCrossbones', 'BuriedTreasure' };

function Rogue:IsRefreshable(buff)
	return buff.refreshable and buff.remains <= 10
end

function Rogue:Outlaw()
	local fd = MaxDps.FrameData;
	local cooldown = fd.cooldown;
	local azerite = fd.azerite;
	local buff = fd.buff;
	local talents = fd.talents;
	local timeToDie = fd.timeToDie;
	local covenantId = fd.covenant.covenantId;
	local conduit = fd.covenant.soulbindConduits;
	local targets = MaxDps:SmartAoe();
	local comboPoints = UnitPower('player', 4);
	local comboPointsMax = UnitPowerMax('player', 4);
	local comboPointsDeficit = comboPointsMax - comboPoints;
	local energy = UnitPower('player', 3);
	local energyMax = UnitPowerMax('player', 3);

	local comboGain;
	if buff[OL.Broadside].up then
		comboGain = 2;
	else
		comboGain = 1;
	end

	local rollTheBonesBuffCount = 0;
	if buff[OL.SkullAndCrossbones].up then rollTheBonesBuffCount = rollTheBonesBuffCount + 1; end
	if buff[OL.TrueBearing].up        then rollTheBonesBuffCount = rollTheBonesBuffCount + 1; end
	if buff[OL.RuthlessPrecision].up  then rollTheBonesBuffCount = rollTheBonesBuffCount + 1; end
	if buff[OL.GrandMelee].up         then rollTheBonesBuffCount = rollTheBonesBuffCount + 1; end
	if buff[OL.BuriedTreasure].up     then rollTheBonesBuffCount = rollTheBonesBuffCount + 1; end
	if buff[OL.Broadside].up          then rollTheBonesBuffCount = rollTheBonesBuffCount + 1; end

	MaxDps:GlowEssences();
	MaxDps:GlowCooldown(OL.AdrenalineRush, cooldown[OL.AdrenalineRush].ready);
	MaxDps:GlowCooldown(OL.Vanish, comboPointsDeficit >= 2 and cooldown[OL.Vanish].ready);
	--ADRENALINE RUSH KILLING SPREE BLADE RUSH MARKED FOR DEATH
	-- adrenaline_rush,if=!buff.adrenaline_rush.up&energy.time_to_max>1;
	--if cooldown[OL.AdrenalineRush].ready and not buff[OL.AdrenalineRush].up and energyTimeToMax > 1 then
	--	MaxDps:GlowCooldown(OL.AdrenalineRush);
	--end

	if buff[OL.StealthAura].up or buff[OL.VanishAura].up or buff[OL.SepsisAura].up then
		return OL.Ambush;
	end

	if targets >= 2 and cooldown[OL.BladeFlurry].ready and Rogue:IsRefreshable(buff[OL.BladeFlurry]) then
		return OL.BladeFlurry;
	end

	if cooldown[OL.RollTheBones].ready then
		-- Always reroll single buffs if Sleight of Hand is your Potency Conduit
		if conduit[Conduits.SleightOfHand] > 0 and rollTheBonesBuffCount < 2 then return OL.RollTheBones; end
		-- No buffs or single buff if it's neither Broadside nor True Bearing
		if rollTheBonesBuffCount < 2 and not buff[OL.Broadside].up and not buff[OL.TrueBearing].up then return OL.RollTheBones; end
		-- Two buffs if it's Grand Melee AND Buried Treasure
		if rollTheBonesBuffCount == 2 and buff[OL.GrandMelee].up and buff[OL.BuriedTreasure] then return OL.RollTheBones; end
	end

	if cooldown[OL.BetweenTheEyes].ready and comboPointsDeficit <= 1 then
		return OL.BetweenTheEyes;
	end

	if cooldown[OL.SliceAndDice].ready and comboPointsDeficit <= 1 and Rogue:IsRefreshable(buff[OL.SliceAndDice]) then
		return OL.SliceAndDice;
	end

	if talents[OL.BladeRush] and cooldown[OL.BladeRush].ready then
		return OL.BladeRush;
	end

	if talents[OL.KillingSpree] and cooldown[OL.KillingSpree].ready and not buff[OL.AdrenalineRush].up then
		return OL.KillingSpree;
	end

	if comboPointsDeficit >= 1 and covenantId == Enum.CovenantType.NightFae and cooldown[OL.Sepsis].ready then
		return OL.Sepsis;
	end

	if comboPointsDeficit <= 1 and cooldown[OL.Dispatch].ready then
		return OL.Dispatch;
	end

	if comboPointsDeficit >= 2 and buff[OL.Opportunity].up then
		return OL.PistolShot;
	end

	return OL.SinisterStrike;
end