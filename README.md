## QtShadow - Nvidia Shadowplay on Wayland? + AMD ;)

Quickshell overlay for controlling OBS >30 via websocketv5.
Specify your websocket key with env variable `WSKEY=123456`,
as well as your websocket port `WSPORT=4455`.

Card options `NVIDIACARD=1` or `AMDCARD=1`
(purely aesthetic, functionally the same... for now)

and finally your `OBSCMD=com.obsproject.Studio`

Built w/ Quickshell, big thanks to outfoxxed!
https://git.outfoxxed.me/outfoxxed/quickshell

Make sure the icons reside in the same directory as qml document.

Why? because I felt like it.

**Features:**

- Launch OBS
- Toggle recording
- Toggle streaming
- Toggle replay buffer

#### Roadmap:

- Scene selection
- Card usage statistics
- Gallery
- Quickmenu

#### Dependencies:

```
quickshell
yay -S --needed qt5-graphicaleffects qt6ct qt6-shadertools obs-cmd
flatpak install com.obsproject.Studio
```

#### Setup:

Open OBS, Tools > Websocket Server Settings
Enable WebSocket server and set server password
Create a scene with your source of choice. When
monitor or source select prompt pops up make sure
to check "Allow restore token".

_Optionally: Settings > General > System Tray > Enable & Minimize to tray when started_

```
mv qtshadow ~/.config/quickshell/
```

_Hyprland: toggle / bindr and layerrules_

```
layerrule = blur, qtshadow
layerrule = ignorezero, qtshadow
layerrule = animation slide, qtshadow

bindr = SUPERSHIFT, Q, exec, pkill quickshell || NVIDIACARD=1 WSKEY=123456 quickshell --config ~/.config/quickshell/qtshadow/shell.qml 2>/dev/null &
```
