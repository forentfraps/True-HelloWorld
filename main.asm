global _start

extern get_ntdll_base
extern get_stdout
extern get_export_directory
extern find_function_by_name

section .text

_start:
  ; push r14
  ; push r15
  ; push rdi
  ; push rsi
  ; push rbx
  ; We dont do this since we dont care about the stack


  call get_ntdll_base ;base address of ntdll.dll in rax
  mov rsi, rax ;ntdll base
  mov rcx, rax
  mov ax, word [rcx] ;pe magic
  cmp ax, 0x5a4d
  jnz error
  call get_export_directory
  mov rbx, rax ;ntdll export dir
  mov rcx, rsi
  mov rdx, rbx
  lea r8, [rel NtWriteFileS]
  call find_function_by_name
  mov r15w, word [rax + 4] ;syscall number of NtWriteFile
  mov rcx, rsi
  mov rdx, rbx
  lea r8, [rel NtTerminateProcessS]
  call find_function_by_name
  mov r14w, word [rax + 4] ;syscall number of NtTerminateProcess

  call get_stdout
  mov r10, rax ; stdout
  lea rax, [rel HelloWorldS]
  lea rdx, [rsp]
  push 0 ;Key
  push 0 ;Byte Offset
  push 20 ;len
  push rax ; buffer
  push rdx ; IoStatusBlock
  push 0 ; I love 4 empty spots for 4 input registers
  push 0 ; I love 4 empty spots for 4 input registers
  push 0 ; I love 4 empty spots for 4 input registers
  push 0 ; I love 4 empty spots for 4 input registers
  push 0 ; and the fifth as if we called the syscall
  mov rax, r15 ;syscall number
  ; mov r10, stdout (already there)
  mov rdx, 0 ;Event
  mov r8, 0 ; ApcRoutine
  mov r9, 0 ; APcContext
  syscall

  ; Exit called once
  mov rax, r14
  mov r10, 0
  mov rdx, 0
  syscall

  ; Exit called second time
  mov rax, r14
  mov r10, 0
  mov rdx, 0
  syscall






error:
  hlt ; we cant really do much else


section .data

NtWriteFileS: db 'NtWriteFile',0
NtTerminateProcessS: db 'NtTerminateProcess',0
HelloWorldS: db 'Hello World!',10,0
