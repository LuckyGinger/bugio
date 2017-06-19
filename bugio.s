 @ Start writing code
.include "mov32.inc"

.set STDOUT, 1
.set WRITE, 0x04


@constant min bound
.set MIN, 0

@constant max bound
.set MAX, 60

.balign 4
.data
playerBody:
	.ascii "#"
	.set body_len, .-playerBody
space:
	.ascii " "

gameKey:
	.skip 4

player:
	.skip 1 // 
	.set length, .-player // length of 1
	.word 30 // 30 
	.set player_len, .-length-player

	.balign 4
	.text

//drawGame:
//	mov r0, #MIN


drawPlayer:
	mov r3, lr
	mov r0, #STDOUT
	mov32 r1, playerBody
	mov r2, #body_len
	mov r7, #WRITE
	svc #0

	bx r3

gameLoop:
	mov r4, lr

	bl clear_screen
        bl cursor_home
	bl drawPlayer

	bx r4

.global _start
_start:
	bl gameLoop

	mov r7, #1
	svc #0


