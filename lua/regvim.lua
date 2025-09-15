-- lua/regvim.lua
-- Simple regex character escaping for Neovim command line

local M = {}

-- Configuration
M.config = {
  enabled = true,
  escape_characters = { "(", ")", "+", "?", "|", "{", "}" },
  show_conversion = false,
  convert_key = '<Tab>',
}
local fallback_match_regex = "[%(%)%+%?|{}]"

local function _should_map(cmdline)
  return cmdline:match("^%s*s/") or cmdline:match("^%s*%%s/") or cmdline:match("^%s*'<,'>s/")
end

local function create_match_regex()
  local chars = {}
  for _, char in ipairs(M.config.escape_characters) do
    table.insert(chars, vim.pesc(char))
  end
  return "[" .. table.concat(chars) .. "]"
end

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
        (cmdtype == ":" and (_should_map(cmdline)))) then
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
  local char_match_regex = fallback_match_regex;

  if #M.config.escape_characters > 0 then
    char_match_regex = create_match_regex();
  end

  if char_before:match(char_match_regex) then
    -- Check if it's already escaped (character before it is \)
    if char_pos == 1 or cmdline:sub(char_pos - 1, char_pos - 1) ~= "\\" then
      needs_escape = true
    end
  end

  if needs_escape then
    -- Insert backslash before the character
    local new_cmdline = cmdline:sub(1, char_pos - 1) .. "\\" .. cmdline:sub(char_pos)
    vim.fn.setcmdline(new_cmdline, cmdpos + 1)

    if M.config.show_conversion then
      vim.schedule(function()
        vim.api.nvim_echo({ { "RegVim: Escaped '" .. char_before .. "' to '\\" .. char_before .. "'", "Comment" } },
          false, {})
      end)
    end
  end
end

local function generate_handle_key()
  vim.keymap.set('c', M.config.convert_key, function()
    M._handle_tab_conversion()
  end, { buffer = false })
  return true
end
-- Set up the key mapping
local function setup_keymap()
  -- Clear any existing autocommands
  vim.api.nvim_create_augroup("RegVim", { clear = true })

  local is_mapped = false
  -- For : commands, watch what they type and map/unmap dynamically
  vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = "RegVim",
    callback = function()
      local cmdtype = vim.fn.getcmdtype()
      if cmdtype == ":" then
        local cmdline = vim.fn.getcmdline()
        local should_map = _should_map(cmdline)
        if should_map and not is_mapped then
          is_mapped = generate_handle_key()
        elseif not should_map and is_mapped then
          pcall(vim.keymap.del, 'c', M.config.convert_key)
          is_mapped = false
        end
      elseif cmdtype == "/" or cmdtype == "?" then
        -- For search modes, always map the key
        if not is_mapped then
          is_mapped = generate_handle_key()
        end
      end
    end,
  })

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = "RegVim",
    callback = function()
      if is_mapped then
        pcall(vim.keymap.del, 'c', M.config.convert_key)
        is_mapped = false
      end
    end,
  })
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
