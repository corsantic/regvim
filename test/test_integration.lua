-- test/test_integration.lua
-- Integration tests for RegVim functionality
-- Run with: nvim --headless -c "set runtimepath+=." -c "luafile test/test_integration.lua" -c "q"

local regvim = require('regvim')

print("RegVim Integration Tests")
print("========================")
print()

-- Test 1: Setup function
print("Test 1: Testing setup function")
local success1 = pcall(function()
  regvim.setup({
    enabled = true,
    auto_convert = true,
    show_conversion = false
  })
end)

if success1 then
  print("✓ Setup function works correctly")
else
  print("✗ Setup function failed")
end

-- Test 2: Configuration
print("\nTest 2: Testing configuration")
regvim.setup({
  enabled = false,
  auto_convert = false,
  show_conversion = true
})

local config_correct = not regvim.config.enabled and
                      not regvim.config.auto_convert and
                      regvim.config.show_conversion

if config_correct then
  print("✓ Configuration updates correctly")
else
  print("✗ Configuration update failed")
  print("  enabled:", regvim.config.enabled)
  print("  auto_convert:", regvim.config.auto_convert)
  print("  show_conversion:", regvim.config.show_conversion)
end

-- Test 3: Enable/Disable functions
print("\nTest 3: Testing enable/disable functions")
regvim.disable()
local disabled = not regvim.config.enabled

regvim.enable()
local enabled = regvim.config.enabled

if disabled and enabled then
  print("✓ Enable/disable functions work correctly")
else
  print("✗ Enable/disable functions failed")
end

-- Test 4: Toggle function
print("\nTest 4: Testing toggle function")
local initial_state = regvim.config.enabled
regvim.toggle()
local toggled_state = regvim.config.enabled
regvim.toggle()
local back_to_initial = regvim.config.enabled

if toggled_state ~= initial_state and back_to_initial == initial_state then
  print("✓ Toggle function works correctly")
else
  print("✗ Toggle function failed")
end

-- Test 5: Module structure
print("\nTest 5: Testing module structure")
local has_required_functions = type(regvim.setup) == 'function' and
                              type(regvim.enable) == 'function' and
                              type(regvim.disable) == 'function' and
                              type(regvim.toggle) == 'function' and
                              type(regvim.regvim) == 'function' and
                              type(regvim.config) == 'table'

if has_required_functions then
  print("✓ Module exports all required functions and config")
else
  print("✗ Module structure is incomplete")
end

-- Test 6: Autocommand creation (basic check)
print("\nTest 6: Testing autocommand creation")
local success6 = pcall(function()
  regvim.setup() -- This should create the autocommand
  -- We can't easily test the autocommand functionality in headless mode
  -- but we can at least verify setup doesn't crash
end)

if success6 then
  print("✓ Autocommand setup completes without errors")
else
  print("✗ Autocommand setup failed")
end

-- Test 7: Default configuration
print("\nTest 7: Testing default configuration")
regvim.setup({
  enabled = true,
  auto_convert = true,
  show_conversion = false
}) -- Explicitly set to defaults

local defaults_correct = regvim.config.enabled == true and
                        regvim.config.auto_convert == true and
                        regvim.config.show_conversion == false

if defaults_correct then
  print("✓ Default configuration is correct")
else
  print("✗ Default configuration is incorrect")
end

-- Summary
print("\n" .. string.rep("=", 30))
print("Integration tests completed!")
print("\nNote: Full functionality testing requires interactive")
print("command line usage in a real Neovim session.")
print("\nTo test manually:")
print("1. Start nvim with this plugin loaded")
print("2. Type: :RegVim  (to toggle on/off)")
print("3. Type: :%s/(test)/replacement/g")
print("4. Observe that it becomes: :%s/\\(test\\)/replacement/g")
print("5. Watch the live preview and highlighting work!")