local telescope = require('telescope')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local previewers = require('telescope.previewers')
local previewer_utils = require('telescope.previewers.utils')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

function upper_first(word)
  return word:gsub("(%a)([%w_']*)", function(first, rest) return first:upper()..rest:lower() end)
end

return telescope.register_extension {
  exports = {
    synonyms = function(opts)
      opts = opts or {}
      local cursor_word = vim.fn.expand("<cword>")
      local command = table.concat({
        "perl ",
        script_path().."/cmd.pl ",
        "synonyms ",
        vim.fn.shellescape(cursor_word)
      })
      local synonyms = vim.fn.systemlist(command) or {}
      table.insert(synonyms, cursor_word:lower())
      pickers.new(opts, {
        prompt_title = upper_first(cursor_word).." Synonyms",
        finder = finders.new_table {
          results = synonyms,
        },
        sorter = sorters.get_substr_matcher(),
        previewer = previewers.new_buffer_previewer({
          define_preview = function(self, entry, status)
            vim.api.nvim_win_set_option(self.state.winid, 'wrap', true)
            vim.api.nvim_win_set_option(self.state.winid, 'lbr', true)
            local cmd = { "perl", script_path().."/cmd.pl", "definitions", entry.value }
            return previewer_utils.job_maker(cmd, self.state.bufnr, {
              callback = function(bufnr, content)
                previewer_utils.highlighter(bufnr, 'yaml')
              end
            })
          end,
          title = "Definition"
        }),
        dynamic_preview_title = true,
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            vim.cmd("normal! ciw" .. selection[1])
            vim.cmd "stopinsert"
          end)
          return true
        end,
      }):find()
    end
  }
}
