; rom_512.asm
; 6502 assembly in acme syntax for for tst_6502.
; E. Brombaugh 03-02-19

; some fixed addresses in the design
tst_ram   = $0000
tst_gpio  = $1000
acia_ctl  = $2000
acia_dat  = $2001
tst_rom   = $fe00
cpu_nmi   = $fffa
cpu_reset = $fffc
cpu_irq   = $fffe

; some variables
led_bits  = tst_ram
dly_cnt	  = tst_ram + 1
str_low   = tst_ram + 2
str_high  = tst_ram + 3
tst_chr   = tst_ram + 4

; start of program at start of ROM
	*= tst_rom
	
; initiaize stack pointer
	ldx #$ff
	txs

; initialize led data
	lda #8
	sta led_bits

; initialize test character
	lda #0
	sta tst_chr

; initialize ACIA
	lda #$03			; reset ACIA
	sta acia_ctl
	lda #$00			; normal running
	sta acia_ctl

; send startup message
	jsr startup_msg

; enable ACIA RX IRQ
	lda #$80			; rx irq enable
	sta acia_ctl
	cli					; enable irqs
	
; main loop
lp	lda #16				; delay 16 outer loops
	jsr delay
	lda led_bits		; get LED state
	sta tst_gpio		; save to GPIO
	clc					; shift left
	rol
	bcc +				; reload if bit shifted out msb
	lda #8
+	sta led_bits		; save new state
;	lda tst_chr			; send test character
;	and #$7f
;	jsr send_chr
;	inc tst_chr			; advance test char
	jmp lp				; loop forever
	
; delay routine
delay
	sta dly_cnt			; save loop count
	txa					; temp save x
	pha
	tya					; temp save y
	pha
-	ldx #0				; init x loop
--	ldy #0				; init y loop
---	dey
	bne ---				; loop on y
	dex
	bne --				; loop on x
	dec dly_cnt
	bne -				; loop on loop count
	pla					; restore y
	tay
	pla					; restore x
	tax
	rts

; send startup message
startup_msg
	pha					; temp save acc
	lda #< start_string	; get addr of string for send routine
	sta str_low
	lda #> start_string
	sta str_high
	jsr send_str		; send it
	pla					; restore acc
	rts

; send a max 255 char string to serial port
send_str
	tya					; temp save y
	pha
	ldy #0				; point to start of string
-	lda (<str_low),y	; get char
	beq +				; terminator?
	jsr send_chr		; no, send
	iny					; advance pointer
	bne -				; loop if < 256 sent
+	pla					; restore y
	tay
	rts

; send a single character to serial port
send_chr
	pha					; temp save char to send
-	lda acia_ctl		; wait for TX empty
	and #$02
	beq -
	pla					; restor char
	sta acia_dat		; send
	rts

; interrupt service routine for serial RX
isr
	pha					; save acc
	lda acia_dat		; get data, clear irq
	jsr send_chr		; echo it
	pla					; restore acc
	rti

; end of program

; strings
start_string
	!raw 13, 10, 10, "Icestick 6502 serial test", 13, 10, 10, 0

; vectors
	*= cpu_nmi
	!word tst_rom
	*= cpu_reset
	!word tst_rom
	*= cpu_irq
	!word isr
	


