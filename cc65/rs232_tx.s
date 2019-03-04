; ---------------------------------------------------------------------------
; rs232_tx.s
; Modified for icestick_6502
; 03-04-19 E. Brombaugh
; ---------------------------------------------------------------------------
;
; Write a string to the transmit UART

.export         _rs232_tx
.exportzp       _rs232_data: near

.define         ACIA_CTRL $2000    ;  ACIA control register location
.define         ACIA_DATA $2001    ;  ACIA data register location

.zeropage

_rs232_data:    .res 2, $00      ;  Reserve a local zero page pointer

.segment  "CODE"

.proc _rs232_tx: near

; ---------------------------------------------------------------------------
; Store pointer to zero page memory and load first character

        sta     _rs232_data      ;  Set zero page pointer to string address
        stx     _rs232_data+1    ;    (pointer passed in via the A/X registers)
        ldy     #00              ;  Initialize Y to 0
        lda     (_rs232_data),y  ;  Load first character

; ---------------------------------------------------------------------------
; Main loop:  read data and store to FIFO until \0 is encountered

loop:   jsr     tx               ;  Loop:  send char to ACIA
        iny                      ;         Increment Y index
        lda     (_rs232_data),y  ;         Get next character
        bne     loop             ;         If character == 0, exit loop
        rts                      ;  Return
        
; ---------------------------------------------------------------------------
; wait for TX empty and send single character to ACIA

tx:     pha                      ; temp save char to send
txw:    lda      ACIA_CTRL       ; wait for TX empty
        and      #$02
        beq      txw
        pla                      ; restore char
        sta      ACIA_DATA       ; send
        rts

.endproc
