@ Start writing code
.include "mov32.inc"

.set STDOUT, 1

.set READ,  0x03
.set WRITE, 0x04

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


/*.L1:
	bl clear_screen
        bl cursor_home
	bl drawPlayer
	b .L0


.L0:
        mov r0, #STDIN
	mov r1, r6
	mov r2, #4096
	mov r7, #READ
	svc #0
*/
	mov lr, r4
	bx lr


	.global _start
_start:
	bl gameLoop
	bl term_inited

	sub sp, sp, #1
	
while_loop:
	mov r7, #READ
	mov r0, #STDIN
	mov r1, sp
	mov r2, #1
	svc #0
	
        // If nothing was read, don't bother writing
	cmp r0, #0
	beq skip_print

skip_print:
	ldrb r0, [sp]
	cmp r0, #32
	bne while_loop

	add sp, sp, #1
	bl term_quit

	mov r7, #1
	svc #0


	// Print a byte as a number
p_byte:
	mov r3, sp // String pointer
	sub sp, sp, #4

	mov r12, #10

	mov r1, #10     // Newline
	strb r1, [r3, #-1]!


	b test_non_zero
while_digits:
	// Divide/Modulus (r1, r2)
	udiv r1, r0, r12
	mls r2, r1, r12, r0

	add r2, r2, #48  // r2 = r2 + "0"
	strb r2, [r3, #-1]!

	mov r0, r1

test_non_zero:
	cmp r0, #0
	bne while_digits


	mov r7, #WRITE
	mov r0, #STDOUT
	mov r1, r3
	add r2, sp, #4
	sub r2, r2, r1
	svc #0

	add sp, sp, #4
	bx lr
