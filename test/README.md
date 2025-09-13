# RegVim Test Suite

This directory contains comprehensive tests for the RegVim plugin.

## Test Files

### `test_regex_conversion.lua`
Comprehensive unit tests for the regex conversion logic, testing:

- **Basic parentheses conversion**: `(test)` → `\(test\)`
- **Escaped parentheses handling**: `\(test\)` → `\(test\)` (no change)
- **Mixed escaped/unescaped patterns**
- **Brace quantifiers**: `{2,3}` → `\{2,3\}`
- **Plus quantifiers**: `a+` → `a\+`
- **Question mark quantifiers**: `a?` → `a\?`
- **Pipe alternation**: `foo|bar` → `foo\|bar`
- **Complex combinations**: `(foo|bar)+` → `\(foo\|bar\)\+`
- **Edge cases**: empty strings, backslashes, already escaped patterns
- **Real-world patterns**: email addresses, URLs, phone numbers

**Total Tests**: 57 test cases organized in 10 categories

### `test_integration.lua`
Integration tests for the RegVim plugin functionality:

- Setup and configuration
- Enable/disable/toggle functions
- Module structure validation
- Autocommand creation
- Default configuration verification

## Running Tests

### Individual Test Files
```bash
# Run regex conversion tests
nvim --headless -c "set runtimepath+=." -c "luafile test/test_regex_conversion.lua" -c "q"

# Run integration tests
nvim --headless -c "set runtimepath+=." -c "luafile test/test_integration.lua" -c "q"
```

### All Tests
```bash
# Run all tests
for test in test/*.lua; do
  echo "Running $test..."
  nvim --headless -c "set runtimepath+=." -c "luafile $test" -c "q"
  echo
done
```

## Manual Testing

For full functionality testing, you need to test in an interactive Neovim session:

1. Start nvim with RegVim loaded
2. Verify auto-setup by checking `:RegVim` command is available
3. Test real-time conversion:
   - Type `:%s/(test)/replacement/g`
   - Observe it becomes `:%s/\(test\)/replacement/g`
   - Watch live preview and highlighting
4. Test search patterns:
   - Type `/(foo|bar)+`
   - Observe it becomes `/\(foo\|bar\)\+`
5. Test toggle functionality:
   - Use `:RegVim` to toggle on/off
   - Verify conversion stops when disabled

## Test Results

As of the last run:
- **Regex Conversion Tests**: 57/57 passed (100% success rate)
- **Integration Tests**: 7/7 passed

## Test Categories Coverage

✅ **Basic Conversions**: Parentheses, braces, plus, question mark, pipe
✅ **Escape Handling**: Already escaped patterns, mixed patterns
✅ **Complex Patterns**: Nested groups, quantifiers, alternations
✅ **Edge Cases**: Empty strings, backslashes, special characters
✅ **Real-world Patterns**: Email, URL, phone number patterns
✅ **Plugin Functions**: Setup, enable, disable, toggle
✅ **Configuration**: Default and custom configuration handling

## Adding New Tests

To add new test cases to `test_regex_conversion.lua`:

```lua
-- Add to appropriate category in test_cases table
{ input = "your_input", expected = "expected_output", desc = "Test description" },
```

To add new integration tests to `test_integration.lua`:

```lua
-- Add new test section
print("\nTest X: Testing new functionality")
-- Test implementation
-- Result validation
```