; ---------------------------------------------------------------------------
; init.s
; icestick_6502 main assembly routine
; 03-04-19 E. Brombaugh
; ---------------------------------------------------------------------------

.import   _acia_tx_str
.export   _init

.include  "fpga.inc"

.zeropage

_led_bits:      .res 1, $00        ;  Reserve a local zero page pointer
_dly_cnt:       .res 1, $00        ;  Reserve a local zero page pointer

.segment  "CODE"

; ---------------------------------------------------------------------------
; Execution starts here

_init:     ldx #$ff             ; initiaize stack pointer
		   txs
		   lda #8               ; initialize led data
		   sta _led_bits

; initialize ACIA
		   lda #$03				; reset ACIA
		   sta ACIA_CTRL
		   lda #$00				; normal running
		   sta ACIA_CTRL

; send startup message
           lda # .lobyte(start_str)
		   ldx # .hibyte(start_str)
		   jsr _acia_tx_str

; enable ACIA RX IRQ
		   lda #$80				; rx irq enable
		   sta ACIA_CTRL
		   cli					; enable irqs
	
; main loop
lp:        lda #16				; delay 16 outer loops
		   jsr delay
		   lda _led_bits		; get LED state
		   sta GPIO_DATA		; save to GPIO
		   clc					; shift left
		   rol
		   bcc sld 				; reload if bit shifted out msb
		   lda #8
sld:       sta _led_bits		; save new state
		   jmp lp				; loop forever
	
; ---------------------------------------------------------------------------
; delay routine
delay:     sta _dly_cnt			; save loop count
		   txa					; temp save x
		   pha
		   tya					; temp save y
		   pha
d1:	       ldx #0				; init x loop
d2:        ldy #0				; init y loop
d3:	       dey
		   bne d3				; loop on y
		   dex
		   bne d2				; loop on x
		   dec _dly_cnt
		   bne d1				; loop on loop count
		   pla					; restore y
		   tay
		   pla					; restore x
		   tax
		   rts

.segment  "RODATA"

; ---------------------------------------------------------------------------
; startup message

start_str:
          .byte $0A, $0A, $0D, "Icestick 6502 serial test.", $0A, $0A, $0D, $00
