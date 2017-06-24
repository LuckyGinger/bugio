

	.data
spider:
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
	.set spider_Len, .-spider
	
