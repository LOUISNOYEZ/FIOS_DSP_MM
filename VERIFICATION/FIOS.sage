import math
import random

def FIOS(n, a, b, w = 17, WIDTH = 256):

	# WIDTH is taken to be the width of n and the operands plus 2
	# in order for intermediate results to be contained without
	# having to perform the final subtraction of the Montgomery Multiplication
	WIDTH = WIDTH + 2
	
	# s is the number of blocks of width w required to slice operands
	s = (WIDTH-1)//w + 1
	
	W = 2**w
	
	R = 2**(s*w)
	R_inv = inverse_mod(R, n)
	
	n_prime_0 = inverse_mod(-n, R) % W
	
	a_arr = [(a >> (i*w)) % W for i in range(s)]
	b_arr = [(b >> (i*w)) % W for i in range(s)]
	n_arr = [(n >> (i*w)) % W for i in range(s)]
	
	res_arr = s*[0]
	
	for i in range(s):
		
		# The outer loop scans the a operand.
		# the least significant block of the result is processed
		# and reduced at the beginning of each iterations
		
		res_arr[0] += a_arr[i]*b_arr[0]
		
		m = res_arr[0]*n_prime_0 % W
		
		res_arr[0] += m*n_arr[0]
		res_arr[0] = res_arr[0] >> w
		
		for j in range(1, s):
		
			# The inner loop scans the b operand.
			# The remaining blocks are processed in this loop.
		
			res_arr[j-1] += a_arr[i]*b_arr[j] + m*n_arr[j] + res_arr[j]
			
			res_arr[j] = res_arr[j-1] >> w
			res_arr[j-1] = res_arr[j-1] % W
			
	
	return res_arr, n_prime_0
	
	
if __name__ == "__main__":

	# Running this file will test one random set of inputs fed to the FIOS function

	WIDTH = 256

	n = random_prime(2**WIDTH, False, 2**(WIDTH-1))
	
	print("WIDTH : ", WIDTH)
	
	a = random.randrange(2**(WIDTH-1), n)
	b = random.randrange(2**(WIDTH-1), n)
	

	WIDTH = WIDTH + 2

	w = 17
	
	s = (WIDTH-1)//w + 1

	R = 2**(s*w)
	R_inv = inverse_mod(R, n)
	

	verif = a*b*R_inv % n

	res_arr = FIOS(n, a, b, w, WIDTH = WIDTH)[0]

	res = 0
	for i in range(len(res_arr)):
	
		res += res_arr[i] << (i*w)
		
	print("n : ", hex(n), "\na : ", hex(a), "\nb : ", hex(b))
	
	print("\ntest  : ", hex(res), "\nverif : ", hex(verif), "\nmatch : ", res == verif)
