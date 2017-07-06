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
userName:
	.space 28
userScore:
	.space 4
file_info:
	.space 96
temp_score:
	.space 4


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

	bl check_file

	blne display_scores

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

	// If r0 = 0, then file is empty :: if r0 = 1, then file contains something
	cmp r1, #0

	bx lr


continue:
	// Get input from  user
	mov r0, #STDIN
	mov32 r1, userName
	mov r2, #32
	mov r7, #READ
	svc #0

	// Write to File
	mov r0, r4
	mov32 r1, userName
	mov r2, #6
	mov r7, #WRITE
	svc #0


display_scores:
	push {r4, lr}

	mov r0, #20 //  Middle
	mov r1, #30 // Screen
@Add this later	bl locate

	mov r0, #STDOUT
	mov32 r1, file_info
	mov r2, #100
	mov r7, #WRITE
	svc #0

	pop {r4, pc}

did_user_place:
	push {r4, lr}
	mov32 r0, file_info
	mov r1, #0 // Shift bit Counter
	mov r3, #1 // Top Player = 1 if r3 = 2 then we are at second top PLayer etc
	mov32 r4, temp_score // This is used to compare scores
while_loop:
	ldrb r0, [r0, r1]
	cmp r0, #57
	movgt r0, #100
	cmp r0, #32
	moveq r0, #100

	cmp r0, #100
	// Here we will store 1 score from the file one by one and comparing
	strbne r0, [r4, #1]
	cmp r0, #10

	bl compare_scores

	beq while_loop

	pop {r4, pc}

compare_scores:
	push {r4, lr}

	

	pop {r4, pc}
