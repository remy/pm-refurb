;-----------------------------------------------------------------------------
; BIOS
;-----------------------------------------------------------------------------

	.org		0
	.incbin		includes/bios.min		; must specify that bios.min is inside includes
										; because the assembly will happen from one directory up

;-----------------------------------------------------------------------------
; Memory addresses
;-----------------------------------------------------------------------------

	.equ		VRAM		$1000
	.equ		OAM			$1300
	.equ		TILEMAP		$1360

	.equ		REG_BASE	$2000


	.equ		BIOS_SIZE		$1000
	.equ		RAM_SIZE		$1000
	.equ		IO_SIZE			$0100
	.equ		ROM_SIZE		$80000


	.reloc
BIOS_BEGIN:		.ds		BIOS_SIZE
BIOS_END:
RAM_BEGIN:		.ds		RAM_SIZE
RAM_END:
IO_BEGIN:		.ds		IO_SIZE
IO_END:
USER_BEGIN:
	.endreloc

	.equ		NN				IO_BEGIN		; you can use [NN+...] instead of [nn+...] when required


;-----------------------------------------------------------------------------
; I/O address offsets
;-----------------------------------------------------------------------------

	.equ		BUTTONS			$52

	.equ		IO_DIR			$60
	.equ		IO_DATA			$61

	.equ		VIDEO_0			$80
	.equ		VIDEO_1			$81
	.equ		VIDEO_TILEDATA	$82		; word

	.equ		COUNTER2		$08

	.equ		CPU0			$00
	.equ		CPU2			$02

;-----------------------------------------------------------------------------
; I/O bits
;-----------------------------------------------------------------------------

	.equ		BUTTON_A		$01
	.equ		BUTTON_B		$02
	.equ		BUTTON_C		$04
	.equ		BUTTON_UP		$08
	.equ		BUTTON_DOWN		$10
	.equ		BUTTON_LEFT		$20
	.equ		BUTTON_RIGHT	$40
	.equ		BUTTON_POWER	$80

	.equ		RUMBLE			$10

	.equ		CPU2_SPEED		$08

	.equ		COUNTER2_START	$01
	.equ		COUNTER2_RESET	$02

	.equ		VIDEO_0_INVERT	$01
	.equ		VIDEO_0_TILED	$02
	.equ		VIDEO_0_ENABLE0	$08
	.equ		VIDEO_0_TSIZE0	$10
	.equ		VIDEO_0_TSIZE1	$20

	.equ		VIDEO_1_ENABLE1	$01
	.equ		VIDEO_1_SLOW0	$02
	.equ		VIDEO_1_SLOW1	$04

;-----------------------------------------------------------------------------
; Interrupt numbers
; https://github.com/logicplace/pm-dev-docs/blob/master/PM_IRQs.md#vector-tables
 ;-----------------------------------------------------------------------------

	.equ		INT_SUSPEND		$21
	.equ		INT_SHUTDOWN	$24

# int buttons
	.equ		REG_EVENT1P		$21            ; priorty register
	.equ		INT1P_KEYPAD	0b1100        ; range in priority register
	# enable
	.equ		REG_EVENT1S	$25
	.equ		INT1S_KEY_A		0b1
	.equ		INT1S_KEY_B		0b10
	.equ		INT1S_KEY_C		0b100
	.equ		INT1S_KEY_UP	0b1000
	.equ		INT1S_KEY_DOWN	0b10000
	.equ		INT1S_KEY_LEFT	0b100000
	.equ		INT1S_KEY_RIGHT	0b1000000
	.equ		INT1S_KEY_POWER	0b10000000
	.equ		REG_INT1P_FLAG	$29            ; hardware strobe
	.equ		IF_KEY_A		0b1
	.equ		IF_KEY_B		0b10
	.equ		IF_KEY_C		0b100
	.equ		IF_KEY_UP		0b1000
	.equ		IF_KEY_DOWN		0b10000
	.equ		IF_KEY_LEFT		0b100000
	.equ		IF_KEY_RIGHT	0b1000000
	.equ		IF_KEY_POWER	0b10000000

# int shock
	.equ		REG_EVENT2P		$22
	.equ		INT2P_SHOCK		0b11
	# enable
	.equ		REG_EVENT2S		$26
	.equ		INT2S_SHOCK		0b1000000
	.equ		REG_INT_FLAG	$2a
