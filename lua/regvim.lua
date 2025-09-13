-- lua/regvim.lua
-- Simple regex character escaping for Neovim command line

local M = {}

-- Configuration
M.config = {
  enabled = true,
  show_conversion = false,
  convert_key = '<Tab>',
}

-- Handle Tab key conversion - escape only the character before cursor
function M._handle_tab_conversion()
  if not M.config or not M.config.enabled then
    return
  end

  local cmdtype = vim.fn.getcmdtype()
  local cmdline = vim.fn.getcmdline()
  local cmdpos = vim.fn.getcmdpos()

  -- Only work in search and substitute contexts
  if not (cmdtype == "/" or cmdtype == "?" or
          (cmdtype == ":" and (cmdline:match("^%s*s/") or cmdline:match("^%s*%%s/")))) then
    return
  end

  if not cmdline or cmdline == "" or cmdpos <= 1 then
    return
  end

  -- Get character before cursor (cursor is 1-indexed)
  local char_pos = cmdpos - 1
  local char_before = cmdline:sub(char_pos, char_pos)

  -- Check if it's a character that needs escaping and isn't already escaped
  local needs_escape = false
  if char_before:match("[%(%)%+%?|{}]") then
    -- Check if it's already escaped (character before it is \)
    if char_pos == 1 or cmdline:sub(char_pos - 1, char_pos - 1) ~= "\\" then
      needs_escape = true
    end
  end

  if needs_escape then
    -- Insert backslash before the character
    local new_cmdline = cmdline:sub(1, char_pos - 1) .. "\\" .. cmdline:sub(char_pos)
    vim.fn.setcmdline(new_cmdline)
    -- Move cursor forward by 1 to account for the added backslash
    vim.fn.setcmdpos(cmdpos + 1)

    if M.config.show_conversion then
      vim.schedule(function()
        vim.api.nvim_echo({{"RegVim: Escaped '" .. char_before .. "' to '\\" .. char_before .. "'", "Comment"}}, false, {})
      end)
    end
  end
end

-- Set up the key mapping
local function setup_keymap()
  -- Clear any existing autocommands
  vim.api.nvim_create_augroup("RegVim", { clear = true })

  -- Set up key mapping for character escaping in command mode
  vim.cmd(string.format([[
    cnoremap %s <Cmd>lua require("regvim")._handle_tab_conversion()<CR>
  ]], M.config.convert_key))
end

-- Initialize RegVim
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)
  setup_keymap()
end

-- Toggle RegVim on/off
function M.toggle()
  M.config.enabled = not M.config.enabled
  local status = M.config.enabled and "enabled" or "disabled"
  print("RegVim " .. status)
end

-- Enable RegVim
function M.enable()
  M.config.enabled = true
  print("RegVim enabled")
end

-- Disable RegVim
function M.disable()
  M.config.enabled = false
  print("RegVim disabled")
end

return M
