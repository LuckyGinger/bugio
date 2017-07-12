.include "mov32.inc"

@ System Calls
.set EXIT, 1
.set READ, 3
.set WRITE, 4
.set OPEN, 5
.set CLOSE, 6
.set MMAP2, 192

@ Constants for System Calls
.set STDIN, 0
.set STDOUT, 1

.set MAP_SHARED, 1
.set MUNMMAP, 91
.set PROT_READ, 1
.set PROT_WRITE, 2
.set MAP_PROT, (PROT_READ | PROT_WRITE)

.set O_WRONLY, 1
.set O_RDWR , 2
.set O_CREAT, 64
.set O_TRUNC, 512
.set O_APPEND, 1024
.set FILE_FLAGS, (/*O_WRONLY*/O_RDWR | O_APPEND | O_CREAT/* | O_TRUNC*/)


.balign 4
.data
filename:
	.ascii "highscore.txt\0"
	.set filename_Len, .-filename
newline:
	.ascii "\n\0"
	.set newline_Len, .-newline
empty_mess:
	.ascii "Empty File::::\n\0"
	.set empty_mess_Len, .-empty_mess
you_placed:
	.ascii "Congragulations you placed in the top 3.\n\0"
	.ascii "\tPlease enter your name: \0"
	.set you_placed_Len, .-you_placed
sorry_message:
	.ascii "Sorry but you suck\n\t\tand did not place in the top 3\n\0"
	.set sorry_message_Len, .-sorry_message
score_bar:
	.ascii "Score: \0"
	.set score_bar_Len, .-score_bar

.balign 4
.bss // any label created after this point will be be zeroed
user_name:
	.space 20
user_score:
	.space 4
user_score_ascii:
	.space 8
file_info:
	.space 10 // Name 1
	.word 5 // Score 1
        .space 10 // Name 2
        .word 5 // Score 2
        .space 10 // Name 3
        .word 5 // Score 3



.balign 4
.text
.global get_name
get_name:
	push {r0-r2, lr}
	mov r11, r3
	// Move cursor to middle of screen
	mov r0, #9
	mov r1, #14
	bl locate

	// Print a message to the user for input
	mov r0, #STDOUT
        mov32 r1, you_placed
        mov r2, #you_placed_Len
        mov r7, #WRITE
        svc #0

	// Get input from  user
	mov r0, #STDIN
	mov32 r1, user_name
	mov r2, #20
	mov r7, #READ
	svc #0

	mov r3, r11

	cmp r0, #10
	bgt finish_spaces
	subs r0, #1
add_filler_spaces:
	mov r2, #32
	strb r2, [r1, r0]
	add r0, #1
	cmp r0, #10
	blt add_filler_spaces
finish_spaces:
	pop {r0-r2, pc}


.balign 4
.text
.global hit
hit:
	push {r0, r1, r4, lr}
	// This function will count a kill point :)
	mov32 r0, user_score
	ldr r1, [r0] @ Here we are De-Referencing
	add r1, r1, #1 @ Adding a Kill point

	@ Now add the new value back into label
	str r1, [r0]
	mov r4, r1

	mov r0, #2
	mov r1, #51

	bl locate

	mov r0, #STDOUT
        mov32 r1, score_bar
        mov r2, #10
        mov r7, #WRITE
        svc #0

	mov r0, #2
        mov r1, #58

        bl locate

        mov r1, r4 // decimal score
	mov r6, #10 // Constant Value
	mov r5, #0
how_big:
	sdiv r1, r1, r6
	cmp r1, #0
	addgt r5, #1
	bgt how_big

	mov32 r3, user_score_ascii
convert_ascii:
	mov r8, r4 // x
        sdiv r4, r4, r6 // x/10
        mul r7, r6, r4 // r7 = 10 * x
        subs r7, r8, r7 // r7 = x - r7
        add r7, #48 // r7 + 48
        strb r7, [r3, r5]
	sub r5, #1
        cmp r4, #0
        bgt convert_ascii

	mov r0, #STDOUT
	mov32 r1, user_score_ascii
	mov r2, #10
	mov r7, #WRITE
	svc #0

	pop {r0, r1, r4, pc}

.balign 4
.text
.global score_to_ascii
score_to_ascii:
	push {r3-r7, lr}

	// r4 already has score in decimal already
	mov r5, #0x3
	mov r6, #10
loop:
	mov r8, r2
	sdiv r2, r2, r6
	mul r7, r6, r2
	subs r7, r8, r7
	add r7, #48
	strb r7, [r3, r5]
	subs r5, #1
	cmp r2, #1
	bge loop

	mov r6, #32
	cmp r5, #0
	strgeb r6, [r3, r5]
	sub r5, #1
	cmp r5, #0
	strgeb r6, [r3, r5]
	sub r5, #1
	cmp r5, #0
	strgeb r6, [r3, r5]

	// This will add a newline athe end of the line
	mov r2, #10
	add r3, #4
	str r2, [r3]
	add r3, #1

	pop {r3-r7, pc}

.balign 4
.text
.global highscore
highscore:
	push {r3-r9, lr}

	bl open_file // returns the file descriptor in r0
	mov r6, r0 // Need to save the file descriptor else where
	bl unload_file // load file descriptor and content into mmap2. Also returns the mmap address in r4

	blne display_scores
	bleq display_empty_message

	bl did_user_place // Did the user place in the top three

	cmp r1, #1
	bleq get_name
	cmp r1, #1
	mov r1, r3 // move counter ro r1 instead
	mov r2, r4 // move usersScore to r2 instead
	blne sorry_prompt // if r1 != 1 then they did place into top score file
	bleq add_new_score
	bleq display_scores

	bl close_all_files

	pop {r3-r9, pc}
open_file:
	mov32 r0, filename
	movw r1, #FILE_FLAGS
	movw r2, #00644 // Permission for File number 644 ultimate power
	mov r7, #OPEN
	svc #0

	bx lr

unload_file:
	// First allocate 2k of memory
	mov r0, #0
	mov r1, #2000
	mov r2, #MAP_PROT
	mov r3, #MAP_SHARED
	mov r4, r6
	mov r5, #0
	mov r7, #MMAP2
	svc #0

	mov r4, r0 // Keep the address of mmap.
	mov r5, r0 // delete later maybe this is for the display message

	// We can close the file here and keep mmap open.
	mov r0, r6 // r6 = file descriptor
	mov r7, #CLOSE
	svc #0

	// Load first byte from file and check to see if there is information
	ldrb r1, [r4]

	// If r0 = 0, then file is empty :: if r0 = any #, then file contains something
	cmp r1, #0

	bx lr

@ This functio sets variables some variables will change others wont
did_user_place:
	push {r4, lr}

	mov r0, r4 // mmap memory address
	mov r1, #0 // This is a flag if r1 = 0 then did not make top 3, else if r1 = 1 then user placed in top
	mov r2, #0 // This will contain the score in file byte at a time
	mov r3, #0 // This is our counter
	mov32 r4, user_score // This is used to compare scores
	ldr r4, [r4]
	mov r5, #0 // number from file after r2 conversion
	mov r6, #10 // For multiplication purposes
	mov r7, #0
while_loop:
	ldrb r2, [r0, r3]

	cmp r2, #57
	movgt r2, #100
	cmp r2, #32
	moveq r2, #100

	// If at the end of the line then lets compare scores
	cmp r2, #10
	bleq compare_scores

	// If Equal then we are at end of File
	cmp r2, #0
	beq finish_loop

	add r3, #1 // add counter

	// Loop from the begining if number did not exist
	cmp r2, #100
	beq while_loop

	// Go ahead and convert user score into a register
	mul r5, r6, r5
	subs r2, #48
	add r5, r2, r5
	b while_loop
finish_loop:
	pop {r2, pc}
compare_scores:
	push {r4, lr}

	cmp r4, r5 // r4 = user score, r5 = file score "one of the file scores"
	movle r2, #100 // This will kick out of the while_loop
	movgt r2, #0
	movgt r1, #1 // This indicates that the user placed in the top 3
	mov r5, #0 // reset this value otherwise things will go off when converting

	pop {r4, pc}





@ At this point r0 = initial memory in mmap
@		r1 = counter
@		r2 = users score
add_new_score:
	push {r0, lr}
	mov32 r3, file_info // Temporary memory holder in .bss section
	mov32 r4, user_name // Get user name in ascii style memory aka sucks
	mov r5, #0
	sub r1, r1, #14 // This shifts the pointer of memory to the begining of a line
adding_score_loop:
	cmp r1, r5
	bne copy_old_info
	beq add_new_info
done_adding_score:
	mov r6, #0
	str r6, [r3]

	pop {r0, pc}
copy_old_info:
	cmp r5, #45
	bge done_adding_score
	ldm r0, {r8-r11} 	// Load 16 Bytes BUT our line is only 15 bytes
	stm r3, {r8-r11}	// Store 16 bytes
	add r5, #15		// This will take care of the extra byte above

	add r0, #15 		// Move pointer from mmap
	add r3, #15		// Move pointer from .bss section
	cmp r5, #45
	b adding_score_loop
add_new_info:
	ldm r4, {r8-r10}
	stm r3, {r8-r10}

	add r3, #10
	bl score_to_ascii // returns address of ascii number in r2

	add r5, #15
	add r3, #5
	cmp r5, #45
	bge done_adding_score
	b adding_score_loop

sorry_prompt:
	mov r9, lr // Save lr to branch back later
	mov r0, #9
	mov r1, #20

	mov r11, r3
	bl locate
	mov r3, r11

        mov r0, #STDOUT
        mov32 r1, sorry_message
        mov r2, #sorry_message_Len
        mov r7, #WRITE
        svc #0

	mov lr, r9
	bx lr

display_scores:
	push {r0, lr}

	mov r0, #23 //  Middle
	mov r1, #0 // Screen
	bl locate

	// Print top 3 score from file pulled from memory for now.
	mov r0, #STDOUT
	mov32 r1, file_info
	mov r2, #100
	mov r7, #WRITE
	svc #0

	pop {r0, pc}

display_empty_message:
	push {r4, lr}

	mov r0, #20 //  Middle
	mov r1, #30 // Screen
@Add this later bl locate

	mov r0, #STDOUT
        mov32 r1, empty_mess
        mov r2, #empty_mess_Len
        mov r7, #WRITE
        svc #0

	pop {r4, pc}

close_all_files:
	mov32 r1, file_info
	ldr r1, [r1]
	cmp r1, #0
	ldrne r1, =file_info
	ldmne r1, {r1-r11}
	stmne r0, {r1-r11}

	mov r0, r0
	movw r1, #2000
	mov r7, #MUNMMAP
	svc #0

	bx lr
