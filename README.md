# karvi
ANSI support for terminal applications with [Odin](https://odin-lang.org/) lang.

The intent of this library is to serve as a base foundation for text user interfaces (TUI) and simple games/apps.
Similar in funtionality to crossterm.

## Features

- ANSI Color Support
  - ANSI16, ANSI256, Truecolor
  - hex color, rgb
  - Foreground / background color
  - Text Styling
  - Text attributes (bold, italic, underscore, crossed)
- is tty
- Terminal screen
  - Raw mode
  - Alternate screen
  - Restore screen
  - Clear (all lines, current line, etc..)
  - Terminal size
  - Set window title
  - Set foreground/background color
- Cursor
  - Show/hide cursor
  - Set cursor color
  - Positioning (up, down, forward, back, etc)
  - Save position
  - Restore position
  - Scroll up, down
  - Erase line
  - and more....
- Event handling
  - Keyboard input
  - Modifiers (ALT, CRTL, SHIFT)
  - Mouse Events (press, release, drag)
  - Terminal Resize
- Copy/paste
  
The core of this library is ported from [termenv](https://github.com/muesli/termenv) with additional features.

TODO: Windows support
