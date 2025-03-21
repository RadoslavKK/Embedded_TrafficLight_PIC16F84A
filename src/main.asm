    LIST P=16F84A           ; Define the PIC microcontroller
    #INCLUDE <P16F84A.INC>  ; Include the microcontroller header

    _CONFIG_CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC_ON ; Disable code protection, disable WDT, enable XT oscillator, enable Power-up Timer

    ; Program Description:
    ; Define the address H'0C' as COUNTER.
    ; Define REG_NUMBER and REG_IFTIME registers.

    COUNTER     EQU H'0C'   ; COUNTER register
    REG_NUMBER  EQU H'0D'   ; REG_NUMBER register
    REG_IFTIME  EQU H'0E'   ; REG_IFTIME register

    ORG H'0000'             ; Set program origin
    GOTO START              ; Jump to START

; Program Operation:
START:
    BSF STATUS, RP0         ; Switch to Bank 1 (set bit 5 of STATUS)
    CLRF TRISB              ; Clear TRISB (configure PORTB as output)
    MOVLW B'10000100'       ; Load B'1000 0100' into WREG
    MOVWF OPTION_REG        ; Set OPTION_REG
    BCF STATUS, RP0         ; Switch back to Bank 0 (clear bit 5 of STATUS)
    CLRF TMR0               ; Clear TMR0
    GOTO BEGIN              ; Jump to BEGIN

; Bit Check:
WAIT:
    BTFSS REG_IFTIME, 0     ; Check bit 0 of REG_IFTIME
    MOVLW B'1111'           ; If bit is 0, load B'1111' into WREG
    MOVLW B'1010'           ; Otherwise, load B'1010' into WREG
    MOVWF COUNTER           ; Store value in COUNTER
    CLRF TMR0               ; Clear TMR0

; Time Counting Program ('WAIT'):
YESTWO:
    BCF INTCON, TOIF        ; Clear TOIF bit in INTCON

YESONE:
    BTFSS INTCON, TOIF      ; Check TOIF bit in INTCON
    GOTO YESONE             ; If TOIF is 0, keep checking

    DECFSZ COUNTER          ; Decrement COUNTER
    GOTO YESTWO             ; Loop until COUNTER reaches 0

    BTFSC REG_IFTIME, 0     ; Check bit 0 of REG_IFTIME
    GOTO BEGIN3             ; If 1, go to BEGIN3

    BTFSS REG_NUMBER, 0     ; Check bit 0 of REG_NUMBER
    GOTO BEGIN              ; If 0, go to BEGIN
    GOTO BEGIN2             ; Otherwise, go to BEGIN2

; State 1 Output:
BEGIN:
    BCF REG_IFTIME, 0       ; Clear bit 0 of REG_IFTIME
    BSF REG_NUMBER, 0       ; Set bit 0 of REG_NUMBER to 1
    BCF PORTB, 2            ; Clear bit 2 of PORTB
    BCF PORTB, 3            ; Clear bit 3 of PORTB
    BSF PORTB, 0            ; Set bit 0 of PORTB to 1
    BSF PORTB, 5            ; Set bit 5 of PORTB to 1
    CALL WAIT               ; Go to WAIT

; State 2 Output:
BEGIN2:
    BSF REG_IFTIME, 0       ; Set bit 0 of REG_IFTIME to 1
    BCF PORTB, 0            ; Clear bit 0 of PORTB
    BCF PORTB, 5            ; Clear bit 5 of PORTB
    BSF PORTB, 1            ; Set bit 1 of PORTB to 1
    BSF PORTB, 4            ; Set bit 4 of PORTB to 1
    CALL WAIT               ; Go to WAIT

; State 3 Output:
BEGIN3:
    BCF REG_IFTIME, 0       ; Clear bit 0 of REG_IFTIME
    BCF PORTB, 1            ; Clear bit 1 of PORTB
    BCF PORTB, 4            ; Clear bit 4 of PORTB
    BCF REG_NUMBER, 0       ; Clear bit 0 of REG_NUMBER
    BSF PORTB, 2            ; Set bit 2 of PORTB to 1
    BSF PORTB, 3            ; Set bit 3 of PORTB to 1
    GOTO WAIT               ; Go to WAIT

    END                     ; End of program