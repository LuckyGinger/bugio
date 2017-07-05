@ Start writing code
        .set CLOCK_GETTIME, 0x107
	.set CLOCK_REALTIME, 0
	.set CLOCK_NANOSLEEP, 0x109
	.set TIMER_ABSTIME, 1
	

.include "mov32.inc"
.include "system_calls.s"
//.include "spider.s"

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
player:
	.skip 1
	.set lenX, .-player
	.skip 1
	.set lenY, .-lenX-player
spider:
	.byte 27
	.ascii "[2C"
	.ascii "/"
	.byte 27
	.ascii "[1C"
	.ascii "_"
	.byte 27
	.ascii "[1C"
	.ascii "\\"
	.byte 27
	.ascii "[1B"
	.byte 27
	.ascii "[7D"
	//.set spider_Len1, .-spider
	.ascii "\\_\\(_)\/_/"
	.byte 27
	.ascii "[1B"
	.byte 27
	.ascii "[9D"
	.byte 27
	.ascii "[1C"
	//.set spider_Len2, .-spider-spider_Len1
	.ascii "_\/\/o\\\\_"
	.byte 27
	.ascii "[1B"
	.byte 27
	.ascii "[8D"
	.byte 27
	.ascii "[2C"
	//.set spider_Len3, .-spider-spider_Len2
	.ascii "\/"
	.byte 27
	.ascii "[3C"
	.ascii "\\"
	//.set spider_Len4, .-spider-spider_Len3
	.set spider_Len, .-spider

bullet:
	.ascii "*"
	.set bullet_Len, .-bullet
timespec:
	.word 1
	.word 1


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

.global gameLoop
gameLoop:
	mov r4, lr
	bl clear_screen
	bl cursor_home
	bl cursor_hide
	mov lr, r4
	bx lr

.global draw_spider
draw_spider:
	mov r4, lr
	mov r0, #5   @ For color code text
	mov r1, #27  @ x pos

	bl spider_color
	mov r0, #2
	bl locate

	mov r0, #STDOUT
	mov32 r1, spider
	mov r2, #spider_Len
	mov r7, #WRITE
	svc #0

	mov r0, #9
	bl fore_color

	mov lr, r4
	bx lr

init_bullet:
	mov r6, #1      @ isLive bullet
	mov r0, r9      @ y pos
	mov r1, r10	@ x pos
	add r1, r1, #1

	push {r0, r1, r6, r7}

	b continue_while_loop

draw_bullet:
	mov r4, lr



	pop {r0, r1, r6, r7}
//	cmp r7, #50
//	addne r7, #1
	subeq r0, r0, #1
//	moveq r7, #0
	cmp r0, #2
	movle r6, #0

	push {r0, r1, r6, r7}
	bl locate @ This locate is erasing the r0 and r1


	mov r0, #STDOUT
	mov32 r1, bullet
	mov r2, #bullet_Len
	mov r7, #WRITE
	svc #0

	mov lr, r4
	bx lr

.global reset_cursor
reset_cursor:
	mov r4, lr
	mov r0, #23 @ y pos
	mov r1, #0  @ x pos

	bl locate

	mov lr, r4
	bx lr

.global _start
_start:
	mov r9, #20  @ posY - init
	mov r10, #30  @ posX - init

	bl gameLoop

	bl term_init

	bl draw_game

	bl draw_spider

	sub sp, sp, #1

while_loop:
	// get movement from user
	mov r7, #READ
	mov r0, #STDIN
	mov r1, sp
	mov r2, #1
	svc #0

	@Testing something here ignore for now
	cmp r6, #1
	bleq draw_bullet

	// If nothing was read, don't bother writing
	cmp r0, #0
	beq skip_print
	mov r0, #0
	
	ldrb r0, [sp]

	cmp r0, #97        @ a
	beq subLeft

	cmp r0, #119       @ w
	beq subDown

	cmp r0, #115       @ s
	beq addUp

	cmp r0, #100       @ d
	beq addRight

	cmp r0, #32        @ space
	beq init_bullet

continue_while_loop:
	mov r0, #CLOCK_REALTIME
	mov r1, #0
	mov32 r2, timespec
	mov r3, #0
	movw r7, #CLOCK_NANOSLEEP
	svc #0

	bl cursor_home
	bl draw_game

	bl draw_spider

	cmp r0, #27
	bne while_loop

skip_print:
	ldrb r0, [sp]

	cmp r0, #27 // Escape Key / Alt Key
	bne while_loop // Go back if

	add sp, sp, #1
	bl term_quit

	bl cursor_show  // need to re-show the cursor

	bl reset_cursor

	mov r7, #EXIT
	svc #0

addUp:
	cmp r9, #20	@ Added this to make guy not go past the floor
	addlt r9, r9, #1
	b continue_while_loop
subLeft:
	cmp r10, #1		@ Added this code to not make guy go past left wall
	subgt r10, r10, #1
	b continue_while_loop
addRight:
	cmp r10, #60		@ Added this code to not make guy go past Right Wall
	addlt r10, r10, #1
	b continue_while_loop
subDown:
	cmp r9, #1		@ Added this code to stop guy from going to high
	subgt r9, r9, #1
	b continue_while_loop

displaymessage:
	mov r0, #STDOUT
	mov32 r1, message
	mov r2, #7
	mov r7, #WRITE
	svc #0

	bx lr
