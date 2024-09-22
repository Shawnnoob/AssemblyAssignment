.model small
.stack 100h
.data
    company_name db "====================", 0dh, 0ah
                 db "|    ABC Retail    |", 0dh, 0ah
                 db "--------------------", 0dh, 0ah, 0

     company_menu_name db"+================================================================+", 0dh, 0ah
                      db"|    _      ____     ____     ____           _             _   _ |", 0dh, 0ah
                      db"|   / \    | __ )   / ___|   |  _ \    ___  | |_    __ _  (_) | ||", 0dh, 0ah
                      db"|  / _ \   |  _ \  | |       | |_) |  / _ \ | __|  / _` | | | | ||", 0dh, 0ah
                      db"| / ___ \  | |_) | | |___    |  _ <  |  __/ | |_  | (_| | | | | ||", 0dh, 0ah
                      db"|/_/   \_\ |____/   \____|   |_| \_\  \___|  \__|  \__,_| |_| |_||", 0dh, 0ah
                      db"+================================================================+", 0dh, 0ah, 0

    menu db "-----------------------------------", 0dh, 0ah
         db "|       1. Start transaction      |", 0dh, 0ah
         db "|       2. Show cashbox           |", 0dh, 0ah
         db "|       3. Restock product        |", 0dh, 0ah
         db "|       4. System HELP            |", 0dh, 0ah
         db "|       5. Exit program           |", 0dh, 0ah
         db "-----------------------------------", 0dh, 0ah, 0

    product_menu db "==========================================", 0dh, 0ah
                 db "|         Products           | Price(RM) |", 0dh, 0ah
                 db "|----------------------------|-----------|", 0dh, 0ah
                 db "| 1. Tissue                  |    4.20   |", 0dh, 0ah
                 db "| 2. Toothpaste              |   13.20   |", 0dh, 0ah
                 db "| 3. Body Wash               |   18.90   |", 0dh, 0ah
                 db "| 4. Lotion                  |   21.00   |", 0dh, 0ah
                 db "------------------------------------------", 0dh, 0ah, 0

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
    product_d db 'Lotion     ', 0

    product_lengths db 11, 11, 11, 11     ; Lengths of each product name
    product_qty db 0, 0, 0, 0             ; Chosen quantity for each product

    product_id db ?                 ; Buffer to store current product ID
    current_product db 20 dup('$')  ; Buffer to store current product name
    quantity db ?                   ; Buffer to store quantity user inputs

    ; Variable for calculations
    preset_price_int dw 4, 13, 18, 21    ; Price in RM
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

    prompt_menu_choice db 'Enter your choice (1-5): $'
    prompt_product_id db 'Enter product ID: $'
    prompt_quantity db 'Enter quantity (1-3): $'
    prompt_more_product db 'Do you want to buy more products? (Y/N): $'
    msg_selected_product db 13, 10, 'Selected product: $'
    msg_current_quantity db 'Current quantity (max 3 per item): $'
    msg_invalid_product db 13, 10, 'Invalid product ID. Enter to try again.$'
    msg_invalid_quantity db 13, 10, 'Invalid input/quantity. Enter to try again.$'
    msg_invalid_input db 'Invalid input. Enter to try again with a correct number. $'
    msg_exit db 'Exiting program. Thank you for using our POS system! $'
    msg_max_quantity db 13, 10, 'Maximum quantity reached for this product. Enter to continue.$'
    msg_subtotal db 'Subtotal: RM$'
    msg_total db 'Total: RM$'
    msg_continue db 'Press enter to continue...$'

;----------------------------------Receipt-------------------------------------------
    receipt_start   db "===========================================", 0dh, 0ah
                    db "|               Receipt                   |", 0dh, 0ah
                    db "-------------------------------------------", 0dh, 0ah
                    db "Product Name         QTY        Amount(RM) ", 0dh, 0ah
                    db "                                           ", 0dh, 0ah, 0

    receipt_middle db "-------------------------------------------$", 0dh, 0ah

    receipt_end     db  "-------------------------------------------", 0dh, 0ah
                    db  "          Thanks You Very Much              ", 0dh, 0ah           
                    db  "            Have A Nice Day                 ", 0dh, 0ah
                    db  "===========================================", 0dh, 0ah
                    db  "                                           $", 0dh, 0ah

    wkz_subTotal    db  "Total                          |$", 0dh, 0ah
    discount        db  "Discount(10%)                  |$", 0dh, 0ah
    discount_value  dw 0                 ; Store discount amount here
    no_discount_msg db "0.00$",0dh,0ah
    sst         db      "SST (8%)                       |$", 0dh, 0ah
    wkz_total       db  "Net Total                      |$", 0dh, 0ah   
    after_total_int dw 0
    after_total_dec dw 0


    print   db "Do you want to print the receipt?", 0dh, 0ah
            db "      Y - Yes  N - No            ", 0dh, 0ah
            db "$"

    enter_choice db "Enter your choice: $", 0dh, 0ah

    printing    db "===============================",0dh,0ah
                db "Printing......                ", 0dh, 0ah
                db "Press Enter to process       ", 0dh, 0ah
                db "$"

    discount_dec dw 0
    discount_int dw 0
    sst_int dw 0
    sst_dec dw 0

;----------------------------------------------addStock------------------------------
    error db "Invalid input please try again.$"
    Pause_Msg db "Press any key to continue...$",0dh,0ah
    Restock_Msg db "Enter (1,2,3,4) to restock the product, x to exit: $",0dh,0ah

    restock_heading   db "===========================================", 0dh, 0ah
                      db "|              Add stock                   |", 0dh, 0ah
                      db "-------------------------------------------", 0dh, 0ah
                      db "                                           ", 0dh, 0ah, 0

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
    msg_insufficient_stock db 0dh, 0ah, 'Not enough stock for sales.', 0dh, 0ah
                           db 'Enter to try again...$'

    product_1   db "1. Tissue                  $"
    product_2   db "2. Toothpaste              $"
    product_3   db "3. Body Wash               $"
    product_4   db "4. Lotion                  $"
    restock_Exit db    "X. Exit$"
    
    restock_x db 0
    restock_y db 0     
    product_qty_store db 3, 6, 9, 5
    msg_confirm_purchase db "Do you want to purchase? (Y/N)         :$"
    msg_purchase_cancelled db "The purchase cancelled.$"
    confirmation_flag db 0
    space_padding db '    ', 24h     ; Four spaces for padding

;----------------------------HELP function---------------------------
    msg_help db '-Welcome to the HELP page!        ', 0dh, 0ah
             db '-You are now using the POS system of ABC Retail.          ', 0dh, 0ah
             db '-This system helps you to perform transactions and track stock.          ', 0dh, 0ah
             db '-Below is a list of functions available in the system.          ', 0dh, 0ah, 0dh, 0ah, '$'

    msg_options db '===============================================================', 0dh, 0ah
                db '|                    Functions Available                      |', 0dh, 0ah
                db '===============================================================', 0dh, 0ah
                db '| 1. Start transaction                                        |', 0dh, 0ah
                db '| 2. Show cashbox                                             |', 0dh, 0ah
                db '| 3. Restock product                                          |', 0dh, 0ah
                db '| 4. RETURN TO MAIN                                           |', 0dh, 0ah
                db '===============================================================', 0dh, 0ah, 0

    prompt_help db 'Select the function to provide help on ( 1-3 | 4 to exit ): $'

    help_option1 db 0dh, 0ah
                 db ':Start transaction:- ', 0dh, 0ah
                 db ':Starts a  new transaction  by  choosing  products  and  their ', 0dh, 0ah
                 db ':quantity.  Product ID  will  be  used  to  pick  the  product ', 0dh, 0ah
                 db ':desired. Prices will be displayed as a receipt. ', 0dh, 0ah, 0dh, 0ah, '$'

    help_option2 db 0dh, 0ah
                 db ':Show cashbox:- ', 0dh, 0ah
                 db ':Displays the amount of cash  accumulated within the  cashbox. ', 0dh, 0ah
                 db ':It is the accumulation of all current session. ', 0dh, 0ah, 0dh, 0ah, '$'

    help_option3 db 0dh, 0ah
                 db ':Restock product:- ', 0dh, 0ah
                 db ':Allows user to  increase  the  inventory level  of  products. ', 0dh, 0ah
                 db ':Product ID will  be  used to  pick  the  product desired, and ', 0dh, 0ah
                 db ':quantity will be added as input. ', 0dh, 0ah, 0dh, 0ah, '$'

    msg_invalid_help db 'Invalid option. Please choose a number between 0 and 4.$'

     ;--------------------------------Cashbox----------------------------------------------------
    ;Message for cashbox
    cashbox_header  db '-------------------------', 0Dh, 0Ah
                    db '     Cashbox Summary     ', 0Dh, 0Ah
                    db '-------------------------', 0Dh, 0Ah, 0
    cashbox_total_msg      db 'Cashbox Total: RM', '$'
    msg_continue_1         db  'Press enter to continue...', '$'
    cashbox_total_int dw 0
    cashbox_total_dec dw 0
    cashbox_overflow  dw ?
    cashbox_result_int dw ?             ; Variable to store RM result
    cashbox_result_dec dw ?             ; Variable to store cents result
    cashbox_buffer db 7 dup('$')          ; Buffer for displaying

    ;--------------------------------Sound---------------------------------------------------------
    sound1 dw 6370h	; frequency for tone1 (440 Hz)

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
    inc si                       ; move to the next byte in the buffer
    loop clear_loop              ; Repeat until CX = 0 (end of buffer)

menu_loop:
    ; Clear the screen
    call clear_screen
    ; Print company name
    call display_company_menu_colour_name

    ; Print success message
    mov ah, 09h
    lea dx, msg_success_login
    int 21h
    lea dx, newline
    int 21h

    call display_menu_colour_name

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

    call display_product_menu_color_name

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
    mov al, quantity
    cmp al, 3
    jg max_quantity_reached_msg
    jmp valid_quantity_2

max_quantity_reached_msg:
    jmp max_quantity_reached

valid_quantity_2:
    ; Check if the stock has enough qty to reduce
    mov bl, product_id
    dec bl  ; Adjust for 0-based index
    mov bh, 0
    mov al, [product_qty_store + bx]
    mov ah, [quantity]
    cmp ah, al
    jg not_enough_stock_msg
    jmp valid_quantity_3

not_enough_stock_msg:
    jmp not_enough_stock

valid_quantity_3:
    ; Update product quantity
    mov bl, product_id
    dec bl  ; Adjust for 0-based index
    mov bh, 0
    mov al, quantity
    mov [product_qty + bx], al

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
    lea dx,newline
    int 21h
    lea dx, msg_purchase_cancelled ; "Purchase has been canceled."
    int 21h

    ; Pause for user to read the message
    mov ah, 01h
    int 21h

reset_data:   
    mov cx, 4              ; Number of elements in the product_qty array
    lea si, product_qty     ; Load the offset of the product_qty array into SI
reset_qty:
    mov byte ptr [si], 0    ; Set the current element to 0
    inc si                  ; move to the next element in the array
    loop reset_qty           ; Repeat until CX becomes 0

    ; Clear buffer
    mov cx, 6               ; Clear 6 bytes of buffer (Leave $ for last)
    lea si, buffer           ; Load the offset of the buffer into SI


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

    call display_receipt_start_color_name

    ;Display product name, qty and price
    push si
    push ax
    push bx
    push dx

    mov cx, 4   ; Loop 4 times for 4 products
    mov si, 0   ; move SI to 0 for index
display_receipt_loop:
    push cx
    mov ax, si                    ; move SI into AX
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
    mov dl, bl                     ; move quantity into DL for display  
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
    mov bx, 100                 ; move BX to 100 for division
    div bx                      ; AX = AX / BX, remainder goes to DX
    mov result_overflow, ax     ; move AX (overflow) to result_overflow
    mov result_dec, dx          ; move DX (remainder (cents)) to result_dec

    ; Add the overflow to RM
    mov ax, result_int          ; Load RM into AX
    mov bx, result_overflow     ; Load overflow into BX
    add ax, bx                  ; AX = AX + BX (overflow)
    mov result_int, ax          ; Store result back into result_int
    mov bx, 0                   ; Set BX to 0
    mov ax, 0                   ; Set AX to 0
    mov result_overflow, ax     ; Clear result_overflow to 0

    call update_cashbox

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
    mov bx, 100                 ; move BX to 100 for division
    div bx                      ; AX = AX / BX, remainder goes to DX
    mov result_overflow, ax     ; move AX (overflow) to result_overflow
    mov total_dec, dx           ; move DX (remainder (cents)) to total_dec

    ; Add the overflow to RM
    mov ax, total_int           ; Load RM into AX
    mov bx, result_overflow     ; Load overflow into BX
    add ax, bx                  ; AX = AX + BX (overflow)
    mov total_int, ax           ; Store result back into total_int
    mov bx, 0                   ; Set BX to 0
    mov ax, 0                   ; Set AX to 0
    mov result_overflow, ax     ; Clear result_overflow to 0

    ; move both totals into result
    mov ax, total_int
    mov result_int, ax  ; Store total RM into result_int for display
    mov ax, total_dec   
    mov result_dec, ax  ; Store total cents into result_dec for display
    mov ax, 0           ; Clear AX

    call display_price

    mov ax,total_int
    cmp ax,100
    jle jmp_sst

    mov ah,09h
    lea dx,newline
    int 21h
    lea dx,discount
    int 21h

    call calculate_discount
    call display_discount
    
jmp_sst:
    mov ah,09h
    lea dx, newline
    int 21h
    lea dx,sst
    int 21h

    call calculate_sst
    call display_sst
    

    mov ah,09h
    lea dx,newline
    int 21h
    lea dx,wkz_total
    int 21h 

    call calculate_after_total
    call display_after_total


    mov ah,09h
    lea dx,newline
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

    ; Clear all totals
    mov ax, 0
    mov total_int, ax
    mov total_dec, ax

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

not_enough_stock:
    mov ah, 09h
    lea dx, msg_insufficient_stock
    int 21h
    mov ah, 01h
    int 21h
    jmp transaction_loop

option_2:
    ; Cashbox module
    call display_cashbox_total
    jmp menu_loop

option_3:
    ; Restock module
    call restock_proc
    jmp menu_loop

option_4:
    ; HELP module
    call help_menu
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
    add di, cx                ; move DI to the end of the input string
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
    add di, cx                ; move DI to the end of the input string
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
    mov si, bx                  ; move BX (product_id value) into SI
    mov al, product_lengths[si] ; Get the length of the product name
    mov cl, al                  ; move length into CL
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

    mov bl, product_id
    dec bl  ; Adjust for 0-based index
    mov bh, 0
    mov al, [product_qty_store + bx]
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

display_price proc ;Convert results into ASCII to display
    ; Convert for RM
    lea si, buffer
    mov cx, 3           ; Loop 3 times for 3 bytes in buffer (max 3 digits)
    add si, 2           ; Start from the end of buffer before decimal
    mov ax, result_int  ; move result to AX

    ; Extract and convert each digit
convert_loop_int:
    xor dx, dx      ; Clear DX for division
    mov bx, 10      ; Base 10 for conversion
    div bx          ; AX = AX / 10, DX = remainder (last digit)
    add dl, 30h     ; Convert digit to ASCII
    mov [si], dl    ; Store the digit in the buffer
    dec si          ; move to the next buffer position
    loop convert_loop_int

    ; Remove leading zeros for RM
    lea si, buffer          ; Points SI to starting address of buffer
    mov cx, 2               ; We'll check the first 2 digits (leave 1 in case of RM0)
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
    mov ax, result_dec  ; move result to AX

    ; Extract and convert each digit
convert_loop_dec:
    xor dx, dx      ; Clear DX for division
    mov bx, 10      ; Base 10 for conversion
    div bx          ; AX = AX / 10, DX = remainder (last digit)
    add dl, 30h     ; Convert digit to ASCII
    mov [si], dl    ; Store the digit in the buffer
    dec si          ; move to the next buffer position
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

    inc si           ; move to next character in first string
    inc di           ; move to next character in second string
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
    inc dh               ; move cursor to next row
    mov dl, 0            ; Reset cursor to first column
    jmp set_cursor

print_char:
    ; Print the character with color
    mov ah, 09h          ; BIOS function to write character and attribute
    mov bh, 0            ; Display page number (0)
    mov cx, 1            ; Number of times to print the character (once)
    int 10h              ; call BIOS interrupt to display the character

    inc dl               ; move cursor to next column

set_cursor:
    mov ah, 02h          ; Set cursor position
    mov bh, 0            ; Page number
    int 10h              ; call BIOS interrupt to set new position

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
    int 21h       ; interrupt 21h to read from keyboard
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

    call display_restock_heading_color_name

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
    lea dx, newline
    int 21h
    lea dx,Pause_Msg
    int 21h
    mov ah,07h
    int 21h
    ret

Pause endp    


warning proc
    call nextLine
    mov ah, 09h
    lea dx, error
    int 21h
    call Pause
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
    jg warning1_jmp
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
    jg warning1_jmp
    call nextLine
    call captureTwoNum
    add product_qty_store[di],bl

    call nextLine
    lea si,restock_success_msg
    call printString
    call Pause
    call clear_screen

    jmp restock_Screen

warning1_jmp:
    jmp warning1

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


    mov ah, 09h
    lea dx, nextline
    int 21h
    lea dx, error
    int 21h
    
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
    inc si                        ; move to the next product quantity
    loop clear_qty_loop           ; Repeat until all quantities are cleared

    ret                          ; Return from the procedure
    
confirm_purchase endp

reduce_stock proc
    push ax
    push bx
    push dx

    ; Parameters: product_id in BL, quantity purchased in AL
    mov cx, 4
    mov si, 0
reduce_stock_loop:
    ; Load current stock from product_qty_store
    ;mov bl, product_id
    ;dec bl                              ; Adjust for 0-based index
    mov ah, [product_qty_store + si]    ; Load current stock into AH
    mov al, [product_qty + si]          ; Load purchase qty into AL

    ; Subtract quantity bought from stock
    sub ah, al
    mov [product_qty_store + si], ah ; Store the updated stock

    inc si
    loop reduce_stock_loop

done_reduce_stock:
    pop dx
    pop bx
    pop ax
    ret
reduce_stock endp

;Receipt------------------------------------


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
    
    cmp al, 'Y'
    je PrintReceipt
    cmp al, 'y'
    je PrintReceipt
    cmp al, 'n'
    je NoPrint
    cmp al, 'N'
    je NoPrint
    
    mov ah,09h
    lea dx,newline
    int 21h
    lea si,error
    call printString
    jmp testing

PrintReceipt:

	lea dx, newline
	int 21h

    call Enter_to_process  ; call printing procedure
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
    inc si                  ; move to the next element in the array
    loop zero_qty           ; Repeat until CX becomes 0

    ; Clear buffer
    mov cx, 6               ; Clear 6 bytes of buffer (Leave $ for last)
    lea si, buffer           ; Load the offset of the buffer into SI

zero_buffer:
    mov byte ptr [si], 0     ; Set the current byte in buffer to 0
    inc si                   ; move to the next byte
    loop zero_buffer          ; Repeat until CX becomes 0

    ; Clear discount_value
    mov discount_value, 0    ; Directly set discount_value to 0

    ret

Ask_Print_Receipt endp

calculate_discount proc

    mov ax, total_int          ; Load total RM (integer part) into AX
    cmp ax, 100                 ; Compare result_int with 100
    jl no_discount
    ; Calculate discount on integer part (result_int)
    mov ax, total_int          ; Load total RM (integer part) into AX
    mov bx, 10                   ; 10% discount
    mul bx                      ; Multiply result_int by 10
    mov cx, 100                 ; Divide by 100 to get the percentage
    div cx                      ; AX now has the discount integer part
    mov discount_int, ax  ; Store the integer part of the discount

    ; Store the remainder from the division in DX (this is part of the decimal)
    mov ax, dx                  ; DX contains the remainder (this is part of cents)
    mov discount_dec, ax  ; Temporarily store it in discount_amount_dec

    ; Calculate discount on decimal part (result_dec)
    mov ax, total_dec          ; Load total cents into AX
    mul bx                      ; Multiply result_dec by 10
    div cx                      ; Divide by 100 to get the percentage
    add discount_dec, ax  ; Add the discount from the decimal part to the remainder

check_discount_overflow:
    ; Handle cases where discount_amount_dec exceeds 100
    cmp discount_dec, 100
    jl skip_adjustment          ; If decimal part exceeds 100, increase discount_amount_int by 1
    inc discount_int
    sub discount_dec, 100       ; Adjust the decimal part
    loop check_discount_overflow

skip_adjustment:
    ret

no_discount:
    ; If result_int < 100, set discount to 0.00
    mov discount_int, 0         ; No discount for integer part
    mov discount_dec, 0         ; No discount for decimal part
    ret
calculate_discount endp

calculate_sst proc

    mov ax, total_int           ; Load total RM (integer part) into AX
    ; Calculate discount on integer part (result_int)
    mov bx, 8                   ; 8% sst
    mul bx                      ; Multiply total_int by 8
    mov cx, 100                 ; Divide by 100 to get the percentage
    div cx                      ; AX now has the discount integer part
    mov sst_int, ax  ; Store the integer part of the sst

    ; Store the remainder from the division in DX (this is part of the decimal)
    mov ax, dx                  ; DX contains the remainder (this is part of cents)
    mov sst_dec, ax  ; Store the decimal part of the sst

    ; Calculate discount on decimal part (result_dec)
    mov ax, total_dec           ; Load total cents into AX
    mul bx                      ; Multiply total_dec by 10
    div cx                      ; Divide by 100 to get the percentage
    add sst_dec, ax  ; Store the dec part of the sst

check_sst_overflow:
    ; Handle cases where sst_dec exceeds 100
    cmp sst_dec, 100
    jl skip_adjustment1          ; If decimal part exceeds 100, increase sst_int by 1
    inc sst_int
    sub sst, 100                ; Adjust the decimal part
    loop check_sst_overflow
skip_adjustment1:
    ret
calculate_sst endp


calculate_after_total proc

    mov ax, total_int      ; Load total RM (integer part) into AX
    sub ax, discount_int   ; Subtract discount_int from total_int
    add ax, sst_int        ; Add sst_int to total_int
    mov after_total_int, ax      ; Store the result back into after_total_int
    
    mov ax, total_dec      ; Load total RM (integer part) into AX
    sub ax, discount_dec   ; Subtract discount_int from total_int
    add ax, sst_dec        ; Add sst_int to total_int
check_overflow:
    cmp ax, 100            ; Check if decimal part exceeds 100
    jl skip_adjustment2    ; If less than 100, then skip the overflow handling
    inc after_total_int    ; Increase integer part by 1
    sub ax, 100            ; Adjust the decimal part
    loop check_overflow    ; Loops until it is less than 100

skip_adjustment2:
    mov after_total_dec, ax      ; Store the result back into after_total_dec

    ret
calculate_after_total endp

display_after_total proc
    mov ax, after_total_int  ; Load discounted RM (integer part)
    call display_integer_part    ; Display the integer part

    ; Display the decimal point
    lea si, buffer
    add si, 3                    ; move to 4th position
    mov byte ptr [si], '.'       ; Insert decimal point

    mov ax, after_total_dec  ; Load discounted cents (decimal part)
    call display_decimal_part    ; Display the decimal part

    ; Display the result
    lea dx, buffer               ; Load buffer into DX
    mov ah, 09h                  ; DOS interrupt to display string
    int 21h
    ret
display_after_total endp


;-----------------------------------
; Procedure to display discount amount
;-----------------------------------
display_discount proc
    mov ax, discount_int  ; Load discounted RM (integer part)
    call display_integer_part    ; Display the integer part

    ; Display the decimal point
    lea si, buffer
    add si, 3                    ; move to 4th position
    mov byte ptr [si], '.'       ; Insert decimal point

    mov ax, discount_dec  ; Load discounted cents (decimal part)
    call display_decimal_part    ; Display the decimal part

    ; Display the result
    lea dx, buffer               ; Load buffer into DX
    mov ah, 09h                  ; DOS interrupt to display string
    int 21h
    ret
display_discount endp


display_sst proc
    mov ax, sst_int  ; Load discounted RM (integer part)
    call display_integer_part    ; Display the integer part

    ; Display the decimal point
    lea si, buffer
    add si, 3                    ; move to 4th position
    mov byte ptr [si], '.'       ; Insert decimal point

    mov ax, sst_dec  ; Load discounted cents (decimal part)
    call display_decimal_part    ; Display the decimal part

    ; Display the result
    lea dx, buffer               ; Load buffer into DX
    mov ah, 09h                  ; DOS interrupt to display string
    int 21h
    ret
display_sst endp

;-----------------------------------
; Procedure to display integer part
;-----------------------------------
display_integer_part proc
    lea si, buffer               ; Load buffer into SI
    mov cx, 3                    ; Loop for 3 digits
    add si, 2                    ; Start at the last buffer position

convert_loop_int_discount:
    xor dx, dx                   ; Clear DX for division
    mov bx, 10                   ; Set divisor to 10
    div bx                       ; Divide AX by 10, remainder in DX
    add dl, 30h                  ; Convert remainder to ASCII
    mov [si], dl                 ; Store ASCII in buffer
    dec si                       ; move to next buffer position
    loop convert_loop_int_discount

    ; Remove leading zeroes
    lea si, buffer               ; Point SI to start of buffer
    mov cx, 2                    ; Check the first 2 digits
remove_leading_zeros_discount:
    cmp byte ptr [si], '0'       ; Check for leading '0'
    jne skip_zero_removal        ; If not '0', stop removing
    mov byte ptr [si], ' '       ; Replace '0' with space
    inc si                       ; move to the next byte
    loop remove_leading_zeros_discount

skip_zero_removal:
    ret
display_integer_part endp

;-----------------------------------
; Procedure to display decimal part
;-----------------------------------
display_decimal_part proc
    lea si, buffer               ; Load buffer into SI
    add si, 5                    ; move to the position after the decimal point
    mov cx, 2                    ; Two digits for the decimal part

convert_loop_dec_discount:
    xor dx, dx                   ; Clear DX for division
    mov bx, 10                   ; Set divisor to 10
    div bx                       ; Divide AX by 10, remainder in DX
    add dl, 30h                  ; Convert remainder to ASCII
    mov [si], dl                 ; Store ASCII in buffer
    dec si                       ; move back in buffer
    loop convert_loop_dec_discount
    ret
display_decimal_part endp


Enter_to_process proc
    mov ah, 09h
    lea dx, printing
    int 21h

     ; Play sound1 (440 Hz)
	mov ax, sound1
	call PlayTone

	; Stop sound1
	call StopTone
	mov ah,09h
	lea dx, newline
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
    mov si, bx                  ; move BX (product_id value) into SI
    mov al, product_lengths[si] ; Get the length of the product name
    mov cl, al                  ; move length into CL
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

;-------------------------------
; Procedure for displaying HELP
;-------------------------------

help_menu proc
    call clear_screen
    call display_company_colour_name

   ; Display welcome message
    lea SI, msg_help
    call slow_display

help_loop:
    ; Display options
    call display_msg_help_colour_name

    ; Prompt for user input
    mov AH, 09h
    lea DX, prompt_help
    int 21h

    ; Get user input
    mov AH, 01h
    int 21h

    ; Convert ASCII to number (1-4)
    sub AL, '0'

    ; Check if input is valid (1-4)
    cmp AL, 1
    JL invalid_help_input
    cmp AL, 4
    JG invalid_help_input

    ; Jump to appropriate option explanation
    cmp AL, 1
    je option1
    cmp AL, 2
    je option2
    cmp AL, 3
    je option3
    cmp AL, 4
    je option4

option1:
    mov AH, 09h
    lea DX, newline
    int 21h
    lea SI, help_option1
    jmp display_help_option

option2:
    mov AH, 09h
    lea DX, newline
    int 21h
    lea SI, help_option2
    jmp display_help_option

option3:
    mov AH, 09h
    lea DX, newline
    int 21h
    lea SI, help_option3
    jmp display_help_option

option4:
    ret

display_help_option:
    call slow_display
    
    ; Display "Press Enter to continue" message
    mov AH, 09h
    lea DX, msg_continue
    int 21h

    ; Wait for Enter key
    mov AH, 01h
    int 21h

    call clear_screen
    call display_company_colour_name

    mov ah, 09h
    lea dx, msg_help
    int 21h

    jmp help_loop

invalid_help_input:
    mov AH, 09h
    lea DX, newline
    int 21h
    lea DX, msg_invalid_help
    int 21h
    lea dx, newline
    int 21h
    ; Display "Press Enter to continue" message
    lea DX, msg_continue
    int 21h
    ; Wait for Enter key
    mov AH, 01h
    int 21h

    call clear_screen
    call display_company_colour_name

    mov ah, 09h
    lea dx, msg_help
    int 21h

    jmp help_loop

help_menu endp

slow_display PROC ; Displays characters slowly
next_char:
    mov AL, [SI]              ; Load the next character from the message
    cmp AL, '$'               ; Check if it's the end of the string
    je done_slow_display                   ; If yes, exit the loop

    ; Display the character
    mov AH, 0Eh               ; BIOS Teletype output function (output 1 char on screen)
    mov BH, 0                 ; Page number (0 for standard output)
    mov BL, 7                 ; Text attribute (white text)
    int 10H                   ; Interrupt to display character

    call delay                ; Call the delay function

    inc SI                    ; Move to the next character
    jmp next_char              ; Repeat the loop

done_slow_display:
    ret
slow_display ENDP

; Simple delay procedure to slow down the display
delay proc
    mov cx, 00002H            ; Set CX for outer loop
delay_loop:                    ; Outer loop count for delay
    push cx
    mov cx, 08FFFH            ; Set CX for inner loop
delay_loop2:               ; Inner loop count for delay
    nop                       ; No operation
    loop delay_loop2           ; Decrement CX and repeat until CX = 0
    pop CX
    loop delay_loop            ; Decrement CX and repeat until CX = 0
    ret
delay endp

update_cashbox proc
    ; Add transaction total to cashbox total
    mov ax, result_int
    add cashbox_total_int, ax
    mov ax, result_dec
    add cashbox_total_dec, ax
    
    ; Handle overflow from cents to dollars
    mov ax, cashbox_total_dec
    cmp ax, 100
    jl no_overflow
    sub ax, 100
    mov cashbox_total_dec, ax
    inc cashbox_total_int
no_overflow:
    ret
update_cashbox endp

display_cashbox_total proc

    call clear_screen

    call display_cashbox_header_color_name
    
    ; Display cashbox total message
    mov ah, 09h
    lea dx, cashbox_total_msg
    int 21h
    
    ; Extract overflow in cents result for cashbox total
    xor dx, dx                  ; Clear DX to save remainder
    mov ax, cashbox_total_dec   ; Load cents into AX
    mov bx, 100                 ; Move BX to 100 for division
    div bx                      ; AX = AX / BX, remainder goes to DX
    mov cashbox_overflow, ax    ; Move AX (overflow) to result_overflow
    mov cashbox_total_dec, dx   ; Move DX (remainder (cents)) to cashbox_total_dec
    
    ; Add the overflow to RM
    mov ax, cashbox_total_int   ; Load RM into AX
    mov bx, cashbox_overflow     ; Load overflow into BX
    add ax, bx                  ; AX = AX + BX (overflow)
    mov cashbox_total_int, ax   ; Store result back into cashbox_total_int
    mov bx, 0                   ; Set BX to 0
    mov ax, 0                   ; Set AX to 0
    mov cashbox_overflow, ax     ; Clear result_overflow to 0
    
    ; Move both totals into result for display
    mov ax, cashbox_total_int
    mov cashbox_result_int, ax  ; Store total RM into result_int for display
    mov ax, cashbox_total_dec
    mov cashbox_result_dec, ax  ; Store total cents into result_dec for display
    mov ax, 0           ; Clear AX
    
    call display_price_cashbox
    
    ; Display newline
    mov ah, 09h
    lea dx, newline
    int 21h
    
    ; Display continue message
    lea dx, msg_continue_1
    int 21h
    
    ; Wait for Enter key
    mov ah, 01h
    int 21h
    
    ret
display_cashbox_total endp

display_price_cashbox proc ;Convert results into ASCII to display
    ; Convert for RM
    lea si, cashbox_buffer
    mov cx, 3           ; Loop 3 times for 3 bytes in buffer (max 3 digits)
    add si, 2           ; Start from the end of buffer before decimal
    mov ax, cashbox_result_int  ; Move result to AX

    ; Extract and convert each digit
convert_cashbox_loop_int:
    xor dx, dx      ; Clear DX for division
    mov bx, 10      ; Base 10 for conversion
    div bx          ; AX = AX / 10, DX = remainder (last digit)
    add dl, 30h     ; Convert digit to ASCII
    mov [si], dl    ; Store the digit in the buffer
    dec si          ; Move to the next buffer position
    loop convert_cashbox_loop_int

    ; Remove leading zeros for RM
    lea si, cashbox_buffer          ; Points SI to starting address of buffer
    mov cx, 2               ; We'll check the first 2 digits (leave 1 digit of 0)
remove_leading_zeros_cashbox:
    cmp byte ptr [si], '0'  ; Check for leading '0'
    jne convert_cents_cashbox       ; If found non-zero number, break from loop
    mov byte ptr [si], ' '  ; Replace '0' with space
    inc si
    loop remove_leading_zeros_cashbox

convert_cents_cashbox:
    ; Convert for cents
    lea si, cashbox_buffer
    mov byte ptr [si+3], '.'   ; Put decimal point at the 4th byte
    mov cx, 2           ; Loop 2 times for 2 bytes in buffer (max 2 digits)
    add si, 5           ; Start from the end of buffer before '$'(leave 1 extra $ for end string)
    mov ax, cashbox_result_dec  ; Move result to AX

    ; Extract and convert each digit
convert_loop_dec_cashbox:
    xor dx, dx      ; Clear DX for division
    mov bx, 10      ; Base 10 for conversion
    div bx          ; AX = AX / 10, DX = remainder (last digit)
    add dl, 30h     ; Convert digit to ASCII
    mov [si], dl    ; Store the digit in the buffer
    dec si          ; Move to the next buffer position
    loop convert_loop_dec_cashbox

    ; Display result
    mov ah, 09h
    lea dx, cashbox_buffer
    int 21h

    ret
display_price_cashbox endp

display_company_menu_colour_name proc ;Thee Chern Hao
    ; Save registers to preserve their original values
    push ax
    push bx
    push cx
    push dx
    push si

    ; Set up for colored text display
    mov bl, 10            ; Text color: light green (10) on black background (0)

    mov si, offset company_menu_name  ; Point SI to the start of company_name string
    mov dh, 0            ; Start at row 0
    mov dl, 0            ; Start at column 0

    ; Start displaying characters
company_menu_name_loop:
    lodsb                ; Load next character from [SI] into AL and increment SI

    cmp al, 0            ; Check for end of string (null terminator)
    je done_company_menu              ; If end of string, exit the loop

    cmp al, 0Dh          ; Check if the character is a carriage return (ASCII code 0Dh)
    je skip_char_company_menu         ; If carriage return, skip to next character

    cmp al, 0Ah          ; Check if the character is a newline (ASCII code 0Ah)
    jne print_char_company_menu       ; If not a newline, proceed to print the character

    ; Handle newline character
    inc dh               ; Move cursor to next row
    mov dl, 0            ; Reset cursor to first column
    jmp set_cursor_company_menu

print_char_company_menu:
    ; Print the character with color
    mov ah, 09h          ; BIOS function to write character and attribute
    mov bh, 0            ; Display page number (0)
    mov cx, 1            ; Number of times to print the character (once)
    int 10h              ; Call BIOS interrupt to display the character

    inc dl               ; Move cursor to next column

set_cursor_company_menu:
    mov ah, 02h          ; Set cursor position
    mov bh, 0            ; Page number
    int 10h              ; Call BIOS interrupt to set new position

skip_char_company_menu:
    jmp company_menu_name_loop       ; Continue with the next character

done_company_menu:
    ; Restore registers to their original values
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret                  ; Return from the procedure
display_company_menu_colour_name endp

display_menu_colour_name proc
    ; Save registers to preserve their original values
    push ax
    push bx
    push cx
    push dx
    push si

    mov ah, 09h
    lea dx, newline
    int 21h

    ; Set up for colored text display
    mov bl, 14            ; Text color: yellow (14) on black background (0)

    mov si, offset menu  ; Point SI to the start of menu string
    mov dh, 9            ; Start at row 9 (adjust as needed)
    mov dl, 0            ; Start at column 0

    ; Start displaying characters
menu_name_loop:
    lodsb                ; Load next character from [SI] into AL and increment SI

    cmp al, 0            ; Check for end of string (null terminator)
    je done_menu_name         ; If end of string, exit the loop

    cmp al, 0Dh          ; Check if the character is a carriage return (ASCII code 0Dh)
    je skip_char_menu_name    ; If carriage return, skip to next character

    cmp al, 0Ah          ; Check if the character is a newline (ASCII code 0Ah)
    jne print_char_menu_name  ; If not a newline, proceed to print the character

    ; Handle newline character
    inc dh               ; Move cursor to next row
    mov dl, 0            ; Reset cursor to first column
    jmp set_cursor_menu_name

print_char_menu_name:
    ; Print the character with color
    mov ah, 09h          ; BIOS function to write character and attribute
    mov bh, 0            ; Display page number (0)
    mov cx, 1            ; Number of times to print the character (once)
    int 10h              ; Call BIOS interrupt to display the character

    inc dl               ; Move cursor to next column

set_cursor_menu_name:
    mov ah, 02h          ; Set cursor position
    mov bh, 0            ; Page number
    int 10h              ; Call BIOS interrupt to set new position

skip_char_menu_name:
    jmp menu_name_loop        ; Continue with the next character

done_menu_name:
    ; Restore registers to their original values
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret                  ; Return from the procedure
display_menu_colour_name endp

display_product_menu_color_name proc
    push ax
    push bx
    push cx
    push dx
    push si

    mov ah, 09h
    lea dx, newline
    int 21h

    ; Set up for colored text display
    mov bl, 11            ; Text color: light cyan (11) on black background (0)

    mov si, offset product_menu  ; Point SI to the start of product_menu string
    mov dh, 4             ; Start at row 4
    mov dl, 0             ; Start at column 0

    ; Start displaying characters
product_menu_loop:
    lodsb                 ; Load next character from [SI] into AL and increment SI

    cmp al, 0             ; Check for end of string (null terminator)
    je done_product_menu  ; If end of string, exit the loop

    cmp al, 0Dh           ; Check if the character is a carriage return (ASCII code 0Dh)
    je skip_char_product_menu  ; If carriage return, skip to next character

    cmp al, 0Ah           ; Check if the character is a newline (ASCII code 0Ah)
    jne print_char_product_menu  ; If not a newline, proceed to print the character

    ; Handle newline character
    inc dh                ; Move cursor to next row
    mov dl, 0             ; Reset cursor to first column
    jmp set_cursor_product_menu

print_char_product_menu:
    ; Print the character with color
    mov ah, 09h           ; BIOS function to write character and attribute
    mov bh, 0             ; Display page number (0)
    mov cx, 1             ; Number of times to print the character (once)
    int 10h               ; Call BIOS interrupt to display the character

    inc dl                ; Move cursor to next column

set_cursor_product_menu:
    mov ah, 02h           ; Set cursor position
    mov bh, 0             ; Page number
    int 10h               ; Call BIOS interrupt to set new position

skip_char_product_menu:
    jmp product_menu_loop ; Continue with the next character

done_product_menu:
    ; Restore registers to their original values
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret                   ; Return from the procedure
display_product_menu_color_name endp

display_restock_heading_color_name proc
    push ax
    push bx
    push cx
    push dx
    push si

    ; Set up for colored text display
    mov bl, 13            ; Text color: light magenta (13) on black background (0)

    mov si, offset restock_heading  ; Point SI to the start of restock_heading string
    mov dh, 0             ; Start at row 0
    mov dl, 0             ; Start at column 0

    ; Start displaying characters
restock_heading_loop:
    lodsb                 ; Load next character from [SI] into AL and increment SI

    cmp al, 0             ; Check for end of string (null terminator)
    je done_restock_heading  ; If end of string, exit the loop

    cmp al, 0Dh           ; Check if the character is a carriage return (ASCII code 0Dh)
    je skip_char_restock_heading  ; If carriage return, skip to next character

    cmp al, 0Ah           ; Check if the character is a newline (ASCII code 0Ah)
    jne print_char_restock_heading  ; If not a newline, proceed to print the character

    ; Handle newline character
    inc dh                ; Move cursor to next row
    mov dl, 0             ; Reset cursor to first column
    jmp set_cursor_restock_heading

print_char_restock_heading:
    ; Print the character with color
    mov ah, 09h           ; BIOS function to write character and attribute
    mov bh, 0             ; Display page number (0)
    mov cx, 1             ; Number of times to print the character (once)
    int 10h               ; Call BIOS interrupt to display the character

    inc dl                ; Move cursor to next column

set_cursor_restock_heading:
    mov ah, 02h           ; Set cursor position
    mov bh, 0             ; Page number
    int 10h               ; Call BIOS interrupt to set new position

skip_char_restock_heading:
    jmp restock_heading_loop ; Continue with the next character

done_restock_heading:
    ; Restore registers to their original values
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret                   ; Return from the procedure
display_restock_heading_color_name endp

display_receipt_start_color_name proc
    push ax
    push bx
    push cx
    push dx
    push si

    mov ah, 09h
    lea dx, newline
    int 21h

    ; Set up for colored text display
    mov bl, 9            ; Text color: bright white (15) on black background (0)

    mov si, offset receipt_start  ; Point SI to the start of receipt_start string
    mov dh, 5             ; Start at row 0 (you can adjust this as needed)
    mov dl, 0             ; Start at column 0

    ; Start displaying characters
receipt_start_loop:
    lodsb                 ; Load next character from [SI] into AL and increment SI

    cmp al, 0             ; Check for end of string (null terminator)
    je done_receipt_start ; If end of string, exit the loop

    cmp al, 0Dh           ; Check if the character is a carriage return (ASCII code 0Dh)
    je skip_char_receipt_start  ; If carriage return, skip to next character

    cmp al, 0Ah           ; Check if the character is a newline (ASCII code 0Ah)
    jne print_char_receipt_start  ; If not a newline, proceed to print the character

    ; Handle newline character
    inc dh                ; Move cursor to next row
    mov dl, 0             ; Reset cursor to first column
    jmp set_cursor_receipt_start

print_char_receipt_start:
    ; Print the character with color
    mov ah, 09h           ; BIOS function to write character and attribute
    mov bh, 0             ; Display page number (0)
    mov cx, 1             ; Number of times to print the character (once)
    int 10h               ; Call BIOS interrupt to display the character

    inc dl                ; Move cursor to next column

set_cursor_receipt_start:
    mov ah, 02h           ; Set cursor position
    mov bh, 0             ; Page number
    int 10h               ; Call BIOS interrupt to set new position

skip_char_receipt_start:
    jmp receipt_start_loop ; Continue with the next character

done_receipt_start:
    ; Restore registers to their original values
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret                   ; Return from the procedure
display_receipt_start_color_name endp

display_cashbox_header_color_name proc
    push ax
    push bx
    push cx
    push dx
    push si

    ; Set up for colored text display
    mov bl, 13            ; Text color: bright white (15) on black background (0)

    mov si, offset cashbox_header  ; Point SI to the start of receipt_start string
    mov dh, 0             ; Start at row 0 (you can adjust this as needed)
    mov dl, 0             ; Start at column 0

    ; Start displaying characters
cashbox_header_loop:
    lodsb                 ; Load next character from [SI] into AL and increment SI

    cmp al, 0             ; Check for end of string (null terminator)
    je done_cashbox_header ; If end of string, exit the loop

    cmp al, 0Dh           ; Check if the character is a carriage return (ASCII code 0Dh)
    je skip_char_cashbox_header  ; If carriage return, skip to next character

    cmp al, 0Ah           ; Check if the character is a newline (ASCII code 0Ah)
    jne print_char_cashbox_header  ; If not a newline, proceed to print the character

    ; Handle newline character
    inc dh                ; Move cursor to next row
    mov dl, 0             ; Reset cursor to first column
    jmp set_cursor_cashbox_header

print_char_cashbox_header:
    ; Print the character with color
    mov ah, 09h           ; BIOS function to write character and attribute
    mov bh, 0             ; Display page number (0)
    mov cx, 1             ; Number of times to print the character (once)
    int 10h               ; Call BIOS interrupt to display the character

    inc dl                ; Move cursor to next column

set_cursor_cashbox_header:
    mov ah, 02h           ; Set cursor position
    mov bh, 0             ; Page number
    int 10h               ; Call BIOS interrupt to set new position

skip_char_cashbox_header:
    jmp cashbox_header_loop ; Continue with the next character

done_cashbox_header:
    ; Restore registers to their original values
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret                   ; Return from the procedure
display_cashbox_header_color_name endp

display_msg_help_colour_name proc
    ; Save registers to preserve their original values
    push ax
    push bx
    push cx
    push dx
    push si

    mov ah, 09h
    lea dx, newline
    int 21h

    ; Set up for colored text display
    mov bl, 12           ; Text color: yellow (14) on black background (0)

    mov si, offset msg_options  ; Point SI to the start of menu string
    mov dh, 9                   ; Start at row 9 (adjust as needed)
    mov dl, 0                   ; Start at column 0

    ; Start displaying characters
msg_help_loop:
    lodsb                ; Load next character from [SI] into AL and increment SI

    cmp al, 0            ; Check for end of string (null terminator)
    je done_msg_help     ; If end of string, exit the loop

    cmp al, 0Dh              ; Check if the character is a carriage return (ASCII code 0Dh)
    je skip_char_msg_help    ; If carriage return, skip to next character

    cmp al, 0Ah              ; Check if the character is a newline (ASCII code 0Ah)
    jne print_char_msg_help  ; If not a newline, proceed to print the character

    ; Handle newline character
    inc dh               ; Move cursor to next row
    mov dl, 0            ; Reset cursor to first column
    jmp set_cursor_msg_help

print_char_msg_help:
    ; Print the character with color
    mov ah, 09h          ; BIOS function to write character and attribute
    mov bh, 0            ; Display page number (0)
    mov cx, 1            ; Number of times to print the character (once)
    int 10h              ; Call BIOS interrupt to display the character

    inc dl               ; Move cursor to next column

set_cursor_msg_help:
    mov ah, 02h          ; Set cursor position
    mov bh, 0            ; Page number
    int 10h              ; Call BIOS interrupt to set new position

skip_char_msg_help:
    jmp msg_help_loop        ; Continue with the next character

done_msg_help:
    ; Restore registers to their original values
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret                  ; Return from the procedure
display_msg_help_colour_name endp

; Procedure to play a tone
PlayTone proc
	; Set up PIT to play the tone
	mov al, 00110110b	; Command byte for mode 3(square wave generator) on channel 2
	out 43h, al		; Send command to PIT control register

	; Load frequency value
	mov bl, al
	mov al, ah
	out 42h, al
	mov al, bl
	out 42h, al

	; Enable the speaker
	in al, 61h
	or al, 03h		; Set bits 0 and 1 to enable the speaker
	out 61h, al

	; Delay for the tone duration
	mov cx, 00020h
delay_sound_loop:
    push cx
    mov cx, 0FFFFh
delay_sound_loop2:
    loop delay_sound_loop2
    pop cx
	loop delay_sound_loop

	ret
PlayTone endp

; Procedure to stop the tone
StopTone proc
	; Disable the speaker
	in al, 61h
	and al, 0FCh	; Clear bits 0 and 1 to disable the speaker
	out 61h, al
	ret
StopTone endp

end main
