.data
	m: .long 0
	n: .long 0
	m2: .long 0
	n2: .long 0
	p: .long 0
	k: .long 0
	mat: .space 500
	mat_updt: .space 500
	format_scanf: .asciz "%ld"
	format_printf: .asciz "%ld "
	format_printf_eol: .asciz "%ld \n"
	in: .asciz "in.txt"
	out: .asciz "out.txt"
	in_mode: .asciz "r"
	out_mode: .asciz "w"
	file_ptr_in: .long 0
	file_ptr_out: .long 0
.text
read_input:
	# setup_stack:
		push %ebp
		mov %esp, %ebp
		sub $8, %esp	
	
	# read_m:
		push $m
		push $format_scanf
		push file_ptr_in
		call fscanf
		add $12, %esp
		mov m, %edx
		movl %edx, m2
		addl $2, m
		
	# read_n:
		push $n
		push $format_scanf
		push file_ptr_in
		call fscanf
		add $12, %esp
		mov n, %edx
		movl %edx, n2
		addl $2, n
	
	# read_p:	
		push $p
		push $format_scanf
		push file_ptr_in
		call fscanf
		add $12, %esp
	
	cmpl $0, p
	je read_k
	xor %ecx, %ecx
	read_cells:
		push %ecx
		
		lea -4(%ebp), %eax
		# read_line:
			push %eax	
			push $format_scanf
			push file_ptr_in
			call fscanf
			add $12, %esp		

		lea -8(%ebp), %eax
		# read_row:
			push %eax	
			push $format_scanf
			push file_ptr_in
			call fscanf
			add $12, %esp

		# det_offset:
			addl $1, -4(%ebp)
			mov -4(%ebp), %eax
			mull n
			addl $1, -8(%ebp)
			add -8(%ebp), %eax

		# set_cell:
			lea mat, %edi
			xor %edx, %edx
			mov $1, %dl
			mov %dl, (%edi, %eax, 1)
		
		pop %ecx
		inc %ecx
		cmp p, %ecx
		jne read_cells
	
	read_k:	
		push $k
		push $format_scanf
		push file_ptr_in
		call fscanf
		add $12, %esp
	
	# reset_stack:	  
		add $8, %esp
		pop %ebp
		ret

gol:
	# setup_stack:
		push %ebp
		mov %esp, %ebp
		push %esi
		push %edi
		sub $8, %esp	# -4, -8 l, c 
				
	# set_locals:
		movl $1, -4(%ebp)
		movl $1, -8(%ebp)
		
	update:
		# det_offset:
			lea mat, %esi
			mov -4(%ebp), %eax
			mull n
			add -8(%ebp), %eax
			add %eax, %esi	
			
			lea mat_updt, %edi
			push %eax
			mov -4(%ebp), %eax
			mull n2
			add -8(%ebp), %eax
			add %eax, %edi
			pop %eax
			
		
		# cnt_neighb:
			jmp check_neighb
			inc_counter:
				cmpb $1, (%esi)
				jne not_neighb
				neighb:
					inc %ecx
					ret
				not_neighb:
					ret		
			
			check_neighb:
				xor %ecx, %ecx	
				subl $1, %esi
				call inc_counter
				subl n, %esi
				call inc_counter
				addl $1, %esi
				call inc_counter
				addl $1, %esi
				call inc_counter
				addl n, %esi
				call inc_counter
				addl n, %esi
				call inc_counter
				subl $1, %esi
				call inc_counter
				subl $1, %esi
				call inc_counter
			
			addl $1, %esi
			subl n, %esi
		
		# update_cell:
			mov (%esi), %dl
			cmp $1, %dl
			jne dead
			alive:
				cmp $2, %ecx
				jl die
				survive_maybe:
				cmp $3, %ecx
				jg die
				movb $1, (%edi)
				jmp goto_next
				die:
					movb $0, (%edi)
					jmp goto_next
			dead:
				cmp $3, %ecx
				je born
				end_dead:
					jmp goto_next
				born:
					movb $1, (%edi)
					jmp goto_next
			
		goto_next:
			# bounds_check:
				mov n2, %eax
				cmp %eax, -8(%ebp)
				jl next_col
				next_line:
					mov m2, %eax
					cmp %eax, -4(%ebp)
					jge end_cycle
					addl $1, -4(%ebp)
					movl $1, -8(%ebp)
					jmp update 
				 next_col:
					addl $1, -8(%ebp)
					jmp update
	
	end_cycle:				
	# set_locals:
		movl $1, -4(%ebp)
		movl $1, -8(%ebp)

	copy:
		# det_offset:
			lea mat, %edi
			mov -4(%ebp), %eax
			mull n
			add -8(%ebp), %eax
			add %eax, %edi	
			
			lea mat_updt, %esi
			push %eax
			mov -4(%ebp), %eax
			mull n2
			add -8(%ebp), %eax
			add %eax, %esi
			pop %eax
			
		# copy_cell:
			mov (%esi), %dl
			mov %dl, (%edi)	
		u_goto_next:
			# bounds_check:
				mov n2, %eax
				cmp %eax, -8(%ebp)
				jl u_next_col
				u_next_line:
					mov m2, %eax
					cmp %eax, -4(%ebp)
					jge end_gol
					addl $1, -4(%ebp)
					movl $1, -8(%ebp)
					jmp copy 
				 u_next_col:
					addl $1, -8(%ebp)
					jmp copy
				
	end_gol:
	# reset_stack:	  
		add $8, %esp
		pop %edi
		pop %esi
		pop %ebp
		ret

print_output:
 	# setup_stack:
		push %ebp
		mov %esp, %ebp
		push %esi
		sub $8, %esp	# -4, -8 l, c 
				
	# set_locals:
		movl $1, -4(%ebp)
		movl $1, -8(%ebp)
	
	cmpl $0, k
	je print_og
	
	print:
		# det_offset:
			lea mat_updt, %esi
			push %eax
			mov -4(%ebp), %eax
			mull n2
			add -8(%ebp), %eax
			add %eax, %esi
			pop %eax
				
		p_goto_next:
			# bounds_check:
				mov n2, %eax
				cmp %eax, -8(%ebp)
				jl p_next_col
				p_next_line:
					xor %edx, %edx
				    mov (%esi), %dl
					push %edx
					push $format_printf_eol
					push file_ptr_out
					call fprintf
					add $12, %esp
					mov m2, %eax
					cmp %eax, -4(%ebp)
					jge end_print	
					addl $1, -4(%ebp)
					movl $1, -8(%ebp)
					jmp print 
				p_next_col:
					xor %edx, %edx
					mov (%esi), %dl
					push %edx
					push $format_printf
					push file_ptr_out
					call fprintf
					add $12, %esp
					addl $1, -8(%ebp)
					jmp print

	print_og:
		# det_offset:
			lea mat, %esi
			mov -4(%ebp), %eax
			mull n
			add -8(%ebp), %eax
			add %eax, %esi
			
		p_og_goto_next:
			# bounds_check:
				mov n2, %eax
				cmp %eax, -8(%ebp)
				jl p_og_next_col
				p_og_next_line:
					xor %edx, %edx
				    mov (%esi), %dl
					push %edx
					push $format_printf_eol
					push file_ptr_out
					call fprintf
					add $12, %esp
					mov m2, %eax
					cmp %eax, -4(%ebp)
					jge end_print	
					addl $1, -4(%ebp)
					movl $1, -8(%ebp)
					jmp print_og 
				p_og_next_col:
					xor %edx, %edx
					mov (%esi), %dl
					push %edx
					push $format_printf
					push file_ptr_out
					call fprintf
					add $12, %esp
					addl $1, -8(%ebp)
					jmp print_og
						
	end_print:
		# reset_stack:	  
			add $8, %esp
			pop %esi
			pop %ebp
			ret

.global main
main:
	push $in_mode
	push $in
	call fopen
	add $8, %esp
	mov %eax, file_ptr_in
	push $out_mode
	push $out
	call fopen
	add $8, %esp
	mov %eax, file_ptr_out
	call read_input
	cmpl $0, k
	je print_result
	mov k, %ecx
	gol_loop:
		push %ecx
		call gol
		pop %ecx
		loop gol_loop
	print_result:
		call print_output
		pushl $0
		call fflush
		add $4, %esp
	bye:
		push file_ptr_in
		call fclose
		add $4, %esp
		push file_ptr_out
		call fclose
		add $4, %esp	
		mov $1, %eax
		mov $0, %ebx
		int $0x80
