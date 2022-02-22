**Note:** Active development has moved to https://code.sitosis.com/rudism/telescope-dict.nvim

# telescope-dict.nvim

A [Telescope](https://github.com/nvim-telescope/telescope.nvim) extension that loads a list of synonyms for the word under the cusor in the current buffer, and shows their definition in the preview window. Selecting one of the synonyms replaces the word in the buffer.

![Screenshot](https://raw.githubusercontent.com/wiki/rudism/telescope-dict.nvim/img/screen_shot.png)

## Requirements

These should be available through your package manager (or likely already installed, in the case of `perl`):

- `perl`
- `dictd`: dictionary server
  - `dict-wn`: WordNet dictionary for `dictd`
  - `dict-moby-thesaurus`: Moby Thesaurus dictionary for `dictd`

## Usage

Install with packer (or similar equivalent package manager):

```lua
use 'rudism/telescope-dict.nvim'
```

Bind this to a key and execute it to open the synonym list for the word currently under the cursor:

```lua
require('telescope').extensions.dict.synonyms()
```
