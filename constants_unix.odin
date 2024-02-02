package karvi

when ODIN_OS != .Linux && ODIN_OS != .Windows {
	TC_GET_ATTR :: 0x402c7413
	TC_SET_ATTR :: 0x802c7414
}
