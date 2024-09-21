.model small
.stack 100h
.data

	sound1 dw 6370h	; frequency for tone1 (440 Hz)
	newline_music db 0dh,0ah,"$"

.code
main proc

	mov ax,@data
	mov ds,ax

	; Play sound1 (440 Hz)
	mov ax, sound1
	call PlayTone
	mov ah,09h
	lea dx,newline_music
	int 21h

	; Stop sound1
	call StopTone
	mov ah,09h
	lea dx,newline_music
	int 21h

	; Terminate program
	mov ax,4c00h
	int 21h

main endp

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
	mov cx, 0FFFFh
delay_sound_loop:
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
