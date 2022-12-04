	.global _start

	.bss
	.lcomm buffer, 1048576

	.data
filename:
	.asciz "input"

strTitle:
	.ascii "Advent of Code: 1\n\0"

strFOpenOK:
	.asciz "syscall Open() successful.\n\0"

strFOpenError:
	.asciz "syscall Open() failed.\n\0"

inputInFile:
	.string	""

inputInFileSize:
	.quad 0

offset:
	.quad 0

BElf:
	.quad 0

CElf:
	.quad 0

fHandle:
	.quad 1

.text

#-------------------------------------
_start:
	movq $strTitle, %rax
	call .print

	#//open file (handle in rax)
	movq $filename, %rax
	movq $0666, %rbx
	call .open

	cmp $0, %rax
	#// if (rax == 0) { 

	jl start_bad 

	#// } else {

	#//store file handle
	mov %rax, fHandle

	movq $strFOpenOK, %rax
	call .print

	start_read_loop:
		mov $0, %rdx
		mov %rdx, offset
		mov $fHandle, %rax
		mov $inputInFile,%rbx
		mov $1048570, %rcx
		call .read

		cmp $0, %rax
		jne start_eof
		jmp start_read_loop

	start_eof:
		mov $inputInFile, %rax
		call .len
		mov %rax, inputInFileSize

		mov $offset, %rbx
		mov $inputInFile, %rax
		call .toInt
		mov %rdx, offset

		cmp $-1, %rax
		jg add_to_CELF
			mov $CElf, %rdx
			mov $BElf, %rcx
			cmp %rdx, %rcx
			jg change_elf
				mov $0, %rcx
				mov %rcx, CElf
				jmp same_elf

			change_elf:
				mov %rdx, BElf

			same_elf:
				mov $offset, %rdx
				mov $inputInFileSize, %rcx
				cmp %rdx, %rcx
				jge elf_done

			jmp start_eof

		add_to_CELF:
			add %rax, CElf

		elf_done:
			mov $fHandle, %rax
			call .close
		#// }

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
.read: #// file:rax; Buffer:rbx; Size:rcx; ret:rax 
	#//rebase stack
	pushq %rbp
	movq %rsp, %rbp

	#//movqe params
	movq %rcx, %rdx #//Size
	movq %rbx, %rsi #//Buffer
	movq (%rax), %rdi #//fileDescriptor

	#// read(rdi:file, rsi:buffer, rdx:size) - return rax;
	movq $0, %rax  #//syscall 0 = read
	#//movq [File], %rdi
	#//movq [Buffer], %rsi
	#//movq [Size], %rdx
	syscall

	#//reset stack
	popq %rbp
	ret

#-------------------------------------
.open: #// filename:rax; perms:rbx; ret:rax
	#// return value of negative is a error
	#//rebase stack
	pushq %rbp
	movq %rsp, %rbp

	#//movqe params
	movq %rbx, %rdx #//perm
	movq %rax, %rdi #//filename

	#// open(rdi:filename, rdx:perm) - return rax;
	movq $2, %rax #//syscall 2 = open
	#//movq [filename], %rdi
	movq $0, %rsi
	#//movq [perm], %rdx
	syscall

	#//reset stack
	popq %rbp
	ret

#-------------------------------------
.close: #// file:rax; ret:none
	#//rebase stack
	pushq %rbp
	movq %rsp, %rbp

	#//movqe params
	movq (%rax), %rdi #//fileDescriptor

	#// close(rdi:file) - return none;
	movq $3, %rax  #//syscall 3 = close
	syscall

	#//reset stack
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
.toInt: #// string:rax; offset:rbx;  ret: rax
	#//rebase stack
	pushq %rbp
	movq %rsp, %rbp

	#//movqe params
	mov %rax, %rsi #//String
	add %rbx, %rsi

	mov %rbx, %rdx
	mov $0, %rbx
	mov $0, %rax

	toInt_next_char:
		mov $0, %rbx
		mov (%rsi), %bl

		cmp $'\n', %bl #//is char '\n'?
		je toInt_newline

		inc %rsi
		inc %rdx

		cmp $'0', %bl #//is char '0'?
		jb toInt_invalid_char #//jump if below
		cmp $'9', %bl #//is char '9'?
		ja toInt_invalid_char #//jump if above
		sub $'0', %bl #//lazy convert

		imul $10, %rax
		add %rbx, %rax
		jmp toInt_next_char

	toInt_newline:
		mov $-1, %rax
		inc %rdx

	toInt_invalid_char:
		#//reset stack
		popq %rbp
		ret

#-------------------------------------
.exit:
	# exit(0)
	movq $60, %rax
	xor %rdi,%rdi
	syscall
