	.global _start
	.data

testString:
	.ascii "test\n"

	.text
_start:
	#write(1, message, 13)
	mov $1, %rax
	mov $1, %rdi
	mov $testString, %rsi
	mov $13, %rdx
	syscall

	
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
