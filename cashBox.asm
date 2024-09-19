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

    buffer_int db 4 dup('$')    ; Buffer for displaying RM
    buffer_dec db 4 dup('$')    ; Buffer for displaying cents

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

    ; Extract overflow in cents result for total
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
    mov result_int, ax
    mov ax, total_dec
    mov result_dec, ax
    mov ax, 0       ; Clear AX

    ; Display total
    mov ah, 09h
    lea dx, msg_total
    int 21h

    call DisplayPrice ; result_int and result_dec used

    ; Exit program
    mov ah, 4Ch
    int 21h
main endp

DisplayPrice proc ; Convert the result to ASCII for display
    ; Convert for RM
    lea si, buffer_int
    mov cx, 3           ; Loop 3 times for 3 bytes in buffer (max 3 digits)
    add si, 2           ; Start from the end of buffer (leave 1 extra $ for end string)
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
    lea si, buffer_int      ; Points SI to starting address of buffer
    mov cx, 3               ; We'll check the first 3 digits (before the decimal point / end string)
remove_leading_zeros:
    cmp byte ptr [si], '0'  ; Check for leading '0'
    jne convert_cents       ; If found non-zero number, break from loop
    mov byte ptr [si], ' '  ; Replace '0' with space
    inc si
    loop remove_leading_zeros

convert_cents:
    ; Convert for cents
    lea si, buffer_dec
    mov byte ptr [si], '.'   ; Put decimal point at the 1st byte
    mov cx, 2           ; Loop 2 times for 2 bytes in buffer (max 2 digits)
    add si, 2           ; Start from the end of buffer (leave 1 extra $ for end string)
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
    lea dx, buffer_int
    int 21h
    lea dx, buffer_dec
    int 21h

    ret
DisplayPrice endp

end main
