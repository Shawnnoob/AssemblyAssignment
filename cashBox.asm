.model small
.stack 100h
.data
     ; Display Messages
    msgTitle db '-------------------------', 0Dh, 0Ah, '   Show Cashbox', 0Dh, 0Ah, '-------------------------', 0Dh, 0Ah, '$'
    msgTotal db '- Total Cash: $', 0
    msgDenominations db 0Dh, 0Ah, '- Denominations:', 0Dh, 0Ah, '$'
    
    ; Adjust these to align the output correctly with sufficient spaces
    msg100 db '- $100:    ', '$'
    msg50 db '- $50:     ', '$'
    msg10 db '- $10:     ', '$'
    msg1 db '- $1:      ', '$'
    msg10cent db '- $0.10:   ', '$'
    msg5cent db '- $0.05:   ', '$'

    msgOptions db 0Dh, 0Ah, 0Dh, 0Ah, '1: Return Money', 0Dh, 0Ah, '2: Add Money', 0Dh, 0Ah, '3: Exit', 0Dh, 0Ah, 'Enter your choice: $', 0
    msgEnterPurchase db 'Enter the total purchase price (in cents): $', 0
    msgAdd100 db 'Enter number of $100 bills to add: $', 0
    msgAdd50 db 'Enter number of $50 bills to add: $', 0
    msgAdd10 db 'Enter number of $10 bills to add: $', 0
    msgAdd1 db 'Enter number of $1 bills to add: $', 0
    msgAdd10cent db 'Enter number of 10-cent coins to add: $', 0
    msgAdd5cent db 'Enter number of 5-cent coins to add: $', 0
    msgInvalidOption db 'Invalid option, try again...', 0Dh, 0Ah, '$'
    msgInsufficientFunds db 'Insufficient funds in cashbox!', 0Dh, 0Ah, '$'
    msgNewLine db 0Dh, 0Ah, '$'

    ; Cashbox Data
    totalCash dw 20000  ; Total cash in cents ($200)
    num100 dw 1         ; 1 x $100 bill
    num50 dw 2          ; 2 x $50 bills
    num10 dw 4          ; 4 x $10 bills
    num1 dw 10          ; 10 x $1 bills
    num10cent dw 50     ; 50 x $0.10 coins
    num5cent dw 20      ; 20 x $0.05 coins

    buffer db 6 dup(0)  ; Buffer for user input

.code
main proc
    mov ax, @data
    mov ds, ax

start_loop:
    ; Display cashbox
    call show_cashbox

    ; Prompt user for input
    call display_options
    mov ah, 01h      ; Wait for key press
    int 21h
    sub al, '0'      ; Convert ASCII to number

    cmp al, 1        ; Return money option
    je return_money

    cmp al, 2        ; Add money option
    je add_money

    cmp al, 3        ; Exit option
    je exit_system

    ; Invalid input handling
    lea dx, msgInvalidOption
    mov ah, 09h
    int 21h
    jmp start_loop

return_money:
    ; Ask user for the total purchase price
    lea dx, msgEnterPurchase
    mov ah, 09h
    int 21h

    call get_input
    mov bx, ax       ; Store purchase price in BX

    ; Check if there's enough money in the cashbox
    cmp bx, totalCash
    jg insufficient_funds

    ; Subtract from cashbox total
    sub totalCash, bx

    ; Update denominations (simplified approach)
    call update_denominations

    jmp start_loop

insufficient_funds:
    lea dx, msgInsufficientFunds
    mov ah, 09h
    int 21h
    jmp start_loop

add_money:
    ; Ask user to input number of bills/coins for each denomination
    lea dx, msgAdd100
    call get_input
    add num100, ax

    lea dx, msgAdd50
    call get_input
    add num50, ax

    lea dx, msgAdd10
    call get_input
    add num10, ax

    lea dx, msgAdd1
    call get_input
    add num1, ax

    lea dx, msgAdd10cent
    call get_input
    add num10cent, ax

    lea dx, msgAdd5cent
    call get_input
    add num5cent, ax

    ; Update the total cash in cashbox
    call update_total_cash
    jmp start_loop

exit_system:
    ; Reset the cashbox total to $200 and exit
    mov totalCash, 20000
    mov num100, 1
    mov num50, 2
    mov num10, 4
    mov num1, 10
    mov num10cent, 50
    mov num5cent, 20

    ; Exit the program
    mov ax, 4C00h
    int 21h

show_cashbox proc
    ; Display title
    lea dx, msgTitle
    mov ah, 09h
    int 21h

    ; Display total cash
    lea dx, msgTotal
    mov ah, 09h
    int 21h
    mov ax, totalCash
    mov bx, 100
    xor dx, dx
    div bx
    call print_number
    call print_newline

    ; Display denominations header
    lea dx, msgDenominations
    mov ah, 09h
    int 21h

    ; $100 bills
    lea dx, msg100
    mov ah, 09h
    int 21h
    mov ax, num100
    call print_number

    ; $50 bills
    lea dx, msg50
    mov ah, 09h
    int 21h
    mov ax, num50
    call print_number

    ; $10 bills
    lea dx, msg10
    mov ah, 09h
    int 21h
    mov ax, num10
    call print_number

    ; $1 bills
    lea dx, msg1
    mov ah, 09h
    int 21h
    mov ax, num1
    call print_number

    ; 10-cent coins
    lea dx, msg10cent
    mov ah, 09h
    int 21h
    mov ax, num10cent
    call print_number

    ; 5-cent coins
    lea dx, msg5cent
    mov ah, 09h
    int 21h
    mov ax, num5cent
    call print_number

    ret
show_cashbox endp

print_newline proc
    lea dx, msgNewLine
    mov ah, 09h
    int 21h
    ret
print_newline endp

display_options proc
    ; Display menu options for user to choose (return money, add money, or exit)
    lea dx, msgOptions
    mov ah, 09h
    int 21h
    ret
display_options endp

update_total_cash proc
    ; Calculate the total cash in cents
    xor ax, ax
    mov ax, num100
    mov bx, 10000
    mul bx
    mov totalCash, ax

    mov ax, num50
    mov bx, 5000
    mul bx
    add totalCash, ax

    mov ax, num10
    mov bx, 1000
    mul bx
    add totalCash, ax

    mov ax, num1
    mov bx, 100
    mul bx
    add totalCash, ax

    mov ax, num10cent
    mov bx, 10
    mul bx
    add totalCash, ax

    mov ax, num5cent
    mov bx, 5
    mul bx
    add totalCash, ax

    ret
update_total_cash endp

get_input proc
    ; Function to get user input
    mov si, offset buffer
    mov cx, 5
    mov ah, 01h

input_loop:
    int 21h
    cmp al, 0Dh  ; Check for Enter key
    je end_input
    mov [si], al
    inc si
    loop input_loop

end_input:
    mov byte ptr [si], '$'  ; Null-terminate the string
    
    ; Convert string to number
    mov si, offset buffer
    xor ax, ax
    xor bx, bx

convert_loop:
    mov bl, [si]
    cmp bl, '$'
    je end_convert
    sub bl, '0'
    mov dx, 10
    mul dx          ; Multiply AX by 10
    add ax, bx
    inc si
    jmp convert_loop

end_convert:
    ret
get_input endp

print_number proc
    ; Function to print the number
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

print_loop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_loop

    call print_newline

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_number endp

update_denominations proc
    ; Simplified approach to update denominations
    ; This is a basic implementation and might not be optimal for all cases
    push ax
    push bx
    push cx
    push dx

    mov ax, totalCash
    mov bx, 10000
    xor dx, dx
    div bx
    mov num100, ax
    mov ax, dx

    mov bx, 5000
    xor dx, dx
    div bx
    mov num50, ax
    mov ax, dx

    mov bx, 1000
    xor dx, dx
    div bx
    mov num10, ax
    mov ax, dx

    mov bx, 100
    xor dx, dx
    div bx
    mov num1, ax
    mov ax, dx

    mov bx, 10
    xor dx, dx
    div bx
    mov num10cent, ax
    mov num5cent, dx

    pop dx
    pop cx
    pop bx
    pop ax
    ret
update_denominations endp

main endp
end main
