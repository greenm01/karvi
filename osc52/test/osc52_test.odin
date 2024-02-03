package test_osc52

import "core:bytes"
import "core:io"
import "core:bufio"
import "core:testing"
import "core:fmt"
import "core:os"

import "../"

TEST_count := 0
TEST_fail  := 0

when ODIN_TEST {
	expect  :: testing.expect
	log     :: testing.log
	errorf  :: testing.errorf
} else {
	expect  :: proc(t: ^testing.T, condition: bool, message: string, loc := #caller_location) {
		TEST_count += 1
		if !condition {
			TEST_fail += 1
			fmt.printf("[%v:%s] FAIL %v\n", loc, loc.procedure, message)
			return
		}
	}
	errorf  :: proc(t: ^testing.T, message: string, args: ..any, loc := #caller_location) {
		TEST_fail += 1
		fmt.printf("[%v:%s] Error %v\n", loc, loc.procedure, fmt.tprintf(message, ..args))
		return
	}
	log     :: proc(t: ^testing.T, v: any, loc := #caller_location) {
		fmt.printf("[%v] ", loc)
		fmt.printf("log: %v\n", v)
	}
}

report :: proc(t: ^testing.T) {
	if TEST_fail > 0 {
		if TEST_fail > 1 {
			fmt.printf("%v/%v tests successful, %v tests failed.\n", TEST_count - TEST_fail, TEST_count, TEST_fail)
		} else {
			fmt.printf("%v/%v tests successful, 1 test failed.\n", TEST_count - TEST_fail, TEST_count)
		}
		os.exit(1)
	} else {
		fmt.printf("%v/%v tests successful.\n", TEST_count, TEST_count)
	}
}

main :: proc() {
	t := testing.T{}
	test_copy(&t)

	test_count := fmt.tprintf("%v/%v tests successful.\n", TEST_count - TEST_fail, TEST_count)
	fmt.print(test_count)
	if TEST_fail > 0 {
		os.exit(1)
	}

	// copy to primary system clipboard
	seq := osc52.new_sequence(test_count)
	osc52.set_primary(seq)
	fmt.fprintf(os.stderr, osc52.get_string(seq))

}

@(test)
test_copy :: proc(t: ^testing.T) {
   using osc52.Mode

   cases := []struct {
      name:      string,
      str:       string,
      clipboard: osc52.Clipboard,
      mode:      osc52.Mode,
      limit:     int,
      expected:  string,
      }{
      {
         name =      "hello world",
         str =       "hello world",
         clipboard = osc52.System_Clipboard,
         mode =      Default_Mode,
         limit =     0,
         expected =  "\x1b]52;c;aGVsbG8gd29ybGQ=\x07",
      },
      {
         name =      "empty string",
         str =       "",
         clipboard = osc52.System_Clipboard,
         mode =      Default_Mode,
         limit =     0,
         expected =  "\x1b]52;c;\x07",
      },
      {
         name =      "hello world primary",
         str =       "hello world",
         clipboard = osc52.Primary_Clipboard,
         mode =      Default_Mode,
         limit =     0,
         expected =  "\x1b]52;p;aGVsbG8gd29ybGQ=\x07",
      },
      {
         name =      "hello world tmux mode",
         str =       "hello world",
         clipboard = osc52.System_Clipboard,
         mode =      Tmux_Mode,
         limit =     0,
         expected =  "\x1bPtmux;\x1b\x1b]52;c;aGVsbG8gd29ybGQ=\x07\x1b\\",
      },
      {
         name =      "hello world screen mode",
         str =       "hello world",
         clipboard = osc52.System_Clipboard,
         mode =      Screen_Mode,
         limit =     0,
         expected =  "\x1bP\x1b]52;c;aGVsbG8gd29ybGQ=\x07\x1b\\",
      },
      {
         name =      "hello world screen mode longer than 76 bytes string",
         str =       "hello world hello world hello world hello world hello world hello world hello world hello world",
         clipboard = osc52.System_Clipboard,
         mode =      Screen_Mode,
         limit =     0,
         expected =  "\x1bP\x1b]52;c;aGVsbG8gd29ybGQgaGVsbG8gd29ybGQgaGVsbG8gd29ybGQgaGVsbG8gd29ybGQgaGVsbG8gd29y\x1b\\\x1bPbGQgaGVsbG8gd29ybGQgaGVsbG8gd29ybGQgaGVsbG8gd29ybGQ=\a\x1b\\",
      },
      {
         name =      "hello world with limit 11",
         str =       "hello world",
         clipboard = osc52.System_Clipboard,
         mode =      Default_Mode,
         limit =     11,
         expected =  "\x1b]52;c;aGVsbG8gd29ybGQ=\x07",
      },
      {
         name =      "hello world with limit 10",
         str =       "hello world",
         clipboard = osc52.System_Clipboard,
         mode =      Default_Mode,
         limit =     10,
         expected =  "",
      },
   }

   for c in cases {
      s := osc52.new_sequence(c.str)
      osc52.set_clipboard(s, c.clipboard)
      osc52.set_mode(s, c.mode)
      osc52.set_limit(s, c.limit)
      str := osc52.get_string(s)
      expect(t, str == c.expected, fmt.tprintf("expected %q, got %q", c.expected, str))    
   }
}

@(test)
test_query :: proc(t: ^testing.T) {
	using osc52.Mode

	cases := []struct {
		name:      string,
		mode:      osc52.Mode,
		clipboard: osc52.Clipboard,
		expected:  string,
	}{
		{
			name =      "query system clipboard",
			mode =      Default_Mode,
			clipboard = osc52.System_Clipboard,
			expected =  "\x1b]52;c;?\x07",
		},
		{
			name =      "query primary clipboard",
			mode =      Default_Mode,
			clipboard = osc52.Primary_Clipboard,
			expected =  "\x1b]52;p;?\x07",
		},
		{
			name =      "query system clipboard tmux mode",
			mode =      Tmux_Mode,
			clipboard = osc52.System_Clipboard,
			expected =  "\x1bPtmux;\x1b\x1b]52;c;?\x07\x1b\\",
		},
		{
			name =      "query system clipboard screen mode",
			mode =      Screen_Mode,
			clipboard = osc52.System_Clipboard,
			expected =  "\x1bP\x1b]52;c;?\x07\x1b\\",
		},
		{
			name =      "query primary clipboard tmux mode",
			mode =      Tmux_Mode,
			clipboard = osc52.Primary_Clipboard,
			expected =  "\x1bPtmux;\x1b\x1b]52;p;?\x07\x1b\\",
		},
		{
			name =      "query primary clipboard screen mode",
			mode =      Screen_Mode,
			clipboard = osc52.Primary_Clipboard,
			expected =  "\x1bP\x1b]52;p;?\x07\x1b\\",
		},
	}
   
	for c in cases {
		s := osc52.new_query()
		osc52.set_clipboard(s, c.clipboard)
		osc52.set_mode(s, c.mode)
      	str := osc52.get_string(s)
      	expect(t, str == c.expected, fmt.tprintf("expected %q, got %q", c.expected, str))    
	}

}

@(test)
test_clear :: proc(t: ^testing.T) {
	using osc52.Mode

	cases := []struct {
		name:      string,
		mode:      osc52.Mode,
		clipboard: osc52.Clipboard,
		expected:  string,
	}{
		{
			name =      "clear system clipboard",
			mode =      Default_Mode,
			clipboard = osc52.System_Clipboard,
			expected =  "\x1b]52;c;!\x07",
		},
		{
			name =      "clear system clipboard tmux mode",
			mode =      Tmux_Mode,
			clipboard = osc52.System_Clipboard,
			expected =  "\x1bPtmux;\x1b\x1b]52;c;!\x07\x1b\\",
		},
		{
			name =      "clear system clipboard screen mode",
			mode =      Screen_Mode,
			clipboard = osc52.System_Clipboard,
			expected =  "\x1bP\x1b]52;c;!\x07\x1b\\",
		},
	}
	for c in cases {
		s := osc52.new_clear()
		osc52.set_clipboard(s, c.clipboard)
		osc52.set_mode(s, c.mode)
	  	str := osc52.get_string(s)
	  	expect(t, str == c.expected, fmt.tprintf("expected %q, got %q", c.expected, str))    
	}	
}

@(test)
test_write_to :: proc(t: ^testing.T) {
	using osc52.Mode

	writer := new(bufio.Writer)
	wr: io.Stream
	bufio.writer_init(writer, wr)

	cases := []struct {
		name:      string,
		str:       string,
		clipboard: osc52.Clipboard,
		mode:      osc52.Mode,
		limit:     int,
		expected:  string,
	}{
		{
			name =      "hello world",
			str =       "hello world",
			clipboard = osc52.System_Clipboard,
			mode =      Default_Mode,
			limit =     0,
			expected =  "\x1b]52;c;aGVsbG8gd29ybGQ=\x07",
		},
		{
			name =      "empty string",
			str =       "",
			clipboard = osc52.System_Clipboard,
			mode =      Default_Mode,
			limit =     0,
			expected =  "\x1b]52;c;\x07",
		},
	}

	using io.Error
	for c in cases {
		bufio.writer_reset(writer, wr)
		s := osc52.new_sequence(c.str)
		osc52.set_clipboard(s, c.clipboard)
		osc52.set_mode(s, c.mode)
		osc52.set_limit(s, c.limit)
		_, err := osc52.write_to(s, writer)
		expect(t, err == None, fmt.tprintf("expected None, got %v", err)) 
		str := osc52.get_string(s)
		expect(t, str == c.expected, fmt.tprintf("expected %q, got %q", c.expected, str))    
	}
}
