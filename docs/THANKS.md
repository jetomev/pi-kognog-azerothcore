# Thanks

This guide stands on other people's work. None of it — not the server, not the bots, not
the Linux client — would exist without the projects and individuals below. Credit is not a
formality; these are real people who spent real time so the rest of us could do this at all.

For the technical source list and per-source notes, see **[SOURCES.md](SOURCES.md)**.

## Projects

- **[AzerothCore](https://www.azerothcore.org)** ([@azerothcore](https://github.com/azerothcore))
  — the open-source WotLK core this entire guide is built on, and a wiki that taught most of
  what's here. An extraordinary community effort.
- **[mod-playerbots](https://github.com/mod-playerbots/mod-playerbots)**
  ([@mod-playerbots](https://github.com/mod-playerbots)) — the Playerbots fork and module
  that make a *solo* realm worth playing. The heart of this project. Originally the work of
  **[liyunfan1223](https://github.com/liyunfan1223)**, now maintained under the org.
- **[Wine / WineHQ](https://www.winehq.org)** — the compatibility layer that lets a 3.3.5a
  client run natively-enough on Linux, with no Windows anywhere.
- **[DXVK](https://github.com/doitsujin/dxvk)** by **[Philip Rebohle
  (@doitsujin)](https://github.com/doitsujin)** — D3D9→Vulkan translation; the smooth-frames
  layer for the client.
- **[Lutris](https://lutris.net)** ([@lutris](https://github.com/lutris)) — the managed
  runner that makes Wine approachable, and how this project's maintainer first played 3.3.5a
  on Linux.
- **[ChromieCraft](https://chromiecraft.com)** — for a clean 3.3.5a client and years of
  keeping WotLK alive and well-run.

## Individual writers

- **[sebyx07](https://github.com/sebyx07)** — for the current (Jan 2026) Wine + DXVK gist
  that shaped this guide's recommended client setup.
- **The MangosRumors team** ([mangosrumors.org](https://www.mangosrumors.org)) — for an
  early, plain how-to that still works as a first smoke test.
- **The Warmane community** ([forum.warmane.com](https://forum.warmane.com)) — for the
  Arch/CachyOS play notes and hard-won distro gotchas.

## Following, if you'd like

Following a maintainer on GitHub is a small, genuine way to say thanks and keep up with
their work. These are the handles above, gathered for convenience:

`@azerothcore` · `@mod-playerbots` · `@liyunfan1223` · `@doitsujin` · `@lutris` ·
`@sebyx07`

You can follow from each profile page, or with the `gh` CLI, e.g.:

```
gh api -X PUT /user/following/mod-playerbots
gh api -X PUT /user/following/liyunfan1223
```

*(Following is a change to **your** account — do it deliberately, per person. Nothing here
does it for you.)*

---

*Did we miss someone whose work is in these pages? That's a bug. Open an issue and we'll
add them.*
