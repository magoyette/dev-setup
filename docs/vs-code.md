# VS Code Setup

My personal VS Code setup.

## Tasks

- TODO Add shortcuts for Java: Go to test and Run Tests in Current File and Run Test at Cursor

## Extensions

- [Astro](https://marketplace.visualstudio.com/items?itemName=astro-build.astro-vscode)
- [Claude Code for VS Code](https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code)
- [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker)
  - [French - Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker-french)
- [Container Tools](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-containers)
- [Debugger for Firefox](https://marketplace.visualstudio.com/items?itemName=firefox-devtools.vscode-firefox-debug)
- [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
- [Docker DX](https://marketplace.visualstudio.com/items?itemName=docker.docker)
- [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
- [Git Blame](https://marketplace.visualstudio.com/items?itemName=waderyan.gitblame)
- [GitHub Theme](https://marketplace.visualstudio.com/items?itemName=GitHub.github-vscode-theme)
- [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)
- [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
- [Material Icon Theme](https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme)
- [MDX](https://marketplace.visualstudio.com/items?itemName=unifiedjs.vscode-mdx)
- [npm Intellisense](https://marketplace.visualstudio.com/items?itemName=christian-kohler.npm-intellisense)
- [Path Intellisense](https://marketplace.visualstudio.com/items?itemName=christian-kohler.path-intellisense)
- [Playwright Test for VSCode](https://marketplace.visualstudio.com/items?itemName=ms-playwright.playwright)
- [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
- [Project Manager](https://marketplace.visualstudio.com/items?itemName=alefragnani.project-manager)
- [ShellCheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck)
- [Stylelint](https://marketplace.visualstudio.com/items?itemName=stylelint.vscode-stylelint)
- [Tailwind CSS IntelliSense](https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss)
- [Todo Tree](https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.todo-tree)
- [WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)
- [YAML](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)

## Settings

Apply the following user settings.

```json
{
  "cSpell.ignoreRegExpList": ["/\\w+([0-9]+\\w*)+/"],
  "cSpell.language": "en,fr",
  "cSpell.enableFiletypes": ["!json", "!mjs", "!cjs"],
  "diffEditor.renderSideBySide": false,
  "diffEditor.experimental.showMoves": true,
  "diffEditor.hideUnchangedRegions.enabled": true,
  "editor.minimap.enabled": false,
  "editor.fontFamily": "'DejaVu Sans Mono', 'Droid Sans Mono', 'monospace', monospace, 'Droid Sans Fallback'",
  "editor.fontSize": 16,
  "editor.lineHeight": 20,
  "editor.guides.bracketPairs": true,
  "extensions.ignoreRecommendations": false,
  "files.trimTrailingWhitespace": true,
  "git.closeDiffOnOperation": true,
  "javascript.updateImportsOnFileMove.enabled": "always",
  "editor.inlayHints.enabled": "on",
  "typescript.inlayHints.parameterNames.enabled": "all",
  "javascript.inlayHints.parameterNames.enabled": "all",
  "telemetry.telemetryLevel": "off",
  "terminal.integrated.defaultProfile.windows": "Git Bash",
  "workbench.editor.enablePreview": false,
  "workbench.enableExperiments": false,
  "workbench.iconTheme": "material-icon-theme",
  "workbench.startupEditor": "newUntitledFile",
  "prettier.documentSelectors": ["**/*.astro"],
  "[astro]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[html]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[jsonc]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[markdown]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true,
    "files.trimTrailingWhitespace": false
  },
  "[mdx]": {
    "editor.wordWrap": "on"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
  "editor.linkedEditing": true,
  "[css]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "todo-tree.general.tags": [
    "IDEA",
    "READ",
    "TODO",
    "NEXT",
    "DOING",
    "READING",
    "STARTED",
    "WAIT",
    "DONE"
  ],
  "todo-tree.highlights.defaultHighlight": {
    "fontWeight": "bold"
  },
  "todo-tree.highlights.customHighlight": {
    "READ": {
      "foreground": "#bc4c00"
    },
    "IDEA": {
      "foreground": "#bc4c00"
    },
    "TODO": {
      "foreground": "#bc4c00"
    },
    "NEXT": {
      "foreground": "#0969da"
    },
    "DOING": {
      "foreground": "#8250df"
    },
    "STARTED": {
      "foreground": "#8250df"
    },
    "READING": {
      "foreground": "#8250df"
    },
    "WAIT": {
      "foreground": "#57606a"
    },
    "DONE": {
      "foreground": "#1a7f37"
    }
  },
  "projectManager.git.baseFolders": ["*****TODO Add folder of projects*****"],
  "projectManager.git.ignoredFolders": ["node_modules", "archives"],
  "redhat.telemetry.enabled": false,
  "playwright.reuseBrowser": false,
  "playwright.showTrace": false,
  "workbench.colorTheme": "One Dark Pro",
  "claudeCode.preferredLocation": "panel",
  "claudeCode.useTerminal": true,
  "remote.extensionKind": {
    "alefragnani.project-manager": ["workspace"]
  }
}
```

## Keybindings (for Windows)

```json
[
  {
    "key": "ctrl+alt+i",
    "command": "bookmarks.toggleLabeled"
  },
  {
    "key": "ctrl+alt+o",
    "command": "bookmarks.list"
  },
  {
    "key": "ctrl+alt+u",
    "command": "bookmarks.listFromAllFiles"
  },
  {
    "key": "ctrl+alt+oem_period",
    "command": "cSpell.addWordToWorkspaceSettings"
  },
  {
    "key": "tab",
    "command": "editor.toggleFold",
    "when": "editorLangId == 'markdown' && editorTextFocus && foldingEnabled"
  },
  {
    "key": "ctrl+k ctrl+l",
    "command": "-editor.toggleFold",
    "when": "editorTextFocus && foldingEnabled"
  },
  {
    "key": "ctrl+shift+alt+p",
    "command": "projectManager.listProjectsNewWindow"
  },
  {
    "key": "alt+x",
    "command": "editor.action.openLink"
  }
]
```

### Views and Commands

| Keybinding               | Command                    |
| ------------------------ | -------------------------- |
| Ctrl+Shift+P             | Command Palette            |
| Ctrl+,                   | Settings                   |
| Ctrl+Shift+E             | Explorer view              |
| Ctrl+Shift+G             | Source control view        |
| Ctrl+`                   | Terminal panel             |
| Ctrl+PgUp or Ctrl+PgDown | Focus on next editor group |

### Files and Navigation

| Keybinding                 | Command                                                |
| -------------------------- | ------------------------------------------------------ |
| Ctrl+R                     | Open recent folders or files                           |
| Shift+Alt+P                | Open a project (Project Manager extension)             |
| Ctrl+P                     | Open a file by name                                    |
| Ctrl+Tab or Ctrl+Shift+Tab | Select next or previous file in a list of opened files |
| Alt+Right or Alt+Left      | Go to next or previous edit location                   |
| F12 or Ctrl+Click          | Go to the definition of a symbol                       |
| Ctrl+F12                   | Go to implementation                                   |
| Alt+F12                    | Peek definition of symbol                              |
| Ctrl+F12                   | Go to implementation of a symbol                       |
| Ctrl+P then #              | Search symbol in workspace (or Ctrl+T)                 |
| Ctrl+P then @              | Search symbol in file (or Ctrl+Shift+O)                |
| Shift+Alt+F12              | Find references                                        |
| F8 or Shift+F8             | Go to next or previous problem                         |
| Ctrl+Up or Ctrl+Down       | Scroll line up or down                                 |
| Alt+X                      | Open link                                              |

### Java

| Keybinding      | Command                         |
| --------------- | ------------------------------- |
| Ctrl+Shift+P    | Java: Go to Test                |
| Ctrl+P then #@/ | Spring Boot request mappings    |
| Ctrl+P then #@+ | Spring Boot defined beans       |
| Ctrl+P then #@> | Spring Boot functions           |
| Ctrl+P then #@  | Spring Boot annotations in code |

### Edition

| Keybinding                        | Command                                                                          |
| --------------------------------- | -------------------------------------------------------------------------------- |
| Ctrl+.                            | Quick fix and refactoring for the current problem                                |
| F2                                | Rename symbol                                                                    |
| Ctrl+Shift+Alt+(arrow key)        | Column (box) selection                                                           |
| Shift+Alt+Right or Shift+Alt+Left | Expand or shrink current selection                                               |
| Alt+Up or Alt+Down                | Move line up or down                                                             |
| Ctrl+Shift+K                      | Delete line                                                                      |
| Ctrl+Enter or Ctrl+Shift+Enter    | Insert line below or above                                                       |
| Ctrl+Space                        | Intellisense                                                                     |
| Shift+Alt+F                       | Format file                                                                      |
| Alt+Click                         | Add a cursor to the multiple cursors                                             |
| Ctrl+Alt+Down                     | Add cursor below to the multiple cursors                                         |
| Ctrl+Alt+Up                       | Add cursor above to the multiple cursors                                         |
| Ctrl+Alt+.                        | Add word to code spell checker workspace settings (Code Spell Checker extension) |
| Ctrl+Delete                       | Delete to Word End                                                               |
| Ctrl+Backspace                    | Delete to Word Start                                                             |
| Alt+Shift+Down                    | Duplicate line                                                                   |
| Ctrl+Shift+R                      | Refactor                                                                         |

### Search

| Keybinding   | Command                                                              |
| ------------ | -------------------------------------------------------------------- |
| Ctrl+F       | Search in current editor (navigate results with Enter & Shift+Enter) |
| F3           | Go to next search result                                             |
| Shift+F3     | Go to previous search result                                         |
| Ctrl+H       | Replace in current editor                                            |
| Ctrl+Shift+F | Search all files in current folder                                   |

### Bookmarks

| Keybinding | Command                   |
| ---------- | ------------------------- |
| Ctrl+Alt+K | Toggle bookmark           |
| Ctrl+Alt+I | Toggle labeled bookmark   |
| Ctrl+Alt+L | Jump to next bookmark     |
| Ctrl+Alt+J | Jump to previous bookmark |
| Ctrl+Alt+O | List bookmarks            |
| Ctrl+Alt+U | List from all files       |

### Markdown

| Keybinding   | Command                                    |
| ------------ | ------------------------------------------ |
| Ctrl+Shift+V | Switch between Markdown editor and preview |
| Ctrl+K V     | Open preview on the side                   |
| Alt+Shift+F  | Format Markdown table                      |
| Tab          | Toggle fold of the current region          |
| Ctrl+B       | Toggle bold                                |
| Ctrl+I       | Toggle italic                              |
