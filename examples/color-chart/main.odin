package main

import "core:fmt"

import kv "../../"

main :: proc() {
	kv.enable_raw_mode()
	defer kv.disable_raw_mode()

	// Basic ANSI colors 0 - 15
	fmt.println(kv.set_bold("Basic ANSI colors"))

	using kv.Profile

	p := ANSI
	for i := i64(0); i < 16; i +=1 {
		if i%8 == 0 do fmt.println()

		// background color
		bg := kv.color(p, fmt.tprintf("%d", i))
		out := kv.new_style()

		// apply colors
		if i < 5 {
			kv.set_style_foreground(out, kv.color(p, "7"))
		} else {
			kv.set_style_foreground(out, kv.color(p, "0"))
		}
		kv.set_style_background(out, bg)

		s := fmt.tprintf(" %2d %s ", i, bg.color) 
		fmt.print(kv.render_style(out, s))
	}
	fmt.print("\n\n")

	// Extended ANSI colors 16-231
	fmt.println(kv.set_bold("Extended ANSI colors"))

	p = ANSI256
	for i := i64(16); i < 232; i += 1 {
		if (i-16)%6 == 0 do	fmt.println()

		// background color
		bg := kv.color(p, fmt.tprintf("%d", i))
		out := kv.new_style()

		// apply colors
		if i < 28 {
			kv.set_style_foreground(out, kv.color(p, "7"))
		} else {
			kv.set_style_foreground(out, kv.color(p, "0"))
		}
		kv.set_style_background(out, bg)

		s := fmt.tprintf(" %3d %s ", i, bg.color)
		fmt.print(kv.render_style(out, s))
	}
	fmt.print("\n\n")

	// Grayscale ANSI colors 232-255
	fmt.println(kv.set_bold("Extended ANSI Grayscale"))

	p = ANSI256
	for i := i64(232); i < 256; i += 1 {
		if (i-232)%6 == 0 do fmt.println()

		// background color
		bg := kv.color(p, fmt.tprintf("%d", i))
		out := kv.new_style()

		// apply colors
		if i < 244 {
			kv.set_style_foreground(out, kv.color(p, "7"))
		} else {
			kv.set_style_foreground(out, kv.color(p, "0"))
		}
		kv.set_style_background(out, bg)

		s := fmt.tprintf(" %3d %s ", i, bg.color)
		fmt.print(kv.render_style(out, s))
	}
	fmt.print("\n\n")
}
