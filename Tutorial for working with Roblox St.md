## **Tutorial for working with Roblox Studio and GitHub**

By Sujal Chand - why is it so hard? idk...



GitHub link: [https://github.com/jaf12345/RobloxHorrorGame](https://github.com/jaf12345/RobloxHorrorGame)

Link to download Roblox Studio: [https://create.roblox.com/](https://create.roblox.com/)  (make sure you also make a Roblox account) 

> Assuming you have your GitHub account created, download GitHub Desktop from: \\\[https://desktop.github.com/download/](https://desktop.github.com/download/) (if you don't have Git, get it here: \\\[https://git-scm.com/downloads](https://git-scm.com/downloads)

> Open GitHub Desktop and click File > Options, make sure you sign in to GitHub in order to pull/push commits.

> Click File > Clone Repository > GitHub.com > jaf12345/RobloxHorrorGame | REMEMBER THE \*\*LOCAL PATH\*\* YOU CLONE TO AS \*\*YOU WILL NEED IT LATER\*\*



> Go to \\\[https://code.visualstudio.com/](https://code.visualstudio.com/) to install VS Code.

> Next, you will ned Rokit, this is a toolchain manager for Roblox projects, you can get it from \\\[https://github.com/rojo-rbx/rokit](https://github.com/rojo-rbx/rokit); If you're on windows run the below command in PowerShell to install it

Invoke-RestMethod https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.ps1 | Invoke-Expression

> Restart your PC as it needs your PATH file to be updated, trust me i am not trying to get you hacked.. (you'll know you installed it correctly by running \*\*rokit --version\*\* and seeing something like: rokit 1.0.0)



Now we will be looking at extensions needed for VS Code

> Open VS Code and click the bottom icon (looks like 3 squares with a tilted square)

> Search 'Luau Language Server' - Install this

> Search 'Rojo - Roblox Studio Sync' - Install this

> Click File > Open Folder > path/to/folder/you/cloned (make sure the folder is .../ROBLOXHORRORGAME/)

> Hold CTRL+SHIFT+P and search 'rojo'. Click 'Rojo: Open Menu'

> Click 'Install Roblox Studio Plugin' 

> **Hold CTRL+SHIFT+P and search 'rojo'. Click 'Rojo: Open Menu' Click the green play symbol (Do this step every time)**

> Open Roblox Studio, Click File > Open From File > path/to/ROBLOXHORRORGAME/ProtocolAscend. 

> **Click the Plugins tab, Rojo, then click 'Connect' (Do this step every time)**

If you're making scripts, Please Read the README.md file too, it is very important. DO NOT MAKE SCRIPTS ON STUDIO. THEY WILL NOT SYNC TO GITHUB AND WILL BE LOST