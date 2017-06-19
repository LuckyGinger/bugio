# Makefile
all: bugio.exe

bugio.exe: bugio.o cursor.o term.o 
	ld -o $@ $+

bugio.o: bugio.s
	as -o $@ $<

cursor.o: cursor.s
	as -o $@ $<

term.o: term.s
	as -o $@ $<

clean:
	rm -vf *.exe *.o
