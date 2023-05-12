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

;-----------------------------------------------------------------------------
; Variables
;-----------------------------------------------------------------------------
.org 0x1300
btnMarker: .ds $FA
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
    jmp unhandled_interrupt
#INT #16
.orgfill 0x2162   #KEY PRESS: D-PAD RIGHT
    jmp unhandled_interrupt
#INT #17
.orgfill 0x2168   #KEY PRESS: D-PAD LEFT
    jmp unhandled_interrupt
#INT #18
.orgfill 0x216E   #KEY PRESS: D-PAD DOWN
    jmp unhandled_interrupt
#INT #19
.orgfill 0x2174   #KEY PRESS: D-PAD UP
    jmp unhandled_interrupt
#INT #20
.orgfill 0x217A   #KEY PRESS: C KEY
    jmp unhandled_interrupt
#INT #21
.orgfill 0x2180   #KEY PRESS: B KEY
    jmp unhandled_interrupt
#INT #22
.orgfill 0x2186   #KEY PRESS: A KEY
    jmp unhandled_interrupt
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

	movb	[nn+REG_INT_FLAG],INT2S_SHOCK

	; set interrupt on shock
    movb	[nn+REG_EVENT2P],INT2P_SHOCK
    movb	[nn+REG_EVENT2S],INT2S_SHOCK

	; set tile data pointer point to the loaded bitmaps
	mov		x1, tile_data
	movw	[REG_BASE+VIDEO_TILEDATA], x1

	call 	fill_screen

	; Activate all interrupts
	mov 	flags, 0

	call 	rumble

main_loop:
	call keys_wait_for_release
	call keys_wait_for_press

check_input:
	test [nn+BUTTONS], BUTTON_POWER
	jz pressed_power
	test [nn+BUTTONS], BUTTON_LEFT
	jz pressed_left
	test [nn+BUTTONS], BUTTON_RIGHT
	jz pressed_right
	test [nn+BUTTONS], BUTTON_UP
	jz pressed_up
	test [nn+BUTTONS], BUTTON_DOWN
	jz pressed_down
	test [nn+BUTTONS], BUTTON_A
	jz pressed_a
	test [nn+BUTTONS], BUTTON_B
	jz pressed_b
	test [nn+BUTTONS], BUTTON_C
	jz pressed_c

	jmp main_loop

pressed_power:
	int		INT_SHUTDOWN

int_shock:
	pusha

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
	popa
	reti

pressed_left:
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
	jmp main_loop

pressed_right:
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
	jmp main_loop

pressed_up:
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
	jmp main_loop

pressed_down:
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
	jmp main_loop

pressed_a:
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
	; call rumble_stop
	jmp main_loop

pressed_b:
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
	jmp main_loop

pressed_c:
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
; 	mov a, [btnC]
; 	cmp a, 0
; 	jnz _skip_rumble
; _skip_rumble:
	jmp main_loop


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
	push a
	push b
put_tile_loop:
	add a, 12      ; a := a + 12*b
	jdbnz put_tile_loop ;

	mov x2, TILEMAP
	mov l, a
	mov b, [x1]
	mov [x2+l], b

	pop b
	pop a
	ret

;-----------------------------------------------------------------------------
; Rumble -  this doesnt quite work yet
;-----------------------------------------------------------------------------
rumble:
  push ba

;   mov [nn+$60],$10		; RUMBLE!
  mov [nn+$61],$10		; RUMBLE!

  mov a, $ff
_rumble_loop_outer:
  mov b, $ff

_rumble_loop:
	jdbnz _rumble_loop
	dec a
	JNZ _rumble_loop_outer

	mov	[nn+$61],$64 ; stop rumble
	pop ba
	ret


;-----------------------------------------------------------------------------
; keys_wait_for_press
;-----------------------------------------------------------------------------
keys_wait_for_press:
	mov		a, [nn+BUTTONS]
	cmp		a, 0xFF
	jz		keys_wait_for_press
	ret

;-----------------------------------------------------------------------------
; keys_wait_for_release
;-----------------------------------------------------------------------------
keys_wait_for_release:
	mov		a, [nn+BUTTONS]
	cmp		a, 0xFF
	jnz		keys_wait_for_release
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

author: .db "Written by Remy Sharp, 2023"

	.align 8

tile_data:
	.incbin includes/tiles.bin

	.end
