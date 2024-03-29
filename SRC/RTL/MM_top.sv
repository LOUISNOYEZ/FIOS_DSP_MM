`timescale 1ns / 1ps


module MM_top #(parameter  string CONFIGURATION = "FOLD",
                           string DSP_PRIMITIVE = "DSP48E2",
                        int    ABREG = 1,
                        int    MREG = 1,
                        int    CREG = 1,
                        int    LOOP_DELAY = 0,
                        int    CASCADE = 0,
                        int    WORD_WIDTH = 17,
                        int    s = 8,
                        int COL_LENGTH = 168,
             localparam int    DSP_REG_LEVEL = ABREG+MREG+1,
             localparam int   PE_DELAY = (((DSP_PRIMITIVE == "generic_DSP_3A") ||
                                                                     (DSP_PRIMITIVE == "DSP48") ||
                                                                     (DSP_PRIMITIVE == "DSP48E") ||
                                                                     (DSP_PRIMITIVE == "DSP48E1")) ? 1 : 0) + ((CREG && (CASCADE == 0)) ? 1 : 0) + ((DSP_REG_LEVEL == 1) ? 5 :
                                                                               (DSP_REG_LEVEL == 2) ? 6 :
                                                                               (DSP_REG_LEVEL == 3) ? 8 :
                                                                                8),
                        int    PE_NB = (CONFIGURATION == "FOLD") ? (((DSP_PRIMITIVE == "generic_DSP_3A") ||
                                                                     (DSP_PRIMITIVE == "DSP48") ||
                                                                     (DSP_PRIMITIVE == "DSP48E") ||
                                                                     (DSP_PRIMITIVE == "DSP48E1")) ? (3*s+2*DSP_REG_LEVEL+((DSP_REG_LEVEL == 3) ? 1 :0)) : (2*s+2+DSP_REG_LEVEL-1))/PE_DELAY+1 :
                                       s                                                               ) (
        input clock_i, reset_i,
        
        input start_i,
        
        
        input [WORD_WIDTH-1:0] BRAM_dout_i, // Data Out Bus (optional)

        output [WORD_WIDTH-1:0] BRAM_din_o, // Data In Bus (optional)
    
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
    
    wire [WORD_WIDTH-1:0] RES;
    

    reg [WORD_WIDTH-1:0] BRAM_dout_reg;
    
    always @ (posedge clock_i)
        BRAM_dout_reg <= BRAM_dout_i;
    
    
    // The top_control FSM controls the loading of operands
    // from the bridge BRAM to operand registers p_prime_0, a, b and p.
    // The FIOS_control FSM controls the initial loading of operand sections
    // into the PEs using the b_fetch, p_fetch and a_shift signals.
    
    reg p_prime_0_reg_en;
    reg [WORD_WIDTH-1:0] p_prime_0_reg;
    
    always @ (posedge clock_i) begin
        
        if (reset_i)
            p_prime_0_reg <= 0;
        else if (p_prime_0_reg_en)
            p_prime_0_reg <= BRAM_dout_reg;
        else
            p_prime_0_reg <= p_prime_0_reg;
    
    end
    
    reg p_reg_en;
    reg [s*WORD_WIDTH-1:0] p_reg;
    
    always @ (posedge clock_i) begin
        
        if (reset_i)
            p_reg <= 0;
        else if (p_reg_en || p_fetch)
            p_reg <= {BRAM_dout_reg, p_reg[s*WORD_WIDTH-1:WORD_WIDTH]};
        else
            p_reg <= p_reg;
    
    end
    
    reg a_reg_en;
    reg [s*WORD_WIDTH-1:0] a_reg;
    
    generate
        if(CONFIGURATION == "FOLD") begin
    
            always @ (posedge clock_i) begin
        
                if (reset_i)
                    a_reg <= 0;
                else if (a_reg_en)
                    a_reg <= {BRAM_dout_reg, a_reg[s*WORD_WIDTH-1:WORD_WIDTH]};
                else if (a_shift)
                    a_reg <= {{PE_NB{{WORD_WIDTH{1'd0}}}}, a_reg[s*WORD_WIDTH-1:PE_NB*WORD_WIDTH]};
                else
                    a_reg <= a_reg;
            
            end
    
        end else begin
        
            always @ (posedge clock_i) begin
        
                if (reset_i)
                    a_reg <= 0;
                else if (a_reg_en)
                    a_reg <= {BRAM_dout_reg, a_reg[s*WORD_WIDTH-1:WORD_WIDTH]};
                else
                    a_reg <= a_reg;
            
            end

        end
    endgenerate
    
    reg b_reg_en;
    reg [s*WORD_WIDTH-1:0] b_reg;
    
    always @ (posedge clock_i) begin
        
        if (reset_i)
            b_reg <= 0;
        else if (b_reg_en || b_fetch)
            b_reg <= {BRAM_dout_reg, b_reg[s*WORD_WIDTH-1:WORD_WIDTH]};
        else
            b_reg <= b_reg;
    
    end
    
    // RES_reg stores the result of the FIOS multiplication
    // once result sections are provided. Result sections
    // are then loaded by the top_control FSM into the bridge BRAM.

    reg [s*WORD_WIDTH-1:0] RES_reg;

    always @ (posedge clock_i) begin
    
        if (reset_i)
            RES_reg <= 0;
        else if (BRAM_we_o || RES_push)
            RES_reg <= {RES, RES_reg[s*WORD_WIDTH-1:WORD_WIDTH]};
        else
            RES_reg <= RES_reg;
    
    end
    
    generate
    
        if ((DSP_PRIMITIVE == "generic_DSP_3A") ||
            (DSP_PRIMITIVE == "DSP48") ||
            (DSP_PRIMITIVE == "DSP48E") ||
            (DSP_PRIMITIVE == "DSP48E1")) begin
    
        if (CASCADE == 0) begin
    
            FIOS_NOCASC_3A #(.CONFIGURATION(CONFIGURATION), .ABREG(ABREG), .MREG(MREG), .CREG(CREG), .s(s), .LOOP_DELAY(LOOP_DELAY), .DSP_PRIMITIVE(DSP_PRIMITIVE), .WORD_WIDTH(WORD_WIDTH)) FIOS_NOCASC_3A_inst (
                        .clock_i(clock_i), .reset_i(reset_i),
                        
                        .start_i(FIOS_start),
                
                        
                        .p_prime_0_i(p_prime_0_reg),
                        
                        .a_i(a_reg[PE_NB*WORD_WIDTH-1:0]),
                        
                        .b_i(b_reg[WORD_WIDTH-1:0]),
                        .p_i(p_reg[WORD_WIDTH-1:0]),
                        
                        
                        .a_shift_o(a_shift),
                        
                        .b_fetch_o(b_fetch),
                        .p_fetch_o(p_fetch),
                        
                        .RES_push_o(RES_push),
                        
                        .done_o(FIOS_done),
                        
                        
                        .RES_o(RES)
                    
            );
            
        end else if (CASCADE == 1) begin
        
            FIOS_CASC_3A #(.CONFIGURATION(CONFIGURATION), .ABREG(ABREG), .MREG(MREG), .s(s), .LOOP_DELAY(LOOP_DELAY), .COL_LENGTH(COL_LENGTH), .DSP_PRIMITIVE(DSP_PRIMITIVE), .WORD_WIDTH(WORD_WIDTH)) FIOS_CASC_3A_inst (
                        .clock_i(clock_i), .reset_i(reset_i),
                        
                        .start_i(FIOS_start),
                
                        
                        .p_prime_0_i(p_prime_0_reg),
                        
                        .a_i(a_reg[PE_NB*WORD_WIDTH-1:0]),
                        
                        .b_i(b_reg[WORD_WIDTH-1:0]),
                        .p_i(p_reg[WORD_WIDTH-1:0]),
                        
                        
                        .a_shift_o(a_shift),
                        
                        .b_fetch_o(b_fetch),
                        .p_fetch_o(p_fetch),
                        
                        .RES_push_o(RES_push),
                        
                        .done_o(FIOS_done),
                        
                        
                        .RES_o(RES)
                    
            );
        
        end
        
        end else begin
            
        if (CASCADE == 0) begin
            
            FIOS_NOCASC_4A #(.CONFIGURATION(CONFIGURATION), .ABREG(ABREG), .MREG(MREG), .CREG(CREG), .s(s), .LOOP_DELAY(LOOP_DELAY), .DSP_PRIMITIVE(DSP_PRIMITIVE), .WORD_WIDTH(WORD_WIDTH)) FIOS_NOCASC_4A_inst (
                        .clock_i(clock_i), .reset_i(reset_i),
                        
                        .start_i(FIOS_start),
                
                        
                        .p_prime_0_i(p_prime_0_reg),
                        
                        .a_i(a_reg[PE_NB*WORD_WIDTH-1:0]),
                        
                        .b_i(b_reg[WORD_WIDTH-1:0]),
                        .p_i(p_reg[WORD_WIDTH-1:0]),
                        
                        
                        .a_shift_o(a_shift),
                        
                        .b_fetch_o(b_fetch),
                        .p_fetch_o(p_fetch),
                        
                        .RES_push_o(RES_push),
                        
                        .done_o(FIOS_done),
                        
                        
                        .RES_o(RES)
                    
            );
        
        end else if (CASCADE == 1) begin
        
            FIOS_CASC_4A #(.CONFIGURATION(CONFIGURATION), .ABREG(ABREG), .MREG(MREG), .s(s), .LOOP_DELAY(LOOP_DELAY), .COL_LENGTH(COL_LENGTH), .DSP_PRIMITIVE(DSP_PRIMITIVE), .WORD_WIDTH(WORD_WIDTH)) FIOS_CASC_4A_inst (
                        .clock_i(clock_i), .reset_i(reset_i),
                        
                        .start_i(FIOS_start),
                
                        
                        .p_prime_0_i(p_prime_0_reg),
                        
                        .a_i(a_reg[PE_NB*WORD_WIDTH-1:0]),
                        
                        .b_i(b_reg[WORD_WIDTH-1:0]),
                        .p_i(p_reg[WORD_WIDTH-1:0]),
                        
                        
                        .a_shift_o(a_shift),
                        
                        .b_fetch_o(b_fetch),
                        .p_fetch_o(p_fetch),
                        
                        .RES_push_o(RES_push),
                        
                        .done_o(FIOS_done),
                        
                        
                        .RES_o(RES)
                    
            );
        
        end
        
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

    assign BRAM_din_o = RES_reg[WORD_WIDTH-1:0];

endmodule
