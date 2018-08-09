--
-- Created by IntelliJ IDEA.
-- User: Tony
-- Date: 8/8/2018
-- Time: 10:27 PM
-- To change this template use File | Settings | File Templates.
--

--GLOBALS: Quotable_Config, SLASH_QUOTABLE, SLASH_QUOTABLE2

--[[
Quotable Version 0.0.1 for World of Warcraft 8.0.1
Written by Dorventh of US-WyrmrestAccord
--]]

-- Local vars declared with QT_
local QT_PRIMARY = "|cff9004e8";
local QT_WHITE = "|cffffffff";
local QT_ERROR = "|cffd35058";

local QT_COLOR_GREEN = "|cff91f97a";
local QT_COLOR_RED = "|cffd35058";
local QT_COLOR_GREY = "|cff7c7c7c";

local QT_Message_Prefix = "!qt"; -- Incoming whispers prefix
local QT_Short_Prefix = "[QT]"; -- Short tag prefix
local QT_Long_Prefix = "Quotable"; -- Long tag prefix

-- Config/Saved Vars
local QT_Channel = 'guild';
local QT_Debug = false;

-- Init

local Quotable = CreateFrame('Frame');
Quotable:RegisterEvent('PLAYER_LOGIN');

Quotable.OnEvent = function(self, event, ...)
    if event == 'PLAYER_LOGIN' then
        Quotable.Print('hello world');
    end
end
Quotable:SetScript("OnEvent", Quotable.OnEvent);

----------------------------------------------------------------------------
-- UTILITY FUNCTIONS
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Print message in console
----------------------------------------------------------------------------
function Quotable.Print(msg)
    -- Format the message
    msg = QT_PRIMARY .. QT_Long_Prefix .. "|r: " .. msg;
    print(msg);
end

function Quotable.PrintError(msg)
    msg = QT_ERROR .. msg;
    Quotable.Print(msg);
end

function Quotable.PrintDebug(msg)
    msg = "(Debug) " .. msg;
    if QT_Debug then Quotable.Print(msg); end
end



