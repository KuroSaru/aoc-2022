bold := \033[1m
clr := \033[0m
grey := \033[0;37m
white := \033[1;37m
green := \033[0;32m
red := \033[0;31m

.PHONY: all

all:
	@echo "$(bold)$(green)GCC compiling C Code$(clr)"
	@gcc aoc-v.c -o aoc-v
	@echo "$(bold)running verification code $(clr) \n $(grey)------------------- $(clr)"
	./aoc-v
	@echo 
	@echo "$(grey)-----------------------$(clr)"
	@echo 
	@echo "$(bold)$(green)GCC compiling ASM Code$(clr)"
	@gcc -c aoc.s -O0
	@echo "$(bold)$(green)LD Linking object$(clr)"
	@ld aoc.o -o aoc
	@rm aoc.o
	@echo "$(bold)running code $(clr) \n $(grey)------------------- $(clr)"
	@echo 
	./aoc
	@echo 
	@echo "$(grey)-----------------------$(clr)"

clean:
	rm aoc
	rm aoc-v
