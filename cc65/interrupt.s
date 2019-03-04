; ---------------------------------------------------------------------------
; interrupt.s
; ---------------------------------------------------------------------------
;
; Interrupt handler.
;
; Checks for a BRK instruction and returns from all valid interrupts.

.import   _stop
.export   _irq_int, _nmi_int

.segment  "CODE"

; EMEB 03-04-19 - removed 65C02 instructions from ISR
;.PC02                             ; Force 65C02 assembly mode
;

; ---------------------------------------------------------------------------
; Non-maskable interrupt (NMI) service routine

_nmi_int:  RTI                    ; Return from all NMI interrupts

; ---------------------------------------------------------------------------
; Maskable interrupt (IRQ) service routine

_irq_int:  PHA                    ; Save accumulator contents to stack
           TXA                    ; Save X register contents to stack
           PHA
           TSX                    ; Transfer stack pointer to X
           INX                    ; Increment X so it points to the status
           INX                    ;   register value saved on the stack
           LDA $100,X             ; Load status register contents
           AND #$10               ; Isolate B status bit
           BNE break              ; If B = 1, BRK detected

; ---------------------------------------------------------------------------
; IRQ detected, return

irq:       PLA                    ; Restore X register contents
           TAX
           PLA                    ; Restore accumulator contents
           RTI                    ; Return from all IRQ interrupts

; ---------------------------------------------------------------------------
; BRK detected, stop

break:     JMP _stop              ; If BRK is detected, something very bad
                                  ;   has happened, so stop running
