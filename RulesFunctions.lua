local _, core = ...;
local CommDKP = core.CommDKP;
local _G = _G;
local L = core.L;

function CommDKP:UseMinAndMaxValues()
	return core.DB.modes.mode == "Minimum Bid Values" or core.DB.modes.mode == "Bonus Roll" or (core.DB.modes.mode == "Zero Sum" and core.DB.modes.ZeroSumBidType == "Minimum Bid")
end

