@ Start writing code
.include "mov32.inc"
.include "system_calls.s"

@constant min bound
.set MIN, 0

@constant max bound
.set MAX, 60

.balign 4
.data
playerBody:
	.asciz "#\n"
	.set body_len, .-playerBody
space:
	.ascii " "

message:
	.asciz "hit 40"
gameKey:
	.skip 4
posX:
	.word 30
posY:
	.word 20
player:
	.skip 1
	.set lenX, .-player
	.skip 1
	.set lenY, .-lenX-player

	.balign 4
	.text

drawPlayer:
	mov r3, lr
	mov r0, #STDOUT
	mov32 r1, playerBody
	mov r2, #body_len
	mov r7, #WRITE
	svc #0

	mov lr, r3
	bx lr



gameLoop:
	mov r4, lr

	bl clear_screen
	bl cursor_home

	mov lr, r4
	bx lr


.global _start
_start:
	mov r9, #30  @ posX
	mov r10, #20  @ posY

	bl gameLoop
	bl term_init

	sub sp, sp, #1

while_loop:
	// get movement from user
	mov r7, #READ
	mov r0, #STDIN
	mov r1, sp
	mov r2, #1
	svc #0

	// If nothing was read, don't bother writing
	cmp r0, #0
	beq skip_print

	ldrb r0, [sp]

	cmp r0, #97        @ a
	beq subLeft

	cmp r0, #119       @ w
	beq subDown

	cmp r0, #115       @ s
	beq addUp

	cmp r0, #100       @ d
	beq addRight

continue_while_loop:
	cmp r9, #40
	bleq displaymessage

	cmp r0, #27
	bne while_loop

skip_print:
	ldrb r0, [sp]

	cmp r0, #27 // Escape Key / Alt Key
	bne while_loop // Go back if

	add sp, sp, #1
	bl term_quit

	mov r7, #EXIT
	svc #0

addUp:
	add r9, r9, #1
	b continue_while_loop
subLeft:
	sub r10, r10, #1
	b continue_while_loop
addRight:
	add r10, r10, #1
	b continue_while_loop
subDown:
	sub r9, r9, #1
	b continue_while_loop

displaymessage:
	mov r0, #STDOUT
	mov32 r1, message
	mov r2, #7
	mov r7, #WRITE
	svc #0

	bx lr

