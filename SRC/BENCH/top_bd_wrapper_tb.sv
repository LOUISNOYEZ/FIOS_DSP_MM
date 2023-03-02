`timescale 1ns / 1fs

// This module is the testbench for the sim_top_bd block design.
// It is meant to load test vectors from a text test vectors file,
// store operand data in the Block RAM, launch an FIOS computation
// and compare the stored result with the expected result.

module top_bd_wrapper_tb #(parameter WIDTH = 256) ();

    // The block design uses a clock wizard which uses
    // a 300 MHz clock to generate the higher frequency clock used by the design.
    localparam PERIOD = 3.333,
               HALF_PERIOD = PERIOD/2;

    // Bit width of the operands and number of 17 bits blocks
    // required to slice operands. Note that WIDTH+2 is used
    // instead of WIDTH to compute s in order not to have to perform
    // the final subtraction in the Montgomery Algorithm (see paper).
    localparam s = (WIDTH+1)/17+1;

    // Global clock reset and start signals of the FIOS multiplier design.
    reg clock_i = 0;
    reg reset_i = 1;
    reg start_i = 0;

    // BRAM master interface used to store test vectors in BRAM and load result from BRAM.
    wire BRAM_PORTA_i_clk;
    reg [31:0] BRAM_PORTA_i_din = 0;
    reg [3:0] BRAM_PORTA_i_we = 0;
    reg [31:0] BRAM_PORTA_i_addr = 0;
    wire [31:0] BRAM_PORTA_i_dout;
    
    reg BRAM_PORTA_i_rst = 0;
    reg BRAM_PORTA_en_i = 0;

    // FIOS done status signal.
    wire done_o;

    // Wrapper instance for the block design.
    sim_top_bd_wrapper DUT (
        . reset_i(reset_i),
        .start_i(start_i),
        .BRAM_PORTA_i_addr(BRAM_PORTA_i_addr),
        .BRAM_PORTA_i_clk(BRAM_PORTA_i_clk),
        .BRAM_PORTA_i_din(BRAM_PORTA_i_din),
        .BRAM_PORTA_i_dout(BRAM_PORTA_i_dout),
        .BRAM_PORTA_i_we(BRAM_PORTA_i_we),
        .BRAM_PORTA_i_rst(BRAM_PORTA_i_rst),
        .BRAM_PORTA_i_en(1),
        .done_o(done_o));

    // testbench-side BRAM port runs at 300 MHz.
    assign BRAM_PORTA_i_clk = clock_i;
        
    always #HALF_PERIOD clock_i <= ~(clock_i);
    
    // The following registers are used to store input operands and expect result read from test vector files prior
    // being stored in the BRAM.
    reg [16:0] p_prime_0_reg;
    reg [s*17-1:0] p_reg;
    reg [s*17-1:0] a_reg;
    reg [s*17-1:0] b_reg;

    reg [s*17-1:0] verif_res = 0;

    // The following register and register enable signals are used to load the result computed by the FIOS module from the BRAM
    // and compare it with the expected result.
    reg [s*17-1:0] res;
    reg en_res = 0;
    reg en_res_reg;

    always @ (posedge clock_i) begin
        en_res_reg <= en_res;
    end

    // The computed result is loaded from BRAM using a shift register.
    always @ (posedge clock_i) begin
        if(en_res_reg)
            res <= {BRAM_PORTA_i_dout[16:0], res[s*17-1:17]};
    end


    // Default test vector file name is "sim_<WIDTH>.txt", it is generated using the WIDTH localparam.
    string WIDTH_str;

    // Test vector file descriptor, line variable to store data read from test vector and status variable.
    int fd;
    string line;
    int status;
    
    // A counter is used to count the numbers of test vectors tested.
    int count = 0;
    int SUCCESS_COUNT = 0;
    
    string success_string;

    initial begin
    
        count <= 0;
        reset_i <= 1;
        en_res <= 0;

        BRAM_PORTA_i_rst <= 1;

        // Generate test vector file name and open test vector file.
        $sformat(WIDTH_str, "%0d", WIDTH);
        
        fd = $fopen({"sim_",WIDTH_str, ".txt"}, "r");
        
        BRAM_PORTA_en_i <= 1;
        
        #PERIOD;
            
        #(100*PERIOD);
        
        BRAM_PORTA_i_rst <= 0;
        
        // While the test vector file has not been read completely, the n, n_prime_0, X and Y operands as
        // well as the expected result are read and tested.
        while (! $feof(fd)) begin
        
        reset_i <= 1;
        en_res <= 0;
        
        #(100*PERIOD);
        
        reset_i <= 0;
        
        #(100*PERIOD);
        
        status = $fgets(line, fd);
        status = $fgets(line, fd);
        status = $sscanf(line, "%h", p_reg);
        status = $fgets(line, fd);
        status = $fgets(line, fd);
        status = $fgets(line, fd);
        status = $sscanf(line, "%h", p_prime_0_reg);
        status = $fgets(line, fd);
        status = $fgets(line, fd);
        status = $fgets(line, fd);
        status = $sscanf(line, "%h", a_reg);
        status = $fgets(line, fd);
        status = $fgets(line, fd);
        status = $fgets(line, fd);
        status = $sscanf(line, "%h", b_reg);
        status = $fgets(line, fd);
        status = $fgets(line, fd);
        status = $fgets(line, fd);
        status = $sscanf(line, "%h", verif_res);
        status = $fgets(line, fd);
        status = $fgets(line, fd);

        // Operand data read from the test vector file is written to the Block RAM.
        BRAM_PORTA_i_we <= 'hf;
        
        BRAM_PORTA_i_addr <= 0;
        BRAM_PORTA_i_din <= p_prime_0_reg;
        #PERIOD;
        for(int i = 0; i < s;i++) begin
            BRAM_PORTA_i_addr <= (i+1) << 2;
            BRAM_PORTA_i_din <= p_reg[17*i+:17];
            #PERIOD;        
        end
        for(int i = 0; i < s;i++) begin
            BRAM_PORTA_i_addr <= (i+s+1) << 2;
            BRAM_PORTA_i_din <= a_reg[17*i+:17];
            #PERIOD;        
        end
        for(int i = 0; i < s;i++) begin
            BRAM_PORTA_i_addr <= (i+2*s+1) << 2;
            BRAM_PORTA_i_din <= b_reg[17*i+:17];
            #PERIOD;
        end
        
        BRAM_PORTA_i_we <= 0;
        BRAM_PORTA_i_din <= 0;
        
        BRAM_PORTA_en_i <= 0;
        
        #PERIOD;
        
        // The testbench starts the FIOS computation and waits for the done_o status signal to be set.
        start_i <= 1;
        
        #(PERIOD);
        
        start_i <= 0;

        while(~done_o)
            #PERIOD;


        #PERIOD;
        BRAM_PORTA_en_i <= 1;
        // Computed result is loaded from the BRAM.
        for(int i = 0; i < s;i++) begin
            en_res <= 1;
            BRAM_PORTA_i_addr <= i << 2;
            #PERIOD;
        end

        en_res <= 0;

        #(2*PERIOD);

        // Computed result is compared to the expected result and the test vector count is incremented.       
        if(res == verif_res) begin
            $display("test vector %0d match at %0t ps.", count, $realtime);
            SUCCESS_COUNT <= SUCCESS_COUNT + 1;
        end else begin
            $display("test vector %0d mismatch at %0t ps.", count, $realtime);
        end

        #(5*PERIOD); 
        
        count <= count+1;
        
        end



        if (SUCCESS_COUNT-1 == count) begin
            success_string = "SUCCESS";
            $display("SUCCESS");
        end else begin
            success_string = "FAILURE";
            $display("FAILURE");
        end

        $stop;

    end


endmodule





