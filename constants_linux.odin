package karvi

when ODIN_OS == .Linux {

    ECHO        :: 0x8	
    TC_GET_ATTR :: 0x5401
	TC_SET_ATTR :: 0x5402

    when ODIN_ARCH == .amd64 {
	    ICANON :: 0x2
    } else when ODIN_ARCH == .arm64 {
	    ICANON :: 0x2
    } else when ODIN_ARCH == .i386 {
	    ICANON :: 0x2
    } else when ODIN_ARCH == .arm32 {
	    ICANON :: 0x2
    } else {
        #panic("Unsupported architecure")
    }

}
