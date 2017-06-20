# Makefile
all: tt.exe

tt.exe: thomtest.o cursor.o term.o 
	ld -o $@ $+

thomtest.o: thomtest.s
	as -o $@ $<

cursor.o: cursor.s
	as -o $@ $<

term.o: term.s
	as -o $@ $<

clean:
	rm -vf *.exe *.o
