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
        Quotable.Init();
    end
end
Quotable:SetScript("OnEvent", Quotable.OnEvent);

----------------------------------------------------------------------------
-- Initialize the addon
----------------------------------------------------------------------------
function Quotable.Init()
    -- Register Slash Command
    SLASH_QUOTABLE1 = "/quote";
    SLASH_QUOTABLE2 = "/quotable";
    SlashCmdList['QUOTABLE'] = Quotable.Command;

    Quotable.Print("Welcome to Quotable! /quote or /quotable to use.");
end

---------------------------------------------------------------------------
-- HANDLERS
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Command handler
----------------------------------------------------------------------------

function Quotable.Command(cmd)
    --Create variables
    local msgArgs = {};

    --convert to lower case
    cmd = string.lower(cmd);

    --separate args
    for value in string.gmatch(cmd, "[^ ]+") do
        table.insert(msgArgs, value);
    end

    -- Handle commands
    if(#msgArgs == 0) then
        Quotable.DisplayHelp();
    elseif(msgArgs[1] == 'add') then
        Quotable.AddQuote();
    elseif(msgArgs[1] == 'remove') then
        Quotable.RemoveQuote();
    elseif(msgArgs[1] == 'speak') then
        Quotable.SpeakQuote();
    else
        Quotable.DisplayHelp();
    end

end

----------------------------------------------------------------------------
-- Chat command handlers
----------------------------------------------------------------------------

function Quotable.DisplayHelp()
    Quotable.Print('--- Quotable Help ---');
    --TODO tony Add more help lmao
end

function Quotable.AddQuote()

end

function Quotable.RemoveQuote()

end

function Quotable.SpeakQuote()
end


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