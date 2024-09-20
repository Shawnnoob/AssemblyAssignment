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
         db "|       4. Restock product        |", 0dh, 0ah
         db "|       5. Exit program           |", 0dh, 0ah
         db "-----------------------------------", 0dh, 0ah, '$'

    product_menu db "==========================================", 0dh, 0ah
                 db "|         Products           | Price(RM) |", 0dh, 0ah
                 db "|----------------------------|-----------|", 0dh, 0ah
                 db "| 1. Tissue                  |    1.20   |", 0dh, 0ah
                 db "| 2. Toothpaste              |   13.20   |", 0dh, 0ah
                 db "| 3. Body Wash               |   17.90   |", 0dh, 0ah
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

    product_id db ?                 ; Buffer to store current product ID
    current_product db 20 dup('$')  ; Buffer to store current product name
    quantity db ?                   ; Buffer to store quantity user inputs

    ; Variable for calculations
    preset_price_int dw 1, 130, 17, 1    ; Price in RM
    preset_price_dec dw 20, 20, 90, 00  ; Price in cents

    result_int dw ?             ; Variable to store RM result
    result_dec dw ?             ; Variable to store cents result
    result_overflow dw ?        ; Variable to store overflow from cents

    total_int dw 0              ; Store total RM
    total_dec dw 0              ; Store total cents

    buffer db 7 dup('$')          ; Buffer for displaying

    ;Prompts and messages
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

;----------------------------------Receipt-------------------------------------------
    receipt_start   db "===========================================", 0dh, 0ah
                    db "|               Receipt                   |", 0dh, 0ah
                    db "-------------------------------------------", 0dh, 0ah
                    db "Product Name         QTY        Amount(RM) ", 0dh, 0ah
                    db "                                           $", 0dh, 0ah

    receipt_middle db "-------------------------------------------$", 0dh, 0ah

    receipt_end     db  "-------------------------------------------", 0dh, 0ah
                    db  "          Thanks You Very Much              ", 0dh, 0ah           
                    db  "            Have A Nice Day                 ", 0dh, 0ah
                    db  "===========================================", 0dh, 0ah
                    db  "                                           $", 0dh, 0ah

    wkz_subTotal    db  "SubTotal                       |$", 0dh, 0ah
    discount        db  "Discount                       |$", 0dh, 0ah
    discount_value  dw 0                 ; Store discount amount here
    no_discount_msg db "0.00$",0dh,0ah
    sst         db "SST(8%)                            $", 0dh, 0ah
    wkz_total       db "Total                              $", 0dh, 0ah   

    print   db "Do you want to print the receipt?", 0dh, 0ah
            db "      a - Yes  b - No            ", 0dh, 0ah
            db "$"

    enter_choice db "Enter your choice: $", 0dh, 0ah

    printing    db "===============================",0dh,0ah
                db "Printing......                ", 0dh, 0ah
                db "Press Enter to process       ", 0dh, 0ah
                db "$"
    product_column equ 5
    qty_column equ 15
    subtotal_column equ 20
    price_column equ 10

;----------------------------------------------addStock------------------------------
    error db "Invalid input please try again.$"
    Pause_Msg db "Press any key to continue...$",0dh,0ah
    Restock_Msg db "Enter the (1,2,3,4) to restock the product:$",0dh,0ah

    restock_heading   db "===========================================", 0dh, 0ah
                      db "|              Add stock                   |", 0dh, 0ah
                      db "-------------------------------------------", 0dh, 0ah
                      db "$"

    restock_confirm_msg db "Are you sure you want to restock? (Y/N):$",0dh,0ah
    restock_cancel_msg db "Canceled restock... $"
    restock_success_msg db "Success to restock the product...$"
    restock_maxMsg_msg db "Stock exceed 99! please try again. $"
    restock_inputMsg_msg db "Enter the quantity you want to restock(Enter 2 digits/x to exit): $"

    restock_prod db "==========================================", 0dh, 0ah
                 db "|         Products           |   Stock   |", 0dh, 0ah
                 db "|----------------------------|-----------|", 0dh, 0ah
    input_firstdigit db "First digit cannot be more than 9!/invalid input! $"
    current_stock_msg db "Current stock: $",0dh,0ah
                 
    restock_A db '1'
    restock_B db '2'
    restock_C db '3'
    restock_D db '4'
    msg_insufficient_stock db 'No enough stock to let the customer buy $',0dh,0ah

    product_1   db "1. Tissue                  $"
    product_2   db "2. Toothpaste              $"
    product_3   db "3. Body Wash               $"
    product_4   db "4. Cotton Buds             $"
    restock_Exit db    "x.Exit$"
    
    restock_x db 0
    restock_y db 0     
    product_qty_store db 3, 6, 9, 5
    msg_confirm_purchase db "Do you want to purchase?(Y/N):$"
    msg_purchase_cancelled db "The purchase cancelled.$"
    confirmation_flag db 0
    space_padding db '    ', 24h     ; Four spaces for padding


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
option_4_jmp:
    jmp option_4
to_option_4:
    cmp al,'4'
    je option_4_jmp
    jmp to_option_5
to_option_5:
    cmp al, '5'
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
    cmp al, 'n'
    je jmp_confirmation
    cmp al, 'N'
    je jmp_confirmation

    jmp handle_cancellation

handle_cancellation:
    ; Display a message indicating that the purchase was canceled
    mov ah, 09h
    lea dx, msg_purchase_cancelled ; "Purchase has been canceled."
    int 21h

    ; Pause for user to read the message
    mov ah, 01h
    int 21h

    ; Optionally, return to the main menu or another process
    jmp menu_loop                 ; Jump back to the main menu or another process 

transaction_loop_jmp:
    jmp transaction_loop

jmp_confirmation:
    call confirm_purchase

    cmp confirmation_flag , 1
    jne jmp_back
    jmp to_display_receipt

jmp_back:
    jmp menu_loop


to_display_receipt:
    call clear_screen
    call display_company_colour_name

    mov ah, 09h
    lea dx, newline
    int 21h

    mov ah,09h
    lea dx,receipt_start
    int 21h
    ;Display product name, qty and price
    push si
    push ax
    push bx
    push dx

    mov cx, 4   ; Loop 4 times for 4 products
    mov si, 0   ; Move SI to 0 for index
display_receipt_loop:
    push cx
    mov ax, si                    ; Move SI into AX
    xor ah, ah                    ; Clear AH
    add al, 1                     ; Add 1 to AL since display_selected_product function decrements product_id
    mov product_id, al            ; Load AL (with SI value) into product_id
    sub al, 1                     ; Sub 1 from AL

    mov bl, product_qty[si]        ; Load quantity to BL
    cmp bl, 0                      ; Compare product_qty with 0
    je skip_product1               ; If qty is 0, skip to the next product

    call display_receipt_product ; Display product name and quantity

; Display product quantity
    mov bl, product_qty[si]        ; Load quantity
    add bl, '0'                    ; Convert to ASCII
    mov dl, bl                     ; Move quantity into DL for display  
    mov ah, 02h
    int 21h                        ; Display quantity

    ; Add space padding adjust the subtotal
    mov ah,09h
    lea dx, space_padding
    int 21h
    lea dx, space_padding
    int 21h
    
    ; NEW CALCULATIONS FOR SUBTOTAL
    ; Calculate subtotal for RM
    shl si, 1                       ; Shift SI one bit left (multiply 2)
    mov ax, preset_price_int[si]    ; Load price to AL. (We multiply since preset_price is word, hence 2 bytes)
    shr si, 1                       ; Shift SI one bit right (divide 2, return to original)
    mov bl, product_qty[si]         ; Load quantity to BL
    xor bh, bh                      ; Clear BH
    mul bx                          ; AX multiplies BX to get total (price * quantity = total)
    mov result_int, ax              ; Store the total into result

    ; Add to total for RM
    add total_int, ax

    ; Calculate subtotal for cents
    shl si, 1
    mov ax, preset_price_dec[si]
    shr si, 1
    mov bl, product_qty[si]
    xor bh, bh
    mul bx
    mov result_dec, ax

    ; Add to total for cents
    add total_dec, ax
    
    ; Extract overflow in cents result
    xor dx, dx                  ; Clear DX to save remainder
    mov ax, result_dec          ; Load cents into AX
    mov bx, 100                 ; Move BX to 100 for division
    div bx                      ; AX = AX / BX, remainder goes to DX
    mov result_overflow, ax     ; Move AX (overflow) to result_overflow
    mov result_dec, dx          ; Move DX (remainder (cents)) to result_dec

    ; Add the overflow to RM
    mov ax, result_int          ; Load RM into AX
    mov bx, result_overflow     ; Load overflow into BX
    add ax, bx                  ; AX = AX + BX (overflow)
    mov result_int, ax          ; Store result back into result_int
    mov bx, 0                   ; Set BX to 0
    mov ax, 0                   ; Set AX to 0
    mov result_overflow, ax     ; Clear result_overflow to 0

    push si             ; Save SI value
    call display_price
    pop si              ; Load SI value

skip_product1:
    inc si                         ; Increment product index
    pop cx
    dec cx
    jne display_receipt_loop_jmp
    jmp display_total
    
display_receipt_loop_jmp:
    jmp display_receipt_loop

display_total:
    mov ah, 09h
    lea dx, newline
    int 21h 
    lea dx,receipt_middle
    int 21h
    lea dx,newline
    int 21h

    ; Display total
    mov ah, 09h
    lea dx, wkz_subTotal
    int 21h
   
    ; Extract overflow in cents result for total
    xor dx, dx                  ; Clear DX to save remainder
    mov ax, total_dec           ; Load cents into AX
    mov bx, 100                 ; Move BX to 100 for division
    div bx                      ; AX = AX / BX, remainder goes to DX
    mov result_overflow, ax     ; Move AX (overflow) to result_overflow
    mov total_dec, dx           ; Move DX (remainder (cents)) to total_dec

    ; Add the overflow to RM
    mov ax, total_int           ; Load RM into AX
    mov bx, result_overflow     ; Load overflow into BX
    add ax, bx                  ; AX = AX + BX (overflow)
    mov total_int, ax           ; Store result back into total_int
    mov bx, 0                   ; Set BX to 0
    mov ax, 0                   ; Set AX to 0
    mov result_overflow, ax     ; Clear result_overflow to 0

    ; Move both totals into result
    mov ax, total_int
    mov result_int, ax  ; Store total RM into result_int for display
    mov ax, total_dec   
    mov result_dec, ax  ; Store total cents into result_dec for display
    mov ax, 0           ; Clear AX

    call display_price

    mov ah,09h
    lea dx,newline
    int 21h
    lea dx,discount
    int 21h

    call display_discount

    mov ah,09h
    lea dx, newline
    int 21h
    lea dx,receipt_end
    int 21h

    mov ah, 09h
    lea dx, newline
    int 21h
    
    call Ask_Print_Receipt

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

option_4:
    ; restock model
    jmp restock_proc

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

    mov ah,09h
    lea dx,newline
    int 21h

    mov ah,09h
    lea dx,current_stock_msg
    int 21h

    ; Update stock after purchase
    ; Get the quantity the user purchased from product_qty
    mov al, [product_qty + bx]    ; Load the quantity the user bought into AL

    ; Get the current stock from product_qty_store
    mov bl, product_id
    dec bl                        ; Adjust for 0-based index
    mov ah, [product_qty_store + bx] ; Load current stock into AH
    cmp ah, al
    jle not_enough_stock

    sub ah, al                 ; Subtract quantity bought from stock
    mov [product_qty_store + bx], ah ; Store the updated stock

    ; Display the updated stock
    mov al, ah     ; Load updated stock
    mov bl,al
    add al, '0'                          ; Convert to ASCII
    mov dl, al
    mov ah, 02h
    int 21h

    cmp bl,10
    jl done1
    mov ah,bl
    sub al, 10
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h

    jmp done1

not_enough_stock:
    mov al, [product_qty_store + bx] ; Load updated stock
    add al, '0'                      ; Convert to ASCII
    mov dl, al
    mov ah, 02h
    int 21h

    mov ah,09h
    lea dx,newline
    int 21h

    mov ah,09h
    lea dx,msg_insufficient_stock
    int 21h

    jmp done1
    
done1:
    pop di
    pop si
    pop dx
    pop bx
    pop ax
    ret
display_selected_product endp

display_price proc ;Convert results into ASCII to display
    ; Convert for RM
    lea si, buffer
    mov cx, 3           ; Loop 3 times for 3 bytes in buffer (max 3 digits)
    add si, 2           ; Start from the end of buffer before decimal
    mov ax, result_int  ; Move result to AX

    ; Extract and convert each digit
convert_loop_int:
    xor dx, dx      ; Clear DX for division
    mov bx, 10      ; Base 10 for conversion
    div bx          ; AX = AX / 10, DX = remainder (last digit)
    add dl, 30h     ; Convert digit to ASCII
    mov [si], dl    ; Store the digit in the buffer
    dec si          ; Move to the next buffer position
    loop convert_loop_int

    ; Remove leading zeros for RM
    lea si, buffer          ; Points SI to starting address of buffer
    mov cx, 3               ; We'll check the first 3 digits (before the decimal point / end string)
remove_leading_zeros:
    cmp byte ptr [si], '0'  ; Check for leading '0'
    jne convert_cents       ; If found non-zero number, break from loop
    mov byte ptr [si], ' '  ; Replace '0' with space
    inc si
    loop remove_leading_zeros

convert_cents:
    ; Convert for cents
    lea si, buffer
    mov byte ptr [si+3], '.'   ; Put decimal point at the 4th byte
    mov cx, 2           ; Loop 2 times for 2 bytes in buffer (max 2 digits)
    add si, 5           ; Start from the end of buffer before '$'(leave 1 extra $ for end string)
    mov ax, result_dec  ; Move result to AX

    ; Extract and convert each digit
convert_loop_dec:
    xor dx, dx      ; Clear DX for division
    mov bx, 10      ; Base 10 for conversion
    div bx          ; AX = AX / 10, DX = remainder (last digit)
    add dl, 30h     ; Convert digit to ASCII
    mov [si], dl    ; Store the digit in the buffer
    dec si          ; Move to the next buffer position
    loop convert_loop_dec

    ; Display result
    mov ah, 09h
    lea dx, buffer
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

;--------------------------------------------Restock------------------------------------
nextLine proc
    mov ah,02h
    mov dl,10d
    int 21h
    mov ah,02h
    mov dl,13
    int 21h
    ret
nextLine endp

printString proc
    mov ah, 09h         
    lea dx, [si]         
    int 21h
    xor si,si           
    ret
printString endp

captureChar proc
    mov ah, 01h   ; Set DOS function to read a single character with echo
    int 21h       ; Interrupt 21h to read from keyboard
    ret 
captureChar endp


PrintQty proc

    mov al, product_qty_store[si]  ; Load the byte at ps_inStockQuantity[si] into AL
    cmp al, 10           ; Compare with 10
    jl PrintSingleDigit   ; Jump to PrintSingleDigit if less than 10
    xor ah,ah
    mov bl, 10d           ; Prepare for division
    div bl               ; AL = quotient (tens digit), AH = remainder (ones digit)

    ; Print tens digit
    mov dl, al           ; Load tens digit into DL
    add dl, '0'          ; Convert to ASCII
    mov restock_x,ah
    mov ah, 02h          ; Function 02h - Print character
    int 21h

    ; Print ones digit
    mov dl, restock_x          ; Load ones digit into DL
    add dl, '0'          ; Convert to ASCII
    mov ah, 02h          ; Function 02h - Print character
    int 21h
    
    mov bl,0
    mov restock_x,bl  ;initialize x to 0
    jmp PrintQtyDone      ; Jump to the end

PrintSingleDigit:
    add al, '0'          ; Convert single digit to ASCII
    mov ah, 0Eh          ; Function 0Eh - Print character
    int 10h

PrintQtyDone:
    ret
PrintQty endp



restock_display proc
    call clear_screen

    lea si,restock_heading
    call printString
    call nextLine

    lea si,product_1
    call printString
    mov si,0
    call PrintQty
    call nextLine

    lea si,product_2
    call printString
    mov si,1
    call PrintQty
    call nextLine
    
    lea si,product_3
    call printString
    mov si,2
    call PrintQty
    call nextLine

    lea si,product_4
    call printString
    mov si,3
    call PrintQty
    call nextLine

    lea si,restock_Exit
    call printString
    call nextLine
    ret

restock_display endp

captureTwoNum proc

capturefirstdigit:
    lea si,restock_inputMsg_msg
    call printString
	mov ah, 01h
	int 21h
    mov restock_x,al ;x=first digit
    cmp al,'x'
    je return
    cmp al,39h ;compare first digit to 9
    jg errormsg ;jump if firstnum>=2
    cmp al,30h ;compare first digit to 0
    jl errormsg

    mov ah, 01h
	int 21h
    mov restock_y,al ;y=second digit
    cmp al,39h ;compare 2nd digit to 9
    jg errormsg
    cmp al,30h
    jl errormsg
    jmp restock_calc

errormsg:
    call nextLine
    lea si,input_firstdigit ;first digit cannot more than 1!
    call printString
    call Pause 
    call clear_screen
    call restock_display
    call nextLine
    jmp capturefirstdigit

  
restock_calc:
    xor bx,bx
    mov bl,10
    sub restock_x,30h;substract it from ASCII
    sub restock_y,30h;substract from ASCII
    mov al,restock_x
    mul bl

    add al,restock_y
    mov bx,ax ;two digits store result into bx
    call nextLine
    jmp restock_sure

restock_sure: 
    lea si,restock_confirm_msg
    call printString
    call captureChar
    cmp al,'y'
    je return
    jne restock_no

restock_no:
    cmp al,'n'
    je restock_cancel
    jne errormsg2
return:
    ret

errormsg2:
    call nextLine
    lea si,error ;invalid input !
    call printString
    call nextLine
    call Pause
    call clear_screen 
    jmp restock_sure

restock_cancel: 
    call nextLine
    lea si,restock_cancel_msg ;restock canceled
    call printString
    call nextLine
    call Pause
    call main


captureTwoNum endp


Pause proc
    mov ah,09h
    lea dx,Pause_Msg
    int 21h
    mov ah,07h
    int 21h
    ret

Pause endp    


warning proc
    call nextLine
    lea si,error
    call Pause
    call clear_screen
    ret
warning endp    
    
restock_proc proc
    call clear_screen
restock_Screen:
    
    lea si,restock_heading
    call nextLine
    call restock_display

    call nextLine
    lea si,Restock_Msg
    call printString
    call captureChar
    mov restock_x ,al ;save in restock_x
    cmp al,'x'      ;compare input is x or not
    je restock_end ;if yes then jump to restock_end
    cmp al,31h  ; compare input is more then 1 in ASCII
    jl warningMsg ;if less then 1 then jump to error msg
    cmp al,34h ; compare input is more then 4 in ASCII
    jg warningMsg ; if less then 4 then jump to error msg
    jmp select_restock

restock_end:
    call menu_loop    
warningMsg:
    call warning
    jmp restock_screen

warning1:
    call warningMsg
    jmp restock_screen

restockA:
    mov di,0
    cmp product_qty_store[di],20
    jg warning1
    call nextLine
    call captureTwoNum
    add product_qty_store[di],bl

    call nextLine
    lea si,restock_success_msg
    call printString
    call Pause
    call clear_screen

    jmp restock_Screen

restockB:
    mov di,1
    cmp product_qty_store[di],20
    jg warning1
    call nextLine
    call captureTwoNum
    add product_qty_store[di],bl

    call nextLine
    lea si,restock_success_msg
    call printString
    call Pause
    call clear_screen

    jmp restock_Screen    

restockC:
    mov di,2
    cmp product_qty_store[di],20
    jg warning1
    call nextLine
    call captureTwoNum
    add product_qty_store[di],bl

    call nextLine
    lea si,restock_success_msg
    call printString
    call Pause
    call clear_screen

    jmp restock_Screen

restockD:
    mov di,3
    cmp product_qty_store[di],20
    jg warning1
    call nextLine
    call captureTwoNum
    add product_qty_store[di],bl

    call nextLine
    lea si,restock_success_msg
    call printString
    call Pause
    call clear_screen

    jmp restock_Screen
restockA1:
    jmp restockA
restockB1:
    jmp restockB
restockC1:
    jmp restockC
restockD1:
    jmp restockD

select_restock:
    cmp al, restock_A
    je restockA1
    cmp al, restock_B
    je restockB1
    cmp al, restock_C
    je restockC1
    cmp al, restock_D
    je restockD1

ret 
restock_proc endp    

confirm_purchase proc
    mov ah, 09h
    lea dx, newline
    int 21h

    ; Ask user for confirmation to buy
    mov ah, 09h
    lea dx, msg_confirm_purchase ; "Do you want to purchase? (Y/N): "
    int 21h

    ; Get the user input
    mov ah, 01h                 ; DOS input function
    int 21h
    cmp al, 'Y'                 ; Compare input to 'Y'
    je purchase_confirmed       ; If 'Y', jump to confirm purchase
    cmp al, 'y'        
    je purchase_confirmed
    cmp al, 'n'                 ; Compare input to 'N'
    je purchase_cancelled        ; If 'N', jump to cancel purchase
    cmp al, 'N'                 
    je purchase_cancelled        

    ; If input is invalid, ask again (simple loop)
    jmp confirm_purchase         ; Loop back if neither Y nor N

purchase_confirmed:
    mov confirmation_flag, 1
    call reduce_stock
    ret

purchase_cancelled:
    mov confirmation_flag, 0
; Set all product_qty values to 0
    mov cx, 4                    ; Number of products (assuming 4 products)
    mov si, offset product_qty    ; Load the offset of product_qty array

clear_qty_loop:
    mov byte ptr [si], 0          ; Set the current product quantity to 0
    inc si                        ; Move to the next product quantity
    loop clear_qty_loop           ; Repeat until all quantities are cleared

    ret                          ; Return from the procedure
    
confirm_purchase endp

reduce_stock proc
    push ax
    push bx
    push dx

    ; Parameters: product_id in BL, quantity purchased in AL

    ; Load current stock from product_qty_store
    mov bl, product_id
    dec bl                       ; Adjust for 0-based index
    mov ah, [product_qty_store + bx] ; Load current stock into AH

    ; Check if there is enough stock
    cmp ah, al                   ; Compare stock (AH) with quantity bought (AL)
    jb insufficient_stock         ; Jump if stock is less than the quantity bought

    ; Subtract quantity bought from stock
    sub ah, al
    mov [product_qty_store + bx], ah ; Store the updated stock

    jmp done_reduce_stock

insufficient_stock:
    ; Display 0 to indicate no stock available
     ; Set stock to 0 if insufficient
    mov byte ptr [product_qty_store + bx], 0

    mov ah, 09h
    lea dx, msg_insufficient_stock
    int 21h

done_reduce_stock:
    pop dx
    pop bx
    pop ax
    ret
reduce_stock endp

;---------------------------------------------receipt------------------------------------


display_receipt_heading proc
    call clear_screen
    call display_company_colour_name

    mov ah, 09h
    lea dx, newline
    int 21h

    mov ah,09h
    lea si,receipt_start
    int 21h


display_receipt_heading endp

Ask_Print_Receipt proc
   
testing:
    mov ah, 09h
    lea dx, newline
    int 21h

    lea si,print
    call printString
    
    lea si, enter_choice
    call printString 
    call captureChar
    
    cmp al, 'a'
    je PrintReceipt
    cmp al, 'b'
    je NoPrint
    
    lea si,error
    call printString
    jmp testing

PrintReceipt:
    mov ah, 09h
    lea dx, newline
    int 21h

    call Enter_to_process  ; Call printing procedure
    jmp clear_data
    ret

NoPrint:
    ; Display the company name and skip the print process
    ; Print newline
    jmp clear_data

clear_data:
    
    mov cx, 4              ; Number of elements in the product_qty array
    lea si, product_qty     ; Load the offset of the product_qty array into SI

zero_qty:
    mov byte ptr [si], 0    ; Set the current element to 0
    inc si                  ; Move to the next element in the array
    loop zero_qty           ; Repeat until CX becomes 0
    ; Clear buffer
    mov cx, 7               ; Assuming buffer is 10 bytes long (adjust size accordingly)
    lea si, buffer           ; Load the offset of the buffer into SI

zero_buffer:
    mov byte ptr [si], 0     ; Set the current byte in buffer to 0
    inc si                   ; Move to the next byte
    loop zero_buffer          ; Repeat until CX becomes 0

    ; Clear discount_value
    mov discount_value, 0    ; Directly set discount_value to 0


    ret

Ask_Print_Receipt endp

display_discount proc
    ; Display Subtotal
    lea si, buffer
    mov cx, 3               ; Loop 3 times for 3 digits in buffer
    add si, 2               ; Start at the end of the buffer
    mov ax, result_int       ; Move result_int to AX

    ; Convert and display subtotal
convert_loop_int1:
    xor dx, dx              ; Clear DX for division
    mov bx, 10              ; Base 10 for conversion
    div bx                  ; Divide AX by 10, remainder in DX
    add dl, 30h             ; Convert remainder to ASCII
    mov [si], dl            ; Store ASCII digit in buffer
    dec si                  ; Move to next buffer position
    loop convert_loop_int1

    ; Now calculate the discount if result_int >= 100
    mov ax, result_int      ; Load integer result into AX
    cmp ax, 100             ; Compare AX with 100
    jl no_discount          ; Jump to no_discount if less than 100

    ; Apply 8% discount calculation
    mov cx, 8               ; Load 8 (percent) into CX
    mul cx                  ; Multiply AX by 8 (result in DX:AX)
    mov cx, 100             ; Load 100 for division
    div cx                  ; Divide AX by 100 (AX = 8% of subtotal)

    ; Store the discount value in a separate variable (discount_value)
    mov discount_value, ax

    ; Convert and display the discount (8 RM in this case)
    lea si, buffer
    mov cx, 3               ; Convert and display the discount amount
    add si, 2
    mov ax, discount_value   ; Load discount value into AX

convert_loop_discount:
    xor dx, dx
    mov bx, 10
    div bx
    add dl, 30h
    mov [si], dl
    dec si
    loop convert_loop_discount

    mov ah ,09h
    lea dx,buffer
    int 21h

    jmp end

no_discount:
    mov ah,09h
    lea dx, space_padding
    int 21h
    ; If no discount or after discount, continue here
    mov ah,09h
    lea dx, no_discount_msg
    int 21h

end:

    ret
display_discount endp

Enter_to_process proc
    mov ah, 09h
    lea dx, printing
    int 21h
    mov ah, 07h
    int 21h
    ret
Enter_to_process endp

display_receipt_product proc ;Display Product
    push ax
    push bx
    push dx
    push si
    push di

    mov ah, 09h 
    lea dx, newline
    int 21h ;selected product

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
receipt_product_name:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    loop receipt_product_name

    mov byte ptr [di], '$'  ; Null-terminate the string

    mov ah, 09h
    lea dx, current_product
    int 21h


    mov bl, product_id
    dec bl  ; Adjust for 0-based index
    mov bh, 0

    ; Add space padding
    lea dx, space_padding
    int 21h
    ; Add space padding
    lea dx, space_padding
    int 21h; Add space padding
    lea dx, space_padding
    int 21h

    mov al, [product_qty + bx]
    add al, '0'
    mov dl, al


    pop di
    pop si
    pop dx
    pop bx
    pop ax
    ret
display_receipt_product endp

add_spaces proc
    push cx
    mov ah, 02h               ; DOS function to display characters
    mov dl, ' '               ; Character to display (space)
add_space_loop:
    int 21h                   ; Display space
    loop add_space_loop
    pop cx
    ret
add_spaces endp



end main
