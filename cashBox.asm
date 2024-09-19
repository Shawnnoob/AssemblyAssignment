.model small
.stack 100h
.data
    product_list  db 'Tissue     ', '$'
                  db 'Toothpaste ', '$'
                  db 'Body Wash  ', '$'
                  db 'Cotton Buds', '$'
    preset_price_int dw 1, 12, 15, 1    ; Price in RM
    preset_price_dec dw 20, 90, 20, 00  ; Price in cents
    product_qty db 2, 2, 2, 2   ; Chosen quantity for each product (assumed to be 2)

    result_int dw ?             ; Variable to store RM result
    result_dec dw ?             ; Variable to store cents result
    result_overflow dw ?        ; Variable to store overflow from cents

    total_int dw 0              ; Store total RM
    total_dec dw 0              ; Store total cents
    total_overflow dw 0         ; Store overflow from cents

    buffer_int db 5 dup('$')    ; Buffer for displaying RM
    buffer_dec db 5 dup('$')    ; Buffer for displaying cents

    msg_product db 'Product: $'
    msg_subtotal db 'Subtotal: RM$'
    msg_total db 'Total: RM$'
    newline db 13, 10, '$'

.code
main proc
    mov ax, @data
    mov ds, ax

    mov si, 0  ; Initialize index to 0
    mov cx, 4   ; Loop 4 times for 4 products

product_loop:
    push cx     ; Save loop counter
    push si     ; Save SI

    ; Display product name
    mov ax, cx
    mov ah, 09h
    lea dx, product_list[si]
    int 21h

    pop si      ; Load SI
    
    ; Calculate subtotal for RM
    shl si, 1
    mov ax, preset_price_int[si]
    shr si, 1
    mov bl, product_qty[si]
    xor bh, bh
    mul bx
    mov result_int, ax

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
    mov ax, result_dec          ; Load cents into AX
    mov bx, 100                 ; Move BX to 100 for division
    div bx                      ; AX = AX / BX, remainder goes to DX
    mov result_overflow, ax     ; Move overflow to result_overflow
    mov result_dec, dx          ; Move remainder (cents) to result_dec






    ; Display subtotal
    mov ah, 09h
    lea dx, msg_subtotal
    int 21h

    push si             ; Save SI value
    call DisplayPrice
    pop si              ; Load SI value

    ; Display newline
    mov ah, 09h
    lea dx, newline
    int 21h

    add si, 1   ; Move to next product (2 bytes for word)
    pop cx      ; Restore loop counter
    loop product_loop

    ; Display total
    mov ah, 09h
    lea dx, msg_total
    int 21h

    mov ax, total_result
    mov result, ax
    call DisplayPrice

    ; Exit program
    mov ah, 4Ch
    int 21h
main endp

DisplayPrice proc
    ; Convert the result to ASCII for display
    lea si, buffer
    mov cx, 5       ; Loop 5 times for 5 bytes in buffer (max 5 digits)
    add si, 4       ; Start from the end of buffer (leave 1 extra $ for end string)
    mov ax, result  ; Move result to AX

    ; Extract and convert each digit
convert_loop:
    xor dx, dx      ; Clear DX for division
    mov bx, 10      ; Base 10 for conversion
    div bx          ; AX = AX / 10, DX = remainder (last digit)
    add dl, 30h     ; Convert digit to ASCII
    mov [si], dl    ; Store the digit in the buffer
    dec si          ; Move to the next buffer position
    loop convert_loop

    ; Extract the cents
    lea si, buffer           ; Points SI to starting address of buffer
    mov ax, word ptr [si+3]  ; Loads the last two digits into cent_result
    mov cent_result, ax

    ; Ensure the buffer is in the correct format (00.00)
    mov byte ptr [si+3], '.'
    mov byte ptr [si+4], '$'

    ; Remove leading zeros
    lea si, buffer           ; Points SI to starting address of buffer
    mov cx, 3               ; We'll check the first 3 digits (before the decimal point)
remove_leading_zeros:
    cmp byte ptr [si], '0'  ; Check for leading '0'
    jne display_price       ; If found non-zero number, display
    mov byte ptr [si], ' '  ; Replace '0' with space
    inc si
    loop remove_leading_zeros

display_price:
    ; Display the price
    mov ah, 09h
    lea dx, buffer
    int 21h

    mov ah, 09h
    lea dx, cent_result
    int 21h

    ret
DisplayPrice endp
