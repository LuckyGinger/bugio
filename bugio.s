 @ Start writing code
.include "cursor.s"
.include "system_calls.s"

@constant min bound
.set MIN, 0

@constant max bound
.set MAX, 60

.balign 4
.data
playerBody:
	.asciz "#"
	.set body_len, .-playerBody
space:
	.ascii " "

gameKey:
	.skip 4

player:
	.skip 1
	.set length, .-player
	.word 30
	.set player_len, .-length

.balign 4
.text

//drawGame:
//	mov r0, #MIN


drawPlayer:
	mov r3, lr
	mov r0, #STDOUT
	movw r1, #:lower16:playerBody
	movt r1, #:upper16:playerBody
	mov r2, #body_len
	mov r7, #WRITE
	svc #0

	mov lr, r3
	bx lr



gameLoop:
	mov r4, lr

	bl clear_screen
        bl cursor_home
	bl drawPlayer

	mov lr, r4
	bx lr


.global _start
_start:
	bl gameLoop

	mov r7, #1
	svc #0


