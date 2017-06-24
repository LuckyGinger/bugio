/* Loads a 32-bit immediate onto a register without a data access */

.macro	mov32, reg, val

	movw	\reg, #:lower16:\val

	movt	\reg, #:upper16:\val

.endm


.macro mov_L_cur, left, down

	.byte 27
	.ascii "[\left()D\0"
	.byte 27
	.ascii "[\down()B\0"
	

.endm 
