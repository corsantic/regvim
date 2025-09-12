local M = {}


function M.regex(pattern)
   local settings = vim.g.regvim_settings or {}
   -- local option_x = settings.option_x or 'some_default_value'
   vim.cmd(pattern)

end

return M
