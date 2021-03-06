.globl decoder
.globl main

main:
decoder:
addi $sp, $sp, -36
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $s4, 16($sp)
sw $s5, 20($sp)
sw $s6, 24($sp)
sw $s7, 28($sp)
sw $ra, 32($sp)

li $v0, 5
syscall
move $s0, $v0 #s0=n

#allocate array for symbol
li $v0, 9
sll $a0, $s0, 2
syscall
move $s1, $v0
#s1 is the array for address of symbols

li $t1, 0
move $t2, $s1
decoder_loop1:
li $v0, 5
syscall
sw $v0, 0($t2)
addi $t2, $t2, 4
addi $t1, $t1, 1
bne $t1, $s0, decoder_loop1

move $s6, $s0 #$s6 is n
sll $s0, $s0, 1
addi $s0, $s0, -1 #s0=2*n-1

#allocate memory for left children
li $v0, 9
sll $a0, $s0, 2
syscall
move $s2, $v0
#s2 is the array for left children

li $t1, 0
move $t2, $s2
decoder_loop2:
li $v0, 5
syscall
sw $v0, 0($t2)
addi $t2, $t2, 4
addi $t1, $t1, 1
bne $t1, $s0, decoder_loop2

#allocate memory for right children
li $v0, 9
sll $a0, $s0, 2
syscall
move $s3, $v0
#s3 is the array for right children

li $t1, 0
move $t2, $s3
decoder_loop3:
li $v0, 5
syscall
sw $v0, 0($t2)
addi $t2, $t2, 4
addi $t1, $t1, 1
bne $t1, $s0, decoder_loop3

li $v0, 5
syscall
move $s4, $v0 
#s4 is the number of bits

#allocate memory for encrypted text
li $v0, 9
sll $a0, $s4, 2
syscall
move $s5, $v0
#s5 is the address of encrypted text

li $t8, 8
div $s4, $t8
mflo $t1
mfhi $t2
beq $t2, $zero, decoder_donplus
addi $t1, $t1, 1
decoder_donplus:

move $a0, $s5
add $s5, $s5, $t1
addi $a1, $t1, 16
addi $v0, $zero, 8
syscall


#move $t1, $s4
#decoder_loop4:
#li $v0, 12
#syscall
#sb $v0, 0($s5)
#addi $s5, $s5, 1
#addi $t1, $t1, -8
#blt $zero, $t1, decoder_loop4

addi $s5, $s5, -1 #the end of array

move $t5, $s0
addi $t5, $t5, -1 # t5 is pointer to tree

andi $t1, $s4, 0x00000007 #mod 8
beq $t1, $zero, decoder_eight_bit
addi $t1, $t1, -1
li $t3, 1
sllv $t2, $t3, $t1
j decoder_either
decoder_eight_bit:
li $t1, 7
li $t3, 1
sllv $t2, $t3, $t1
decoder_either:
lb $t4, 0($s5) #temp byte
addi $s5, $s5, -1

decoder_loop5:
and $t7, $t2, $t4
#going to left child
bne $t7, $zero, decoder_branch_right
sll $t6, $t5, 2
add $t6, $t6, $s2 # index of left child
lw $t5, 0($t6)
j decoder_branch_either
#going to right child
decoder_branch_right:
sll $t6, $t5, 2
add $t6, $t6, $s3 #index of right child
lw $t5, 0($t6)
decoder_branch_either:
ble $s6, $t5, decoder_continue
sll $t6, $t5, 2
add $t6, $t6, $s1 #index of array of symbols

lb $a0, 0($t6)
li $v0, 11
syscall
li $v0, 11
lb $a0, 1($t6)
syscall
li $v0, 11
lb $a0, 2($t6)
syscall
li $v0, 11
lb $a0, 3($t6)
syscall

move $t5, $s0
addi $t5, $t5, -1 # t5 is pointer to tree

decoder_continue:

srl $t2, $t2, 1
bne $t2, $zero, decoder_continue2
li $t2, 128
lb $t4, 0($s5) #temp byte
addi $s5, $s5, -1
j decoder_continue2_either
decoder_continue2:
decoder_continue2_either:
addi $s4, $s4, -1
bne $s4, $zero, decoder_loop5

lw $s0, 0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $s4, 16($sp)
lw $s5, 20($sp)
lw $s6, 24($sp)
lw $s7, 28($sp)
lw $ra, 32($sp)
addi $sp, $sp, 36

li $v0, 11
li $a0, 10
syscall

li $v0, 10
syscall
