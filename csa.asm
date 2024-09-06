.model small
.stack 100
.data
    username db "admin","$"
    password db "password","$"
    input_username db 10 dup (?)
    input_password db 10 dup (?)
    welcome_message db 'Welcome to ABC Retail Store!', 0
    invalid_message db 'Invalid username or password. Try again.', 0

.code
start:
    mov ax, @data
    mov ds, ax

    ; clear screen
    mov ax, 0600h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184fh
    int 10h

    ; print welcome message
    mov ah, 09h
    mov dx, offset welcome_message
    int 21h

    ; print login prompt
    mov ah, 09h
    mov dx, offset login_prompt
    int 21h

login_loop:
    ; get username
    mov ah, 0ah
    mov dx, offset input_username
    int 21h

    ; get password
    mov ah, 0ah
    mov dx, offset input_password
    int 21h

    ; compare username and password
    mov si, offset username
    mov di, offset input_username
    mov cx, 5
    repe cmpsb
    jne invalid_login

    mov si, offset password
    mov di, offset input_password
    mov cx, 8
    repe cmpsb
    jne invalid_login

    ; valid login, print welcome message
    mov ah, 09h
    mov dx, offset welcome_message
    int 21h

    ; print store name
    mov ah, 09h
    mov dx, offset store_name
    int 21h

    jmp exit

invalid_login:
    ; invalid login, print error message
    mov ah, 09h
    mov dx, offset invalid_message
    int 21h
    jmp login_loop

exit:
    ; exit program
    mov ah, 4ch
    int 21h

login_prompt db 'Username: $'
store_name db '         ABC Retail Store         ', 0

end start
