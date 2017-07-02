
	.include "mov32.inc"
	.set CLOCK_GETTIME, 0x107
	.set CLOCK_REALTIME, 0
	.set CLOCK_NANOSLEEP, 0x109
	.set TIMER_ABSTIME, 1
	
	.data
	.balign 4
struct:
	.word 2
	.word 5

	.balign 4
	.text
	.global _start
_start:
/*	mov r0, #CLOCK_REALTIME
	mov32 r1, struct
	movw r7, #CLOCK_GETTIME
	svc #0
*/

	mov r0, #CLOCK_REALTIME
	mov r1, #0
	mov32 r2, struct
	mov r3, #0
	movw r7, #CLOCK_NANOSLEEP
	svc #0
	
	
	
	mov r7, #1
	svc #0
