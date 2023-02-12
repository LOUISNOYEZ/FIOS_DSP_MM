#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_io.h"
#include "xgpiops.h"

#define RESET_PIN 78
#define START_PIN 79

//#define s 16


XGpioPs Gpio;


int main()
{
    init_platform();
	
	// n = 0xaefc4579c76d7e88a586d3e787ba739826622c209d181191a25409c1dbcc8bef
    u32 p_arr[16] = {0x8bef, 0xede6, 0x10270, 0x344a, 0x18119, 0x104e8, 0x188b0, 0x1304c, 0x1ba73, 0x1f3c3, 0x161b4, 0x1d114, 0x76d7, 0x2bce, 0xbbf1, 0x1};


    u32 p_prime_0 = 0x1fcf1;

	// a = 0x9c595cfbb4783c24e21a274ac0bc5305030c517928cfdb3b4ad0a51cbe42264e
    u32 a_arr[16] = {0x264e, 0x5f21, 0x2947, 0x1695a, 0xfdb3, 0x1c946, 0x3145, 0xa06, 0xbc53, 0x1a560, 0x8689, 0x1849c, 0x14783, 0xe7dd, 0x7165, 0x1};

	// b = 0x807e96eac45731e81e5e971cdba416d53a47a698cc9c2baa9cdf36bf92dc9938
    u32 b_arr[16] = {0x9938, 0x1c96e, 0x1cdaf, 0x1539b, 0x1c2ba, 0xc664, 0x11e9a, 0x1aa74, 0x1a416, 0x18e6d, 0x197a5, 0x3d03, 0x4573, 0xb756, 0x1fa, 0x1};
    
    
    u32 res[16];

	// expected_res = 0x8462647bc45afc3da53e99bcbace467da14dbb78aa3619409b43c9455ddc4dc3
	u32 expected_res_arr[16] = {0x4dc3, 0xaeee, 0xf251, 0x1368, 0x16194, 0x1c551, 0x136ed, 0xfb42, 0xce46, 0xde5d, 0x14fa6, 0x187b4, 0x45af, 0x123de, 0x1189, 0x1};



	// Setup of reset and start GPIOs.
    int Status;
	XGpioPs_Config *ConfigPtr;

	//Fetch the configuration of the GPIO device used in the design.
	ConfigPtr = XGpioPs_LookupConfig(XPAR_XGPIOPS_0_DEVICE_ID);
	Status = XGpioPs_CfgInitialize(&Gpio, ConfigPtr, ConfigPtr->BaseAddr); //Configure and initialize GPIO instance.

	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	XGpioPs_SetDirectionPin(&Gpio, RESET_PIN, 1); // Pin 78 is the reset pin of the design.
	XGpioPs_SetOutputEnablePin(&Gpio, RESET_PIN, 0);

	XGpioPs_SetDirectionPin(&Gpio, START_PIN, 1); // Pin 79 is the start pin of the design.
	XGpioPs_SetOutputEnablePin(&Gpio, START_PIN, 0);
	
	XGpioPs_WritePin(&Gpio, START_PIN, 0);

	XGpioPs_WritePin(&Gpio, RESET_PIN, 0); // reset.

	for (int i = 0; i < 1000000; i++) {


	}

	XGpioPs_WritePin(&Gpio, RESET_PIN, 1); // End of reset.

	for (int i = 0; i < 1000000; i++) {


	}


	// Loading of the operands in the bridge BRAM.

	Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR, p_prime_0);

    for(int i = 0; i < 16;i++) {

        Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR+4*(i+1), p_arr[i]);

    }

    for(int i = 0; i < 16;i++) {

        Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR+4*(16+1+i), a_arr[i]);

    }

    for(int i = 0; i < 16;i++) {

        Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR+4*(2*16+1+i), b_arr[i]);

    }

	

	// Start of computation.
	
	XGpioPs_WritePin(&Gpio, START_PIN, 1);

	for (int i = 0; i < 1000000; i++) {


	}
	
	XGpioPs_WritePin(&Gpio, START_PIN, 0); // End of computation.


	// Fetching of the result from the bridge BRAM.

	for (int i = 0; i < 16; i++) {
	
		res[i] = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR+i*4);
	
	}	

	for(int i = 0 ; i < 16; i++) {

		xil_printf("\nRES %d : %x", i, res[i]);

	}

    cleanup_platform();
    return 0;
}
