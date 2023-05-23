;-----------------------------------------------------------------------------
;
; Refurb
;       by Remy Sharp, 2023
;       https://remysharp.com
;
; Utility ROM to test Pokemon Mini after refurb.
;
;-----------------------------------------------------------------------------

	.include ./includes/header.asm
	.include ./includes/pm_init.asm
	.include ./includes/pm_music.asm


;-----------------------------------------------------------------------------
; Variables
;-----------------------------------------------------------------------------
.equ 	EEPROM_DATA_ADDR $0000			; we're going to read GB from the eeprom
.equ	EEPROM_DATA_SIZE	2

.org 0x1300
error: .db 0
eeprom_buffer: .ds EEPROM_DATA_SIZE
btnA: .db 0
btnB: .db 0
btnC: .db 0
btnD: .db 0
btnU: .db 0
btnL: .db 0
btnR: .db 0
btnS: .db 0

;-----------------------------------------------------------------------------
; Header
;-----------------------------------------------------------------------------

	.org 0x2100
# ROM ID (part of ROM header, this is needed or the ROM won't run)
	.db		"MN"
begin:
	jmp		start

# interrupt handlers - most of which I don't use

#INT #1
.orgfill 0x2108   #V-BLANK
    jmp unhandled_interrupt # not handled
#INT #2
.orgfill 0x210E   #V-DRAW
    jmp unhandled_interrupt
#INT #3
.orgfill 0x2114   #TIMER 2 OVERFLOW
	jmp unhandled_interrupt
#INT #4
.orgfill 0x211A   #
    jmp unhandled_interrupt
#INT #5
.orgfill 0x2120   #TIMER 1 OVERFLOW
	jmp unhandled_interrupt
#INT #6
.orgfill 0x2126   #
    #jmp unhandled_interrupt
#INT #7
.orgfill 0x212C   #TIMER 3 OVERFLOW
    jmp unhandled_interrupt
#INT #8
.orgfill 0x2132   #TIMER 3 OVERFLOW
    jmp unhandled_interrupt
#INT #9
.orgfill 0x2138   #
    jmp unhandled_interrupt
#INT #10
.orgfill 0x213E   #
    jmp unhandled_interrupt
#INT #11
.orgfill 0x2144   #
    jmp unhandled_interrupt
#INT #12
.orgfill 0x214A   #
    jmp unhandled_interrupt
#INT #13
.orgfill 0x2150   #IR RECEIVE LOW TO HIGH
    jmp unhandled_interrupt
#INT #14
.orgfill 0x2156   #SHOCK DETECTOR
    jmp int_shock
#INT #15
.orgfill 0x215C   #KEY PRESS: POWER BUTTON
    jmp pressed_power
#INT #16
.orgfill 0x2162   #KEY PRESS: D-PAD RIGHT
    jmp pressed_right
#INT #17
.orgfill 0x2168   #KEY PRESS: D-PAD LEFT
    jmp pressed_left
#INT #18
.orgfill 0x216E   #KEY PRESS: D-PAD DOWN
    jmp pressed_down
#INT #19
.orgfill 0x2174   #KEY PRESS: D-PAD UP
    jmp pressed_up
#INT #20
.orgfill 0x217A   #KEY PRESS: C KEY
    jmp pressed_c
#INT #21
.orgfill 0x2180   #KEY PRESS: B KEY
    jmp pressed_b
#INT #22
.orgfill 0x2186   #KEY PRESS: A KEY
    jmp pressed_a
#INT #23
.orgfill 0x218C   #
    jmp unhandled_interrupt
#INT #24
.orgfill 0x2192   #
    jmp unhandled_interrupt
#INT #25
.orgfill 0x2198   #
    jmp unhandled_interrupt

	.org	0x21A4
	.db		"NINTENDO"		; magic string
	.db		"REFURB    "	; name
	.db		"REFB"			; 4-character gamecode
	.db		"2P"			;

unhandled_interrupt:
	reti

start:

	# set SP to end of general purpose RAM (stack grows downwards)
    movw	sp, 0x2000
    # NN register points to hardware registers
    movw	nn, 0x2000

	;movw nn, IO_BEGIN
	; set tiled mode 12x8, non-inverted, and enable video
	movb	[nn+VIDEO_0], $02+$08
	movb	[nn+VIDEO_1], $01+$08

	; interrupts

	; enable the input interrupts
    movb	[nn+REG_EVENT1P],INT1P_KEYPAD ; clear the current state
	movb	[nn+REG_EVENT1S],INT1S_KEY_UP|INT1S_KEY_DOWN|INT1S_KEY_LEFT|INT1S_KEY_RIGHT|INT1S_KEY_POWER|INT1S_KEY_A|INT1S_KEY_B|INT1S_KEY_C

	; shock
	movb	[nn+REG_INT_FLAG],INT2S_SHOCK ; clear the state
    movb	[nn+REG_EVENT2P],INT2P_SHOCK
    movb	[nn+REG_EVENT2S],INT2S_SHOCK

	; get irqs working in minimon
	mov		flags, 0


	; set tile data pointer point to the loaded bitmaps
	mov		x1, tile_data
	movw	[REG_BASE+VIDEO_TILEDATA], x1

	call 	fill_screen
	call	get_eeprom_data

	call	is_eeprom_ok

	call 	rumble


main_loop:
	jr main_loop

is_eeprom_ok:
	mov 	x2, TILEMAP
	ld		l, 75
	mov 	x1, eeprom_tile
	mov 	b, 4
_eeprom_print:
	call	print_loop

	ld		x1, [eeprom_buffer]
	cmp		x1, $4247 ; "GB"

	jnz		_eeprom_print_bad
	mov 	x1, eeprom_tile_ok
	jr		_eeprom_print_res
_eeprom_print_bad:
	mov 	x1, eeprom_tile_bad
_eeprom_print_res:
	mov 	b, 2
	call	print_loop

_eeprom_end:
	ret

print_loop:
	mov 	a, [x1]
	mov 	[x2+l], a
	inc 	l
  	inc 	x1
	jdbnz 	print_loop
	ret

pressed_power:
	movb	[nn+REG_INT1P_FLAG],IF_KEY_POWER
	test	[nn+$52],$80		# Power key
	jnz		noturnoff
	cint	INT_SHUTDOWN			# bye bye
noturnoff:
	reti

int_shock:
	push ale

	movb [nn+REG_INT_FLAG],INT2S_SHOCK
	mov a, [btnS]
	inc a
	andb a, $f ; mask only the first nibble
	mov [btnS], a
	mov x1, tile_counter
	mov b, 0
	addw x1, ba

	mov a, 9 ; x axis
	mov b, 4
	call put_tile
	pop ale
	reti

pressed_left:
	push ale
	movb	[nn+REG_INT1P_FLAG],IF_KEY_LEFT
	test	[nn+BUTTONS],IF_KEY_LEFT
	jnz		notdown_left

	mov a, [btnL]
	inc a
	andb a, $f ; mask only the first nibble
	mov [btnL], a
	mov x1, tile_counter
	mov b, 0
	addw x1, ba

	mov a, 5 ; x axis
	mov b, 4
	call put_tile
notdown_left:
	pop ale
	reti

pressed_right:
	push ale
	movb	[nn+REG_INT1P_FLAG],IF_KEY_RIGHT
	test	[nn+BUTTONS],IF_KEY_RIGHT
	jnz		notdown_right

	mov a, [btnR]
	inc a
	andb a, $f ; mask only the first nibble
	mov [btnR], a
	mov x1, tile_counter
	mov b, 0
	addw x1, ba

	mov a, 7 ; x axis
	mov b, 4
	call put_tile
notdown_right:
	pop ale
	reti

pressed_up:
	push ale
	movb	[nn+REG_INT1P_FLAG],IF_KEY_UP
	test	[nn+BUTTONS],IF_KEY_UP
	jnz		notdown_up
	mov a, [btnU]
	inc a
	andb a, $f ; mask only the first nibble
	mov [btnU], a
	mov x1, tile_counter
	mov b, 0
	addw x1, ba

	mov a, 6 ; x axis
	mov b, 4
	call put_tile
notdown_up:
	pop ale
	reti

pressed_down:
	push ale
	movb	[nn+REG_INT1P_FLAG],IF_KEY_DOWN
	test	[nn+BUTTONS],IF_KEY_DOWN
	jnz		notdown_down
	mov a, [btnD]
	inc a
	andb a, $f ; mask only the first nibble
	mov [btnD], a
	mov x1, tile_counter
	mov b, 0
	addw x1, ba

	mov a, 8 ; x axis
	mov b, 4
	call put_tile
notdown_down:
	pop ale
	reti

pressed_a:
	push ale
    movb [nn+REG_INT1P_FLAG],IF_KEY_A
	test	[nn+BUTTONS],IF_KEY_A
	jnz		notdown_a
	mov a, [btnA]
	inc a
	andb a, $f ; mask only the first nibble
	mov [btnA], a
	mov x1, tile_counter
	mov b, 0
	addw x1, ba

	mov a, 2 ; x axis
	mov b, 4
	call put_tile
notdown_a:
	pop ale
	reti

pressed_b:
	push ale
	movb	[nn+REG_INT1P_FLAG],IF_KEY_B
	test	[nn+BUTTONS],IF_KEY_B
	jnz		notdown_b
	mov a, [btnB]
	inc a
	andb a, $f ; mask only the first nibble
	mov [btnB], a
	mov x1, tile_counter
	mov b, 0
	addw x1, ba

	mov a, 3 ; x axis
	mov b, 4
	call put_tile
notdown_b:
	pop ale
	reti

pressed_c:
	push ale
	movb [nn+REG_INT1P_FLAG],IF_KEY_C
	test	[nn+BUTTONS],IF_KEY_C
	jnz		notdown_c
	mov a, [btnC]
	inc a
	andb a, $f ; mask only the first nibble
	mov [btnC], a
	mov x1, tile_counter
	mov b, 0
	addw x1, ba

	mov a, 4 ; x axis
	mov b, 4
	call put_tile
notdown_c:
	pop ale
	; call rumble
	reti


clear_screen:
	mov x2, TILEMAP
	mov x1, tile_empty
	mov a, [x1]
	mov b, 12 * 8
_clear_screen:
	mov [x2+l], a
	inc l
	jdbnz _clear_screen
	ret

;-----------------------------------------------------------------------------
; Fills screen with background
;-----------------------------------------------------------------------------
fill_screen:
	mov x2, TILEMAP
; top left corner
	mov x1, tile_bg_tl
	mov a, [x1]
	mov [x2+l], a
	inc l

	mov x1, tile_bg_t
	mov b, 10
fill_top: ; top row
	mov a, [x1]
	mov [x2+l], a
	inc l
	jdbnz fill_top

; top right corner
	mov x1, tile_bg_tr
	mov a, [x1]
	mov [x2+l], a
	inc l

	mov b, 6
fill_sides: ; left and right sides
	mov x1, tile_bg_l
	mov a, [x1]
	mov [x2+l], a

	inc l
	inc l

	; check here if we're on the row for letters
printing_buttons:
	push a
	movb a, l
	xor a, $26 ; if we're on the start of the letters, show them instead
	jnz fill_sides_continued
	push b

	mov b, 8
	mov x1, tile_a
print_button_loop:
	mov a, [x1] ; might need to subtract L (if possible)
	mov [x2+l], a
  	incw x1
	inc l
	jdbnz print_button_loop

	pop b
	pop a
	jmp fill_sides_continued_after_buttons

fill_sides_continued:
	pop a

	inc l ; a
	inc l ; b
	inc l ; c
	inc l ; left
	inc l ; up
	inc l ;	right
	inc l ; down
	inc l ; shock
fill_sides_continued_after_buttons:
	inc l ; empty


	mov x1, tile_bg_r
	mov a, [x1]
	mov [x2+l], a
	inc l

	jdbnz fill_sides

	mov x1, tile_bg_bl
	mov a, [x1]
	mov [x2+l], a
	inc l

	mov x1, tile_bg_b
	mov b, 10
fill_bottom: ; top row
	mov a, [x1]
	mov [x2+l], a
	inc l
	jdbnz fill_bottom

; top right corner
	mov x1, tile_bg_br
	mov a, [x1]
	mov [x2+l], a

	ret

;-----------------------------------------------------------------------------
; Input:
; 		x1 - tile data
;		a - column
;		b - row
;-----------------------------------------------------------------------------
put_tile:
put_tile_loop:
	add a, 12      ; a := a + 12*b
	jdbnz put_tile_loop ;

	mov x2, TILEMAP
	mov l, a
	mov b, [x1]
	mov [x2+l], b

	ret

;-----------------------------------------------------------------------------
; Rumble
;-----------------------------------------------------------------------------
rumble:
  push ba

  mov [nn+$61],$10		; RUMBLE!

  ; rumble for 0xffff amount of loops - it's about the right timing
  mov a, $ff
_rumble_loop_outer:
  mov b, $ff

_rumble_loop:
	jdbnz _rumble_loop
	dec a
	jnz _rumble_loop_outer

	mov	[nn+$61],$64 ; stop rumble
	pop ba
	ret




play_sfx_1:
	mov b, 0
	mov a, 0
	shl a
	shl a
	mov hl, sfx_list
	add hl, ba
	mov b, [hl]
	dec hl
	dec hl
	mov hl, [hl]

	call pmmusic_playsfx
	ret


;-----------------------------------------------------------------------------
; EEPROM methods
;-----------------------------------------------------------------------------

get_eeprom_data:
	# enable the eeprom lines
	orb		[nn+REG_IO_ENABLE], IO_EEPROM_DATA|IO_EEPROM_CLOCK

	ld		x1, EEPROM_DATA_ADDR

	call	start_condition

	# write device address byte
	mov		a, 0b10100000						# dummy write, to set address
	call 	send_byte
	mov		ba, x1								# get high byte off address
	mov		a, b
	call 	send_byte
	mov		ba, x1								# and low byte
	call 	send_byte
	# now set to read
	call	start_condition
	mov		a, 0b10100001						# read
	call 	send_byte

	# read into buffer
	mov		x2,	eeprom_buffer
	mov		l, 0

read_data:
	andb	[nn+REG_IO_ENABLE], IO_EEPROM_DATA_OFF	# switch data line to read
	call	read_byte
	andb	[nn+REG_IO_DATA], IO_EEPROM_CLOCK_OFF	# clock down
	orb		[nn+REG_IO_ENABLE], IO_EEPROM_DATA		# switch data line to write

	mov		[x2+l], a
	inc		l
	cmp		l, EEPROM_DATA_SIZE
	jz		all_read
	#send ack
	andb	[nn+REG_IO_DATA], IO_EEPROM_DATA_OFF	# data down
	orb		[nn+REG_IO_DATA], IO_EEPROM_CLOCK		# clock up
	andb	[nn+REG_IO_DATA], IO_EEPROM_CLOCK_OFF	# clock down
	jmp		read_data

all_read:
	#send stop condition
	orb		[nn+REG_IO_DATA], IO_EEPROM_CLOCK		# clock up
	orb		[nn+REG_IO_DATA], IO_EEPROM_DATA		# data up
	andb	[nn+REG_IO_DATA], IO_EEPROM_CLOCK_OFF	# clock down

	# disable the eeprom lines
	andb	[nn+REG_IO_ENABLE], IO_EEPROM_DATA_OFF&IO_EEPROM_CLOCK_OFF

	ret


# start condition - data down, clock down
start_condition:
	orb		[nn+REG_IO_DATA], IO_EEPROM_DATA		# data up
	orb		[nn+REG_IO_DATA], IO_EEPROM_CLOCK		# clock up
	andb	[nn+REG_IO_DATA], IO_EEPROM_DATA_OFF
	andb	[nn+REG_IO_DATA], IO_EEPROM_CLOCK_OFF
	ret
#--------------------------------------------
# send byte - transmit a byte of data
# assumes clock is down, destroys b
# input is in a
send_byte:
	mov		b, 8
_send_bit:
	andb	[nn+REG_IO_DATA], IO_EEPROM_CLOCK_OFF	# clock down
	rolb	a										# msb to lsb
	test	a, 1
	jz		_send_bit_off
	orb		[nn+REG_IO_DATA], IO_EEPROM_DATA		# switch bit on
	jmp 	_next_bit

_send_bit_off:
	andb	[nn+REG_IO_DATA], IO_EEPROM_DATA_OFF	#switch bit off

_next_bit:
	orb		[nn+REG_IO_DATA], IO_EEPROM_CLOCK		# clock up
	jdbnz	_send_bit

	# ack
	andb	[nn+REG_IO_DATA], IO_EEPROM_CLOCK_OFF	# clock down
	andb	[nn+REG_IO_ENABLE],	IO_EEPROM_DATA_OFF	# switch data line to read
	orb		[nn+REG_IO_DATA], IO_EEPROM_CLOCK		# clock up
	testb	[nn+REG_IO_DATA], IO_EEPROM_DATA		# read bit
	jnz		_do_something

	orb		[nn+REG_IO_ENABLE],	IO_EEPROM_DATA		# switch data line to write
	jmp		_done

_do_something:
	mov 	b, a
	mov		a, $ff
	mov		[error], a
	mov 	a, b
_done:
	andb	[nn+REG_IO_DATA], IO_EEPROM_CLOCK_OFF	# clock down
	ret
#--------------------------------------------
#read byte - receive a byte of data
# assumes clock is high, destroys b
#output goes in a
read_byte:
	mov		b, 8
	mov		a, 0
_read_bit:
	andb	[nn+REG_IO_DATA], IO_EEPROM_CLOCK_OFF	# clock down
	orb		[nn+REG_IO_DATA], IO_EEPROM_CLOCK		# clock up
	shlb	a
	testb	[nn+REG_IO_DATA], IO_EEPROM_DATA		#read bit
	jz		_next_read
	inc		a										# set low bit

_next_read:
	jdbnz	_read_bit

	ret
;-----------------------------------------------------------------------------
; Data
;-----------------------------------------------------------------------------

tile_empty: .db 0
tile_a: .db 1
tile_b: .db 2
tile_c: .db 3
tile_l: .db 4
tile_u: .db 5
tile_r: .db 6
tile_d: .db 7
tile_shock: .db 8
tile_ok: .db 9
tile_bg_tl: .db 10
tile_bg_t: .db 11
tile_bg_tr: .db 12
tile_bg_br: .db 13
tile_bg_bl: .db 14
tile_bg_l: .db 15
tile_bg_r: .db 16
tile_bg_b: .db 17

tile_counter: .db 18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34

eeprom_tile: .db 34,35,36,37
eeprom_tile_ok: .db 38,39
eeprom_tile_bad: .db 40,41


author: .db "Written by Remy Sharp, 2023"

sfx_list:
	.dd sound_fx0

sfx_list_last:	.db 1

	PMMUSIC_ALIGN

sound_fx0:
	PMMUSIC_ROW N_C_5, $80, 3, 1
	PMMUSIC_ROW N_B_4, $80, 3, 1
	PMMUSIC_ROW N_A_4, $80, 3, 1
	PMMUSIC_END


	.align 8

tile_data:
	.incbin includes/tiles.bin

	.end
