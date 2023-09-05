import argparse
import random
import os
from FIOS import FIOS

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description = "Generate test FIOS test vectors.")
	parser.add_argument("-w", metavar = "WIDTH", type = int, default = 256,
						help = "Bit-width of the test vectors.")
	parser.add_argument("-n", metavar = "NUMBER", type = int, default = None,
						help = "Number of test vectors.")
	parser.add_argument ("-ww", metavar = "WORD WIDTH", type = int, default = 17,
	                    help = "Word width.")
	parser.add_argument("--name", metavar = "FILE NAME", type = str, default = None,
						help = "Name of test vector file. Default : sim_<WIDTH>")
						
	args = parser.parse_args()

	w = args.ww

	WIDTH = args.w

	if args.n is not None:
		test_vectors_nb = args.n
	else:
		test_vectors_nb = 1

	if args.name is not None:
		filename = args.name + ".txt"
	else:
		filename = "sim_" + str(WIDTH) + ".txt"
		

	filename = os.path.abspath(os.path.dirname(__file__)) + "/TEST_VECTORS/TXT/" + filename
    
	with open(filename, "w") as test_file:

		for i in range(test_vectors_nb):
		
			n = random_prime(2**WIDTH, False, 2**(WIDTH-1))
			
			a = random.randrange(2**(WIDTH-1), n)
			b = random.randrange(2**(WIDTH-1), n)
		
		
			res_arr, n_prime_0 = FIOS(n, a, b, w = w, WIDTH = WIDTH)
			
			res = 0
		
			for j in range(len(res_arr)):
				
				res += res_arr[j] << (j*w)
			
			test_file.write("n\n" + hex(n)[2:] + "\n\nn_prime_0\n" + hex(n_prime_0)[2:]
							+ "\n\na\n" + hex(a)[2:] + "\n\nb\n" + hex(b)[2:] + "\n\nres\n"
							+ hex(res)[2:] + "\n\n\n")
