.MODEL SMALL
.STACK 100H

.DATA
    msg_help db 'Welcome to the HELP page!        ', 0dh, 0ah
             db 'You are now using the POS system of ABC Retail.          ', 0dh, 0ah
             db 'This system helps you to perform transactions and track inventory.          ', 0dh, 0ah
             db 'Below is a list of functions available in the system.          ', 0dh, 0ah, 0dh, 0ah, '$'

    msg_options db '===============================================================', 0dh, 0ah
                db '|                    Functions Available                      |', 0dh, 0ah
                db '===============================================================', 0dh, 0ah
                db '| 1. Start transaction                                        |', 0dh, 0ah
                db '| 2. Show product                                             |', 0dh, 0ah
                db '| 3. Show cashbox                                             |', 0dh, 0ah
                db '| 4. Restock product                                          |', 0dh, 0ah
                db '| 5. Exit program                                             |', 0dh, 0ah
                db '===============================================================', 0dh, 0ah, '$'

    msg_prompt db 'Select the function to provide help on ( 1-5 | 0 to exit ): $'
    msg_continue db 0dh, 0ah, 'Press Enter to continue...', 0dh, 0ah, '$'

    msg_option1 db 0dh, 0ah
                db '|Start transaction:', 0dh, 0ah
                db '|Starts a  new transaction  by  choosing  products  and  their ', 0dh, 0ah
                db '|quantity.  Product ID  will  be  used  to  pick  the  product ', 0dh, 0ah
                db '|desired. Prices will be displayed as a receipt. ', 0dh, 0ah, '$'

    msg_option2 db 0dh, 0ah
                db '|Show product: ', 0dh, 0ah
                db '|Displays all products and their current stock levels. ', 0dh, 0ah, '$'

    msg_option3 db 0dh, 0ah
                db '|Show cashbox: ', 0dh, 0ah
                db '|Displays the amount of cash  accumulated within the  cashbox. ', 0dh, 0ah
                db '|It is the accumulation of all current session. ', 0dh, 0ah, '$'

    msg_option4 db 0dh, 0ah
                db '|Restock product: ', 0dh, 0ah
                db '|Allows user to  increase  the  inventory level  of  products. ', 0dh, 0ah
                db '|Product ID will  be  used to  pick  the  product desired, and ', 0dh, 0ah
                db '|quantity will be added as input. ', 0dh, 0ah, '$'

    msg_option5 db 0dh, 0ah
                db '|Exit program: ', 0dh, 0ah
                db '|Ends the current session, and terminates the program. ', 0dh, 0ah, '$'

    msg_invalid db 'Invalid option. Please choose a number between 0 and 5.$'

    new_line db 0dh, 0ah, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Display welcome message
    LEA SI, msg_help
    CALL SlowDisplay

main_loop:
    ; Display options
    MOV AH, 09h
    LEA DX, msg_options
    INT 21h

    ; Prompt for user input
    MOV AH, 09h
    LEA DX, msg_prompt
    INT 21h

    ; Get user input
    MOV AH, 01h
    INT 21h

    ; Convert ASCII to number (0-5)
    SUB AL, '0'

    ; Check if input is 0 (exit)
    CMP AL, 0
    JE exit_program

    ; Check if input is valid (1-5)
    CMP AL, 1
    JL invalid_input
    CMP AL, 5
    JG invalid_input

    ; Display new line
    MOV AH, 09h
    LEA DX, new_line
    INT 21h

    ; Jump to appropriate option explanation
    CMP AL, 1
    JE option1
    CMP AL, 2
    JE option2
    CMP AL, 3
    JE option3
    CMP AL, 4
    JE option4
    CMP AL, 5
    JE option5

option1:
    LEA SI, msg_option1
    JMP display_option

option2:
    LEA SI, msg_option2
    JMP display_option

option3:
    LEA SI, msg_option3
    JMP display_option

option4:
    LEA SI, msg_option4
    JMP display_option

option5:
    LEA SI, msg_option5
    JMP display_option

display_option:
    CALL SlowDisplay
    
    ; Display "Press Enter to continue" message
    MOV AH, 09h
    LEA DX, msg_continue
    INT 21h

    ; Wait for Enter key
    MOV AH, 01h
    INT 21h

    ; Display new line
    MOV AH, 09h
    LEA DX, new_line
    INT 21h

    JMP main_loop

invalid_input:
    MOV AH, 09h
    LEA DX, new_line
    INT 21h
    LEA DX, msg_invalid
    INT 21h
    ; Display "Press Enter to continue" message
    LEA DX, msg_continue
    INT 21h
    ; Wait for Enter key
    MOV AH, 01h
    INT 21h

    MOV AH, 09h
    LEA DX, new_line
    INT 21H
    JMP main_loop

exit_program:
    MOV AH, 4Ch
    INT 21h

MAIN ENDP

; Procedure to display text slowly
SlowDisplay PROC
NextChar:
    MOV AL, [SI]              ; Load the next character from the message
    CMP AL, '$'               ; Check if it's the end of the string
    JE Done                   ; If yes, exit the loop

    ; Display the character
    MOV AH, 0Eh               ; BIOS Teletype output function (output 1 char on screen)
    MOV BH, 0                 ; Page number (0 for standard output)
    MOV BL, 7                 ; Text attribute (white text)
    INT 10H                   ; Interrupt to display character

    CALL Delay                ; Call the delay function

    INC SI                    ; Move to the next character
    JMP NextChar              ; Repeat the loop

Done:
    RET
SlowDisplay ENDP

; Simple delay procedure to slow down the display
Delay proc
    mov cx, 00002H            ; Set CX for outer loop
DelayLoop:                    ; Outer loop count for delay
    push cx
    mov cx, 09FFFH            ; Set CX for inner loop
    DelayLoop2:               ; Inner loop count for delay
    nop                       ; No operation
    loop DelayLoop2           ; Decrement CX and repeat until CX = 0
    pop CX
    loop DelayLoop            ; Decrement CX and repeat until CX = 0
    ret
Delay endp

END MAIN
