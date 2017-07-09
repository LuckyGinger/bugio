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
	.asciz "#"
	.set body_len, .-playerBody
clearChar:
	.asciz " "
	.set clear_body_len, .-clearChar
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
	.word 0
	.word 50000000

.balign 4
.text

draw_player:
	mov r4, lr

	mov r0, r9
	mov r1, r10

	bl locate

	mov r0, #STDOUT
	mov32 r1, playerBody
	mov r2, #body_len
	mov r7, #WRITE
	svc #0

	mov lr, r4
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
	mov r0, r9      @ y pos
	mov r1, r10     @ x pos

//	sub r0, r0, #1      @ 1 higher than the character

	strb r0, [r11, #0]
	strb r1, [r11, #1]

	b continue_while_loop

clear_bullet:
	push {r0, r1, r7, lr}

	bl locate

	mov r0, #STDOUT
	mov32 r1, clearChar
	mov r2, #clear_body_len
	mov r7, #WRITE
	svc #0

	pop {r0, r1, r7, pc}


draw_bullet:
	mov r4, lr

	ldrb r0, [r11, #0]   @ y pos
	ldrb r1, [r11, #1]   @ x pos

	cmp r0, #0           @ does this bullet exist?
	bxeq lr

	cmp r0, r9
	blne clear_bullet

	sub r0, r0, #1

	// Store back on heap
	strb r0, [r11, #0]
	strb r1, [r11, #1]

	// Collision detection
	cmp r0, #5                 @ Where the spider reaches down to
	blls check_collision

	// don't display the bullet if bullet gets to the top
	cmp r0, #1
	movle r6, #0
        moveq lr, r4
	bxeq lr

	// otherwise display the bullet
	bl locate @ This locate is erasing the r0 and r1

	mov r0, #STDOUT
	mov32 r1, bullet
	mov r2, #bullet_Len
	mov r7, #WRITE
	svc #0

	mov r0, #CLOCK_REALTIME
	mov r1, #0
	mov32 r2, timespec
	mov r3, #0
	movw r7, #CLOCK_NANOSLEEP
	svc #0

	mov lr, r4
	bx lr


/*
draw_bullet:
	mov r4, lr

        pop {r0, r1, r6, r7}

	// clear previous bullet
	cmp r0, r9
	blne clear_bullet

	sub r0, r0, #1

	push {r0, r1, r6, r7}

*/


check_collision:
	cmp r1, #26         @ is it less than where the spider starts?
	bxls lr             @ then do nothing and go back

	cmp r1, #35         @ is it greater than where the spider goes to the right?
	bxhi lr             @ Then do nothing and go back

	beq hit_35_27       @ is it equal to 35?

	cmp r1, #33
	beq hit_33_29

	cmp r1, #29
	beq hit_33_29

	cmp r1, #27
	beq hit_35_27

	b hit_34_32_31_30_28   @ All these are equal heights

hit_35_27:
	cmp r0, #3
	bxne lr

	// Add to the score
//	bl hit

	mov r6, #0          @ Kill the bullet
	mov lr, r4          @ put the return for the bullet function to lr

	bx lr

hit_33_29:
	// Add to the score
//	bl hit

	mov r6, #0          @ Kill the bullet
	mov lr, r4          @ put the return for the bullet function to lr

	bx lr

hit_34_32_31_30_28:
	cmp r0, #4
	bxne lr

	// Add to the score
//	bl hit

	mov r6, #0          @ Kill the bullet
	mov lr, r4          @ put the return for the bullet function to lr

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
	mov r9, #21  @ posY - init
	mov r10, #31  @ posX - init

	bl gameLoop

	bl term_init

	bl draw_game

	bl draw_spider

	bl draw_player

	sub sp, sp, #1

	// Map that crap
        mov r0, #0
        mov r1, #2000
        mov r2, #MAP_PROT
        mov r3, #MAP_ANONYMOUS
        mov r4, #-1
        mov r5, #0
        mov r7, #MMAP2
        svc #0

	mov r11, r0     @ Set r11 as the location of the mapped memory

//	mov r0, #0
//	strb r0, [r11]

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

	cmp r0, #32        @ space
	beq init_bullet

continue_while_loop:
	bl draw_player

//	bl draw_bullet

	bl draw_spider

skip_print:
	ldrb r0, [sp]

	cmp r0, #27        @ esc
	bne while_loop

	add sp, sp, #1
	bl term_quit

	bl cursor_show

	bl reset_cursor

	mov r7, #EXIT
	svc #0

clear_player:
	mov r4, lr

	mov r0, r9
	mov r1, r10

	bl locate

	mov r0, #STDOUT
	mov32 r1, clearChar
	mov r2, #clear_body_len
	mov r7, #WRITE
	svc #0

	mov lr, r4
	bx lr
	
	
addUp:
	bl clear_player
	cmp r9, #21	        @ Added this to make guy not go past the floor
	addlt r9, r9, #1
	b continue_while_loop
subLeft:
	bl clear_player
	cmp r10, #2		@ Added this code to not make guy go past left wall
	subgt r10, r10, #1
	b continue_while_loop
addRight:
	bl clear_player
	cmp r10, #61		@ Added this code to not make guy go past Right Wall
	addlt r10, r10, #1
	b continue_while_loop
subDown:
	bl clear_player
	cmp r9, #2		@ Added this code to stop guy from going to high
	subgt r9, r9, #1
	b continue_while_loop

displaymessage:
	mov r0, #STDOUT
	mov32 r1, message
	mov r2, #7
	mov r7, #WRITE
	svc #0

	bx lr
