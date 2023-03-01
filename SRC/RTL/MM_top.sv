`timescale 1ns / 1ps


module MM_top #(parameter  string CONFIGURATION = "FOLD",
                        int    ABREG = 1,
                        int    MREG = 1,
                        int    CREG = 1,
                        int    LOOP_DELAY = 0,
                        int    CASCADE = 0,
                        int    s = 8,
             localparam int    DSP_REG_LEVEL = ABREG+MREG+1,
             localparam int   PE_DELAY = (DSP_REG_LEVEL == 1) ? 5 + ((CREG && CASCADE == 0) ? 1 : 0) :
                                         (DSP_REG_LEVEL == 2) ? 6 + ((CREG && CASCADE == 0) ? 1 : 0) :
                                         (DSP_REG_LEVEL == 3) ? 8 + ((CREG && CASCADE == 0) ? 1 : 0) :
                                         5 + ((CREG && CASCADE == 0) ? 1 : 0),
                        int    PE_NB = (CONFIGURATION == "FOLD") ? (2*s+2+DSP_REG_LEVEL-1)/PE_DELAY+1 :
                                       s                                                               ) (
        input clock_i, reset_i,
        
        input start_i,
        
        
        input [16:0] BRAM_dout_i, // Data Out Bus (optional)

        output [16:0] BRAM_din_o, // Data In Bus (optional)
    
        output BRAM_we_o, // Byte Enables (optional)
    
        output [31:0] BRAM_addr_o, // Address Signal (required)
            
        output BRAM_en_o, // Chip Enable Signal (optional)
        
        
        output done_o

    );
    

    wire FIOS_start;
   
    wire a_shift;
    
    wire b_fetch;
    wire p_fetch;
   
    wire RES_push;
    
    wire FIOS_done;
    
    
    wire [$clog2(4*s)-1:0] BRAM_addr;
    
    wire [16:0] RES;
    

    reg [16:0] BRAM_dout_reg;
    
    always @ (posedge clock_i)
        BRAM_dout_reg <= BRAM_dout_i;
    
    
    // The top_control FSM controls the loading of operands
    // from the bridge BRAM to operand registers p_prime_0, a, b and p.
    // The FIOS_control FSM controls the initial loading of operand sections
    // into the PEs using the b_fetch, p_fetch and a_shift signals.
    
    reg p_prime_0_reg_en;
    reg [16:0] p_prime_0_reg;
    
    always @ (posedge clock_i) begin
        
        if (reset_i)
            p_prime_0_reg <= 0;
        else if (p_prime_0_reg_en)
            p_prime_0_reg <= BRAM_dout_reg;
        else
            p_prime_0_reg <= p_prime_0_reg;
    
    end
    
    reg p_reg_en;
    reg [s*17-1:0] p_reg;
    
    always @ (posedge clock_i) begin
        
        if (reset_i)
            p_reg <= 0;
        else if (p_reg_en || p_fetch)
            p_reg <= {BRAM_dout_reg, p_reg[s*17-1:17]};
        else
            p_reg <= p_reg;
    
    end
    
    reg a_reg_en;
    reg [s*17-1:0] a_reg;
    
    generate
        if(CONFIGURATION == "FOLD") begin
    
            always @ (posedge clock_i) begin
        
                if (reset_i)
                    a_reg <= 0;
                else if (a_reg_en)
                    a_reg <= {BRAM_dout_reg, a_reg[s*17-1:17]};
                else if (a_shift)
                    a_reg <= {{PE_NB{17'd0}}, a_reg[s*17-1:PE_NB*17]};
                else
                    a_reg <= a_reg;
            
            end
    
        end else begin
        
            always @ (posedge clock_i) begin
        
                if (reset_i)
                    a_reg <= 0;
                else if (a_reg_en)
                    a_reg <= {BRAM_dout_reg, a_reg[s*17-1:17]};
                else
                    a_reg <= a_reg;
            
            end

        end
    endgenerate
    
    reg b_reg_en;
    reg [s*17-1:0] b_reg;
    
    always @ (posedge clock_i) begin
        
        if (reset_i)
            b_reg <= 0;
        else if (b_reg_en || b_fetch)
            b_reg <= {BRAM_dout_reg, b_reg[s*17-1:17]};
        else
            b_reg <= b_reg;
    
    end
    
    // RES_reg stores the result of the FIOS multiplication
    // once result sections are provided. Result sections
    // are then loaded by the top_control FSM into the bridge BRAM.

    reg [s*17-1:0] RES_reg;

    always @ (posedge clock_i) begin
    
        if (reset_i)
            RES_reg <= 0;
        else if (BRAM_we_o || RES_push)
            RES_reg <= {RES, RES_reg[s*17-1:17]};
        else
            RES_reg <= RES_reg;
    
    end
    
    
    generate
    
        if (CASCADE == 1) begin
    
            FIOS_CASC #(.CONFIGURATION(CONFIGURATION), .ABREG(ABREG), .MREG(MREG), .LOOP_DELAY(LOOP_DELAY), .s(s)) FIOS_CASC_inst (
                .clock_i(clock_i), .reset_i(reset_i),
                
                .start_i(FIOS_start),
        
                
                .p_prime_0_i(p_prime_0_reg),
                
                .a_i(a_reg[PE_NB*17-1:0]),
                
                .b_i(b_reg[16:0]),
                .p_i(p_reg[16:0]),
                
                
                .a_shift_o(a_shift),
                
                .b_fetch_o(b_fetch),
                .p_fetch_o(p_fetch),
                
                .RES_push_o(RES_push),
                
                .done_o(FIOS_done),
                
                
                .RES_o(RES)
            
            );
            
        end else begin
        
        
            FIOS_NOCASC #(.CONFIGURATION(CONFIGURATION), .ABREG(ABREG), .MREG(MREG), .CREG(CREG), .s(s)) FIOS_NOCASC_inst (
                .clock_i(clock_i), .reset_i(reset_i),
                
                .start_i(FIOS_start),
        
                
                .p_prime_0_i(p_prime_0_reg),
                
                .a_i(a_reg[PE_NB*17-1:0]),
                
                .b_i(b_reg[16:0]),
                .p_i(p_reg[16:0]),
                
                
                .a_shift_o(a_shift),
                
                .b_fetch_o(b_fetch),
                .p_fetch_o(p_fetch),
                
                .RES_push_o(RES_push),
                
                .done_o(FIOS_done),
                
                
                .RES_o(RES)
            
            );
        
        end
    
    endgenerate


    MM_top_control #(.s(s)) MM_top_control_inst (
        .clock_i(clock_i), .reset_i(reset_i),
        
        .start_i(start_i),
        
        .FIOS_done_i(FIOS_done),
        
        
        .p_prime_0_reg_en_o(p_prime_0_reg_en),
        .p_reg_en_o(p_reg_en),
        .a_reg_en_o(a_reg_en),
        .b_reg_en_o(b_reg_en),
        
        .FIOS_start_o(FIOS_start),
        
        
        .BRAM_we_o(BRAM_we_o),

        .BRAM_addr_o(BRAM_addr),

        .BRAM_en_o(BRAM_en_o),

        
        .done_o(done_o)
    );


    assign BRAM_addr_o = {{(32-$clog2(4*s)){1'b0}}, BRAM_addr};

    assign BRAM_din_o = RES_reg[16:0];

endmodule
