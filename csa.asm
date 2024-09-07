.model small
.stack 100h
.data
    company_name db "===================="
                 db 0dh,0ah
                 db "|    ABC Retail    |"
                 db 0dh,0ah
                 db "--------------------"
                 db 0dh,0ah,"$"
    newline db 0dh,0ah,"$"
    username db "admin", 0
    password db "password", 0
    input_buffer db 20, ?, 20 dup(0)
    prompt_user db "Enter username: $"
    prompt_pass db "Enter password: $"
    msg_success db "Login successful!$"
    msg_failure db "Login failed. Try again.$"

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Display store name
    mov ah, 09h
    lea dx, company_name
    int 21h

    ; Prompt for username
    mov ah, 09h
    lea dx, prompt_user
    int 21h

    ; Get username input
    mov ah, 0Ah
    lea dx, input_buffer
    int 21h

    ; Print newline
    mov ah, 09h
    lea dx, newline
    int 21h

    ; Compare username
    mov si, offset username
    lea di, input_buffer + 2
    call compare_strings
    jnz login_failed

    ; Prompt for password
    mov ah, 09h
    lea dx, prompt_pass
    int 21h

    ; Get password input
    mov ah, 0Ah
    lea dx, input_buffer
    int 21h

    ; Print newline
    mov ah, 09h
    lea dx, newline
    int 21h

    ; Compare password
    mov si, offset password
    lea di, input_buffer + 2
    call compare_strings
    jnz login_failed

    ; Login successful
    mov ah, 09h
    lea dx, msg_success
    int 21h
    jmp exit

login_failed:
    mov ah, 09h
    lea dx, msg_failure
    int 21h

exit:
    mov ax, 4C00h
    int 21h

main endp

compare_strings proc
    push cx
    mov cl, [di-1]  ; get length of input
    xor ch, ch
compare_loop:
    mov al, [si]
    cmp al, [di]
    jne compare_end
    test al, al  ; check for null terminator
    jz compare_match
    inc si
    inc di
    loop compare_loop
compare_match:
    pop cx
    xor ax, ax  ; Clear ZF (set to 0 for match)
    ret
compare_end:
    pop cx
    or ax, ax  ; Set ZF to 1 for no match
    ret
compare_strings endp

end main
