@ System Calls
.set EXIT, 1
.set READ, 3
.set WRITE, 4
.set OPEN, 5
.set CLOSE, 6
.set MMAP2, 192

.set STDIN,  0
.set STDOUT, 1

.set TCGETS, 0x5401
.set TCSETS, 0x5402

.set ICANON, 2
.set ECHO, 8

.set VMIN, 6
.set VTIME, 5

.set NCCS, 32

.set IFLAG, 0
.set OFLAG, 4
.set CFLAG, 8
.set LFLAG, 12
.set C_CC,  17
.set ISPEED, 52
.set OSPEED, 56

.set IOCTL, 0x36

// MMAP crud
.set MAP_ANONYMOUS, 32
.set MAP_SHARED, 1
.set MUNMMAP, 91
.set PROT_READ, 1
.set PROT_WRITE, 2
.set MAP_PROT, (PROT_READ | PROT_WRITE)
.set MAP_FLAGS, (MAP_ANONYMOUS | MAP_SHARED)

.set O_WRONLY, 1
.set O_RDWR , 2
.set O_CREAT, 64
.set O_TRUNC, 512
.set O_APPEND, 1024
.set FILE_FLAGS, (/*O_WRONLY*/O_RDWR | O_APPEND | O_CREAT/* | O_TRUNC*/)

