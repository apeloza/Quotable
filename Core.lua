-- Create a new Ace3 module
Quotable = LibStub("AceAddon-3.0"):NewAddon("Quotable", "AceConsole-3.0", "AceEvent-3.0");

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
    },
}

function Quotable:OnEnable()
    Quotable:Print("Welcome to Quotable! /quote or /quotable to use.");
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Quotable", options, {"quotable", "quote"})
    Quotable.message = 'A test message';
    Quotable.Speak();

end

function Quotable:Speak(info)
    Quotable:Print('woopdidy scoop');
end

function Quotable:Save(info, newValue)
    self.message = newValue
end
