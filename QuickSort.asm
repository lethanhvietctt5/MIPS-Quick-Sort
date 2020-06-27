.data
array: .space 4000
before: .asciiz "before sort: "
after: .asciiz "after sort: "
space: .asciiz " "
fileName: .asciiz "input.txt"
fileOutput: .asciiz "output.txt"
newline : .asciiz "\n"
buffer: .asciiz ""
number: .asciiz ""
.text
.globl main
main:
	# open file
	jal openFileToRead
	# read file
	jal readFile

	move $s0,$v0
	li $v0,16
	move $a0,$s0
	syscall

	# pointer to buffer 
	la $t0, buffer
	li $t3,0
	li $t2,0

	#get N (N is number of element) and array positive integer
	jal getN
	sub $v1,$t5,1	
	jal getArr

	# print array before sort
	add $t5,$v1,1	# t5 = number of array
	li $t0,0
	la $t4,array
	jal printArr
	
	# quickSort
	la $t0, array
	add $a0,$t0,$0
	li $a1,0
	add $a2,$0,$v1
	jal quickSort

	jal newLine
	# print array after sort
	li $t0,0
	la $t4,array
	jal printArr

	# convert array to string and write to file
	la $t4,array
	li $t2,0
	la $t6,number

	li $v0,13
	la $a0,fileOutput
	li $a1,1
	li $a2,0
	syscall
	move $s1,$v0

	jal convertToString

	li $v0,16
	move $a0,$s1
	syscall

	# end program
	li $v0,10
	syscall

openFileToRead:
	li $v0,13
	la $a0,fileName
	li $a1,0
	li $a2,0
	syscall
	move $s0,$v0
readFile:
	li $v0,14
	move $a0,$s0
	la $a1,buffer
	li $a2,4000
	syscall
newLine:
	li $v0,4
	la $a0,newline
	syscall
	jr $ra
getN:
	lb $t1,($t0)
	sub $t1,$t1,'0'
	blt $t1,0,exitGetN
	bgt $t1,9,exitGetN
	
	li $t4,10
	mul $t2,$t2,$t4
	add $t2,$t2,$t1
	addi $t0,$t0,1
	b getN
exitGetN: 
	move $t5, $t2
	li $t2,0
	addi $t0,$t0,2	# add 2 to ignore /r/n in file
	jr $ra
getArr:
	lb $t1,($t0)
	sub $t1,$t1,48
	addi $t0,$t0,1
	blt $t5,0,end
	blt $t1,0,continue
	bgt $t1,9,continue
	
	li $t4,10
	mul $t2,$t2,$t4
	add $t2,$t2,$t1
	b getArr
continue:
	sw $t2,array($t3)
	sub $t5,$t5,1
	addi $t3,$t3,4
	li $t2,0
	b getArr
end:
	sw $t2,array($t3)
	li $t2,0
	jr $ra
printArr:
	bge $t0,$t5,endprint
	li $t9,4
	mul $t2,$t0,$t9
	add $t2,$t2,$t4
	lw $a0, ($t2)
	li $v0,1
	syscall
	la $a0,space
	li $v0,4
	syscall
	add $t0,$t0,1
	b printArr
endprint:
	jr $ra

swap:
	li $t9,4
	mult $a1,$t9
	mflo $t1
	add $t1,$t1,$a0	# t1 = arr + 4i
	lw $s1,($t1)	# s1 = arr[i]
	
	mult $a2,$t9
	mflo $t2
	add $t2,$t2,$a0
	lw $s2,($t2)	# s2 = arr[j]
	
	sw $s1,($t2)
	sw $s2,($t1)
	jr $ra
quickSort:
	sub $sp,$sp,16
	sw $a0,($sp) # store a0 (ao point to array)
	sw $a1,4($sp)	# store a1 (a1 = left)
	sw $a2,8($sp)	# store a2 (a2 = right)
	sw $ra,12($sp)

	bgt $a1,$a2,endQS

	li $t9,4
	mult $a2,$t9
	mflo $t3
	add $t3,$t3,$a0
	lw $s3,($t3)	# s3 = arr[right] = pivot
	Loop:
		bge $a1,$a2,end_If
		loop_for_less:
			mult $a1,$t9
			mflo $t3
			add $t3,$t3,$a0
			lw $s4,($t3)	# s4 = arr[i]
			bge $s4,$s3,end_loop_1
			add $a1,$a1,1
			j loop_for_less
		end_loop_1:
			j loop_for_greater
		loop_for_greater:
			mult $a2,$t9
			mflo $t3
			add $t3,$t3,$a0
			lw $s4,($t3)	# s4 = arr[j]
			ble $s4,$s3,end_loop_2
			sub $a2,$a2,1
			j loop_for_greater
		end_loop_2:
			bgt $a1,$a2,end_if_1
			jal swap
			add $a1,$a1,1
			sub $a2,$a2,1
			j Loop
		end_if_1:
			j Loop
	end_If:
		move $t7,$a1	# t7 = i
		move $t8,$a2	# t8 = j
		lw $a1,4($sp)
		lw $a2,8($sp)
		bge $a1,$t8, sort_rest_arr
		move $a2,$t8
		jal quickSort
		j sort_rest_arr
	sort_rest_arr:
		lw $a1,4($sp)
		lw $a2,8($sp)
		ble $a2,$t7,endQS
		move $a1,$t7
		jal quickSort
endQS:
	lw $a0,($sp)
	lw $a1,4($sp)
	lw $a2,8($sp)
	lw $ra,12($sp)
	add $sp,$sp,16
	jr $ra

convertToString:
	beq $t5,$zero,exitConvert
	li $t9,4
	mult $t2,$t9
	mflo $t3
	add $t3,$t3,$t4
	lw $s3,($t3)
	move $s4,$s3
	li $s5,0
	size:
		add $s5,$s5,1
		div $s3,$s3,10
		beq $s3,$zero,exitCountSize
		b size
	exitCountSize:
		move $s3,$s4
		j convert
	convert:
		beq $s5,$zero,repeat
		li $t9,1
		sub $t7,$s5,1
		multiply10th:
			beq $t7,$zero,exitmultiply
			li $t8,10
			mul $t9,$t9,$t8
			sub $t7,$t7,1
			b multiply10th
		exitmultiply:
			div $s3,$t9
			mflo $s2
			mfhi $s3
			add $s2,$s2,48
			sb $s2,($t6)
			li $v0,15
			move $a0,$s1
			la $a1,($t6)
			li $a2,1
			syscall
			add $t6,$t6,1
			sub $s5,$s5,1
			b convert
	repeat:
		add $t2,$t2,1
		sub $t5,$t5,1
		li $v0,15
		move $a0,$s1
		la $a1,space
		li $a2,1
		syscall
		j convertToString
exitConvert:
	jr $ra
