.global _start


.bss
	.lcomm ScoreMatrix, 1024

.data

	filename: .asciz "input"
	testString: .ascii "test\n"
	strDone: .asciz "My Score: \0"
	fd: .quad 1
	score: .quad 0
	buff: .asciz "                "

.text
_start:
	#//prep score matrix
	mov $0x01030804, %rax
	mov %rax, ScoreMatrix
	mov $0x02070905, %rax
	mov %rax, ScoreMatrix+4
	mov $0x10000006, %rax
	mov %rax, ScoreMatrix+8
	call Calc

	#//prep score matrix for round 2
	mov $0x01080403, %rax
	mov %rax, ScoreMatrix
	mov $0x06020905, %rax
	mov %rax, ScoreMatrix+4
	mov $0x10000007, %rax
	mov %rax, ScoreMatrix+8
	call Calc

	call .exit

Calc:
	#//open file (handle reutnred in rax)
	movq $2, %rax #//syscall 2 = open
	movq $filename, %rdi
	movq $0, %rsi
	movq $0666, %rdx
	syscall

	#// if (rax == 0) { 
	cmp $0, %rax
	jl start_bad 

	#// } else {
	#//store file handle
	mov %rax, fd

	xor %rax, %rax
	movq %rax, score

	start_readloop:
		#// Loop read 4 bytes from input.
		movq $0, %rax  #//syscall 0 = read
		movq (fd), %rdi #//fd
		movq $buff, %rsi #//&buff
		movq $4, %rdx #//size
		syscall

		#//if rax < 0 then error.
		cmp $0, %rax
		jl start_bad

		#//if rax > 1 then good. else eof?
		cmp $1, %rax
		jl start_read_eof

		xor %rbx, %rbx 	  #// empty rbx
		mov (buff), %rcx  #// move buff to rcx

		mov %cl, %bl	  #// get O value
		cmp $0x0a, %bl	  #// check if at end of file
		je start_read_eof

		sub $0x41, %rbx    #// convert to 0,1,2
		imul $3, %rbx
		mov %rbx, %r13

		shr $16, %rcx	  #//move to 3rd byte
		mov %cl, %bl      #// get M value
		sub $0x58, %rbx   #// convert to 0,1,2
		mov %rbx, %r14

		#// Get Score: ScoreMatrix + O + M
		add %r14, %r13
		mov %r13, %rbx
		mov $ScoreMatrix, %rax
		mov (%rax, %rbx), %rax
		mov $0, %rbx
		mov %al, %bl

		mov score, %rax
		add %rbx, %rax
		mov %rax, score

		jmp start_readloop

	start_read_eof:
		#//print stuff here
		mov $strDone, %rax
		call .print

		movq score, %rax
		call .printint
		call .printnl
		ret

	start_bad:
		ret

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
