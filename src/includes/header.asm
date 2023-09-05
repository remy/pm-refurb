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
	.equ		REG_EVENT1P		$21			; priorty register
	.equ		INT1P_KEYPAD	0b1100		; range in priority register
	# enable
	.equ 		REG_EVENT1S		$25
	.equ		INT1S_KEY_A		0b1
	.equ		INT1S_KEY_B		0b10
	.equ		INT1S_KEY_C		0b100
	.equ		INT1S_KEY_UP	0b1000
	.equ		INT1S_KEY_DOWN	0b10000
	.equ		INT1S_KEY_LEFT	0b100000
	.equ		INT1S_KEY_RIGHT 0b1000000
	.equ		INT1S_KEY_POWER 0b10000000
	.equ		REG_INT1P_FLAG	$29			; hardware strobe
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

# int audio

	.equ		REG_EVENT3P		$20
	.equ		INT3P_TIMER1OVERFLOW	0b1100
	.equ		INT3P_TIMER2OVERFLOW	0b110000
	.equ		INT3P_TIMER3OVERFLOW	0b11
	.equ		INT3P_V			0b11000000
# secondary enable
	.equ		REG_EVENT3S		$23
	.equ		INT3S_TIMER3OVERFLOW    0b1 ##INT #8
	.equ		INT3S_TIMER3OVERFLOW    0b10 ##INT #8
	.equ		INT3S_TIMER1OVERFLOW    0b1000 ##INT #5
	.equ		INT3S_TIMER2OVERFLOW    0b100000 ##INT #3
	.equ		INT3S_VDRAW		0b1000000 ##INT #2
	.equ		INT3S_VBLANK		0b10000000 ##INT #1


## EEPROM&IO REGISTERS
	.equ 	REG_IO_ENABLE		$60
	.equ	IO_IR				0b10
	.equ	IO_EEPROM_DATA		0b100
	.equ	IO_EEPROM_CLOCK		0b1000
	.equ	IO_EEPROM_RUMBLE	0b10000
	.equ	IO_IR_ENABLE		0b100000

	.equ 	IO_EEPROM_DATA_OFF	0b11111011
	.equ	IO_EEPROM_CLOCK_OFF	0b11110111

	.equ 	REG_IO_DATA			$61
	.equ	IO_IR_IN			0b1
	.equ	IO_IR_OUT			0b10



# AUDIO TIMER
	.equ	REG_VOLUME				$71

	.equ	REG_TIMER3_CNT1			$48
	.equ	REG_TIMER3_CNT2			$49
	.equ	REG_TIMER3_PRESET		$4A
	.equ	REG_TIMER3_PIVOT		$4C
	.equ	REG_TIMER3_COUNT		$4E


	.equ	REG_TIMER2_CNT1			$38
	.equ	REG_TIMER2_CNT2			$39
	.equ	REG_TIMER2_PRESET		$3A
	.equ	REG_TIMER2_PIVOT		$3C #unused?
	.equ	REG_TIMER2_COUNT		$3E


	.equ	REG_TIMER1_CNT1			$30
	.equ	REG_TIMER1_CNT2			$31
	.equ	REG_TIMER1_PRESET		$32
	.equ	REG_TIMER1_PIVOT		$34
	.equ	REG_TIMER1_COUNT		$36

	.equ	TIMER_ENABLE			$80
	.equ	TIMER_PRESET			$04

	.equ	REG_TIMER_CONTROL		$19
	.equ	TIMERS_ON				$20

	.equ	REG_TIMER1_PRESCALE		$18
	.equ	REG_TIMER2_PRESCALE		$1A
	.equ	REG_TIMER3_PRESCALE		$1C
	.equ	PRESCALE_ENABLE			0b01000
	.equ	PRESCALE_FREQ_2MHZ		0
	.equ	PRESCALE_FREQ_500KHZ	1
	.equ	PRESCALE_FREQ_125KHZ	2
	.equ	PRESCALE_FREQ_62500HZ	3
	.equ	PRESCALE_FREQ_31250HZ	4
	.equ	PRESCALE_FREQ_15625HZ	5
	.equ	PRESCALE_FREQ_3906HZ	6
	.equ	PRESCALE_FREQ_976HZ		7

# SECONDS TIMER
	.equ    REG_SECONDS_TIMER_CNT	$08
	.equ	REG_SECONDS_TIMER_DL	$09
	.equ	REG_SECONDS_TIMER_DM	$0A
	.equ	REG_SECONDS_TIMER_DH	$0B

#### INT #1 - #8
.equ	REG_INT_FLAG1		$27
.equ	IF_TIMER3OVERFLOW	0b1
.equ	IF_TIMER3OVERFLOW	0b10
.equ	IF_TIMER1OVERFLOW	0b1000
.equ	IF_TIMER2OVERFLOW	0b100000
.equ	IF_VDRAW		0b1000000
.equ	IF_VBLANK		0b10000000
