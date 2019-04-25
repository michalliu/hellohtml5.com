---
layout: post
title: Best way to disable capslock delay on mac
categories:
tags: Misc
---
If you google "capslock delay mac", you will see a lot of people is suffering by this **Feature**. And there is no builtin method to turn it off.

Here is my method I'd like to share. May be this is the simplest one you can ever found on the internet and it is totally free! The solution supports all mac versions in theoretical. In my case, I have Sierra (10.12.6).


The Reciepe
-----------

Step 1: Download and install the following software we need.

- [Karabiner](https://pqrs.org/osx/karabiner/)
- [Hammerspoon](https://www.hammerspoon.org/)

Step 2: Use Karabiner maps CapsLock key to F19.

{% include image.html img="karabiner_map.png" attr="width:100%;" %}

Step 3: Edit init.lua under the path `~/.hammerspoon`, paste the code below.

{% highlight lua%}
pressedF19 = function()
end

releasedF19 = function()
	hs.hid.capslock.toggle()
end

hs.hotkey.bind({}, 'F19', pressedF19, releasedF19)

{% endhighlight%}

Reload hammerspoon config for changes to take effect.

{% include image.html img="hammerspoon_reload.png" attr="width:20%;" %}

That's all and we are done.
