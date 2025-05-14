# HelloWorld Syscalls in x64 Assembly

**World’s first true assembly-only `Hello World`**: this project is the first in the world to implement a Hello World program purely in x64 assembly on Windows, without using any WinAPI calls or C runtime. It manually locates `ntdll.dll` via the PEB, parses its export directory to resolve syscall numbers at runtime, and issues `syscall` instructions directly to write `Hello World!` to standard output and terminate the process. This approach fetches syscall numbers from loaded libraries, ensuring portability across all Windows versions.

---

## Features

* **First-ever assembly-only `Hello World`** with manual syscall resolution and no WinAPI dependencies, ensuring portability across all Windows versions.

* **PEB parsing** to locate the base address of `ntdll.dll` (see `peb.asm`).

* **PE export directory parsing** to resolve function names to addresses and extract syscall numbers (see `pe.asm`).

* **String comparison routines** for UTF-16 ↔ UTF-8 and UTF-8 ↔ UTF-8 comparisons (see `string_cmp.asm`).

* **Syscall invocation** to perform `NtWriteFile` and `NtTerminateProcess` without CRT (see `main.asm`).

* **Build automation** via `make.bat` for assembling and linking with gcc.

---

## Prerequisites

* Windows x64 (Windows 10/11)
* [NASM](https://www.nasm.us/) assembler
* GCC (Or any other linker for windows) 


---

## Project Structure

```
├── peb.asm           ; Locate ntdll.dll base via PEB
├── pe.asm            ; Parse PE export directory & resolve function names
├── string_cmp.asm    ; utf16 ↔ utf8 and utf8 ↔ utf8 string compare routines
├── main.asm          ; Entry point: find syscalls & write "Hello World!"
└── make.bat          ; Build script (assemble & link)
```

---

## Building the Project

- Run the build script:

   ```bat
   make.bat
   ```

If you prefer manual steps:

```bat
nasm -f win64 peb.asm -o peb.obj
nasm -f win64 pe.asm -o pe.obj
nasm -f win64 string_cmp.asm -o string_cmp.obj
nasm -f win64 main.asm -o main.obj


gcc peb.o pe.o main.o string_cmp.o -nostdlib -ffreestanding -fno-builtin -Wl,-e,_start -static -s -o HelloWorld.exe
```

---


## File Descriptions

* **peb.asm**
  Implements `get_ntdll_base`. Walks the PEB loader data list to locate the base address of `ntdll.dll`.

* **pe.asm**
  Provides `get_export_directory` to retrieve the `IMAGE_EXPORT_DIRECTORY` of a module and `find_function_by_name` to search exports by ASCII name and return function addresses.

* **string\_cmp.asm**
  Contains two utilities:

  * `utf8_utf8_cmp`: Compare two UTF-8 encoded strings.
  * `utf16_utf8_cmp`: Compare a UTF-16 (wchar) string against a UTF-8 string.

* **main.asm**
  Entry point `_start`. Uses the above routines to resolve the syscall numbers for `NtWriteFile` and `NtTerminateProcess`, invokes them via `syscall`, prints a message, and exits.

* **make.bat**
  Batch script automating NASM assembly and linking steps on Windows x64.

---

## Contributing

Contributions, issues, and feature requests are welcome. Feel free to open a GitHub issue or submit a pull request.

---

## License

This project is released under the MIT License. See `LICENSE` for details.
