package main

import "core:fmt"
import "core:c"
import "core:os"

import kv "../../"

main :: proc() {

	err := kv.init()
	defer kv.close()
	
	p := kv.color_profile()

	fmt.printf("\n\t%s %s %s %s %s",
		kv.set_bold("bold"),
		kv.set_faint("faint"),
		kv.set_italic("italic"),
		kv.set_underline("underline"),
		kv.set_crossout("crossout"),
	)

	fmt.printf("\n\t%s %s %s %s %s %s %s",
		kv.set_foreground("red", kv.color(p, "#E88388")),
		kv.set_foreground("green", kv.color(p, "#A8CC8C")),
		kv.set_foreground("yellow", kv.color(p, "#DBAB79")),
		kv.set_foreground("blue", kv.color(p, "#71BEF2")),
		kv.set_foreground("magenta", kv.color(p, "#D290E4")),
		kv.set_foreground("cyan", kv.color(p, "#66C2CD")),
		kv.set_foreground("gray", kv.color(p, "#B9BFCA")),
	)

	fmt.printf("\n\t%s %s %s %s %s %s %s\n\n",
		kv.set_foreground_background("red", kv.color(p, "0"), kv.color(p, "#E88388")),
		kv.set_foreground_background("green", kv.color(p, "0"), kv.color(p, "#A8CC8C")),
		kv.set_foreground_background("yellow", kv.color(p, "0"), kv.color(p, "#DBAB79")),
		kv.set_foreground_background("blue", kv.color(p, "0"), kv.color(p, "#71BEF2")),
		kv.set_foreground_background("magenta", kv.color(p, "0"), kv.color(p, "#D290E4")),
		kv.set_foreground_background("cyan", kv.color(p, "0"), kv.color(p, "#66C2CD")),
		kv.set_foreground_background("gray", kv.color(p, "0"), kv.color(p, "#B9BFCA")),
	)

	fmt.printf("\n\t%s %s\n", kv.set_bold("Has foreground color"), kv.foreground_color())
	fmt.printf("\t%s %s\n", kv.set_bold("Has background color"), kv.background_color())
	fmt.printf("\t%s %t\n\n", kv.set_bold("Has dark background?"), kv.has_dark_background())

	hw := "Hello, world!"
	kv.copy(hw)
	fmt.printf("\t%q copied to system clipboard\n\n", hw)

	kv.notify("Termenv", hw)
	fmt.print("\tTriggered a notification\n")

	fmt.printf("\t%s\n", kv.hyperlink("http://example.com", "This is a link"))
}
