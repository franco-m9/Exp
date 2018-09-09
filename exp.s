# Franco Marcoccia - 7/19/2018
# exp.s - function exp and driver to test number e using doubles
# Register use:
#	$f0 for result returned
#	$f12 for double precision parameter
#	$f20, $22, $f24, $f26 for even floating point math calculations
#	$s0, $s1 for counters of x and n
#	$t0 for arithmetic
exp:	
	addi	$sp, $sp, -12		# save values on stack
	sw	$s0, 8($sp)
	sw	$s1, 4($sp)
	sw	$ra, 0($sp)

	mov.d	$f20, $f12		# for later absolute value of $f12

	li	$s0, 1			# load counter at 1
	li	$t0, 1				
	l.d	$f0, one		# result starting at 1.0
	abs.d	$f12, $f12		# get the absolute value from the start

eloop:	
	li	$s1, 0			# counter starting at 0
	l.d	$f22, one		# double of 1.0
	j	loop2
	

loop2:	beq	$s0, $s1, eexit		# if counters match, go to next portion
	mul.d	$f22, $f12, $f22	# inputed value * initial 1.0
	add	$s1, $s1, $t0		# add one to counter
	mtc1.d	$s1, $f24
	cvt.d.w	$f24, $f24
	div.d	$f22, $f22, $f24	# x/1 ... x^2/2! ...
	j	loop2

eexit:	l.d	$f24, min		# used to check the minimum value
	div.d	$f26, $f22, $f0
	c.lt.d	$f26, $f24
	bc1t	expe
	add.d	$f0, $f0, $f22		# adds double's
	add	$s0, $s0, $t0		# add 1 to counter
	j	eloop

expe:	lw	$ra, 0($sp)		# restore stack
	lw	$s1, 4($sp)
	lw	$s0, 8($sp)
	addi	$sp, $sp, 12
	l.d	$f12, zero
	c.lt.d	$f26, $f20		# to deal with negative #'s
	bc1f	eopp
	jr	$ra			# back to calling

eopp:	l.d	$f12, one		# inverse x
	div.d	$f0, $f12, $f0		# inverse x
	jr	$ra			# back to calling
	

main:	la	$a0, intro		# display into message
	li	$v0, 4
	syscall
loop:
	la	$a0, req		# asks for values until 999
	li	$v0, 4
	syscall

	li $v0, 7
	syscall

	l.d	$f12, stop
	
	c.eq.d 	$f0, $f12		# if input = 999 , end
	bc1t	end

	la	$a0, beg		# first part of messagee
	li	$v0, 4
	syscall

	li	$v0, 3
	mov.d	$f12, $f0
	syscall

	la	$a0, next		# next part of message
	li	$v0, 4
	syscall

	jal exp				# jump to function

	li	$v0, 3
	mov.d	$f12, $f0		# move to display parameter
	syscall

	j	loop

end:
	la	$a0, done		# display ending message
	li	$v0, 4
	syscall

	li	$v0, 10			# exit program
	syscall
	
	.data
intro:	.asciiz "Let's test our exponential function!"
req:	.asciiz "\nEnter a value for x (or 999 to exit): "
beg:	.asciiz "Our approximation for e^"
next:	.asciiz " is "
done:	.asciiz "Come back soon!"
zero:	.double 0.0
one:	.double 1.0
stop:	.double 999.0
min:	.double 1.0e-15