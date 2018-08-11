-- Create a new Ace3 module
Quotable = LibStub("AceAddon-3.0"):NewAddon("Quotable", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0");

local options = {
    name = "Quotable",
    handler = Quotable,
    type = 'group',
    args = {
        speak = {
            type = "execute",
            name = "Speak",
            desc = "Outputs a random quote.",
            func = "Speak"
        },
        save = {
            type="input",
            name="Save",
            desc = "Saves a new quote to the database.",
            get="Save",
            set="Save"
        },
        output = {
            type="input",
            name="Output",
            desc = "Sets the output channel for Quotable (default party).",
            get="SetOutput",
            set="SetOutput",
        }
    },
}

function Quotable:OnEnable()
    Quotable:Print("Welcome to Quotable! /quote or /quotable to use.");
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Quotable", options, {"quotable", "quote"})
    -- declare defaults to be used in the DB

end

function Quotable:OnInitialize()
    local defaults = {
        global = {
            quotes = {'This is a test quote', 'This is a second test quote'},
            channel = 'PARTY',
        },
    }
    -- Assuming the .toc says ## SavedVariables: QuotableDB
    Quotable.db = LibStub("AceDB-3.0"):New("QuotableDB", defaults, true);
end

function Quotable:Speak(info)
    SendChatMessage("QUOTABLE: " .. Quotable.Random(), Quotable.db.global.channel);
end

function Quotable:Random()
    local number = math.random(#Quotable.db.global.quotes);
    return Quotable.db.global.quotes[number];
end

function Quotable:Save(info, newValue)
    Quotable.db.global.quotes[#Quotable.db.global.quotes + 1] = newValue;
end

function Quotable:SetOutput(info, newValue)
    Quotable.db.global.channel = newValue;
end
