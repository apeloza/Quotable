-- Create a new Ace3 module
Quotable = LibStub("AceAddon-3.0"):NewAddon("Quotable", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0");

local MAX_QUOTE_LENGTH = 200

local options = {
    name = "Quotable",
    handler = Quotable,
    type = 'group',
    args = {
        show = {
            type="execute",
            name="Show",
            desc = "Opens the Quotable window.",
            func="Show",
        }
    },
}

function Quotable:OnEnable()
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Quotable", options, {"quotable", "quote"})
    Quotable.DrawMainFrame();
    Quotable:RegisterEvent("PLAYER_LOGOUT", Quotable.SetFrameLocation);

end


function Quotable:OnInitialize()
    -- Database setup
    local defaults = {
        global = {
            channel = 'PARTY',
            position = 'CENTER',
            xOfs = 0,
            yOfs = 0,
            quotes = {},
        }
    }
    -- Assuming the .toc says ## SavedVariables: QuotableDB
    Quotable.db = LibStub("AceDB-3.0"):New("QuotableDB", defaults, true);
end

function Quotable:Speak(author)
    if(#Quotable.db.global.quotes ~= 0) then
        local quote, format

        -- Check for author (will be passed as event/"OnClick" if there is no author)
        if author and author ~= "OnClick" then
            quote = Quotable:Random(author)
        else
            quote = Quotable:Random()
        end

        if Quotable:is_present(quote.author) and Quotable:is_present(quote.date) then
            format = "\"{quote}\" - {author}, {date}"
        elseif Quotable:is_present(quote.author) then
            format = "\"{quote}\" - {author}"
        elseif Quotable:is_present(quote.date) then
            format = "\"{quote}\" - {date}"
        else
            format = "\"{quote}\""
        end

        local formatted_quote = Quotable:replace_vars(format, quote)
        SendChatMessage(formatted_quote, Quotable.db.global.channel);
    else
        Quotable:Print('ERROR: No quotes are in the database. Use /quote save to add quotes!');
    end
end

--Returns a random quote from the quote DB
function Quotable:Random(author)
    local db
    if author then
        db = Quotable:GetAuthorQuotes(author)
    else
        db = Quotable.db.global.quotes
    end
    local number = math.random(#db)
    return db[number];
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
    Quotable.channel_heading:SetText('Channel: ' .. newValue);
end

function Quotable:ListQuotes(info)
    local quote_list = {}
    for i in pairs(Quotable.db.global.quotes) do
        table.insert(quote_list, Quotable.db.global.quotes[i].name)
    end
    Quotable:Print(table.concat(quote_list, ", "))
end

function Quotable:Show()
    if(Quotable.main_frame == nil) then
        Quotable:DrawMainFrame();
    end
end

function Quotable:SetFrameLocation()
    local point, relativeTo, relativePoint, xOfs, yOfs = Quotable.main_frame:GetPoint()
    Quotable.db.global.position  = point;
    Quotable.db.global.xOfs = xOfs;
    Quotable.db.global.yOfs = yOfs;
end

--called to draw the frame into existence/update the frame as needed
function Quotable:DrawMainFrame()
    local AceGUI = LibStub("AceGUI-3.0")
    -- Create a container frame
    local f = AceGUI:Create("Frame")
    f:SetCallback("OnClose", Quotable.OnMainFrameClose)
    f:SetTitle("Quotable")
    f:SetLayout("List")
    f:SetWidth(250);
    f:SetHeight(400);
    f:SetStatusText("v.0.1")
    f:EnableResize(false)

    -- Random! Button
    local btn = AceGUI:Create("Button");
    btn:SetFullWidth(true);
    btn:SetText("Random Quote!");
    btn:SetCallback("OnClick", Quotable.Speak)
    f:AddChild(btn);

    -- Per-author buttons
    local authors = Quotable:GetAuthors()
    for author, _ in pairs(authors) do
        local btn_author = AceGUI:Create("Button")
        btn_author:SetFullWidth(true)
        btn_author:SetText("Random From: " .. author)
        btn_author:SetCallback("OnClick", function() Quotable:Speak(author) end)
        f:AddChild(btn_author)
    end



    -- New Quote
    local btn_new = AceGUI:Create("Button")
    btn_new:SetFullWidth(true);
    btn_new:SetText("New Quote")
    btn_new:SetCallback("OnClick", Quotable.NewQuoteOpenWindow)

    -- Manage Quotes
    local btn_manage = AceGUI:Create("Button")
    btn_manage:SetFullWidth(true);
    btn_manage:SetText("Manage Quotes")
    btn_manage:SetCallback("OnClick", Quotable.ManageQuotesOpenWindow)

    -- Change output channel
    local channelDropdown = AceGUI:Create("Dropdown");
    local channelOptions = {PARTY = 'Party', RAID = 'Raid', GUILD = 'Guild'};
    channelDropdown:SetFullWidth(true);
    channelDropdown:SetList(channelOptions);
    channelDropdown:SetText(channelOptions[Quotable.db.global.channel]);
    channelDropdown:SetLabel('Output Channel');
    channelDropdown:SetCallback("OnValueChanged", Quotable.SetOutput)

    -- Current channel divider
    local currentChannel = AceGUI:Create("Heading");
    currentChannel:SetFullWidth(true);
    currentChannel:SetText('Channel: ' .. channelOptions[Quotable.db.global.channel]);
    f:AddChild(currentChannel);
    f:AddChild(btn_new);
    f:AddChild(btn_manage);
    f:AddChild(channelDropdown);

    Quotable.channel_heading = currentChannel;

    Quotable.main_frame = f;

    -- Snap frame to saved position
    f:SetPoint(Quotable.db.global.position, Quotable.db.global.xOfs, Quotable.db.global.yOfs);
end

function Quotable:OnMainFrameClose()
    local AceGUI = LibStub("AceGUI-3.0")

    Quotable.SetFrameLocation()
    AceGUI:Release(Quotable.main_frame)
    Quotable.main_frame = nil
end

--DESTRUCTIVE
function Quotable:EraseAll(info)
    Quotable.db.global.quotes = {};
    Quotable:ManageQuotesPopulateQuoteList();
end

-- Returns a list of unique quote authors as keys
function Quotable:GetAuthors()
    local authors = {}
    for _, v in pairs(Quotable.db.global.quotes) do
        if v.author ~= nil and v.author ~= "" then
            authors[v.author] = true
        end
    end
    return authors
end

-- Returns all quotes by a specific author
function Quotable:GetAuthorQuotes(author)
    local quotes = {}
    for _, v in pairs(Quotable.db.global.quotes) do
        if v.author == author then
            table.insert(quotes, v)
        end
    end
    return quotes
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
    submit:SetCallback("OnClick", Quotable.NewQuoteSubmit)
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
    local new_quote = {
        quote = Quotable.add_form.input_quote:GetText(),
        author = Quotable.add_form.input_author:GetText(),
        date = Quotable.add_form.input_date:GetText()
    }
    -- TODO: Serialize tags, separated by commas
    table.insert(Quotable.db.global.quotes, new_quote)
    Quotable:ManageQuotesPopulateQuoteList();
    Quotable:Print("Quote saved!")
    -- TODO: Programmatically close form
end

---------------------------
-- MODULE: MANAGE QUOTES
---------------------------

function Quotable:ManageQuotesOpenWindow()
    local AceGUI = LibStub("AceGUI-3.0")

    -- Create a container frame
    local f = AceGUI:Create("Frame")
    f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)
    f:SetTitle("Manage Quotes")
    f:SetLayout("List")
    f:SetHeight(300)
    f:SetWidth(500)
    f:EnableResize(false)

    -- TODO: Search bar

    local header_container = AceGUI:Create("SimpleGroup")
    header_container:SetFullWidth(true)
    header_container:SetHeight(20)
    header_container:SetLayout("Flow")

    local header_number = AceGUI:Create("Label")
    header_number:SetText("#")
    header_number:SetColor(1, .756, .145)
    header_number:SetRelativeWidth(.05)

    local header_quote = AceGUI:Create("Label")
    header_quote:SetText("Quote")
    header_quote:SetColor(1, .756, .145)
    header_quote:SetRelativeWidth(.5)

    local header_author = AceGUI:Create("Label")
    header_author:SetText("Author")
    header_author:SetColor(1, .756, .145)
    header_author:SetRelativeWidth(.45)

    header_container:AddChild(header_number)
    header_container:AddChild(header_quote)
    header_container:AddChild(header_author)

    -- Quote list
    local scroll_container = AceGUI:Create("SimpleGroup")
    scroll_container:SetFullWidth(true)
    scroll_container:SetHeight(220)
    scroll_container:SetLayout("Fill")

    -- Delete All Button
    local delete_all = AceGUI:Create("Button");
    delete_all:SetText("Delete All")
    delete_all:SetRelativeWidth(.225)
    delete_all:SetCallback("OnClick", Quotable.EraseAll);

    Quotable.db.global.manage_quotes = {scroll_container = scroll_container}

    Quotable:ManageQuotesPopulateQuoteList()

    f:AddChild(header_container)
    f:AddChild(scroll_container)
    f:AddChild(delete_all)
end

function Quotable:ManageQuotesPopulateQuoteList()
    local AceGUI = LibStub("AceGUI-3.0")

    Quotable.db.global.manage_quotes.scroll_container:ReleaseChildren()

    local scroll = AceGUI:Create("ScrollFrame")
    Quotable.db.global.manage_quotes.scroll_container:AddChild(scroll)

    -- Add quotes to list
    for i, q in ipairs(Quotable.db.global.quotes) do
        local row = AceGUI:Create("SimpleGroup")
        row:SetLayout("Flow")
        row:SetFullWidth(true)

        local label_number = AceGUI:Create("Label")
        label_number:SetText(i)
        label_number:SetRelativeWidth(.05)

        local label_quote = AceGUI:Create("Label")
        label_quote:SetText(q.quote)
        label_quote:SetRelativeWidth(.5)

        local label_author = AceGUI:Create("Label")
        label_author:SetText(q.author)
        label_author:SetRelativeWidth(.2)

        local edit_btn = AceGUI:Create("Button")
        edit_btn:SetText("Edit")
        edit_btn:SetRelativeWidth(.125)

        local delete_btn = AceGUI:Create("Button")
        delete_btn:SetText("Del")
        delete_btn:SetRelativeWidth(.125)
        delete_btn:SetCallback("OnClick", function() Quotable:DeleteQuote(i) end)

        row:AddChild(label_number)
        row:AddChild(label_quote)
        row:AddChild(label_author)
        row:AddChild(edit_btn)
        row:AddChild(delete_btn)

        scroll:AddChild(row)
    end
end

function Quotable:DeleteQuote(id)
    table.remove(Quotable.db.global.quotes, id)
    Quotable:ManageQuotesPopulateQuoteList()
end

------------------------
--- UTILITY FUNCTIONS
------------------------

function Quotable:replace_vars(str, vars)
    -- Allow replace_vars{str, vars} syntax as well as replace_vars(str, {vars})
    if not vars then
        vars = str
        str = vars[1]
    end
    return (string.gsub(str, "({([^}]+)})",
        function(whole,i)
            return vars[i] or whole
        end))
end

function Quotable:is_present(str)
    return str ~= nil and str ~= ''
end
