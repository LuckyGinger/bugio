.include "mov32.inc"
@ System Calls and Constants
.set STDIN, 0
.set STDOUT, 1
.set READ, 3
.set WRITE, 4

.balign 4
.data
spider:
        .ascii "  / _ \\    \0"
	.set spider_Len1, .-spider
	.ascii "\\_\\(_)\/_/\0"
	.set spider_Len2, .-spider-spider_Len1
	.ascii " _\/\/o\\\\_\0"
	.set spider_Len3, .-spider-spider_Len2
	.ascii "  \/   \\   \0"
	.set spider_Len4, .-spider-spider_Len3
newline:
	.ascii "\n\0"

.balign 4
.text
.global _start
_start:
	// Spider body part 1
//	mov r3, lr
        mov r0, #STDOUT
        mov32 r1, spider
        mov r2, #spider_Len1
        mov r7, #WRITE
        svc #0

	// New line Character long way
	mov r0, #STDOUT
        mov32 r1, newline
        mov r2, #1
        mov r7, #WRITE
        svc #0

	mov r0, #STDOUT
        mov32 r1, spider+12
	//add r1, #spider_Len1
        mov r2, #spider_Len2
        mov r7, #WRITE
        svc #0

        // New line Character long way
        mov r0, #STDOUT
        mov32 r1, newline
        mov r2, #1
        mov r7, #WRITE
        svc #0

        mov r0, #STDOUT
        mov32 r1, spider+21
        mov r2, #12
        mov r7, #WRITE
        svc #0

       // New line Character long way
        mov r0, #STDOUT
        mov32 r1, newline
        mov r2, #1
        mov r7, #WRITE
        svc #0

        mov r0, #STDOUT
        mov32 r1, spider+30
        mov r2, #10
        mov r7, #WRITE
        svc #0

        mov r7, #1
	svc #0

