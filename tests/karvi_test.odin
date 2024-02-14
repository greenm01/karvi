package karvi_test

import "core:testing"
import "core:os"
import "core:fmt"
import "core:strings"

import kv "../"

expect  :: testing.expect
log     :: testing.log
errorf  :: testing.errorf

// Not a great test because terminals normally have different
// foreground and background colors?
@(test)
test_term_env :: proc(t: ^testing.T) {
	using kv.Profile

	kv.init()
	defer kv.close()

	o := kv.new_output()
	test := o.profile == ANSI256
	err := fmt.tprintf("Expected %d got %d", ANSI256, o.profile)
	expect(t, test, err)
	    
	fg := kv.output_fg_color(o)
	fgseq := kv.sequence(fg, false)
	fgexp := "37"
	test = fgseq == fgexp && fgseq != ""
	err = fmt.tprintf("Expected %s got %s", fgexp, fgseq)
	expect(t, test, err)

	bg := kv.output_bg_color(o)
	bgseq := kv.sequence(bg, true)
	bgexp := "48;2;0;0;0"
	test = bgseq == bgexp && bgseq != ""
	err = fmt.tprintf("Expected %s got %s", bgexp, bgseq)
	expect(t, test, err)

	_ = kv.has_dark_background()
	free(o)

}

@(test)
test_rende_ring :: proc(t: ^testing.T) {
	using kv.Profile
	out := kv.new_style(True_Color)
	test := kv.render_style(out, "foobar") == "foobar" 
	expect(t, test, "Unstyled strings should be returned as plain text")

	kv.set_style_foreground(out, kv.color(True_Color, "#abcdef"))
	kv.set_style_background(out, kv.color(True_Color, "69"))
	kv.enable_bold(out)
	kv.enable_italic(out)
	kv.enable_faint(out)
	kv.enable_underline(out)
	kv.enable_blink(out)

	exp := "\x1b[38;2;171;205;239;48;5;69;1;3;2;4;5mfoobar\x1b[0m"
	test = kv.render_style(out, "foobar") == exp 
	err := fmt.tprintf("Expected %s, got %s", exp, kv.render_style(out, "foobar"))
	expect(t, test, err)

	exp = "foobar"
	mono := kv.new_style(Ascii)
	kv.set_style_foreground(mono, kv.new_rgb_color("#abcdef"))
	test = kv.render_style(mono, exp) == exp
	err = fmt.tprintf("Ascii profile should not apply color styles")
	expect(t, test, err)
}

@(test)
test_color_conversion :: proc(t: ^testing.T) {
	using kv.Profile
	// ANSI color
	a := kv.color(ANSI, "7")
	c := kv.convert_to_rgb(a)

	exp := "#c0c0c0"
	test := kv.hex(c) == exp 
	err := fmt.tprintf("Expected %s, got %s", exp, kv.hex(c))
	expect(t, test, err)

	// ANSI-256 color
	a256 := kv.color(ANSI256, "91")
	c = kv.convert_to_rgb(a256)

	exp = "#8700af"
	test = kv.hex(c) == exp 
	err = fmt.tprintf("Expected %s, got %s", exp, kv.hex(c))
	expect(t, test, err)

	// hex color
	hex := "#abcdef"
	argb := kv.color(True_Color, hex)
	c = kv.convert_to_rgb(argb)
	test = kv.hex(c) == hex
	err = fmt.tprintf("Expected %s, got %s", hex, kv.hex(c))
	expect(t, test, err)
}

@(test)
test_ascii :: proc(t: ^testing.T) {
	using kv.Profile
	c := kv.color(Ascii, "#abcdef")
	test := kv.sequence(c, false) == "" 
	err := fmt.tprintf("Expected empty sequence, got %s", kv.sequence(c, false))
	expect(t, test, err)
}

@(test)
test_ansi_profile :: proc(t: ^testing.T) {
	using kv.Profile
	p := ANSI

	c := kv.color(p, "#e88388")
	exp := "91"
	test := kv.sequence(c, false) == exp 
	err := fmt.tprintf("Expected %s, got %s", exp, kv.sequence(c, false))
	expect(t, test, err)

	_, test = c.type.(kv.ANSI_Color) 
	err = fmt.tprintf("Expected type karvi.ANSI_Color, got %T", c)
	expect(t, test, err)

	c = kv.color(p, "82")
	exp = "92"
	test = kv.sequence(c, false) == exp
	err = fmt.tprintf("Expected %s, got %s", exp, kv.sequence(c, false))
	expect(t, test, err)
	
	_, test = c.type.(kv.ANSI_Color)
	err = fmt.tprintf("Expected type karvi.ANSI_Color, got %T", c)
	expect(t, test, err)
	
	c = kv.color(p, "2")
	exp = "32"
	test = kv.sequence(c, false) == exp
	err = fmt.tprintf("Expected %s, got %s", exp, kv.sequence(c, false))
	expect(t, test, err)

	_, test = c.type.(kv.ANSI_Color)
	err = fmt.tprintf("Expected type karvi.ANSI_Color, got %T", c)
	expect(t, test, err)
}

@(test)
test_ansi256_profile :: proc(t: ^testing.T) {
	using kv.Profile
	p := ANSI256

	c := kv.color(p, "#abcdef")
	exp := "38;5;153"
	test := kv.sequence(c, false) == exp
	err := fmt.tprintf("Expected %s, got %s", exp, kv.sequence(c, false))
	expect(t, test, err)

	_, test = c.type.(kv.ANSI256_Color)
	err = fmt.tprintf("Expected type karvi.ANSI256_Color, got %T", c)
	expect(t, test, err)

	c = kv.color(p, "139")
	exp = "38;5;139"
	test = kv.sequence(c, false) == exp
	err = fmt.tprintf("Expected %s, got %s", exp, kv.sequence(c, false))
	expect(t, test, err)
	
	_, test = c.type.(kv.ANSI256_Color)
	err = fmt.tprintf("Expected type karvi.ANSI256_Color, got %T", c)
	expect(t, test, err)
	
	c = kv.color(p, "2")
	exp = "32"
	test = kv.sequence(c, false) == exp
	err = fmt.tprintf("Expected %s, got %s", exp, kv.sequence(c, false))
	expect(t, test, err)
	
	_, test = c.type.(kv.ANSI_Color)
	err = fmt.tprintf("Expected type termenv.ANSIColor, got %T", c)
	expect(t, test, err)
}

@(test)
test_true_color_profile :: proc(t: ^testing.T) {
	using kv.Profile
	p := True_Color

	c := kv.color(p, "#abcdef")
	exp := "38;2;171;205;239"
	test := kv.sequence(c,  false) == exp
	err := fmt.tprintf("Expected %s, got %s", exp, kv.sequence(c,  false))
	expect(t, test, err)
	
	_, test = c.type.(kv.RGB_Color)
	err = fmt.tprintf("Expected type karvi.Hex_Color, got %T", c)
	expect(t, test, err)

	c = kv.color(p, "139")
	exp = "38;5;139"
	test = kv.sequence(c, false) == exp
	err = fmt.tprintf("Expected %s, got %s", exp, kv.sequence(c, false))
	expect(t, test, err)

	_, test = c.type.(kv.ANSI256_Color)
	err = fmt.tprintf("Expected type karvi.ANSI256_Color, got %T", c)
	expect(t, test, err)

	c = kv.color(p, "2")
	exp = "32"
	test = kv.sequence(c, false) == exp
	err = fmt.tprintf("Expected %s, got %s", exp, kv.sequence(c, false))
	expect(t, test, err)
	
	_, test = c.type.(kv.ANSI_Color)
	err = fmt.tprintf("Expected type karvi.ANSI_Color, got %T", c)
	expect(t, test, err)
	
}

@(test)
test_styles :: proc(t: ^testing.T) {
	using kv.Profile
	s := kv.set_foreground("foobar", kv.color(True_Color, "2"))

	exp := "\x1b[32mfoobar\x1b[0m"
	test := s == exp
	err := fmt.tprintf("Expected %s, got %s", exp, s)
	expect(t, test, err)
}

@(test)
test_env_no_color :: proc(t: ^testing.T) {
	tests := []struct {
		name:     string,
		environ:  []string,
		expected: bool,
	}{
		{"no env", nil, false},
		{"no_color", []string{"NO_COLOR", "Y"}, true},
		{"no_color+clicolor=1", []string{"NO_COLOR", "Y", "CLICOLOR", "1"}, true},
		{"no_color+clicolor_force=1", []string{"NO_COLOR", "Y", "CLICOLOR_FORCE", "1"}, true},
		{"clicolor=0", []string{"CLICOLOR", "0"}, true},
		{"clicolor=1", []string{"CLICOLOR", "1"}, false},
		{"clicolor_force=1", []string{"CLICOLOR_FORCE", "0"}, false},
		{"clicolor_force=0", []string{"CLICOLOR_FORCE", "1"}, false},
		{"clicolor=0+clicolor_force=1", []string{"CLICOLOR", "0", "CLICOLOR_FORCE", "1"}, false},
		{"clicolor=1+clicolor_force=1", []string{"CLICOLOR", "1", "CLICOLOR_FORCE", "1"}, false},
		{"clicolor=0+clicolor_force=0", []string{"CLICOLOR", "0", "CLICOLOR_FORCE", "0"}, true},
		{"clicolor=1+clicolor_force=0", []string{"CLICOLOR", "1", "CLICOLOR_FORCE", "0"}, false},
	}
	for test in tests {
		defer proc() {
			os.unset_env("NO_COLOR")
			os.unset_env("CLICOLOR")
			os.unset_env("CLICOLOR_FORCE")
		}()
		for i := 0; i < len(test.environ); i += 2 {
			os.set_env(test.environ[i], test.environ[i+1])
		}
		out := kv.new_output()
		actual := kv.output_env_no_color(out)
		comp := test.expected == actual 
		err := fmt.tprintf("expected %t but was %t", comp, actual)
		expect(t, comp, err)
		free(out)
	}
}

@(test)
test_pseudo_term :: proc(t: ^testing.T) {
	using kv.Profile

	// Enabling the buffer assumes a no tty pseudo terminal
	o := kv.new_output(buffer = true)
	test := o.profile == Ascii
	err := fmt.tprintf("Expected %d, got %d", Ascii, o.profile)
	expect(t, test, err)
	
	fg := kv.output_fg_color(o)
	fgseq := kv.sequence(fg, false)
	test = fgseq == ""
	err = fmt.tprintf("Expected empty response, got %s", fgseq)
	expect(t, test, err)
	
	bg := kv.output_bg_color(o)
	bgseq := kv.sequence(bg, true)
	test = bgseq == ""
	err = fmt.tprintf("Expected empty response, got %s", bgseq)
	expect(t, test, err)

	exp := "foobar"
	out := kv.new_style(o.profile)
	kv.set_style_foreground(out, kv.color(o.profile, "#abcdef"))
	kv.buffer_write_string(o, kv.render_style(out, exp))

	str := kv.buffer_read_string(o) 
	test = str == exp
	err = fmt.tprintf("Expected %s, got %s", exp, str)
	expect(t, test, err)

	kv.buffer_destroy(o)
	free(o)

}
