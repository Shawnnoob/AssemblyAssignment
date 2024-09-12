.model small
.stack 100h
.data
    company_name db "====================", 0dh, 0ah
                 db "|    ABC Retail    |", 0dh, 0ah
                 db "--------------------", 0dh, 0ah, 0
    menu db "-----------------------------------", 0dh, 0ah
         db "|       1. Start transaction      |", 0dh, 0ah
         db "|       2. Show product           |", 0dh, 0ah
         db "|       3. Show cashbox           |", 0dh, 0ah
         db "|       4. Exit program           |", 0dh, 0ah
         db "-----------------------------------", 0dh, 0ah, '$'

    product_menu db "==========================================", 0dh, 0ah
                 db "|         Products           | Price(RM) |", 0dh, 0ah
                 db "|----------------------------|-----------|", 0dh, 0ah
                 db "| 1. Tissue                  |    1.20   |", 0dh, 0ah
                 db "| 2. Toothpaste              |   12.20   |", 0dh, 0ah
                 db "| 3. Body Wash               |   15.90   |", 0dh, 0ah
                 db "| 4. Cotton Buds             |    1.00   |", 0dh, 0ah
                 db "------------------------------------------", '$'

    newline db 0dh,0ah,'$'
    username db "admin", 0
    password db "password", 0
    attempts db 3  ; Counter for login attempts

    input_buffer label byte ; User input characters (strings)
    maxlen db 20
    actlen db ?
    inputdata db 20 dup (0)

    product db "Tissue", 0
            db "Toothpaste", 0
            db "Body Wash", 0
            db "Cotton Buds", 0
    product_qty db 0, 0, 0, 0
    preset_price dw 120, 1220, 1590, 100

    ;prompts and messages
    prompt_username db 'Enter username: $'
    prompt_password db 'Enter password: $'
    msg_success_login db 'Login successful! $'
    msg_failure_login db 'Incorrect username/password. Please try again.$'
    msg_attempts_finished db 'Too many failed attempts. Exiting program...$'

    prompt_menu_choice db 'Enter your choice (1-4): $'
    prompt_product_id db 'Enter product ID: $'
    prompt_quantity db 'Enter quantity (1-3): $'
    prompt_more_products db 13, 10, 'Do you want to purchase more products? (Y/N): $'
    selected_product_msg db 13, 10, 'Selected product: $'
    msg_invalid_product db 13, 10, "Invalid product ID. Please try again.", 13, 10, '$'

    msg_subtotal db "Subtotal for $"
    msg_total db "Total: RM$"

    msg_invalid_input db 'Invalid input. Enter to try again with a correct number. $'
    msg_exit db "Exiting program. Thank you for using ABC Retail! $"

.code

main proc
    mov ax, @data
    mov ds, ax

    call login ; Will terminate program if login attempt exceeds 3 times

success_login: ; Clear the input_buffer
    mov si, OFFSET input_buffer  ; Load the starting address of input_buffer into SI
    mov cx, 20                   ; Load the size of the buffer (50 bytes) into CX
    mov al, 0                    ; We will fill the buffer with 0 (null)

clear_loop:
    mov [si], al                 ; Set current byte to 0
    inc si                       ; Move to the next byte in the buffer
    loop clear_loop              ; Repeat until CX = 0 (end of buffer)

menu_loop:
    ; Clear the screen
    call clear_screen
    ; Print company name
    call display_company_colour_name 

    ; Print success message
    mov ah, 09h
    lea dx, msg_success_login
    int 21h
    lea dx, newline
    int 21h

    ; Print menu
    lea dx, menu
    int 21h

    ; Prompt for user input
    mov ah, 09h
    lea dx, prompt_menu_choice
    int 21h

    ; Get user input
    mov ah, 01h
    int 21h

    ; Check user input
    cmp al, '1'
    je option_1
    cmp al, '2'
    je option_2
    cmp al, '3'
    je option_3
    cmp al, '4'
    je exit_program

    ; Print newline
    mov ah, 09h
    lea dx, newline
    int 21h

    ; If we get here, input was invalid
    mov ah, 09h
    lea dx, msg_invalid_input
    int 21h

    ; Wait for a key press
    mov ah, 01h
    int 21h

    jmp menu_loop

option_1:
    call transaction
    jmp menu_loop

option_2:
    ; Placeholder for Show product
    jmp menu_loop

option_3:
    ; Placeholder for Show cashbox
    jmp menu_loop

exit_program:

    mov ah, 09h
    lea dx, newline
    int 21h
    lea dx, msg_exit
    int 21h

    mov ax, 4C00h
    int 21h

main endp

login proc ;Login - Thee Hao Siang

    ;Display colored store name
    call display_company_colour_name

login_loop:

    ; Prompt for username
    mov ah, 09h
    lea dx, prompt_username
    int 21h

    ; Get username input
    mov ah, 0Ah
    lea dx, input_buffer ; store user input in dx
    int 21h

    ; Null-terminate the string after the input length
    lea di, inputdata
    mov cl, byte ptr [input_buffer + 1] ; Get length of user input
    add di, cx                ; Move DI to the end of the input string
    mov byte ptr [di], 0      ; Null-terminate the input

    ; Compare username
    lea si, username ; move username to si
    lea di, inputdata
    call compare_strings
    jnz login_failed ; if ZF != 0 (failed), jump

    ; Print newline
    mov ah, 09h
    lea dx, newline
    int 21h

    ; Prompt for password
    mov ah, 09h
    lea dx, prompt_password
    int 21h

    ; Get password input
    mov ah, 0Ah
    lea dx, input_buffer
    int 21h

    ; Null-terminate the string after the input length
    lea di, inputdata
    mov cl, [input_buffer + 1] ; Get length of user input
    add di, cx                ; Move DI to the end of the input string
    mov byte ptr [di], 0      ; Null-terminate the input

    ; Compare password
    lea si, password
    lea di, input_buffer + 2
    call compare_strings
    jnz login_failed ; if ZF != 0 (failed), jump

    ; Login succeed
    jmp success_login

login_failed:

    ; Print newline
    mov ah, 09h
    lea dx, newline
    int 21h

    ; Decrease attempts counter
    dec attempts

    ; Check if attempts are exhausted
    cmp attempts, 0
    je too_many_attempts

    mov ah, 09h
    lea dx, msg_failure_login
    int 21h

    ; Print newline
    mov ah, 09h
    lea dx, newline
    int 21h

    jmp login_loop ; Loop back to input

too_many_attempts:
    mov ah, 09h
    lea dx, msg_attempts_finished
    int 21h

exit:
    mov ax, 4C00h
    int 21h

login endp

transaction proc
    ; Clear the screen
    call clear_screen

    ; Display company logo
    call display_company_colour_name

    ; Display product menu
    mov ah, 09h
    lea dx, product_menu
    int 21h

transaction_loop:
    ; Prompt for product ID
    mov ah, 09h
    lea dx, prompt_product_id
    int 21h

    ; Get product ID input
    mov ah, 01h
    int 21h

    ; Convert input to numeric value
    sub al, '1'
    mov bl, al
    cmp bl, 0
    jl invalid_product_jmp
    cmp bl, 3
    jg invalid_product_jmp
    jmp valid_product

invalid_product_jmp:
    jmp invalid_product
valid_product:
    ; Prompt for quantity
    mov ah, 09h
    lea dx, prompt_quantity
    int 21h

    ; Get quantity input
    mov ah, 01h
    int 21h

    ; Convert input to numeric value
    sub al, '0'
    cmp al, 1
    jl invalid_quantity_jmp
    cmp al, 3
    jg invalid_quantity_jmp
    jmp valid_quantity

invalid_quantity_jmp:
    jmp invalid_quantity
valid_quantity:
     ; Store quantity in product_qty array
    mov bh, 0
    mov si, bx
    mov product_qty[si], al

    ; Display selected product and quantity
    mov ah, 09h
    lea dx, selected_product_msg
    int 21h

    ; Calculate the offset for the selected product
    mov si, 0
    mov cx, bx
    jcxz display_product_name
find_product_name:
    mov al, [product + si]
    inc si
    cmp al, 0
    jne find_product_name
    loop find_product_name

display_product_name:
    mov ah, 09h
    mov dx, si
    add dx, offset product
    int 21h

    mov ah, 09h
    lea dx, newline
    int 21h

    ; Prompt for more products
    mov ah, 09h
    lea dx, prompt_more_products
    int 21h

    ; Get user input
    mov ah, 01h
    int 21h

    cmp al, 'Y'
    je transaction_loop
    cmp al, 'y'
    je transaction_loop

    ; Calculate total price
    xor cx, cx
    xor ax, ax
    mov si, 0

calculate_total:
    mov bl, product_qty[si]
    cmp bl, 0
    je skip_product

    mov bh, 0
    shl si, 1  ; Scale the index by 2 because preset_price is a word array
    mov dx, preset_price[si]
    shr si, 1  ; Restore the original index
    mul dx
    add cx, ax

skip_product:
    inc si
    cmp si, 4
    jl calculate_total

    ; Display subtotals and total price
    mov si, 0
    mov bx, 0

display_subtotals:
    mov bl, product_qty[si]
    cmp bl, 0
    je skip_subtotal

    mov ah, 09h
    lea dx, msg_subtotal
    int 21h

    ; Calculate the offset for the selected product
    mov di, 0
    mov cx, si
    jcxz display_subtotal_name
find_subtotal_name:
    lodsb
    cmp al, 0
    jne find_subtotal_name
    loop find_subtotal_name

display_subtotal_name:
    mov ah, 09h
    lea dx, product[di]
    int 21h

    mov ah, 09h
    lea dx, newline
    int 21h

skip_subtotal:
    inc si
    cmp si, 4
    jl display_subtotals

    ; Display total price
    mov ah, 09h
    lea dx, msg_total
    int 21h

    ; Convert total price to RM00.00 format
    mov ax, cx
    mov bx, 100
    div bx
    mov bx, ax
    mov ah, 02h
    mov dl, bh
    add dl, '0'
    int 21h
    mov dl, bl
    add dl, '0'
    int 21h
    mov dl, '.'
    int 21h
    mov ax, dx
    mov bl, 10
    div bl
    mov dl, al
    add dl, '0'
    int 21h
    mov dl, ah
    add dl, '0'
    int 21h

    ; Wait for a key press
    mov ah, 01h
    int 21h

    ret

invalid_product:
    mov ah, 09h
    lea dx, msg_invalid_product
    int 21h
    jmp transaction_loop

invalid_quantity:
    mov ah, 09h
    lea dx, msg_invalid_input
    int 21h
    jmp transaction_loop

transaction endp

compare_strings proc ;Compare two strings (using SI and DI (input))
    push cx ; Save original CX value in stack
    push dx ; Save original DX value in stack

    xor cx, cx ; Initialize character counter to 0

compare_loop:
    mov dl, [si]    ; Load character from first string
    cmp dl, [di]    ; Compare with character from second string (input)
    jne compare_end ; Jump if characters don't match

    cmp dl, 0        ; Check if we reached the null terminator
    je compare_match ; If both strings have the same length, they match

    inc si           ; Move to next character in first string
    inc di           ; Move to next character in second string
    loop compare_loop ; Continue comparing characters

compare_match:
    cmp byte ptr [si], 0 ; Check if first string is at null terminator
    jne compare_end      ; If not, strings don't match
    cmp byte ptr [di], 0 ; Check if second string is at null terminator
    jne compare_end      ; If not, strings don't match

    pop dx     ; Restore original DX value
    pop cx     ; Restore original CX value
    xor ax, ax ; Set ZF to 0 for match
    ret        ; Return ZF 0 (MATCH)

compare_end:
    pop dx     ; Restore original DX value
    pop cx     ; Restore original CX value
    or ax, ax ; Set ZF to 1 for no match
    ret       ; Return ZF 1 (NO MATCH)

compare_strings endp

display_company_colour_name proc ;Thee Chern Hao
    ; Save registers to preserve their original values
    push ax
    push bx
    push cx
    push dx
    push si

    ; Set video mode to standard 80x25 text mode (just in case)
    mov ah, 00h
    mov al, 03h
    int 10h

    ; Set up for colored text display
    mov bl, 10            ; Text color: light green (10) on black background (0)

    mov si, offset company_name  ; Point SI to the start of company_name string
    mov dh, 0            ; Start at row 0
    mov dl, 0            ; Start at column 0

    ; Start displaying characters
company_name_loop:
    lodsb                ; Load next character from [SI] into AL and increment SI

    cmp al, 0            ; Check for end of string (null terminator)
    je done              ; If end of string, exit the loop

    cmp al, 0Dh          ; Check if the character is a carriage return (ASCII code 0Dh)
    je skip_char         ; If carriage return, skip to next character

    cmp al, 0Ah          ; Check if the character is a newline (ASCII code 0Ah)
    jne print_char       ; If not a newline, proceed to print the character

    ; Handle newline character
    inc dh               ; Move cursor to next row
    mov dl, 0            ; Reset cursor to first column
    jmp set_cursor

print_char:
    ; Print the character with color
    mov ah, 09h          ; BIOS function to write character and attribute
    mov bh, 0            ; Display page number (0)
    mov cx, 1            ; Number of times to print the character (once)
    int 10h              ; Call BIOS interrupt to display the character

    inc dl               ; Move cursor to next column

set_cursor:
    mov ah, 02h          ; Set cursor position
    mov bh, 0            ; Page number
    int 10h              ; Call BIOS interrupt to set new position

skip_char:
    jmp company_name_loop       ; Continue with the next character

done:
    ; Restore registers to their original values
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret                  ; Return from the procedure
display_company_colour_name endp

clear_screen proc
    ; Set up the registers for clearing the screen
    mov ah, 06h  ; Function 06h (scroll up)
    mov al, 0    ; Clear entire screen
    mov bh, 07h  ; Attribute (white on black)
    mov cx, 0    ; Start at row 0, column 0
    mov dh, 24   ; End at row 24 (bottom of screen)
    mov dl, 79   ; End at column 79 (right edge of screen)
    int 10h      ; Execute BIOS video interrupt

    ; Set cursor to top-left corner
    mov ah, 02h  ; Function 02h (set cursor position)
    mov bh, 0    ; Page number (usually 0)
    mov dx, 0    ; Row 0, column 0
    int 10h      ; Execute BIOS video interrupt

    ret
clear_screen endp

scroll_screen proc
    ; Set up the registers for scrolling the screen
    mov ah, 06h  ; Function 06h (scroll up)
    mov al, 1    ; Scroll by 1 line
    mov bh, 07h  ; Attribute (white on black)
    mov cx, 0    ; Start at row 0, column 0
    mov dh, 24   ; End at row 24 (bottom of screen)
    mov dl, 79   ; End at column 79 (right edge of screen)
    int 10h      ; Execute BIOS video interrupt

    ; Set cursor to top-left corner
    mov ah, 02h  ; Function 02h (set cursor position)
    mov bh, 0    ; Page number (usually 0)
    mov dx, 0    ; Row 0, column 0
    int 10h      ; Execute BIOS video interrupt

    ret
scroll_screen endp

end main
