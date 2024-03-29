`timescale 1ns / 1ps

// This module is a verilog wrapper for the top module.
// It acts as an interface with the rest of the block design, the Block RAM and the processor.

module MM_top_v_wrapper #(// Bit width of the operands and number of 17 bits blocks
                       // required to slice operands. Note that WIDTH+2 is used
                       // instead of WIDTH to compute s in order not to have to perform
                       // the final subtraction in the Montgomery Algorithm.
                       parameter  string CONFIGURATION = "FOLD",
                       parameter integer DSP_PRIMITIVE = "DSP48E2",
                        //parameter string CONFIGURATION = "FOLD",
                                  integer ABREG = 1,
                                  integer MREG = 1,
                                  integer CREG = 1,
                                  integer CASCADE = 0,
                                  integer LOOP_DELAY = 0,
                                  integer WIDTH = 256,
                                  integer WORD_WIDTH = 17,
                                  integer COL_LENGTH = 168,
                       localparam integer s = ((WIDTH+1)/WORD_WIDTH+1))
    (
    input clock_i, reset_i,
    
    input start_i,

// //The following signals and attributes instanciate a Block RAM master interface.
    (* X_INTERFACE_MODE = "Master" *)
    (* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 MBRAM DOUT" *)
    input [31:0] BRAM_dout_i, // Data Out Bus (optional)

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 MBRAM DIN" *)
    output[31:0] BRAM_din_o, // Data In Bus (optional)

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 MBRAM WE" *)
    output [3:0] BRAM_we_o, // Byte Enables (optional)

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 MBRAM ADDR" *)
    output [31:0] BRAM_addr_o, // Address Signal (required)

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 MBRAM CLK" *)
    output BRAM_clock_o, // Clock Signal (required)
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 MBRAM RST" *)
    output BRAM_reset_o, // Reset Signal (required)
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 MBRAM EN" *)
    output BRAM_en_o, // Chip Enable Signal (optional)
    
    output done_o
    );



	wire [31:0] BRAM_addr;

	wire BRAM_we;

    
    wire [WORD_WIDTH-1:0] BRAM_din;
    
    
    MM_top #(.CONFIGURATION(CONFIGURATION), .ABREG(ABREG), .MREG(MREG), .CREG(CREG), .CASCADE(CASCADE), .LOOP_DELAY(LOOP_DELAY), .s(s), .WORD_WIDTH(WORD_WIDTH),
    .DSP_PRIMITIVE(DSP_PRIMITIVE), .COL_LENGTH(COL_LENGTH)) MM_top_inst (
        .clock_i(clock_i), .reset_i(reset_i),
        
        .start_i(start_i),
        
        
        .BRAM_dout_i(BRAM_dout_i[WORD_WIDTH-1:0]),
        
        .BRAM_din_o(BRAM_din),
        
        .BRAM_we_o(BRAM_we),
        
        .BRAM_addr_o(BRAM_addr),
        
        .BRAM_en_o(BRAM_en_o),
        
        
        .done_o(done_o));


    // The BRAM is byte addressable but only words of 32 bits width are used, hence the left shift of the address.
	assign BRAM_addr_o = BRAM_addr << 2;

    assign BRAM_clock_o = clock_i;

    assign BRAM_reset_o = reset_i;

    // BRAM can be writen one byte at a time, however we write all bytes at once, hence the 4 replications of the write-enable signal.
    assign BRAM_we_o = {4{BRAM_we}};
    
    
    assign BRAM_din_o = {{(32-WORD_WIDTH){1'b0}}, BRAM_din};


endmodule
