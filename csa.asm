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

    product_a db 'Tissue     ', 0
    product_b db 'Toothpaste ', 0
    product_c db 'Body Wash  ', 0
    product_d db 'Cotton Buds', 0

    product_lengths db 11, 11, 11, 11     ; Lengths of each product name
    product_qty db 0, 0, 0, 0             ; Chosen quantity for each product
    preset_price dw 120, 1220, 1590, 100  ; Product price in cents

    product_id db ?                 ; Buffer to store current product ID
    current_product db 20 dup('$')  ; Buffer to store current product name
    quantity db ?                   ; Buffer to store quantity user inputs

    result dw ?                 ; Variable to store the result of transaction
    cent_result dw ' ', '$'     ; Variable to store the result for cent
    total_result dw 0           ; Variable to store the total price
    buffer db 6 dup('$')        ; Buffer to hold the ASCII representation of the transaction result

    prompt_username db 'Enter username: $'
    prompt_password db 'Enter password: $'
    msg_success_login db 'Login successful! $'
    msg_failure_login db 'Incorrect username/password. Please try again.$'
    msg_attempts_finished db 'Too many failed attempts. Exiting program...$'

    prompt_menu_choice db 'Enter your choice (1-4): $'
    prompt_product_id db 'Enter product ID: $'
    prompt_quantity db 'Enter quantity (1-3): $'
    prompt_more_product db 'Do you want to buy more products? (Y/N): $'
    msg_selected_product db 13, 10, 'Selected product: $'
    msg_current_quantity db 'Current quantity (max 3 per item): $'
    msg_invalid_product db 13, 10, 'Invalid product ID. Enter to try again.$'
    msg_invalid_quantity db 13, 10, 'Invalid input/quantity. Enter to try again.$'
    msg_invalid_input db 'Invalid input. Enter to try again with a correct number. $'
    msg_exit db 'Exiting program. Thank you for using ABC Retail! $'
    msg_max_quantity db 13, 10, 'Maximum quantity reached for this product. Enter to continue.$'
    msg_subtotal db 'Subtotal: RM$'
    msg_total db 'Total: RM$'
    msg_continue db 'Press enter to continue...$'

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
    je start_transaction
    cmp al, '2'
    je option_2_jmp
    jmp to_option_3
option_2_jmp:
    jmp option_2
to_option_3:
    cmp al, '3'
    je option_3_jmp
    jmp to_option_4
option_3_jmp:
    jmp option_3
to_option_4:
    cmp al, '4'
    je exit_program_jmp
    jmp to_invalid
exit_program_jmp:
    jmp exit_program
to_invalid:
    jmp invalid_choice

invalid_choice:
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

start_transaction:
    ; Clear the screen
    call clear_screen

transaction_loop:
    ; Display company logo
    call display_company_colour_name

    ; Display product menu
    mov ah, 09h
    lea dx, product_menu
    int 21h

    mov ah, 09h
    lea dx, newline
    int 21h

    ; Prompt for product ID
    mov ah, 09h
    lea dx, prompt_product_id
    int 21h

    ; Get product ID input
    mov ah, 01h
    int 21h
    sub al, '0'  ; Convert ASCII to number
    mov product_id, al

    ; Validate product ID
    cmp al, 1
    jl invalid_product_jmp
    cmp al, 4
    jg invalid_product_jmp
    jmp valid_product
invalid_product_jmp:
    jmp invalid_product

valid_product:
    ; Display selected product and current quantity
    call display_selected_product

    mov ah, 09h
    lea dx, newline
    int 21h
    lea dx, newline
    int 21h

    ; Prompt for quantity
    mov ah, 09h
    lea dx, prompt_quantity
    int 21h

    ; Get quantity input
    mov ah, 01h
    int 21h
    sub al, '0'  ; Convert ASCII to number
    mov quantity, al

    ; Validate quantity
    cmp al, 1
    jl invalid_quantity_jmp
    cmp al, 3
    jg invalid_quantity_jmp
    jmp valid_quantity
invalid_quantity_jmp:
    jmp invalid_quantity

valid_quantity:
    ; Check if adding the quantity will exceed the maximum limit
    mov bl, product_id
    dec bl  ; Adjust for 0-based index
    mov bh, 0
    mov al, [product_qty + bx]
    add al, quantity
    cmp al, 3
    jg max_quantity_reached_msg
    jmp valid_quantity_2
max_quantity_reached_msg:
    jmp max_quantity_reached

valid_quantity_2:
    ; Update product quantity
    mov bl, product_id
    dec bl  ; Adjust for 0-based index
    mov bh, 0
    mov al, quantity
    add [product_qty + bx], al

    ; Ask if user wants to continue shopping
    mov ah, 09h
    lea dx, newline
    int 21h
    lea dx, prompt_more_product
    int 21h
    mov ah, 01h
    int 21h

    cmp al, 'Y'
    je transaction_loop_jmp
    cmp al, 'y'
    je transaction_loop_jmp
    jmp to_display_total
transaction_loop_jmp:
    jmp transaction_loop

to_display_total:
    call clear_screen
    call display_company_colour_name
    ;Display product name, qty and price
    push si
    push ax
    push bx
    push dx

    mov cx, 4   ; Loop 4 times for 4 products
    mov si, 0   ; Move SI to 0 for index
display_price_loop:
    push cx
    mov ax, si                    ; Move SI into AX
    xor ah, ah                    ; Clear AH
    add al, 1                     ; Add 1 to AL since display_selected_product function decrements product_id
    mov product_id, al            ; Load AL (with SI value) into product_id
    sub al, 1                     ; Sub 1 from AL
    call display_selected_product ; Display product name and quantity

    ; Calculate subtotal
    shl si, 1                   ; Shift SI one bit left (multiply 2)
    mov ax, preset_price[si]    ; Load price to AL. (We multiply since preset_price is word, hence 2 bytes)
    shr si, 1                   ; Shift SI one bit right (divide 2, return to original)
    mov bl, product_qty[si]     ; Load quantity to BL
    xor bh, bh                  ; Clear BH
    mul bx                      ; AX multiplies BX to get total (price * quantity = total)
    mov result, ax              ; Store the total into result

    ; Add to total
    add total_result, ax

    ; Display subtotal
    mov ah, 09h
    lea dx, newline
    int 21h
    mov ah, 09h
    lea dx, msg_subtotal
    int 21h

    push si             ; Save SI value
    call display_price
    pop si              ; Load SI value

    inc si
    pop cx
    loop display_price_loop

    ; Display total
    mov ah, 09h
    lea dx, newline
    int 21h
    lea dx, newline
    int 21h
    lea dx, msg_total
    int 21h
    
    mov ax, total_result
    mov result, ax
    call display_price

    mov ah, 09h
    lea dx, newline
    int 21h
    lea dx, msg_continue
    int 21h

    ; Pause before continue
    mov ah, 01h
    int 21h

    pop si
    pop ax
    pop bx
    pop dx

    jmp menu_loop

invalid_product:
    mov ah, 09h
    lea dx, msg_invalid_product
    int 21h
    mov ah, 01h
    int 21h
    jmp transaction_loop

invalid_quantity:
    mov ah, 09h
    lea dx, msg_invalid_quantity
    int 21h
    mov ah, 01h
    int 21h
    jmp transaction_loop

max_quantity_reached:
    mov ah, 09h
    lea dx, msg_max_quantity
    int 21h
    mov ah, 01h
    int 21h
    jmp transaction_loop

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

display_selected_product proc ;Display Product
    push ax
    push bx
    push dx
    push si
    push di

    mov ah, 09h
    lea dx, newline
    int 21h
    lea dx, msg_selected_product
    int 21h

    mov bl, product_id          ; Load product_id into BL
    dec bl                      ; Adjust for 0-based index
    mov bh, 0                   ; Clear BH
    mov si, bx                  ; Move BX (product_id value) into SI
    mov al, product_lengths[si] ; Get the length of the product name
    mov cl, al                  ; Move length into CL
    mov ch, 0                   ; Clear high byte of CX

    ; Calculate the offset for the selected product name
    lea si, product_a   ; Load offset address of product_a
    mov al, bl          ; Load product_id into AL
    mov ah, 12          ; Length of each product name including null terminator
    mul ah              ; AX multiplies AH to get actual address of selected product
    add si, ax          ; Add SI with the actual address

    mov di, offset current_product
copy_product_name:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    loop copy_product_name

    mov byte ptr [di], '$'  ; Null-terminate the string

    mov ah, 09h
    lea dx, current_product
    int 21h

    ; Display current quantity
    mov ah, 09h
    lea dx, newline
    int 21h
    lea dx, msg_current_quantity
    int 21h

    mov bl, product_id
    dec bl  ; Adjust for 0-based index
    mov bh, 0
    mov al, [product_qty + bx]
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h

    pop di
    pop si
    pop dx
    pop bx
    pop ax
    ret
display_selected_product endp

display_price proc ;Display Price
    ; Convert the result to ASCII for display
    lea si, buffer
    mov cx, 5       ; Loop 5 times for 5 bytes in buffer (max 5 digits)
    add si, 4       ; Start from the end of buffer (leave 1 extra $ for end string)
    mov ax, result  ; Move result to AX

    ; Extract and convert each digit
convert_loop:
    xor dx, dx          ; Clear DX for division
    mov bx, 10          ; Base 10 for conversion
    div bx              ; AX = AX / 10, DX = remainder (last digit)
    add dl, 30h         ; Convert digit to ASCII
    mov [si], dl        ; Store the digit in the buffer
    dec si              ; Move to the next buffer position
    loop convert_loop

    ; Extract the cents
    lea si, buffer           ; Points SI to starting address of buffer
    mov ax, word ptr [si+3]  ; Loads the last two digits into cent_result
    mov cent_result, ax

    ; Ensure the buffer is in the correct format (00.00)
    mov byte ptr [si+3], '.'
    mov byte ptr [si+4], '$'

    ; Remove leading zeros
    lea si, buffer          ; Points SI to starting address of buffer
    mov cx, 3               ; We'll check the first 3 digits (before the decimal point)
remove_leading_zeros:
    cmp byte ptr [si], '0'  ; Check for leading '0'
    jne display_result      ; If found non-zero number, display the price
    mov byte ptr [si], ' '  ; Replace '0' with space
    inc si
    loop remove_leading_zeros

display_result:
    ; Display the price
    mov ah, 09h
    lea dx, buffer
    int 21h

    mov ah, 09h
    lea dx, cent_result
    int 21h

    ret
display_price endp

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

clear_screen proc ;Clear Screen
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

scroll_screen proc ;Scroll Screen
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
