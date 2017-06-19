 @ Start writing code
@ .include "cursor.s"
.include "mov32.inc"

@ system Calls
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
line_space:
	.ascii "|                                         |"

gameKey:
	.skip 4 // Key pressed by user

player:
	.skip 1 // X Position
	.set lenX, .-player // lenY = 1 byte
	.skip 1 // Y Position
	.set lenY, .-lenX // lenX = 1 byte
	.word 30 // 30  * 8 bits of memeory
	.set info, .-lenX

//position:
//        .byte 27
//       .ascii "[0000;0000H"

.balign 4
.text
/*.global locate
locate:
        cmp r0, #1000
        bxpl lr
        cmp r1, #1000
        bxpl lr

        push {r4-r7, lr}
        ldr r12, =position
        mov r7, #10

        mov r6, #0  // Which coordiate are we working on? 0 = x, 1 = y  */

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
        bl locate
	bl drawPlayer

	bx r4

.global _start
_start:
	bl gameLoop

	mov r7, #1
	svc #0


