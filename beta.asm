.model small
.stack 100h
.data
    company_name db "====================", 0dh, 0ah
                 db "|    ABC Retail    |", 0dh, 0ah
                 db "--------------------", 0dh, 0ah, 0
    menu db "-----------------------------------", 0dh, 0ah
         db "|        1. Start transaction     |", 0dh, 0ah
         db "|        2. Show product          |", 0dh, 0ah
         db "|        3. Show cashbox          |", 0dh, 0ah
         db "|        4. Exit program          |", 0dh, 0ah
         db "-----------------------------------", 0dh, 0ah, 0
    newline db 0dh,0ah,"$"
    username db "admin", 0
    password db "password", 0

    product_menu db "==========================================", 0dh, 0ah 
                 db "|         Products           |   Price   |", 0dh, 0ah
                 db "|----------------------------|-----------|", 0dh, 0ah
                 db "| 1. Tissue                  |    1.20   |", 0dh, 0ah
                 db "| 2. Toothpaste              |   12.20   |", 0dh, 0ah
                 db "| 3. Body Wash               |   15.90   |", 0dh, 0ah
                 db "| 4. Cotton Buds             |    1.00   |", 0dh, 0ah
                 db "------------------------------------------", 0dh, 0ah, 0

    ; Products: ID (1 byte), Name (20 bytes)
    product db 1, "Tissue              "
            db 2, "Toothpaste          "
            db 3, "Body Wash           "
            db 4, "Cotton Buds         "
    ; Price (2 bytes)
    product_price dw 120
                  dw 1220
                  dw 1590
                  dw 100

    product_count db 4
    product_size equ 23 ; 1 + 20 + 2 = length of product (bytes)

    ; Variables for accessing current/chosen product information
    current_product dw ?
    product_id db ?
    product_name db 20 dup(?)
    product_price_entered dw ?

    price_string db 10 dup(0)  ; Buffer to hold the price string
     prompt_product_id db "Enter product ID: $"
    prompt_more_products db 13, 10, "Do you want to purchase more products? (Y/N): $"
    selected_product_msg db 13, 10, "Selected product: $"
    msg_invalid_product db 13, 10, "Invalid product ID. Please try again.", 13, 10, "$"

    input_buffer label byte ; User input characters (strings)
    maxlen db 20
    actlen db ?
    inputdata db 20 dup (0)

    ; Data for transaction function
    total dw 0
    total_str db 6 dup(0), '$'
    prompt_quantity db "Enter quantity (1-3): $"
    msg_invalid_quantity db "Invalid quantity. Please enter 1, 2, or 3.", 0Dh, 0Ah, "$"
    msg_total db "Total: $", 0Dh, 0Ah, "$"

    prompt_user db "Enter username: $"
    prompt_pass db "Enter password: $"
    msg_success db "Login successful!"
                db 0dh, 0ah, "$"
    msg_failure db "Login failed. Exiting program.$"
    msg_attempts db "Too many failed attempts. Exiting...$"
    attempts db 3  ; Counter for login attempts
    prompt_choice_1 db "Enter your choice (1-4): $"
    invalid_input db "Invalid input. Enter to try again with a correct number."
                  db 0dh, 0ah, "$"
    msg_exit db "Exiting program. Thank you for using ABC Retail!"
             db 0dh, 0ah, "$"

.code

main proc
    mov ax, @data
    mov ds, ax

    call login ; Will terminate program if login attempt exceeds 3 times
    call success_login_menu

    mov ax, 4C00h
    int 21h

main endp

login proc ;Login - Thee Hao Siang

    ;Display colored store name
    call display_company_colour_name

login_loop:

    ; Prompt for username
    mov ah, 09h
    lea dx, prompt_user
    int 21h

    ; Get username input
    mov ah, 0Ah
    lea dx, input_buffer ; store user input in dx
    int 21h

    ; Null-terminate the string after the input length
    lea di, inputdata
    mov cl, [input_buffer + 1] ; Get length of user input
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
    lea dx, prompt_pass
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

    ; Call success_login_menu procedure
    call success_login_menu
    jmp exit

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
    lea dx, msg_failure
    int 21h

    ; Print newline
    mov ah, 09h
    lea dx, newline
    int 21h

    jmp login_loop ; Loop back to input

too_many_attempts:
    mov ah, 09h
    lea dx, msg_attempts
    int 21h

exit:
    mov ax, 4C00h
    int 21h

login endp

success_login_menu proc ;Login Success - Thee Hao Siang
    ; Clear the screen
    mov ah, 06h  ; scroll up function
    mov al, 0    ; clear entire screen
    mov bh, 07h  ; attribute (white on black)
    mov cx, 0    ; start at row 0, column 0
    mov dh, 24   ; end at row 24 (bottom of screen)
    mov dl, 79   ; end at column 79 (right edge of screen)
    int 10h      ; execute BIOS video interrupt

menu_loop:
    ; Set cursor position to top-left corner
    mov ah, 02h  ; set cursor position
    mov bh, 0    ; page number
    mov dh, 0    ; row
    mov dl, 0    ; column
    int 10h

    call display_company_colour_name ; company name

    ; Print success message
    mov ah, 09h
    lea dx, msg_success
    int 21h

    ; Print menu
    mov ah, 09h
    lea dx, menu
    int 21h

    ; Prompt for user input
    mov ah, 09h
    lea dx, prompt_choice_1
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
    lea dx, invalid_input
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
    ret

success_login_menu endp

transaction proc ;Transaction - Thee Hao Siang
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Clear the screen
    mov ah, 06h
    xor al, al
    xor cx, cx
    mov dx, 184Fh
    mov bh, 07h
    int 10h

    ; Display company logo
    call display_company_colour_name

    ; Initialize total
    mov word ptr [total], 0

transaction_loop:
    ; Display product menu
    mov ah, 09h
    lea dx, product_menu
    int 21h

    ; Ask user to enter product ID
    mov ah, 09h
    lea dx, prompt_product_id
    int 21h

    ; Get product ID input
    mov ah, 01h
    int 21h
    sub al, '0'  ; Convert ASCII to number
    dec al       ; Convert to 0-based index
    mov bl, al

    ; Validate product ID
    cmp bl, 0
    jl invalid_product
    cmp bl, [product_count]
    jge invalid_product

    ; Load product info
    call load_product_info

    ; Display selected product
    mov ah, 09h
    lea dx, selected_product_msg
    int 21h
    lea dx, product_name
    int 21h

    ; Ask for quantity
    mov ah, 09h
    lea dx, prompt_quantity
    int 21h

    ; Get quantity input
    mov ah, 01h
    int 21h
    sub al, '0'  ; Convert ASCII to number

    ; Validate quantity (1-3)
    cmp al, 1
    jl invalid_quantity
    cmp al, 3
    jg invalid_quantity

    ; Calculate price
    mov bl, al  ; Store quantity in BL
    mov ax, [product_price]
    mul bx
    add [total], ax

    ; Ask if user wants to purchase more
    mov ah, 09h
    lea dx, prompt_more_products
    int 21h

    ; Get user input (Y/N)
    mov ah, 01h
    int 21h
    cmp al, 'Y'
    je transaction_loop
    cmp al, 'y'
    je transaction_loop

    ; Transaction complete
    jmp transaction_complete

invalid_product:
    mov ah, 09h
    lea dx, msg_invalid_product
    int 21h
    jmp transaction_loop

invalid_quantity:
    mov ah, 09h
    lea dx, msg_invalid_quantity
    int 21h
    jmp transaction_loop

transaction_complete:
    ; Transaction complete, total is saved in [total]
    ; (Code for displaying receipt would go here)

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

transaction endp

price_to_string proc
    push ax
    push bx
    push cx
    push dx
    push si

    ; AX contains the price in cents
    mov bx, 100
    xor dx, dx
    div bx      ; AX now contains dollars, DX contains cents

    ; Convert dollars to string
    mov si, offset price_string
    call number_to_string

    ; Add decimal point
    mov byte ptr [si], '.'
    inc si

    ; Convert cents to string
    mov ax, dx
    mov cx, 2   ; We want two digits for cents
    call number_to_string_padded

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
price_to_string endp

; Convert number in AX to string at [SI], null-terminated
number_to_string proc
    push ax
    push bx
    push cx
    push dx

    mov bx, 10
    xor cx, cx

divide_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz divide_loop

store_loop:
    pop dx
    add dl, '0'
    mov [si], dl
    inc si
    loop store_loop

    mov byte ptr [si], 0  ; Null terminator

    pop dx
    pop cx
    pop bx
    pop ax
    ret
number_to_string endp

; Convert number in AX to string at [SI], padding with leading zeros if necessary
; CX contains the desired string length
number_to_string_padded proc
    push ax
    push bx
    push dx

    mov bx, 10
    add si, cx   ; Point to the end of the string
    dec si

pad_loop:
    xor dx, dx
    div bx
    add dl, '0'
    mov [si], dl
    dec si
    loop pad_loop

    pop dx
    pop bx
    pop ax
    ret
number_to_string_padded endp

; Load product information for the nth product (0-based index) into helper variables
load_product_info proc
    push ax
    push bx
    push si
    push di
    push cx
    
    ; Calculate product address
    xor ah, ah
    mov al, product_size
    mul bl  ; BL contains the product index
    add ax, offset product
    mov si, ax
    
    ; Load ID
    mov al, [si]
    mov [product_id], al
    inc si
    
    ; Load Name
    mov di, offset product_name
    mov cx, 20
    rep movsb
    
    ; Load Price
    mov ax, [si]
    mov [product_price], ax
    
    pop cx
    pop di
    pop si
    pop bx
    pop ax
    ret
load_product_info endp

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

; COMPARE TWO STRINGS (using SI and DI (input))
compare_strings proc 
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

end main
