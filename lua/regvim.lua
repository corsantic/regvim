-- lua/regvim.lua
-- Real-time regex conversion for Neovim command line

local M = {}

-- Configuration
M.config = {
  enabled = true,
  auto_convert = true,
  show_conversion = false, -- Show conversion messages
}

-- Track if we're currently converting to avoid infinite loops
local converting = false

-- Convert extended regex patterns to Vim basic regex
local function convert_extended_to_basic(text)
  if not text or text == "" then
    return text
  end

  local result = text

  -- Convert unescaped parentheses: ( -> \(, ) -> \)
  result = result:gsub("([^\\])%(", "%1\\(")
  result = result:gsub("^%(", "\\(")
  result = result:gsub("([^\\])%)", "%1\\)")
  result = result:gsub("^%)", "\\)")

  -- Convert unescaped braces: { -> \{, } -> \}
  result = result:gsub("([^\\]){", "%1\\{")
  result = result:gsub("^{", "\\{")
  result = result:gsub("([^\\])}", "%1\\}")
  result = result:gsub("^}", "\\}")

  -- Convert unescaped plus: + -> \+
  result = result:gsub("([^\\])%+", "%1\\+")
  result = result:gsub("^%+", "\\+")

  -- Convert unescaped question mark: ? -> \?
  result = result:gsub("([^\\])%?", "%1\\?")
  result = result:gsub("^%?", "\\?")

  -- Convert unescaped pipe: | -> \|
  result = result:gsub("([^\\])|", "%1\\|")
  result = result:gsub("^|", "\\|")

  return result
end

-- Check if we should convert based on command type and context
local function should_convert(cmdtype, cmdline)
  if not M.config.enabled or not M.config.auto_convert then
    return false
  end

  -- Convert in search mode (/ and ?)
  if cmdtype == "/" or cmdtype == "?" then
    return true
  end

  -- Convert in command mode for substitute commands
  if cmdtype == ":" then
    -- Check if it's a substitute command
    if cmdline:match("^%s*s/") or cmdline:match("^%s*%%s/") then
      return true
    end
  end

  return false
end

-- Extract pattern from substitute command
local function extract_substitute_pattern(cmdline)
  -- Match patterns like: s/pattern/replacement/flags or %s/pattern/replacement/flags
  local prefix, pattern, suffix = cmdline:match("^(%s*%%?s/)([^/]*)(/.*)")
  if prefix and pattern and suffix then
    return prefix, pattern, suffix
  end
  return nil, nil, nil
end

-- Handle command line changes
local function on_cmdline_changed()
  if converting then
    return -- Avoid infinite loops
  end

  local cmdtype = vim.fn.getcmdtype()
  local cmdline = vim.fn.getcmdline()
  local cmdpos = vim.fn.getcmdpos()

  if not should_convert(cmdtype, cmdline) then
    return
  end

  local new_cmdline = cmdline
  local new_pos = cmdpos

  if cmdtype == "/" or cmdtype == "?" then
    -- For search patterns, convert the entire line
    local converted = convert_extended_to_basic(cmdline)
    if converted ~= cmdline then
      new_cmdline = converted
      -- Adjust cursor position if text was added
      local diff = #converted - #cmdline
      new_pos = cmdpos + diff
    end
  elseif cmdtype == ":" then
    -- For substitute commands, only convert the pattern part
    local prefix, pattern, suffix = extract_substitute_pattern(cmdline)
    if prefix and pattern and suffix then
      local converted_pattern = convert_extended_to_basic(pattern)
      if converted_pattern ~= pattern then
        new_cmdline = prefix .. converted_pattern .. suffix
        -- Adjust cursor position if we're in the pattern part
        local pattern_start = #prefix + 1
        local pattern_end = pattern_start + #pattern - 1
        if cmdpos >= pattern_start and cmdpos <= pattern_end then
          local offset_in_pattern = cmdpos - pattern_start
          local pattern_diff = #converted_pattern - #pattern
          new_pos = cmdpos + pattern_diff
        else
          -- If cursor is after the pattern, adjust for total length change
          local total_diff = #new_cmdline - #cmdline
          if cmdpos > pattern_end then
            new_pos = cmdpos + total_diff
          end
        end
      end
    end
  end

  -- Apply changes if conversion occurred
  if new_cmdline ~= cmdline then
    converting = true
    vim.fn.setcmdline(new_cmdline)
    if new_pos ~= cmdpos and new_pos > 0 and new_pos <= #new_cmdline + 1 then
      vim.fn.setcmdpos(new_pos)
    end
    converting = false

    if M.config.show_conversion then
      -- Show conversion in a non-intrusive way
      vim.schedule(function()
        vim.api.nvim_echo({{"RegVim: Converted regex pattern", "Comment"}}, false, {})
      end)
    end
  end
end

-- Set up the autocommand for real-time conversion
local function setup_autocommand()
  -- Clear any existing autocommands
  vim.api.nvim_create_augroup("RegVim", { clear = true })

  -- Create the CmdlineChanged autocommand
  vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = "RegVim",
    pattern = "*",
    callback = on_cmdline_changed,
    desc = "Real-time regex conversion for RegVim"
  })
end

-- Initialize RegVim
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)

  setup_autocommand()
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

-- Legacy function for backward compatibility
function M.regvim()
  M.toggle()
end

return M