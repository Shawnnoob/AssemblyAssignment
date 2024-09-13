.model small
.stack 100h

.data
    ; Define product names (null-terminated)
    product_A db "Product A", 0
    product_B db "Product B", 0
    product_prices dw 80, 160  ; Prices for "Product A" and "Product B"

    ; Prompts
    prompt_product db 13, 10, "Enter product choice (a or b, x to finish): $"
    prompt_quantity db 13, 10, "Enter quantity (1-9): $"

    ; Receipt formatting
    receipt_header  db 13, 10, "--------------------------------" 
                    db 13, 10, "            RECEIPT             "
                    db 13, 10, "--------------------------------" 
                    db 13, 10, "PRODUCT           QTY   SUBTOTAL"
                    db 13, 10, "$"
    product_label db "$"
    total_label db 13, 10, "Total:        $"
    receipt_footer db 13, 10, "--------------------------------", 13, 10, '$'

    newline db 13, 10, '$'

    ; Arrays to store multiple products
    MAX_PRODUCTS equ 10
    selected_products dw MAX_PRODUCTS dup(0)  ; Array of pointers to product names
    selected_prices dw MAX_PRODUCTS dup(0)    ; Array of prices
    selected_quantities db MAX_PRODUCTS dup(0) ; Array of quantities
    product_count dw 0                        ; Counter for number of products selected

    total dw 0                   ; Total price for all products

    ; Column positions for formatting
    product_column equ 5         ; Starting position for product name
    quantity_column equ 15       ; Starting position for quantity
    subtotal_column equ 20       ; Starting position for subtotal

.code
main:
    mov ax, @data
    mov ds, ax

main_loop:
    ; Check if we've reached the maximum number of products
    mov ax, product_count
    cmp ax, MAX_PRODUCTS
    jae end_receipt  ; If we've reached the max, jump to printing the receipt

    ; Display product choice prompt
    lea dx, prompt_product
    mov ah, 09h
    int 21h

    ; Read product choice from user
    mov ah, 01h
    int 21h
    cmp al, 'x'  ; Check if the user wants to finish
    je end_receipt
    cmp al, 'a'
    je choose_A
    cmp al, 'b'
    je choose_B

    ; Invalid choice, loop again
    jmp main_loop

choose_A:
    mov si, offset product_A
    mov ax, [product_prices]
    jmp store_product

choose_B:
    mov si, offset product_B
    mov ax, [product_prices + 2]

store_product:
    mov bx, product_count
    shl bx, 1  ; Multiply by 2 for word-sized elements
    mov [selected_products + bx], si
    mov [selected_prices + bx], ax

ask_quantity:
    ; Display quantity prompt
    lea dx, prompt_quantity
    mov ah, 09h
    int 21h

    ; Read quantity
    mov ah, 01h
    int 21h
    sub al, '0'
    mov bx, product_count
    mov [selected_quantities + bx], al

    ; Increment product count
    inc word ptr [product_count]

    ; Loop back to allow another product selection
    jmp main_loop

end_receipt:
    ; Display receipt
    lea dx, receipt_header
    mov ah, 09h
    int 21h

    ; Initialize total to 0
    mov word ptr [total], 0

    ; Loop through all selected products
    xor si, si  ; Use SI as counter

    
print_product_loop:
    cmp si, [product_count]
    jae print_total  ; If we've printed all products, print the total

    ; Print product details
    mov bx, si
    shl bx, 1  ; Multiply by 2 for word-sized elements

    ; Print product name
    lea dx, product_label
    mov ah, 09h
    int 21h
    mov dx, [selected_products + bx]
    call print_string

    ; Move to quantity column
    mov cx, quantity_column - product_column
    call print_spaces

    ; Print quantity
    xor ah, ah
    mov al, [selected_quantities + si]
    call print_number

    ; Move to subtotal column
    mov cx, subtotal_column - quantity_column
    call print_spaces

    ; Calculate and print subtotal
    mov ax, [selected_prices + bx]
    xor bh, bh
    mov bl, [selected_quantities + si]
    mul bx  ; AX = price * quantity
    call print_number

    ; Add to total
    add [total], ax

    ; Print newlines for next row
    lea dx, newline
    mov ah, 09h
    int 21h

    inc si
    jmp print_product_loop

print_total:
    ; Print total
    lea dx, total_label
    mov ah, 09h
    int 21h

    mov ax, [total]
    call print_number

    ; Display receipt footer
    lea dx, receipt_footer
    mov ah, 09h
    int 21h

    ; Exit program
    mov ah, 4Ch
    int 21h

; Subroutine to print a string (terminated by null character)
print_string:
    push ax     ; Preserve AX
    push bx     ; Preserve BX
    mov bx, dx  ; Move string address to BX

print_loop:
    mov al, [bx]  ; Load byte from memory into AL
    cmp al, 0     ; Check if null terminator
    je print_done ; If null terminator, we are done
    mov ah, 02h   ; Function to print a character
    mov dl, al    ; Move character to DL for printing
    int 21h       ; Print the character
    inc bx        ; Move to the next character
    jmp print_loop

print_done:
    pop bx      ; Restore BX
    pop ax      ; Restore AX
    ret

; Subroutine to print a number (in AX)
print_number:
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

print_digits:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_digits

    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Subroutine to print spaces for alignment
print_spaces:
    push cx
print_space_loop:
    cmp cx, 0
    je print_space_done
    mov ah, 02h
    mov dl, ' '
    int 21h
    loop print_space_loop

print_space_done:
    pop cx
    ret

end main
