.include "system_calls.s"
.include "mov32.inc"

.data
//position:
 //       .byte 27
 //       .ascii "[H"

position_up:
        .byte 27
        .ascii "[1A"
position_down:
	.byte 27
	.ascii "[1B"
position_right:
	.byte 27
	.ascii "[1C"
position_left:
	.byte 27
	.ascii "[1D"
test:
        .ascii "  / _ \\"
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

	//.set spider_Len2, .-spider-spider_Len1
        .ascii " _\/\/o\\\\_"
        .byte 27
        .ascii "[1B"
        .byte 27
        .ascii "[8D"

        //.set spider_Len3, .-spider-spider_Len2
        .ascii "  \/   \\   "
        .byte 27
        .ascii "[1B"
        .byte 27
        .ascii "[10D"

       	//.set spider_Len4, .-spider-spider_Len3
	.set spider_Len, .-test


.balign 4
.text
.global _start
_start:
	// Location Part
        cmp r0, #1000
        bxpl lr
        cmp r1, #1000
        bxpl lr

      //  push {r4-r7, lr}
       // ldr r12, =locate
       // mov r7, #10

//	push {r0, r1}
	mov r0, #10
	mov r1, #10
	bl locate
//	pop {r0, r1}
	
	
	// Draw spider Here
        mov r0, #STDOUT
        mov32 r1, test
        mov r2, #spider_Len
        mov r7, #WRITE
        svc #0

	mov r0, #10
	mov r1, #10
	bl locate

        mov r0, #STDOUT
	mov32 r1, test
	mov r2, #spider_Len
	mov r7, #WRITE
	svc #0
	

	mov r7, #1
	svc #0



