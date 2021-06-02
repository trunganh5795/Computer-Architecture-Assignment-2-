#Chuong trinh: chia 2 so nguyen 32 bits
#data segment
	.data
#cac dinh nghia bien
fname:	.asciiz	"E:/bin/INT2.BIN"
buffer:	.space	8
so_bi_chia:		.word 0
so_chia:		.word 0
thuong:			.word 0
so_du:			.word 0
so_chia_ban_dau:	.word 0
so_bi_chia_ban_dau:	.word 0
#cac cau nhac nhap du lieu
nhap_sobichia:  .asciiz "So bi chia A = "
nhap_sochia: 	.asciiz "So chia B = "
Thuong: 	.asciiz "Thuong phep chia la  Quo =  "
ngoaile: 	.asciiz "error: so chia bang 0"
xuong_dong: 	.asciiz "\n"
So_du:		.asciiz "So du cua phep chia la Rem = "
#code segment
	.text
	.globl main
#--------------------------main--------------------------
# Chuong trinh chinh main
main:
#----------------------------------------------------------------
#Open file
	li	$v0, 13		#system call for open file
	la	$a0, fname	#board file name
	li	$a1, 0		#Open for reading
	li	$a2, 0
	syscall			#open a file (file descriptor returned in $v0)
	move	$s6, $v0		#save the file descriptor
#-----------------------------------------------------------------
#Read file
	li	$v0, 14		#system call for read from file
	move	$a0, $s6		#file descriptor 
	la	$a1, buffer	#address of buffer to which to read
	li	$a2, 8		#hardcoded buffer length
	syscall
#-----------------------------------------------------------------
#Nhap syscall
	la	$t1, buffer	# load buffer address 
	lw 	$a1, 0($t1)	# load & store the first integer (multiplicand) to a1

#luu vao so bi chia ban dau
	la $at, so_bi_chia_ban_dau
	sw $a1, 0($at)
	
	lw 	$a2, 4($t1)	# load & store the seccond integer (multiplier) to a2
#luu vao so chia ban dau
	la $at, so_chia_ban_dau
	sw $a2, 0($at)
	
	
#Xu ly:
#neu so chia bang 0, xuat ra ngoai le
	beq $a2 , 0, ngoai_le
	
#Tao bien dem cho chuong trinh count=0
	add $t0, $0, $0				#t0=count=0
	
#check so bi chia(a1) va so chia (a2) duong hay am
#neu a1 < 0 -> set t1 = 1, chuyen a1 ve duong
	slt $t1, $a1, $0
	beq $t1, $0, giunguyen_1
	sub $a1, $0, $a1
giunguyen_1:		
#neu a2 <0 -> set t6 = 1, chuyen a2 ve duong
	slt $t6, $a2, $0
	beq $t6, $0, giunguyen_2
	sub $a2, $0, $a2
	
giunguyen_2:

#khoi tao 32 bit thap so du bang so bi chia, 	t2= so du
	add $t2, $a1, $0
	
#khoi tao 32 bit cao so du bang 0,		t3= bit cao=0
	add $t3, $0, $0

#t6 = 0 -> 2 so cung dau, nguoc lai, khac dau

	sub $t6, $t6, $t1
#goi ham
	jal Dividend



#Xuat ket qua (syscall)
#ket qua tra ve : 
#thuong cua phep chia duoc luu vao thanh ghi v1
#so du cua phep chia duoc luu vao thanh ghi v0

#neu So bi chia va So chia cung dau thi khong doi dau ket qua
	beq $t6, $0, khong_doi_dau 	
#neu So bi chia va So chia khac dau thi doi dau ket qua
	sub $v1, $0, $v1
	
khong_doi_dau:	
#so du cung dau voi so bi chia

	lw 	$a1, so_bi_chia_ban_dau
	blt 	$0, $a1, so_bi_chia_duong
	sub 	$v0, $0, $v0
	
so_bi_chia_duong:
	move 	$t4, $v0

#Ket qua phep chia
	la	$a0, nhap_sobichia
	addi	$v0,$zero,4
	syscall
	lw	$a0, so_bi_chia_ban_dau
	addi	$v0, $zero, 1
	syscall
	li 	$v0, 4
	la 	$a0, xuong_dong
	syscall
	la	$a0,nhap_sochia
	addi	$v0,$zero,4
	syscall
	lw	$a0, so_chia_ban_dau
	addi	$v0, $zero, 1
	syscall
	li 	$v0, 4
	la 	$a0, xuong_dong
	syscall
	li 	$v0, 4
	la 	$a0, Thuong
	syscall
	
	li 	$v0, 1
	addi 	$a0, $v1, 0
	syscall
	
	li 	$v0, 4
	la 	$a0, xuong_dong
	syscall
	
	li 	$v0, 4
	la 	$a0, So_du
	syscall
	
	li 	$v0, 1
	addi 	$a0, $t4, 0
	syscall
	
	j Kthuc

#Xuat ra ngoai le khi so chia bang 0
ngoai_le: 
	li $v0, 4
	la $a0, ngoaile
	syscall
#ket thuc chuong trinh (syscall)
Kthuc:	addi	$v0,$zero,10
	syscall
#-------------------------end main--------------------------

#chuong trinh con chia 2 so nguyen 32 bits
#Input:		 a1= so bi chia, a2= so chia
#Output:	 Thuong va du cua phep chia

Dividend:
#step 1
	
	#bit thap nhat cua $t3 bang bit cao nhat cua t2
	#dich trai t3
	sll	$t3, $t3, 1
	#cong bit cao nhap cua t2 vào t3
	add	$t5, $t2, $0
	srl	$t5, $t5, 31
	add	$t3, $t3, $t5
	
	# dich trai $t2
	sll	$t2, $t2, 1
	
	
	#tru $t3=$t3-$t1 va luu vao t3
	sub 	$t3, $t3, $a2
	#check
	#neu $t3 <0  => $t3= $t3 + $t1

	add	$t5, $t3, $0
	srl	$t5, $t5, 31
	beq	$t5,1, behon_0  
	#neu $t3 >=0 => bit thap nhat cua $t2 =1	
	addi	$t2, $t2, 1
	j out
behon_0:
	add 	$t3, $t3, $a2
out:	
	#count=count+1
	#neu count=32-> exit loop 
	addi 	$t0, $t0, 1
	ble  	$t0, 31, Dividend 

	add 	$v1, $t2, $0
	add 	$v0, $t3, $0
	jr	$ra


