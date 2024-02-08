package karvi_test

import "core:testing"
import "core:os"
import "core:fmt"
import "core:strings"

import kv "../"

/*
import (
	"bytes"
	"fmt"
	"image/color"
	"io"
	"os"
	"strings"
	"testing"
	"text/template"
)
*/

expect  :: testing.expect
log     :: testing.log
errorf  :: testing.errorf

@(test)
test_term_env :: proc(t: ^testing.T) {
	using kv.Profile

	kv.init()
	defer kv.close()

	o := kv.new_output(os.stdout)
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
}

@(test)
test_rende_ring :: proc(t: ^testing.T) {
	using kv.Profile
	out := kv.new_style("foobar", True_Color)
	test := kv.get_string(out) == "foobar" 
	expect(t, test, "Unstyled strings should be returned as plain text")

	kv.set_style_foreground(out, kv.color(True_Color, "#abcdef"))
	kv.set_style_background(out, kv.color(True_Color, "69"))
	kv.enable_bold(out)
	kv.enable_italic(out)
	kv.enable_faint(out)
	kv.enable_underline(out)
	kv.enable_blink(out)

	exp := "\x1b[38;2;171;205;239;48;5;69;1;3;2;4;5mfoobar\x1b[0m"
	test = kv.get_string(out) == exp 
	err := fmt.tprintf("Expected %s, got %s", exp, kv.get_string(out))
	expect(t, test, err)

	exp = "foobar"
	mono := kv.new_style(exp, Ascii)
	kv.set_style_foreground(mono, kv.new_rgb_color("#abcdef"))
	test = kv.get_string(mono) == exp
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

/*
@(test)
func TestTemplateHelpers(t *testing.T) {
	p := TrueColor

	exp := String("Hello World")
	basetpl := `{{ %s "Hello World" }}`
	wraptpl := `{{ %s (%s "Hello World") }}`

	tt := []struct {
		Template string
		Expected string
	}{
		{
			Template: fmt.Sprintf(basetpl, "Bold"),
			Expected: exp.Bold().String(),
		},
		{
			Template: fmt.Sprintf(basetpl, "Faint"),
			Expected: exp.Faint().String(),
		},
		{
			Template: fmt.Sprintf(basetpl, "Italic"),
			Expected: exp.Italic().String(),
		},
		{
			Template: fmt.Sprintf(basetpl, "Underline"),
			Expected: exp.Underline().String(),
		},
		{
			Template: fmt.Sprintf(basetpl, "Overline"),
			Expected: exp.Overline().String(),
		},
		{
			Template: fmt.Sprintf(basetpl, "Blink"),
			Expected: exp.Blink().String(),
		},
		{
			Template: fmt.Sprintf(basetpl, "Reverse"),
			Expected: exp.Reverse().String(),
		},
		{
			Template: fmt.Sprintf(basetpl, "CrossOut"),
			Expected: exp.CrossOut().String(),
		},
		{
			Template: fmt.Sprintf(wraptpl, "Underline", "Bold"),
			Expected: String(exp.Bold().String()).Underline().String(),
		},
		{
			Template: `{{ Color "#ff0000" "foobar" }}`,
			Expected: String("foobar").Foreground(p.Color("#ff0000")).String(),
		},
		{
			Template: `{{ Color "#ff0000" "#0000ff" "foobar" }}`,
			Expected: String("foobar").
				Foreground(p.Color("#ff0000")).
				Background(p.Color("#0000ff")).
				String(),
		},
		{
			Template: `{{ Foreground "#ff0000" "foobar" }}`,
			Expected: String("foobar").Foreground(p.Color("#ff0000")).String(),
		},
		{
			Template: `{{ Background "#ff0000" "foobar" }}`,
			Expected: String("foobar").Background(p.Color("#ff0000")).String(),
		},
	}

	for i, v := range tt {
		tpl, err := template.New(fmt.Sprintf("test_%d", i)).Funcs(TemplateFuncs(p)).Parse(v.Template)
		if err != nil {
			t.Error(err)
		}

		var buf bytes.Buffer
		err = tpl.Execute(&buf, nil)
		if err != nil {
			t.Error(err)
		}

		if buf.String() != v.Expected {
			v1 := strings.ReplaceAll(v.Expected, "\x1b", "")
			v2 := strings.ReplaceAll(buf.String(), "\x1b", "")
			t.Errorf("Expected %s, got %s", v1, v2)
		}
	}
}

@(test)
func TestEnvNoColor(t *testing.T) {
	tests := []struct {
		name     string
		environ  []string
		expected bool
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
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			defer func() {
				os.Unsetenv("NO_COLOR")
				os.Unsetenv("CLICOLOR")
				os.Unsetenv("CLICOLOR_FORCE")
			}()
			for i := 0; i < len(test.environ); i += 2 {
				os.Setenv(test.environ[i], test.environ[i+1])
			}
			out := NewOutput(os.Stdout)
			actual := out.EnvNoColor()
			if test.expected != actual {
				t.Errorf("expected %t but was %t", test.expected, actual)
			}
		})
	}
}

@(test)
func TestPseudoTerm(t *testing.T) {
	buf := &bytes.Buffer{}
	o := NewOutput(buf)
	if o.Profile != Ascii {
		t.Errorf("Expected %d, got %d", Ascii, o.Profile)
	}

	fg := o.ForegroundColor()
	fgseq := fg.Sequence(false)
	if fgseq != "" {
		t.Errorf("Expected empty response, got %s", fgseq)
	}

	bg := o.BackgroundColor()
	bgseq := bg.Sequence(true)
	if bgseq != "" {
		t.Errorf("Expected empty response, got %s", bgseq)
	}

	exp := "foobar"
	out := o.String(exp)
	out = out.Foreground(o.Color("#abcdef"))
	o.Write([]byte(out.String()))

	if buf.String() != exp {
		t.Errorf("Expected %s, got %s", exp, buf.String())
	}
}

@(test)
func TestCache(t *testing.T) {
	o := NewOutput(os.Stdout, WithColorCache(true), WithProfile(TrueColor))

	if o.cache != true {
		t.Errorf("Expected cache to be active, got %t", o.cache)
	}
}

@(test)
func TestEnableVirtualTerminalProcessing(t *testing.T) {
	// EnableVirtualTerminalProcessing should always return a non-nil
	// restoreFunc, and in tests it should never return an error.
	restoreFunc, err := EnableVirtualTerminalProcessing(NewOutput(os.Stdout))
	if restoreFunc == nil || err != nil {
		t.Fatalf("expected non-<nil>, <nil>, got %p, %v", restoreFunc, err)
	}
	// In tests, restoreFunc should never return an error.
	if err := restoreFunc(); err != nil {
		t.Fatalf("expected <nil>, got %v", err)
	}
}

@(test)
func TestWithTTY(t *testing.T) {
	for _, v := range []bool{true, false} {
		o := NewOutput(io.Discard, WithTTY(v))
		if o.isTTY() != v {
			t.Fatalf("expected WithTTY(%t) to set isTTY to %t", v, v)
		}
	}
}
*/
