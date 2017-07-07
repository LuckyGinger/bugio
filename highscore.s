.include "mov32.inc"

@ System Calls
.set EXIT, 1
.set READ, 3
.set WRITE, 4
.set OPEN, 5
.set CLOSE, 6

@ Constants for System Calls
.set STDIN, 0
.set STDOUT, 1
.set O_WRONLY, 1
.set O_CREAT, 64
.set O_RDWR , 2
.set O_TRUNC, 512
.set O_APPEND, 1024
.set CREAT_FLAGS, (/*O_WRONLY*/O_RDWR | O_APPEND | O_CREAT/* | O_TRUNC*/)


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


.balign 4
.bss
user_name:
	.space 28
user_score:
	.space 4
file_info:
	.space 96


.balign 4
.text
.global _get_name
_get_name:
	// Get input from  user
	mov r0, #STDIN
	mov32 r1, user_name
	mov r2, #32
	mov r7, #READ
	svc #0


/*	// Write to File Save for later
	mov r0, r4
	mov32 r1, userName
	mov r2, #6
	mov r7, #WRITE
	svc #0*/

.balign 4
.text
.global _hit
_hit:
	// This function will count a kill point :)
	mov32 r0, userScore
	mov r1, r0 @ This is so we dont loose the memory location
	ldr r0, [r0] @ Here we are De-Referencing
	add r0, r0, #1 @ Adding a Kill point

	@ Now add new value back into label
	str r0, [r1]

	bx lr


.balign 4
.text
.global _start
_start:
	push {r4-r9}

	// OpenFile or Create Highscore File
	mov32 r0, filename
	movw r1, #CREAT_FLAGS
	movw r2, #00644 // Permission for File number 644 ultimate power
	mov r7, #OPEN
	svc #0

	mov r8, r0 // Need to save the file descriptor

	bl check_file

	blne display_scores
	bleq display_empty_message

	bl did_user_place // Did the user place in the top three

	pop {r4-r9}
	mov r7, #EXIT
	svc #0

check_file:
	// Load file information into .data section
	mov32 r1, file_info
	mov r2, #100
	mov r7, #READ
	svc #0

	// Load first byte from file and check to see if there is information
	mov32 r1, file_info
	ldrb r1, [r1]

	// If r0 = 0, then file is empty :: if r0 = any #, then file contains something
	cmp r1, #0

	bx lr

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
	mov r0, #20 //  Middle
	mov r1, #30 // Screen
@Add this later bl locate

	mov r0, #STDOUT
        mov32 r1, empty_mess
        mov r2, #empty_mess_Len
        mov r7, #WRITE
        svc #0

	bx lr

did_user_place:
	push {r4, lr}

	mov32 r0, file_info
	mov r1, #0 // Shift bit Counter
	mov r2, #10
	mov r3, #0 // Contains the byte
	mov32 r4, userScore // This is used to compare scores
	ldr r4, [r4]
	mov r5, #0 // Used for file number score conversion

while_loop:
	ldrb r3, [r0, r1]

	cmp r3, #57
	movgt r3, #100
	cmp r3, #32
	moveq r3, #100

	// If at the end of the line then lets compare scores
	cmp r3, #10
	bleq compare_scores

	// Loop from the begining if number did not exist
	cmp r0, #100
	beq while_loop

	// If Equal then we are at end of File
	cmp r3, #0
	beq finish_loop

	// Go ahead and convert user score into a register
	mul r5, r2, r5
	add r5, r3, r5
	b while_loop
finish_loop:
	pop {r4, pc}

compare_scores:
	push {r4, lr}

	cmp r4, r5 // r4 = user score, r5 = file score "one of the file scores"
	@ Here if the greater than flag is set then the user has a high score


	

	// Need to reset the register r5 = 0
	mov r5, #0

	pop {r4, pc}
