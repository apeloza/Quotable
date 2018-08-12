-- Create a new Ace3 module
Quotable = LibStub("AceAddon-3.0"):NewAddon("Quotable", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0");

local MAX_QUOTE_LENGTH = 200

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
        },
        list = {
            type="execute",
            name="List Quotes",
            desc = "Lists all quotes by name",
            func="ListQuotes"
        }
    },
}

function Quotable:OnEnable()
    Quotable:Print("Welcome to Quotable! /quote or /quotable to use.");
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Quotable", options, {"quotable", "quote"})

    Quotable.DrawMainFrame();
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
    Quotable.channelHeading:SetText('Channel: ' .. newValue);
end

function Quotable:ListQuotes(info)
    local quote_list = {}
    for i in pairs(Quotable.db.global.quotes) do
        table.insert(quote_list, Quotable.db.global.quotes[i].name)
    end
    Quotable:Print(table.concat(quote_list, ", "))
end

--called to draw the frame into existence/update the frame as needed
function Quotable:DrawMainFrame()
    local AceGUI = LibStub("AceGUI-3.0")
    -- Create a container frame
    local f = AceGUI:Create("Frame")
    f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)
    f:SetTitle("Quotable")
    f:SetLayout("List")
    f:SetWidth(250);
    f:SetHeight(400);
    -- Create a button
    local btn = AceGUI:Create("Button");
    btn:SetRelativeWidth(0.8);
    btn:SetText("Random!");
    f:SetStatusText("v.0.1")
    btn:SetCallback("OnClick", Quotable.Speak)
    btn:SetPoint('CENTER', 20, 50);
    -- Add the button to the container
    f:AddChild(btn);

    -- create the add button
    local add_btn = AceGUI:Create("Button")
    add_btn:SetWidth(170)
    add_btn:SetText("New Quote")
    add_btn:SetCallback("OnClick", Quotable.NewQuoteOpenWindow)
    f:AddChild(add_btn)

    local channelDropdown = AceGUI:Create("Dropdown");
    local channelOptions = {PARTY = 'Party', RAID = 'Raid', GUILD = 'Guild'};
    channelDropdown:SetWidth(170);
    channelDropdown:SetList(channelOptions);
    channelDropdown:SetLabel('Output Channel');
    channelDropdown:SetCallback("OnValueChanged", Quotable.SetOutput)
    f:AddChild(channelDropdown);
    local currentChannel = AceGUI:Create("Heading");
    currentChannel:SetRelativeWidth(.9);
    currentChannel:SetText('Channel: ' .. Quotable.db.global.channel);
    f:AddChild(currentChannel);
    Quotable.channelHeading = currentChannel;
end

--DESTRUCTIVE
function Quotable:EraseAll(info)
    Quotable.db.global.quotes = {};
end

-----------------------
-- MODULE: NEW QUOTE
-----------------------

function Quotable:NewQuoteOpenWindow()
    local AceGUI = LibStub("AceGUI-3.0")

    Quotable.add_form = {}

    -- Create a container frame
    local f = AceGUI:Create("Frame")
    f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)
    f:SetTitle("New Quote")
    f:SetLayout("List")
    f:SetHeight(300)
    f:SetWidth(500)
    f:EnableResize(false)

    -- Input: Quote
    local input_quote = AceGUI:Create("MultiLineEditBox")
    input_quote:SetLabel("Quote (Required)")
    input_quote:SetNumLines(3)
    input_quote:SetMaxLetters(200)
    input_quote:DisableButton(true)
    input_quote:SetRelativeWidth(1)

    input_quote:SetCallback("OnTextChanged", Quotable.NewQuoteUpdateCharsRemaining)

    f:AddChild(input_quote)

    -- Characters remaining
    local chars_remaining = AceGUI:Create("Label")
    chars_remaining:SetText(MAX_QUOTE_LENGTH .. " characters remaining")
    chars_remaining:SetRelativeWidth(1)
    f:AddChild(chars_remaining)

    -- Author + date container
    local details = AceGUI:Create("SimpleGroup")
    details:SetLayout("Flow")
    details:SetRelativeWidth(1)

    local input_author = AceGUI:Create("EditBox")
    input_author:SetLabel("Author")
    input_author:SetRelativeWidth(.5)

    local input_date = AceGUI:Create("EditBox")
    input_date:SetLabel("Date")
    input_date:SetRelativeWidth(.5)

    details:AddChild(input_author)
    details:AddChild(input_date)
    f:AddChild(details)

    -- Tags
    local input_tags = AceGUI:Create("EditBox")
    input_tags:SetLabel("Tags")
    input_tags:SetRelativeWidth(1)
    f:AddChild(input_tags)

    -- Submit Button
    local submit = AceGUI:Create("Button")
    submit:SetText("Save")
    submit:SetWidth(200)

    f:AddChild(submit)

    Quotable.add_form.input_quote = input_quote;
    Quotable.add_form.chars_remaining = chars_remaining;
    Quotable.add_form.input_author = input_author;
    Quotable.add_form.input_date = input_date;

    input_quote:SetFocus()
end

function Quotable:NewQuoteUpdateCharsRemaining()
    local char_count = #Quotable.add_form.input_quote:GetText()
    local remaining_char_count = MAX_QUOTE_LENGTH - char_count
    Quotable.add_form.chars_remaining:SetText(remaining_char_count .. " characters remaining")
end

function Quotable:NewQuoteSubmit()

end
