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
	format_scanf_str: .asciz "%s"
	format_printf: .asciz "%ld "
	format_printf_hex: .asciz "%02X"
	format_printf_hex_start: .asciz "0x%02X"
	format_printf_eol: .asciz "%ld\n"
	c_flag: .long 0
	string: .space 30

.text
read_input:
	# setup_stack:
		push %ebp
		mov %esp, %ebp
		sub $8, %esp	
	
	# read_m:
		push $m
		push $format_scanf
		call scanf
		add $8, %esp
		mov m, %edx
		movl %edx, m2
		addl $2, m
		
	# read_n:
		push $n
		push $format_scanf
		call scanf
		add $8, %esp
		mov n, %edx
		movl %edx, n2
		addl $2, n
	
	# read_p:	
		push $p
		push $format_scanf
		call scanf
		add $8, %esp
	
	cmpl $0, p
	je read_k
	xor %ecx, %ecx
	read_cells:
		push %ecx
		
		lea -4(%ebp), %eax
		# read_line:
			push %eax	
			push $format_scanf
			call scanf
			add $8, %esp		

		lea -8(%ebp), %eax
		# read_row:
			push %eax	
			push $format_scanf
			call scanf
			add $8, %esp

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
		call scanf
		add $8, %esp

	read_flag:	
		push $c_flag
		push $format_scanf
		call scanf
		add $8, %esp

	read_str:	
		push $string
		push $format_scanf_str
		call scanf
		add $8, %esp

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
					call printf
					add $8, %esp
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
					call printf
					add $8, %esp
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
					call printf
					add $8, %esp
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
					call printf
					add $8, %esp
					addl $1, -8(%ebp)
					jmp print_og
						
	end_print:
		# reset_stack:	  
			add $8, %esp
			pop %esi
			pop %ebp
			ret

xor_crypt:
	# setup_stack:
        push %ebp
        mov %esp, %ebp
		push %esi
        push %edi
		push %ebx
        sub $4, %esp    # -4 poz in cheie
 
	cmpl $0, c_flag
	je apply_key 
	convert_hex:
		lea string, %esi
		add $2, %esi
		lea string, %edi
		xor %edx, %edx
		start_conv:
			mov $2, %ecx
			loopin:
				cmpb $0, (%esi)
				je add_null
				xor %eax, %eax
				mov (%esi), %al
				cmp $65, %eax
				jl num
			char:
				sub $55, %eax
				jmp merge
			num:		
				sub $48, %eax
			merge:
				add %eax, %edx
				cmp $16, %edx
				jge place_char
				shl $4, %edx
				add $1, %esi
				loop loopin
				jmp start_conv	
		place_char:
			mov %dl, (%edi)
			xor %edx, %edx
			add $1, %esi
			add $1, %edi
			jmp start_conv
	add_null:
		movb $0, (%edi)
	apply_key:	
		lea string, %edi
		mov n, %eax
		mull m
		lea mat, %esi
		movl $0, -4(%ebp)	
		build_key_byte:
			mov $8, %ecx
			xor %ebx, %ebx	
			enc_goto_next:
				cmp %eax, -4(%ebp)
				jl cont
				mat_begin:
					lea mat, %esi
					movl $0, -4(%ebp)
				cont:
					mov (%esi), %dl
					sub $1, %ecx
					shl %ecx, %dl
					add %dl, %bl
					addl $1, -4(%ebp)
					addl $1, %esi
					cmp $0, %ecx
					jg enc_goto_next
						
		key_end:
			cmpb $0, (%edi)
			je end_enc
			xor %bl, (%edi)
			add $1, %edi
			jmp build_key_byte
		
		end_enc:		
		# reset_stack:	  
			add $4, %esp
			pop %ebx
			pop %edi
			pop %esi
			pop %ebp
			ret

.global main
main:
	call read_input
	cmpl $0, k
	je comp
	mov k, %ecx
	gol_loop:
		push %ecx
		call gol
		pop %ecx
		loop gol_loop
	comp:
		call xor_crypt  	
		lea string, %eax	
		cmpl $1, c_flag
		jne print_result_0
	print_result_1:
		push $string
		push $format_scanf_str
		call printf
		add $8, %esp
		push $0
		call fflush
		add $4, %esp
		jmp bye
	print_result_0:
		cmpl $0, (%eax)
		je bye
		xor %ebx, %ebx
		movb (%eax), %bl
		push %eax
		push %ebx
		push $format_printf_hex_start
		call printf
		add $8, %esp
		pop %eax
		add $1, %eax
		cmpl $0, (%eax)
       	je flush
		loopie:
			xor %ebx, %ebx
			movb (%eax), %bl
			push %eax
			push %ebx
			push $format_printf_hex
			call printf
			add $8, %esp
			pop %eax
			add $1, %eax
			cmpl $0, (%eax)
        	jne loopie
		flush:
			pushl $0
			call fflush
			add $4, %esp
	bye:
		mov $1, %eax
		mov $0, %ebx
		int $0x80
