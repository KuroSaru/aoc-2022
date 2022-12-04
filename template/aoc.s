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

	#exit(0)
	mov $60, %rax
	xor %rdi,%rdi
	syscall
