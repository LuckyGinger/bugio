# Makefile
all: bugio.exe

bugio.exe: bugio.o cursor.o term.o draw_game.o
	ld -o $@ $+

bugio.o: bugio.s
	as -o $@ $<

cursor.o: cursor.s
	as -o $@ $<

term.o: term.s
	as -o $@ $<

draw_game.o: draw_game.s
	as -o $@ $<

clean:
	rm -vf *.exe *.o
