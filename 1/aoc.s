	.global _start

.bss
	.lcomm buffer, 1024

	.data
filename:
	.asciz "input"

strTitle:
	.ascii "Advent of Code: 1\n\0"
strFOpenOK:
	.asciz "syscall Open() successful.\n\0"
strFOpenError:
	.asciz "syscall Open() failed.\n\0"
buff:
	.string	""
strEOF:
	.string "EOF!\n\0"
strDone:
	.string "Highest Elf Cals is: \0"
strDone1:
	.string "3 Highest Elf Cals is: \0"
strDone2:
	.string "Combined 3 Highest is: \0"
BElf2:
	.quad 0
BElf1:
	.quad 0
BElf:
	.quad 0
CElf:
	.quad 0
sum:
	.quad 0
count:
	.quad 0
fHandle:
	.quad 1

.text

#-------------------------------------
_start:

	#//open file (handle reutnred in rax)
	movq $2, %rax #//syscall 2 = open
	movq $filename, %rdi
	movq $0, %rsi
	movq $0666, %rdx
	syscall

	cmp $0, %rax
	#// if (rax == 0) { 
	jl start_bad 

	#// } else {
	#//store file handle
	mov %rax, fHandle
	movq $strFOpenOK, %rax
	#//call .print

	mov $0, %rdx
	mov %rdx, count

	#// start parse loop
	start_read_loop:
		#// read(rdi:file, rsi:buffer, rdx:size) - return rax;
		movq $0, %rax  #//syscall 0 = read
		movq (fHandle), %rdi #//fd
		movq $buff, %rsi #//&buff
		movq $1, %rdx #//size
		syscall

		#//if rax < 0 then error.
		cmp $0, %rax
		jl start_bad

		#//if rax > 1 then good. else eof?
		cmp $1, %rax
		jl start_eof

		mov (buff), %rcx
		mov $0, %rbx
		mov %cl, %bl

		cmp $'\n', %bl
		je start_read_eol

		mov count, %rdx
		inc %rdx
		mov %rdx, count

		sub $'0', %bl
		mov sum, %rax
		imul $10, %rax
		add %rbx, %rax
		mov %rax, sum
		jmp start_read_loop

		start_read_eol:
			mov count, %rax
			cmp $0, %rax
			je start_new_elf

			mov sum, %rax
			mov CElf, %rbx
			add %rbx, %rax
			mov %rax, CElf
			mov $0, %rdx
			mov %rdx, count
			mov $0, %rdx
			mov %rdx, sum
			jmp start_read_loop

		start_new_elf:
			mov CElf, %rax

			#// CElf > BElf2?
			mov BElf2, %rbx
			cmp %rax, %rbx
			jg start_new_elf_test2
			mov %rax, BElf2

			#// CElf > BElf1?
			start_new_elf_test2:
			mov BElf1, %rbx
			cmp %rax, %rbx
			jg start_new_elf_test3
			mov %rax, BElf1
			mov %rbx, BElf2

			 #// CElf > BElf?
			start_new_elf_test3:
			mov BElf, %rbx
			cmp %rax, %rbx
			jg start_new_elf_test4
			mov BElf1, %r14
			mov %rax, BElf
			mov %rbx, BElf1
			mov %r14, BElf2

			start_new_elf_test4:
			mov $0, %rdx
			mov %rdx, CElf
			jmp start_read_loop

	start_eof:
		mov $strDone, %rax
		call .print

		movq BElf, %rax
		call .printint
		call .printnl

		mov $strDone1, %rax
		call .print

		movq BElf, %rax
		call .printint
		call .printspace

		movq BElf1, %rax
		call .printint
		call .printspace

		movq BElf2, %rax
		call .printint
		call .printnl

		mov $strDone2, %rax
		call .print

		mov $0, %rax
		add BElf, %rax
		add BElf1, %rax
		add BElf2, %rax
		call .printint
		call .printnl


		#// close(fd);
		movq $3, %rax  #//syscall 3 = close
		movq (fHandle), %rdi #//fileDescriptor
		syscall

		jmp start_end

	start_bad:
		movq $strFOpenError, %rax
		call .print

	start_end:
		call .exit

#-------------------------------------
.len: #// string:rax; return:rax
	#//rebase stack
	pushq %rbp
	movq %rsp, %rbp

	#//move rax to rdi
	movq %rax, %rdi
	movq $0, %rsi

	#//set counter to inverse(0)
	xor %rcx, %rcx
	not %rcx

	xor %rax, %rax
	cld
	#//compare each char in rdi to value in %al
	repne scasb  
	not %rcx

	#//reset stack
	popq %rbp
	lea -1(%rcx), %rax
	ret

#-------------------------------------
.printnl: #// ret: none
	pushq %rbp
	movq %rsp, %rbp

	movq $0x0a, buff

	movq $1, %rax #//syscall 1 = write
	movq $1, %rdi
	movq $buff, %rsi
	movq $1, %rdx
	syscall

	popq %rbp
	ret

#-------------------------------------
.printspace: #// ret: none
	pushq %rbp
	movq %rsp, %rbp

	movq $0x20, buff

	movq $1, %rax #//syscall 1 = write
	movq $1, %rdi
	movq $buff, %rsi
	movq $1, %rdx
	syscall

	popq %rbp
	ret

#------------------------------------
.printint: #// int:rax; ret: none
	pushq %rbp
	pushq %r12
	movq %rsp, %rbp

	cmp $0, %rax
	je printint_end
	mov %rax, %r12

	mov $0, %rdx
	mov $10, %rcx
	idivq %rcx
	call .printint

	mov $0, %rdx
	mov %r12, %rax
	mov $10, %rcx
	idivq %rcx
	mov %rdx, %rax
	add $'0', %rax

	movq %rax, buff

	movq $1, %rax #//syscall 1 = write
	movq $1, %rdi
	movq $buff, %rsi
	movq $1, %rdx
	syscall

	printint_end:
	popq %r12
	popq %rbp
	ret

#-------------------------------------
.print: #// message:rax; len:rbx ret:none
	#//rebase stack
	pushq %rbp
	movq %rsp, %rbp

	#//movqe param1 to rbx
	movq %rax, %rbx

	#//get string len
	call .len
	movq %rax, %rcx

	#//write(rdi, rbx:message, rdx) - syscall
	movq $1, %rax #//syscall 1 = write
	movq $1, %rdi
	movq %rbx, %rsi
	movq %rcx, %rdx
	syscall

	#//reset stack
	popq %rbp
	ret

#-------------------------------------
.exit:
	# exit(0)
	movq $60, %rax
	xor %rdi,%rdi
	syscall
