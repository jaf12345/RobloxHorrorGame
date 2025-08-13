Protocol: Ascend is a game made on ROBLOX STUDIO

This project uses [Rojo](https://rojo.space/) to sync local files with Roblox Studio. All scripts, modules, and local scripts are stored in `src/` and synced automatically.

**Do not create scripts directly in Roblox Studio.** They will not sync to GitHub. Only create scripts in VS Code.

Install Roblox Studio at: https://create.roblox.com/

# Rojo Setup (ALWAYS DO STEP 5, 7 and 8)
1) Get the toolkit at: https://github.com/rojo-rbx/rokit or type the line below for windows

Invoke-RestMethod https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.ps1 | Invoke-Expression

2) Restart your computer
3) Open VS Code and install the extensions "Luau Language Server" and "Rojo - Roblox Studio Sync"
4) Open this folder in VS Code make sure the folder is ./ROBLOXHORRORGAME/
5) Hold CTRL+SHIFT+P and search 'rojo'
6) Click 'Rojo: Open Menu' then click 'Install Roblox Studio Plugin'
7) In the same Rojo menu click the green play button (Make sure to do this everytime you start VS Code)
8) Open Roblox Studio, Click File > Open From File > path/to/ROBLOXHORRORGAME/ProtocolAscend. Click the Plugins tab, Rojo, then click 'Connect'

## INFORMATION ABOUT WHAT SCRIPTS TO USE AND FOLDERS TO PLACE SCRIPTS IN HERE ##

## Roblox Services Overview

- **ReplicatedStorage**: Shared storage accessible by both client and server. Ideal for ModuleScripts, shared configs, and assets.  
- **ServerScriptService**: Server-only scripts. Cannot be accessed by players, runs on the server.  
- **StarterPlayerScripts**: LocalScripts that run on the client when the player joins or respawns.  
- **StarterCharacterScripts**: LocalScripts that are cloned into each player’s character model.

## Script Types

| Type            | Runs On       | File Extension / Naming                 |
|-----------------|---------------|-----------------------------------------|
| **Script**      | Server        | `.server.luau`                          |
| **LocalScript** | Client        | `.client.luau`                          |
| **ModuleScript**| Both / Shared | `.luau`                                 |

Example: Coins.server.luau → Script named `Coins` that runs on the Server
Example: Camera.client.luau → LocalScript named `Camera` that runs on the Client