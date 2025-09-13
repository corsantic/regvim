-- test/test_regex_conversion.lua
-- Comprehensive test suite for RegVim regex conversion
-- Run with: nvim --headless -c "set runtimepath+=." -c "luafile test/test_regex_conversion.lua" -c "q"

local M = {}

-- Test framework functions
local function assert_equal(actual, expected, message)
  if actual ~= expected then
    error(string.format("%s\nExpected: '%s'\nActual: '%s'", message or "Assertion failed", expected, actual))
  end
end

local function run_test(name, test_func)
  local success, err = pcall(test_func)
  if success then
    print("✓ " .. name)
    return true
  else
    print("✗ " .. name .. ": " .. err)
    return false
  end
end

-- Regex conversion function (copied from regvim.lua for testing)
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

-- Test cases organized by category
local test_cases = {
  -- Basic parentheses conversion
  basic_parentheses = {
    { input = "(test)", expected = "\\(test\\)", desc = "Simple parentheses" },
    { input = "foo(bar)baz", expected = "foo\\(bar\\)baz", desc = "Parentheses in middle" },
    { input = "()", expected = "\\(\\)", desc = "Empty parentheses" },
    { input = "(a)(b)(c)", expected = "\\(a\\)\\(b\\)\\(c\\)", desc = "Multiple parentheses" },
    { input = "((nested))", expected = "\\(\\(nested\\))", desc = "Nested parentheses" },
  },

  -- Already escaped parentheses (should not change)
  escaped_parentheses = {
    { input = "\\(test\\)", expected = "\\(test\\)", desc = "Already escaped parentheses" },
    { input = "foo\\(bar\\)baz", expected = "foo\\(bar\\)baz", desc = "Already escaped in middle" },
    { input = "\\(\\)", expected = "\\(\\)", desc = "Already escaped empty" },
    { input = "\\(a\\)\\(b\\)", expected = "\\(a\\)\\(b\\)", desc = "Multiple already escaped" },
  },

  -- Mixed escaped and unescaped
  mixed_parentheses = {
    { input = "(test)\\(already\\)", expected = "\\(test\\)\\(already\\)", desc = "Mixed escaped/unescaped" },
    { input = "\\(escaped\\)(unescaped)", expected = "\\(escaped\\)\\(unescaped\\)", desc = "Escaped then unescaped" },
    { input = "(a\\)b)", expected = "\\(a\\)b\\)", desc = "Partially escaped" },
  },

  -- Braces conversion
  braces = {
    { input = "{2,3}", expected = "\\{2,3\\}", desc = "Simple quantifier braces" },
    { input = "a{1,}", expected = "a\\{1,\\}", desc = "One or more quantifier" },
    { input = "test{5}", expected = "test\\{5\\}", desc = "Exact quantifier" },
    { input = "{}", expected = "\\{\\}", desc = "Empty braces" },
    { input = "a{1,5}b{2,}", expected = "a\\{1,5\\}b\\{2,\\}", desc = "Multiple braces" },
    { input = "\\{2,3\\}", expected = "\\{2,3\\}", desc = "Already escaped braces" },
  },

  -- Plus quantifier
  plus_quantifier = {
    { input = "a+", expected = "a\\+", desc = "Simple plus" },
    { input = "[0-9]+", expected = "[0-9]\\+", desc = "Plus after character class" },
    { input = "test+more", expected = "test\\+more", desc = "Plus in middle" },
    { input = "+start", expected = "\\+start", desc = "Plus at start" },
    { input = "a+b+c+", expected = "a\\+b\\+c\\+", desc = "Multiple plus" },
    { input = "\\+", expected = "\\+", desc = "Already escaped plus" },
  },

  -- Question mark quantifier
  question_quantifier = {
    { input = "a?", expected = "a\\?", desc = "Simple question mark" },
    { input = "colou?r", expected = "colou\\?r", desc = "Optional character" },
    { input = "?start", expected = "\\?start", desc = "Question mark at start" },
    { input = "a?b?c?", expected = "a\\?b\\?c\\?", desc = "Multiple question marks" },
    { input = "\\?", expected = "\\?", desc = "Already escaped question mark" },
  },

  -- Pipe (alternation)
  pipe_alternation = {
    { input = "foo|bar", expected = "foo\\|bar", desc = "Simple alternation" },
    { input = "cat|dog|bird", expected = "cat\\|dog\\|bird", desc = "Multiple alternations" },
    { input = "|start", expected = "\\|start", desc = "Pipe at start" },
    { input = "end|", expected = "end\\|", desc = "Pipe at end" },
    { input = "a|b|c|d", expected = "a\\|b\\|c\\|d", desc = "Many alternations" },
    { input = "\\|", expected = "\\|", desc = "Already escaped pipe" },
  },

  -- Complex combinations
  complex_patterns = {
    { input = "(foo|bar)+", expected = "\\(foo\\|bar\\)\\+", desc = "Grouped alternation with plus" },
    { input = "[a-z]+({0,3})?", expected = "[a-z]\\+\\(\\{0,3\\}\\)\\?", desc = "Complex quantifiers" },
    { input = "(test){2,}|(other)+", expected = "\\(test\\)\\{2,\\}\\|\\(other\\)\\+", desc = "Complex alternation" },
    { input = "^(start).*(end)$", expected = "^\\(start\\).*\\(end\\)$", desc = "Anchored pattern" },
    { input = "a(b|c)+d?", expected = "a\\(b\\|c\\)\\+d\\?", desc = "Mixed operators" },
  },

  -- Edge cases and special scenarios
  edge_cases = {
    { input = "", expected = "", desc = "Empty string" },
    { input = "simple", expected = "simple", desc = "No special characters" },
    { input = "\\", expected = "\\", desc = "Single backslash" },
    { input = "\\\\", expected = "\\\\", desc = "Double backslash" },
    { input = "test\\", expected = "test\\", desc = "Backslash at end" },
    { input = "a.b*c", expected = "a.b*c", desc = "Dot and asterisk (no conversion needed)" },
    { input = "[abc]", expected = "[abc]", desc = "Character class (no conversion)" },
    { input = "^$", expected = "^$", desc = "Anchors only" },
  },

  -- Escape sequences that should not be converted
  no_conversion_needed = {
    { input = "\\(already\\)", expected = "\\(already\\)", desc = "Fully escaped group" },
    { input = "\\{1,3\\}", expected = "\\{1,3\\}", desc = "Fully escaped quantifier" },
    { input = "\\+\\?\\|", expected = "\\+\\?\\|", desc = "All escaped operators" },
    { input = "\\\\(not-group\\\\)", expected = "\\\\(not-group\\\\)", desc = "Literal backslash before parens" },
  },

  -- Real-world regex patterns
  real_world_patterns = {
    { input = "([a-zA-Z]+)@([a-zA-Z0-9.-]+)", expected = "\\([a-zA-Z]\\+\\)@\\([a-zA-Z0-9.-]\\+\\)", desc = "Email pattern" },
    { input = "(https?://)?(www\\.)?([a-zA-Z0-9.-]+)", expected = "\\(https\\?://\\)\\?\\(www\\.\\)\\?\\([a-zA-Z0-9.-]\\+\\)", desc = "URL pattern" },
    { input = "\\d{3}-\\d{2}-\\d{4}", expected = "\\d\\{3\\}-\\d\\{2\\}-\\d\\{4\\}", desc = "SSN pattern with \\d" },
    { input = "[0-9]{1,3}(\\.[0-9]{1,3}){3}", expected = "[0-9]\\{1,3\\}\\(\\.[0-9]\\{1,3\\}\\)\\{3\\}", desc = "IP address pattern" },
    { input = "(Mon|Tue|Wed|Thu|Fri|Sat|Sun)", expected = "\\(Mon\\|Tue\\|Wed\\|Thu\\|Fri\\|Sat\\|Sun\\)", desc = "Day of week alternation" },
  },
}

-- Run all tests
function M.run_all_tests()
  print("RegVim Regex Conversion Test Suite")
  print("==================================")
  print()

  local total_tests = 0
  local passed_tests = 0
  local failed_tests = 0

  for category_name, category_tests in pairs(test_cases) do
    print(string.format("Testing %s:", category_name:gsub("_", " ")))
    print(string.rep("-", 40))

    for _, test_case in ipairs(category_tests) do
      total_tests = total_tests + 1

      local success = run_test(test_case.desc, function()
        local result = convert_extended_to_basic(test_case.input)
        assert_equal(result, test_case.expected,
          string.format("Input: '%s'", test_case.input))
      end)

      if success then
        passed_tests = passed_tests + 1
      else
        failed_tests = failed_tests + 1
      end
    end
    print()
  end

  -- Summary
  print("Test Summary")
  print("============")
  print(string.format("Total tests: %d", total_tests))
  print(string.format("Passed: %d", passed_tests))
  print(string.format("Failed: %d", failed_tests))
  print(string.format("Success rate: %.1f%%", (passed_tests / total_tests) * 100))

  if failed_tests == 0 then
    print("\n🎉 All tests passed!")
  else
    print(string.format("\n❌ %d test(s) failed. Please review the implementation.", failed_tests))
  end

  return failed_tests == 0
end

-- If running directly, execute tests
if ... == nil then
  M.run_all_tests()
end

return M