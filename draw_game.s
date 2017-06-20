/*****************************************************************************
*   Draws the bugio game. Uses regisers 9-12
*   Input the row of bugio in r9 and the column of bugio at r10.
*   Add to this file later to draw the spider.
*****************************************************************************/

.include "mov32.inc"
.include "system_calls.s"

.data
top_bot:
	.asciz "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	.set topBot_len, .-top_bot
new_line:
	.asciz "\n"
	.set newLine_len, .-new_line
space:
	.asciz "                                                            "
	.set space_len, .-space
bugio:
	.asciz "#"
	.set bugio_len, .-bugio
side_wall:
	.asciz "|"
	.set wall_len, .-side_wall

.text
.global _start
_start:
	mov r9, #20     @ Test row for Bugio, This code should eventually be commented out
	mov r10, #30    @ Test Column for bugio, Eventually will be commented out
	mov r11, #21    @ Screen Height
	mov r12, #1    @ Counter to track row number

draw_topBot:
	@ Draws the top or bottom row of tildas
	mov r0, #STDOUT
	mov32 r1, top_bot
	mov r2, #topBot_len
	mov r7, #WRITE
	svc #0

	@ New Line character
	mov r0, #STDOUT
	mov32 r1, new_line
	mov r2, #newLine_len
	mov r7, #WRITE
	svc #0

	@ Is the row equal to the screen height?
	cmp r12, r11
	bne draw_leftWall

	mov r7, #EXIT
	svc #0

draw_leftWall:
        mov r0, #STDOUT
        mov32 r1, side_wall
        mov r2, #wall_len
        mov r7, #WRITE
        svc #0

	@ If this the same row as Bugio
	cmp r12, r9
	beq bugirow
	@ Else keep going

draw_space:
	mov r0, #STDOUT
	mov32 r1, space
	mov r2, #space_len
	mov r7, #WRITE
	svc #0

draw_game:
	@ Draw the Right wall
	mov r0, #STDOUT
	mov32 r1, side_wall
	mov r2, #wall_len
	mov r7, #WRITE
	svc #0

	@ Move to the Next Line
        mov r0, #STDOUT
        mov32 r1, new_line
        mov r2, #newLine_len
        mov r7, #WRITE
        svc #0

	@ Change to a new row
	add r12, r12, #1

        @ Is the Row counter equal to the max height?
	cmp r12, r11
	beq draw_topBot

	b draw_leftWall

bugirow:

	@ Print spaces up to bugio
	mov r0, #STDOUT
	mov32 r1, space
	sub r2, r10, #1           @ Only prints the number of spaces up to Bugio
	mov r7, #WRITE
	svc #0

	@ Print Bugio
	mov r0, #STDOUT
	mov32 r1, bugio
	mov r2, #bugio_len
	mov r7, #WRITE
	svc #0

	@ Print spaces after Bugio
	add r10, r10, #1           @ Starts at 1 past where bugio is
	mov r2, #space_len
	mov r0, #STDOUT
	mov32 r1, space
	sub r2, r2, r10           @ Subtract the full width by the location of Bugio
	mov r7, #WRITE           @ This makes you only print the number of spaces up to Bugio
	svc #0

	b draw_game
