--ChatCastLib.lua v1.1.0 by crimew

---@class cclib
local cclib = {}

cclib.keybinds = {}
--cclib.wheelPage = nil
cclib.counter = 0

--intended to be overwrote
cclib.prefix = "&"
cclib.delimiter = "/"
cclib.logging = false
cclib.language = "en" -- only used for logging

--- Returns the figura keybind object from a cclib keybind object
---@param keybind table A cclib keybind
function cclib.getFiguraKeybind(keybind)
    return cclib.keybinds[keybind.id]
end

Lang = {
    en = {
        message_sent_log = "§6sent message §r%s§6 from the following keybind",
        message_fail_prerequisite = "§6The prerequisite function of the following keybind returned false",
        no_message = "§6The following keybind failed; message is nil",
        no_key_warning = "§6The following keybind was built with no key",
        getfunc_fail = "§6.getFunc() called on the following unbuilt keybind. Keybind must be built for getFunc()"
    },
    en_compact = {
        message_sent_log = "§6sent §r%s§6",
        message_fail_prerequisite = "§6precheck failed",
        no_message = "§6no message",
        no_key_warning = "§6no key",
        getfunc_fail = "build keybind before .getFunc()"
    }
}

---@class cckeybind
local cckeybind = {
    __type = "ccKeybind",
    __tostring = function(o) return string.format("cckeybind: %s", o.name or o.key) end,
}

--- I don't know what this does, I just got it off google
function cckeybind:new()
    local o = {
        key=nil,
        message = nil,
        name = nil,
        guiAllow = false,
        postFunc = nil,
        --actionWheel = false,
        numebred = false,
        incrementor = true,
        id = nil,
        preFunc = nil,
		argGen = nil,
        getFunc = function(o)
            local figuraKeybind = cclib.getFiguraKeybind(o)
            if figuraKeybind == nil then
				cclog("getFunc_fail", o)
                --log(Lang[cclib.language]["getfunc_fail"], o)
            end
            return figuraKeybind.press
        end,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

cclib.newKeybind = function()return cckeybind:new()end

function DefaultIfNil(value, default)
    if value == nil then
        return default
    else
        return value
    end
end

function cclog(translation_key, keybind, format_table)
	format_table = format_table or {}
	if cclib.logging then
		log(string.format(Lang[cclib.language][translation_key], table.unpack(format_table)), keybind)
	end
end

-----   Functions for building a keybind and setting it's parameters.   -----

--- Sets the keybind to be used; /figura docs enums keybinds
---@param keypath string The string representing the key to bind
---@return cckeybind self
function cckeybind:setKey(keypath)
    self.key = keypath
    return self
end

--- Sets the keybind to be used with the root key.keyboard; /figura docs enums keybinds
---@param key string The string representing the key on the keyboard to bind
---@return cckeybind self
function cckeybind:setKeyFromKeyboard(key)
    self.key = "key.keyboard."..key
    return self
end

--- Sets the keybind to be used with the root key.mouse; /figura docs enums keybinds
---@param key string The string representing the key on the mouse to bind
---@return cckeybind self
function cckeybind:setKeyFromMouse(key)
    self.key = "key.mouse."..key
    return self
end

--- Sets the message the keybind will send to chat
---@param message string The string to be sent to chat (cclib.prefix will be appended)
---@return cckeybind self
function cckeybind:setMessage(message)
    self.message = message
    return self
end

--- Sets the name of the keybind
---@param name string The name of the keybind. Defaults to the key's name
---@return cckeybind self
function cckeybind:setName(name)
    self.name = name
    return self
end

--- Sets if the keybind can be used in GUIs
---@param guiAllow boolean True if it can be used in a GUI, false if not. Defaults to false
---@return cckeybind self
function cckeybind:setGuiAllow(guiAllow)
    self.guiAllow = guiAllow
    return self
end

--- Sets a function to be run everytime the keybind is pressed
---@param func function The function to ran after a chat cast
---@return cckeybind self
function cckeybind:setPostFunc(func)
    self.postFunc = func
    return self
end

--- Sets the keybind to be added to the action wheel when registered (once registered)
---@param bool boolean|nil sets whether the keybind will be added to the 
--function cckeybind:setActionWheel(bool)
--    self.actionWheel = bool or true
--    return self
--end

--- Sets if the chat cast should have a number appended to the beginning for ID-ing. cclib.delimiter is used to seperate the number and message.
---@param numbered boolean|nil Whether this cast should start with a numeric ID. Default is false, nil results in true.
---@return cckeybind self
function cckeybind:setNumbered(numbered)
    self.numbered = DefaultIfNil(numbered, true)
    return self
end

--- Sets if the the cast ID number is incremented when chat cast is sent
---@param incrementor boolean|nil Whether this cast increments the internal cast counter. Default is true, nil results in a true value.
---@return cckeybind self
function cckeybind:setIncrementor(incrementor)
    self.incrementor = DefaultIfNil(incrementor, true)
    return self
end

--- Sets a function to be run before chat casting. Chat cast will only go through if the function returns true
---@param func function The function to set as a prerequisite to casting
---@return cckeybind self
function cckeybind:setPreFunc(func)
    self.preFunc = func
    return self
end


--- Sets a function to be ran every time a cast is ran with a message. The function should return a table, and each element of that table will be appended to the message, using cclib.delimiter as the delimiter
---@param func function The function that returns a table of arguments for the chat cast
---@return cckeybind self
function cckeybind:setArgGen(func)
	self.argGen = func
	return self
end

--- Adds the keybind
---@return cckeybind self
function cckeybind:build()
    if host:isHost() then
        -- Variables that absolutely need default values.
        local name = tostring(DefaultIfNil(self.name, self.key))
        local postFunc = DefaultIfNil(self.postFunc, function()end)
        local prerequisiteFunc = DefaultIfNil(self.preFunc, function()return true end)
		local argumentGenerator = DefaultIfNil(self.argGen, function()end)

        local keybind = keybinds:newKeybind(name, self.key, self.guiAllow)
        if self.key == nil then
			cclog("no_key_warning", self)
        end

        keybind.press = function()
            local succeededCheck = prerequisiteFunc()
            local arguments = argumentGenerator() or {}
            if succeededCheck then
				if self.message ~= nil then
                	--sends the chat cast with prefix, counter, and massage
                	local chatCast = cclib.prefix..(self.numbered and {tostring(cclib.counter)..cclib.delimiter} or {""})[1]..self.message
                	if #arguments > 0 then
                	    chatCast = chatCast..cclib.delimiter..table.concat(arguments, cclib.delimiter)
                	end
                	host:sendChatMessage(chatCast)

                	--logs the message
					cclog("message_sent_log", self, {chatCast})

                	--increment the counter
                	if self.incrementor then
                    	cclib.counter = cclib.counter + 1
					end
                else
					cclog("no_message", self)
				end

				-- run post func if check succeeded but irregardless if message is defined
				postFunc()

            else
				cclog("message_fail_prerequisite", self)
            end
        end

        table.insert(cclib.keybinds, self)
        self.id = #cclib.keybinds

        --if actionWheel then
        --    if cclib.actionWheel == nil then
        --        cclib.actionWheel = action_wheel:newPage()
        --    end
        --    action_wheel:setPage(cclib.actionWheel)
        --    cclib.actionWheel:newAction()
        --        :title(self.name or keybind:getKeyName())
        --        :setOnLeftClick(keybind.press)
        --end
    end

    return self
end

return cclib
