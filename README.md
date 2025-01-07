# ChatCastLib v1.0.1
A Figura library for assisting in quickly creating chat casting for Hex Casting.

# Getting Started
  First enable your figura avatars to send chat messages by going into the figura settings and enabling `Chat Messages` under the `Dev` section near the bottom. Then, download the [cclib.lua](https://github.com/candyCalc/cclib/blob/a77ced1e2768a9792c8a46201f22b64265cc805c/cclib.lua) file and place it in your avatar's folder. In your avatar's `script.lua` file, put the following line near the top

```lua
local cclib = require("cclib")
```

We can now create our first keybind. New keybinds are created with `cclib.newKeybind` like so:

```lua
local myKeybind = cclib.newKeybind()
```

From here we can add parameters to our keybind. Here we will just be adding a message to send and a key to press.

```lua
local myKeybind = cclib.newKeybind()
  :setKey("key.keyboard.g")
  :setMessage("Hello world!")
```

Finally keybinds must be built. A keybind that hasn't been built will not activate when pressed. Building a keybind submits it to figura's keybind system. Our `script.lua` file should now look something like this
```lua
local cclib = require("cclib")

local myKeybind = cclib.newKeybind()
  :setKey("key.keyboard.g")
  :setMessage("Hello world!")
  :build()
```
And we're done! When you press `g` in game, the message `&Hello world!` should be sent!

# Global Variables

`cclib` contains four values meant to be overwrote and two that are not.

### prefix
  `cclib.prefix` is the string placed in front of all sent messages, intended to be used with [Sifter's Gambit](https://talia-12.github.io/MoreIotas/#patterns/strings@moreiotas:string/chat/prefix/set). It is initialized to `&`. To change it, simply set the variable to your desired string:
```lua
cclib.prefix = "your string here"
```
<br />

### delimiter
  `cclib.delimiter` is the string used to seperate a cast's numeric id from the message. This only appears if a keybind is set to [numbered](link here). It is initialized to `/`. To change it, simply set the variable to your desired string:
```lua
cclib.delimiter = "your delimiter here"
```
<br />

### logging
  `cclib.logging` is a boolean that determines if cclib should log extra information that can be useful in debugging. It is initialized to `false` and can be enabled by setting the value to true:
```lua
cclib.logging = true
```
<br />

### language
  `cclib.language` is a string that identifies which language to use when loggging. Currently there is only `en` and `en_compact`. It is initialized to `en` and can be changed trivially:
```lua
cclib.language = "en_compact"
```
<br />

### keybinds
  `cclib.keybinds` is a table containing all built keybinds.
<br />

### counter
  `cclib.counter` is the integer used in a cast's numeric id when [numbered](link here) is enabled.
<br />

# cckeybind Class

The `cckeybind` class is where all the magic happens. This is the class that is returned from `cclib.newKeybind()` and the one containing all of the methods used to customize a keybind.

## Methods
A `cckeybind` object has 11 methods used to change it's values, each being called with colon function notation and returning itself as to be chained together.

TODO: finish docs lmoa. Refer to cclib.lua in the meantime

## Values
cckeybinds have 9 values
