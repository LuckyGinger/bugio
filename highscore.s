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
	.ascii "     Please enter your name: \0"
	.set you_placed_Len, .-you_placed
// Delete later and add the one below
user_score:
	.word 120

.balign 4
.bss // any label created after this point will be be zeroed
user_name:
	.space 10
//user_score:
	//.space 4
user_score_ascii:
	.space 4
file_info:
	.space 10 // Name 1
	.word 4 // Score 1
        .space 10 // Name 2
        .word 4 // Score 2
        .space 10 // Name 3
        .word 4 // Score 3



.balign 4
.text
.global get_name
get_name:
	// Move cursor to middle of screen
@	mov r0, #9
@	mov r1, #25
@	bl locate

	// Print a message to the user for input
	mov r0, #STDOUT
        mov32 r1, you_placed
        mov r2, #you_placed_Len
        mov r7, #WRITE
        svc #0



	// Get input from  user
	mov r0, #STDIN
	mov32 r1, user_name
	mov r2, #10
	mov r7, #READ
	svc #0

	bx lr
/*	// Write to File Save for later
	mov r0, r4
	mov32 r1, userName
	mov r2, #6
	mov r7, #WRITE
	svc #0*/

.balign 4
.text
.global hit
hit:
	// This function will count a kill point :)
	mov32 r0, user_score
	ldr r1, [r0] @ Here we are De-Referencing
	add r1, r1, #1 @ Adding a Kill point

	@ Now add the new value back into label
	str r1, [r0]

	bx lr

.balign 4
.text
.global score_to_ascii
score_to_ascii:
	push {r4-r7}

	mov32 r4, user_score
	ldr r5, [r4]
	mov r6, #10
	mov r2, #-3
loop:
	sdiv r5, r5, r6
	cmp r5, #10
	mul r7, r6, r5
	subs r7, r5, r7
	add r7, #48
	strb r7, [r4, r2]
	subs r2, #1
	bgt loop



	//strb [
	pop {r4-r7}

.balign 4
.text
.global _start
_start:
	push {r4-r9}

	bl open_file // returns the file descriptor in r0
	mov r6, r0 // Need to save the file descriptor else where
	bl unload_file // load file descriptor and content into mmap2. Also returns the mmap address in r4

	blne display_scores
	bleq display_empty_message

	bl did_user_place // Did the user place in the top three

	cmp r1, #1
	bleq get_name
	bleq add_new_score
	blne sorry_message // if r1 != 1 then they did place into top score file

	pop {r4-r9}
	mov r7, #EXIT
	svc #0

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

add_new_score:
	mov32 r1, file_info // Temporary memory holder
	mov32 r2, user_name // Get user name

	sub r3, r3, #14 // This shifts the pointer of memory to the begining line
	cmp r3, #15
	blt first_place
	beq second_place
	bgt third_place

	ldr r5, [r2]
	str r5, [r1]
	ldr r5, [r2, #4]
	str r5, [r1, #4]
	ldr r5, [r2, #8]
	str r5, [r2, #8]


	mov r0, #STDOUT
        mov32 r1, file_info
        mov r2, #9
        mov r7, #WRITE
        svc #0

	bx lr


sorry_message:


display_scores:
	push {r4, lr}

	mov r0, #20 //  Middle
	mov r1, #30 // Screen
@Add this later	bl locate

	// Print top 3 score from file pulled from memory for now.
	mov r0, #STDOUT
	mov32 r1, file_info
	mov r2, #100
	mov r7, #WRITE
	svc #0

	pop {r4, pc}

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
