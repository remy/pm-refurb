; 
; NOTE: same values as #defines in instruction.h of PMAS source
;
; To define a new instruction:
; .instruction "format", flags, fixed pattern, size-in-bytes, argcount, [arg-bitshift, arg-flags]...
; e.g.:
; .instruction "nibbles ~0,~1,~2,~3", 0, 0x0000, 2, 4, 0,0x44,4,0x44,8,0x44,12,0x044
;

.set FLAG_CONT			0x01		; can continue to next location
.set FLAG_REL			0x02		; PC relative (SHOULD THIS BE HERE?)
.set FLAG_EXTENDED		0x04		; only used in parsemindx
.set FLAG_DISASMTO		0x10		; use this version for disasm if there are multiple macros which asm to this

.set MAX_ARGS			4

; argument flags for type checking
.set ARGFLAG_U			0x00000040		; unsigned
.set ARGFLAG_S			0x00000080		; signed
.set ARGFLAG_4			0x00000004		; 4 bits
.set ARGFLAG_7			0x00000007		; 7 bits
.set ARGFLAG_8			0x00000008		; 8 bits
.set ARGFLAG_16			0x00000010		; 16 bits
.set ARGFLAG_BITS		0x0000001F

; argument flags for calculation
.set ARGFLAG_REL		0x00000100		; PC relative
.set ARGFLAG_HIGH		0x00000200		; shift argument by 8 bits

; argument flags for meta information
.set ARGFLAG_REG		0x00010000		; register
.set ARGFLAG_IMM		0x00020000		; only used in parsemindx
.set ARGFLAG_OFS		0x00040000		; only used in parsemindx
.set ARGFLAG_INT		0x00080000		; interrupt (only used in parsemindx)
