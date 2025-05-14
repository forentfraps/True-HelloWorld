nasm -fwin64 peb.asm -o peb.o
nasm -fwin64 pe.asm -o pe.o
nasm -fwin64 main.asm -o main.o
nasm -fwin64 string_cmp.asm -o string_cmp.o
gcc peb.o pe.o main.o string_cmp.o -nostdlib -ffreestanding -fno-builtin -Wl,-e,_start -static -s -o HelloWorld.exe
del *.o
