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

/*
func main() {
	restoreConsole, err := termenv.EnableVirtualTerminalProcessing(termenv.DefaultOutput())
	if err != nil {
		panic(err)
	}
	defer restoreConsole()

	p := termenv.ColorProfile()

	fmt.Printf("\n\t%s %s %s %s %s",
		termenv.String("bold").Bold(),
		termenv.String("faint").Faint(),
		termenv.String("italic").Italic(),
		termenv.String("underline").Underline(),
		termenv.String("crossout").CrossOut(),
	)

	fmt.Printf("\n\t%s %s %s %s %s %s %s",
		termenv.String("red").Foreground(p.Color("#E88388")),
		termenv.String("green").Foreground(p.Color("#A8CC8C")),
		termenv.String("yellow").Foreground(p.Color("#DBAB79")),
		termenv.String("blue").Foreground(p.Color("#71BEF2")),
		termenv.String("magenta").Foreground(p.Color("#D290E4")),
		termenv.String("cyan").Foreground(p.Color("#66C2CD")),
		termenv.String("gray").Foreground(p.Color("#B9BFCA")),
	)

	fmt.Printf("\n\t%s %s %s %s %s %s %s\n\n",
		termenv.String("red").Foreground(p.Color("0")).Background(p.Color("#E88388")),
		termenv.String("green").Foreground(p.Color("0")).Background(p.Color("#A8CC8C")),
		termenv.String("yellow").Foreground(p.Color("0")).Background(p.Color("#DBAB79")),
		termenv.String("blue").Foreground(p.Color("0")).Background(p.Color("#71BEF2")),
		termenv.String("magenta").Foreground(p.Color("0")).Background(p.Color("#D290E4")),
		termenv.String("cyan").Foreground(p.Color("0")).Background(p.Color("#66C2CD")),
		termenv.String("gray").Foreground(p.Color("0")).Background(p.Color("#B9BFCA")),
	)

	fmt.Printf("\n\t%s %s\n", termenv.String("Has foreground color").Bold(), termenv.ForegroundColor())
	fmt.Printf("\t%s %s\n", termenv.String("Has background color").Bold(), termenv.BackgroundColor())
	fmt.Printf("\t%s %t\n", termenv.String("Has dark background?").Bold(), termenv.HasDarkBackground())
	fmt.Println()

	hw := "Hello, world!"
	termenv.Copy(hw)
	fmt.Printf("\t%q copied to clipboard\n", hw)
	fmt.Println()

	termenv.Notify("Termenv", hw)
	fmt.Print("\tTriggered a notification")
	fmt.Println()

	fmt.Printf("\t%s", termenv.Hyperlink("http://example.com", "This is a link"))
	fmt.Println()
}
*/
