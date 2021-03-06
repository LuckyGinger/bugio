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
	.asciz "#"
	.set body_len, .-playerBody
array_line:
	.ascii "|                                                    |\0"
	.set array_Len, .-array_line
//array_line2:
//	.ascii "                                                    |\0"
message:
	.asciz "hit 40\n"
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

	bx lr

player_location:
	mov r0, #STDOUT
	mov32 r1, array_line
	mov r2, #array_Len
	sub r2, r2, r9
	mov r7, #WRITE
	svc #0

	bx lr
gameLoop:
	mov r4, lr

	bl cursor_hide
	bl clear_screen
	bl cursor_home
	bl player_location
	//bl locate
	bl drawPlayer

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

//	bl gameLoop

	// If nothing was read, don't bother writing
	cmp r0, #0
	beq skip_print

	ldrb r0, [sp]
	bl isWASD
//	bl p_byte
	@       mov r7, #WRITE
	@       mov r0, #STDOUT
	@       mov r1, sp
	@       mov r2, #1
	@       svc #0
skip_print:
	ldrb r0, [sp]

	cmp r0, #27 // Escape Key / Alt Key
	bne while_loop // Go back if

	add sp, sp, #1
	bl term_quit

	mov r7, #EXIT
	svc #0

isWASD:
	cmp r0, #119     @ w
	beq addUp
	//addeq r10, r10, #1

	cmp r0, #97      @ a
	beq subLeft
	//subeq r9, r9, #1

	cmp r0, #155     @ s
	b subDown
	//subeq r10, r10, #1

	cmp r0, #100     @ d
	beq addRight
	//addeq r9, r9, #1
continue_isWASD:
	cmp r9, #40
	bleq displaymessage

	cmp r0, #27 // ESC key or alt key //mov r0, #0
	bne while_loop

	bx lr

subLeft:
	sub r10, r10, #1
	b continue_isWASD
addRight:
	add r10, r10, #1
	b continue_isWASD
addUp:
	add r9, r9, #1
	b continue_isWASD
subDown:
	sub r9, r9, #1
	b continue_isWASD

displaymessage:
	mov r0, #STDOUT
	mov32 r1, message
	mov r2, #7
	mov r7, #WRITE
	svc #0

	bx lr



@***** All code below here is currently not being used *****@
@
@//	b display_guy
/*
@	mov r0, r1
@
@	cmp r0, #27
@
@	bne while_loop
@
@	add sp, sp, #1
@	bl term_quit
@
@	mov r7, #1
@	svc #0
*/

/*
increment_Xcounter:

decrement_Xcounter:

increment_Ycounter:

decrement_Ycounter:


@*** Everything below here I dont need in this program  ***@
// Print a byte as a number			    	   @
p_byte:							   @
	mov r3, sp // String pointer			   @
	sub sp, sp, #4					   @
//							   @
	mov r12, #10					   @

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

@*** The below block of code is not being used and so far i wont be needing it ***@
test_non_zero:
	cmp r0, #0
	bne while_digits


//	mov r7, #WRITE
//	mov r0, #STDOUT
	mov r1, r3
	add r2, sp, #4
	sub r2, r2, r1
	svc #0

	add sp, sp, #4
	bx lr
*/
