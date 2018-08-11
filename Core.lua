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
            set="Save",
            usage = "/quote save <name> <quote>",
            validate = "ValidateQuote",
        },
        output = {
            type="input",
            name="Output",
            desc = "Sets the output channel for Quotable (default party).",
            get="SetOutput",
            set="SetOutput",
        },
        eraseall = {
            type="execute",
            name="Erase All",
            desc = "Erases ALL quotes in the database (WARNING: permanent!)",
            func="EraseAll",
        }
    },
}

function Quotable:OnEnable()
    Quotable:Print("Welcome to Quotable! /quote or /quotable to use.");
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Quotable", options, {"quotable", "quote"})
    -- declare defaults to be used in the DB
end

function Quotable:OnInitialize()
    -- Database setup
    local defaults = {
        global = {
            channel = 'PARTY',
            quotes = {
                {
                    name = "Tigers",
                    quote = "Oh no I thought we were going to the sandbox tigers",
                    author = "Rom",
                    date = 8/8/2018,
                    tags = { "DMF" }
                },
                {
                    name = "Loops",
                    quote = "Brother may I have some loops",
                    tags = { "meme" },
                    date = 2018
                },
                {
                    name = "Floor Pasta",
                    quote = "Just serve them the floor pasta",
                    author = "Tony",
                    date = 8/9/2018,
                    tags = { "Overcooked" }
                },
                {
                    name = "Desolate Gays",
                    quote = "Watch out for the gays",
                    author = "Tony",
                    tags = { "raid", "guild" }
                }
            },
        }
    }
    -- Assuming the .toc says ## SavedVariables: QuotableDB
    Quotable.db = LibStub("AceDB-3.0"):New("QuotableDB", defaults, true);
end

function Quotable:Speak(info)
    if(#Quotable.db.global.quotes ~= 0) then
        SendChatMessage("QUOTABLE: " .. Quotable.Random(), Quotable.db.global.channel);
    else
        Quotable:Print('ERROR: No quotes are in the database. Use /quote save to add quotes!');
    end
end

--Returns a random quote from the quote DB
function Quotable:Random()
    local number = math.random(#Quotable.db.global.quotes);
    return Quotable.db.global.quotes[number].quote;
end

function Quotable:Save(info, input)
    local parsed_input = Quotable.ParseQuoteInput(info, input)
    local name = parsed_input.name
    Quotable.db.global.quotes[#Quotable.db.global.quotes + 1] = {
        name = name,
        quote = parsed_input.quote
    }
    Quotable:Print("Saved new quote with name: " .. name)
end

function Quotable:ValidateQuote(info, input)
    local quote = Quotable.ParseQuoteInput(info, input) -- not sure why I need to pass info - it breaks if input isn't arg 2
    if quote.status == "success" then
        return true;
    elseif quote.status == "error" then
        return quote.message;
    end
end

function Quotable:ParseQuoteInput(input)
    local parsed_input = {
        name = nil,
        quote = nil,
        message = "ok",
        status = "success"
    }

    local parsed_name = string.match(input, "^(%S+) ")
    local parsed_quote = string.match(input, (parsed_name or "") .. " (.+)$")

    if parsed_name and parsed_quote then
        parsed_input.name = parsed_name
        parsed_input.quote = parsed_quote
    else
        parsed_input.status = "error"
        parsed_input.message = "Name and quote are both required"
    end

    return parsed_input
end

function Quotable:SetOutput(info, newValue)
    Quotable.db.global.channel = newValue;
end

--DESTRUCTIVE
function Quotable:EraseAll(info)
    Quotable.db.global.quotes = {};
end
