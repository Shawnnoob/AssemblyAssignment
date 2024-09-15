.model small
.stack 100h
.data
    num1 dw 1296         ; First number as a fixed-point number (12.90 * 100)
    num2 db 2            ; Second number as quantity
    result dw ?          ; Variable to store the result
    cent_result dw '','$'     ; Variable to store cents
    buffer db 6 dup('$') ; Buffer to hold the ASCII representation of the result
    msg db 'Result: RM$'

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Load the numbers into registers
    mov ax, num1    ; AX = 1290
    mov bl, num2    ; BL = 02
    xor bh, bh      ; Clear BH to ensure BX is 16-bit

    ; Multiply the numbers
    mul bx          ; AX = AX * BX

    ; Store the result in memory
    mov result, ax  ; result = AX (lower 16 bits of the product)

    ; Convert the result to ASCII for display
    lea si, buffer
    mov cx, 5       ; Loop 5 times for 5 bytes in buffer (max 5 digits)
    add si, 4       ; Start from the end of buffer (leave 1 extra $ for end string)
    mov ax, result  ; Move result back to AX (just in case)

    ; Extract and convert each digit
convert_loop:
    xor dx, dx       ; Clear DX for division
    mov bx, 10      ; Base 10 for conversion
    div bx          ; AX = AX / 10, DX = remainder (last digit)
    add dl, 30h     ; Convert digit to ASCII
    mov [si], dl    ; Store the digit in the buffer
    dec si          ; Move to the next buffer position
    loop convert_loop

    ; Ensure the buffer is in the correct format (00.00)
    lea si, buffer          ; Load address of buffer into SI
    mov ax, word ptr [si+3] ; Loads the last two digits into cent_result
    mov cent_result, ax

    mov byte ptr [si+3], '.'
    mov byte ptr [si+4], '$'

    lea si, buffer
    mov cx, 4       ; We'll check the first 4 digits (before the decimal point)
remove_leading_zeros:
    cmp byte ptr [si], '0'  ; Check fot leading '0'
    jne done_removing       ; If found number, skip looping to display
    mov byte ptr [si], ' '  ; Replace '0' with space
    inc si
    loop remove_leading_zeros

done_removing:
    ; Display the result
    mov ah, 09h
    lea dx, msg
    int 21h

    ; Display the number
    mov cx, 5
    mov ah, 09h
    lea dx, buffer      ; Displays the price before floating point
    int 21h

    lea dx, cent_result ; Displays the price after floating point
    int 21h

    ; Exit the program
    mov ah, 4Ch
    int 21h
main endp
end main
