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


	; set interrupts

	movb	[nn+REG_INT_FLAG],INT2S_SHOCK ; clear the state
    movb	[nn+REG_EVENT1P],INT1P_KEYPAD ; clear the current state

	; enable the interrupts
	movb	[nn+REG_EVENT1S],INT1S_KEY_UP|INT1S_KEY_DOWN|INT1S_KEY_LEFT|INT1S_KEY_RIGHT|INT1S_KEY_POWER|INT1S_KEY_A|INT1S_KEY_B|INT1S_KEY_C

    movb	[nn+REG_EVENT2P],INT2P_SHOCK
    movb	[nn+REG_EVENT2S],INT2S_SHOCK

	; set tile data pointer point to the loaded bitmaps
	mov		x1, tile_data
	movw	[REG_BASE+VIDEO_TILEDATA], x1

	call 	fill_screen

	; Activate all interrupts
	mov 	flags, 0

	call play_sfx_1

main_loop:
	jr main_loop


pressed_power:
	movb	[nn+REG_INT1P_FLAG],IF_KEY_POWER
	test	[nn+$52],$80		# Power key
	jnz		noturnoff
	cint	INT_SHUTDOWN			# bye bye
noturnoff:
	reti

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
	movb	[nn+REG_INT1P_FLAG],IF_KEY_LEFT
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
	reti

pressed_right:
	movb	[nn+REG_INT1P_FLAG],IF_KEY_RIGHT
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
	reti

pressed_up:
	movb	[nn+REG_INT1P_FLAG],IF_KEY_UP
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
	reti

pressed_down:
	movb	[nn+REG_INT1P_FLAG],IF_KEY_DOWN
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
	reti

pressed_a:
    movb [nn+REG_INT1P_FLAG],IF_KEY_A
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
	reti

pressed_b:
	movb	[nn+REG_INT1P_FLAG],IF_KEY_B
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
	reti

pressed_c:
	movb [nn+REG_INT1P_FLAG],IF_KEY_C
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
	push b
	mov	[nn+$61],$10		; RUMBLE!
	;   ret
	mov b, $ff

rumble_loop:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	jdbnz rumble_loop
	mov	[nn+$61],$64 ; stop rumble
	pop 	b
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
