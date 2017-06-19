 @ Start writing code
@	.include "cursor.s"
@	.include "term.s"
	.include "mov32.inc"

	.set STDOUT, 1
	
	.set READ,  0x03
	.set WRITE, 0x04
	
	
	@constant min bound
	.set MIN, 0
	
	@constant max bound
	.set MAX, 60
	
	.balign 4
	.data
playerBody:
	.asciz "#"
	.set body_len, .-playerBody
space:
	.ascii " "
	
gameKey:
	.skip 4
	
player:
	.skip 1
	.set length, .-player
	.word 30
	.set player_len, .-length
	
	.balign 4
	.text

//drawGame:
//	mov r0, #MIN
	
	
drawPlayer:
	mov r3, lr
	mov r0, #STDOUT
	mov32 r1, playerBody
	mov r2, #body_len
	mov r7, #WRITE
	svc #0

	mov lr, r3
	bx lr
	
	

gameLoop:
	mov r4, lr

	bl clear_screen
	bl cursor_home

	
/*.L1:
	bl clear_screen
        bl cursor_home
	bl drawPlayer
	b .L0


.L0:
        mov r0, #STDIN
	mov r1, r6
	mov r2, #4096
	mov r7, #READ
	svc #0
*/	
	
	mov lr, r4
	bx lr
	
	
	.global _start
_start:
	bl gameLoop
	bl term_inited
/*
	push {r4-r12, lr}
	sub sp, sp, #60

        // ioctl(unsigned int fd, unsigned int cmd, void* arg)  r7 = 0x36
	ldr r2, =termios // Pointer to the global struct
	ldr r1, =TCGETS // Select ioctl function
	mov r0, #STDIN  // Set device file handle
	mov r7, #IOCTL
	svc #0
	
        // Copy the global struct to local stack for modification
	mov r1, sp
	ldr r0, =termios
	ldm r0!, {r2-r11} // Copy 40 bytes
	stm r1!, {r2-r11}
	ldm r0, {r2-r6} // Copy 20 bytes
	stm r1, {r2-r6}

	// Now we need to modify the struct on the stack
	// Disable Echo and Canonical mode
	ldr r0, [sp, #LFLAG]  // Get the control flags
	bic r0, r0, #(ECHO | ICANON)
	str r0, [sp, #LFLAG]
	// Make input non-blocking, with no timeout (essentially set to polling mode)
	mov r0, #0
	strh r0, [sp, #(C_CC + VTIME)]  // VTIME and VMIN are adjacent bytes, so writing a halfword to VTIME should overwrite both

	// Ready to write back to the device driver now
	mov r2, sp
	ldr r1, =TCSETS
	mov r0, #STDIN
	mov r7, #IOCTL
	svc #0
	
	
	add sp, sp, #60
	pop {r4-r12, pc}
*/	
	sub sp, sp, #1
	
	mov r7, #1
	svc #0

	
