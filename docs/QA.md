# Q&A

Questions that come up while following the guide, answered plainly. Distinct from [TROUBLESHOOTING.md](TROUBLESHOOTING.md): that file is for *errors*, this one is for *"wait, why?"*.

---

### Why 3.3.5a and not a modern version of the game?

AzerothCore is a server emulator for **Wrath of the Lich King, client build 12340**. That is the version its entire database and scripting is built around. Newer clients speak a different protocol and authenticate against Battle.net, so they cannot connect to it at all.

### Will WoW Classic work instead?

No. The Classic lines are separate, newer builds and are locked to Battle.net authentication. They cannot be pointed at a private realm.

### Can a Raspberry Pi really run a WoW server?

For **solo play with a small bot party**, comfortably. RAM is not the constraint on a 16 GB Pi 5; CPU is. Playerbots runs AI for every bot on the world loop, so bot count is what decides whether the hardware copes. Three bots is nothing. Three hundred would be a different machine.

### Why is this on ARM at all? Would x86 not be easier?

Considerably easier, yes. The choice here is deliberate: spare hardware, and the fact that ARM64 is the path nobody has documented. If you have x86 hardware and just want to play, use it, and most of this guide still applies apart from the build chapters.

### Do I need to leave the Pi running all the time?

Only when you want to play. It is a server; start it when you want a realm, stop it when you do not. Chapter 10 covers running it as a service if you would rather it just be there.

### Is this legal?

AzerothCore is open-source software and freely available. The **game client** is Blizzard's copyrighted property, and this guide does not distribute it or link to it; obtaining a 3.3.5a client is your own business. This project is not affiliated with Blizzard.

---

*More questions land here as they are asked. If yours is not answered, open an issue.*
