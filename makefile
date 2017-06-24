# Makefile
all: bugio.exe

bugio.exe: bugio.o cursor.o term.o draw_game.o #spider.o
	ld -o $@ $+

bugio.o: bugio.s
	as -o $@ $<

cursor.o: cursor.s
	as -o $@ $<

term.o: term.s
	as -o $@ $<

draw_game.o: draw_game.s
	as -o $@ $<

#spider.o: spider.s
#	as -o $@ $<

#####################################
#test: test.exe

#test.exe: cursor_test.o cursor.o
#        ld -o $@ $+

#cursor_test.o: cursor_test.s
#        as -o $@ $<

#cursor.o: cursor.s
#        as -o $@ $<
#####################################

clean:
	rm -vf *.exe *.o
