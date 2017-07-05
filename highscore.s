.include "mov32.inc"

@ System Calls
.set READ, 3
.set WRITE, 4
.set OPEN, 5

@ Constants for System Calls
.set STDIN, 0
.set STDOUT, 1
.set O_WRONLY, 1
.set O_CREAT, 64
.set O_TRUNC, 512
.set CREAT_FLAGS, (O_WRONLY | O_CREAT | O_TRUNC)


.balign 4
.data
filename:
	.ascii "highscore.txt\0"
	.set filename_Len, .-filename
newline:
	.ascii "\n\0"
	.set newline_Len, .-newline
userInput:
	.space 32


.balign 4
.text
.global _start
_start:
	// OpenFile or Create Highscore File
	mov32 r0, filename
	movw r1, #CREAT_FLAGS
	movw r2, #0644 // Permission for File number 644 ultimate power
	mov r7, #OPEN
	svc #0

	mov r4, r0

	// Get input from  user
	mov r0, #STDIN
	mov32 r1, userInput
	mov r2, #32
	mov r7, #READ
	svc #0

	// Write to File
	mov r0, r4
	mov32 r1, userInput
	mov r2, #6
	mov r7, #WRITE
	svc #0


	mov r7, #1
	svc #0
