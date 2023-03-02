`timescale 1ns / 1ps

// This module is the Montgomery FIOS multiplier.

module FIOS_MM_NOCASC #(parameter  string CONFIGURATION = "EXPAND",
                            int    ABREG = 1,
                            int    MREG = 1,
                            int    CREG = 1,
                            int    s = 8,
                 localparam int   DSP_REG_LEVEL = ABREG+MREG+1,
                 localparam int   PE_DELAY = (DSP_REG_LEVEL == 1) ? 5 + (CREG ? 1 : 0):
                                          (DSP_REG_LEVEL == 2) ? 6 + (CREG ? 1 : 0) :
                                          (DSP_REG_LEVEL == 3) ? 8 + (CREG ? 1 : 0) :
                                          5 + (CREG ? 1 : 0),
                            int   PE_NB = (CONFIGURATION == "FOLD") ? (2*s+2+DSP_REG_LEVEL-1)/PE_DELAY+1 :
                                          s) (
        input         clock_i,
        
        
        input         a_reg_en_i [0:PE_NB-1],
        
        input         m_reg_en_i [0:PE_NB-1],
  
        input  [1:0]  mux_A_sel_i [0:PE_NB-1],
        input  [1:0]  mux_B_sel_i [0:PE_NB-1],
        
        // An additional delayed C input to the DSP is used for DSP_REG_LEVEL 3.
        input  [1:0] mux_C_sel_i [0:PE_NB-1],
        
        input         CREG_en_i   [0:PE_NB-1],
        
        input  [8:0]  OPMODE_i    [0:PE_NB-1],
        
        input         RES_delay_en_i [0:PE_NB-1],
        
        input         C_input_delay_en_i [0:PE_NB-1],
                
        input         FIOS_input_sel_i,
        
        input  [16:0] p_prime_0_i,
        
        input  [PE_NB*17-1:0] a_i,
    
        input  [16:0] b_i,
        input  [16:0] p_i,
        
        
        output [16:0] RES_o
        
    );
    
    
    reg [16:0] p_prime_0     [0:PE_NB];
    
    reg [16:0] b             [0:PE_NB];
    reg [16:0] p             [0:PE_NB];
    
    reg [16:0] C_input       [0:PE_NB];
    reg [16:0] C_input_1_delay [0:PE_NB];
    reg [16:0] C_input_2_delay [0:PE_NB];
   
    reg [16:0] RES           [0:PE_NB-1];
    reg [16:0] RES_delay     [0:PE_NB-1];
            
    assign p_prime_0[0] = p_prime_0_i;
    
    generate
        
        // Operands are circulated within the multiplier and fed back to the first PE
        // when it has completed its first iteration (when FIOS_input_sel is set).
        if (CONFIGURATION == "FOLD") begin
        
            always_comb begin
            
                if (FIOS_input_sel_i) begin
                
                    b[0] = b[PE_NB];
                    p[0] = p[PE_NB];
                    
                    C_input[0] = C_input[PE_NB];
                    C_input_1_delay[0] = C_input_1_delay[PE_NB];
                    C_input_2_delay[0] = C_input_2_delay[PE_NB];
                                   
                end else begin
                
                    b[0] = b_i;
                    p[0] = p_i;
                    
                    C_input[0] = 0;
                    C_input_1_delay[0] = 0;
                    C_input_2_delay[0] = 0;
                                    
                end
                
            end
            
            
            assign RES_o = RES[(s-1) % PE_NB];
                    
        end else begin
        
            always_comb begin
            
                b[0] = b_i;
                p[0] = p_i;
                
                C_input[0] = 0;
                
                C_input_1_delay[0] = 0;
                C_input_2_delay[0] = 0;
                                
            end
            
            assign RES_o = RES[PE_NB-1];
        
        end
    endgenerate
    

    genvar i;
    
    generate
        for (i = 0; i < PE_NB; i++) begin
        
            // Propagation of the operands is delayed between PE in order to synchronize them.
            delay_line #(.WIDTH(34), .DELAY(PE_DELAY)) operands_delay_line_inst (
                
                .clock_i(clock_i), .reset_i(1'b0), .en_i( 1'b1),
                
                
                .data_i({b[i],
                         p[i]}),
                         
                
                .data_o({b[i+1],
                         p[i+1]})
            
            );
        

            // The following generate describes the propagation and synchronization of
            // results from one PE to the next. In the folded configuration, an additional
            // register is used on this path since the first PE in the chain cannot use the
            // PCIN cascade signal to immediately use the previous result.

            delay_line #(.WIDTH(17), .DELAY(0)) RES_dly_inst (
                .clock_i(clock_i), .reset_i(1'b0), .en_i(1'b1),
                
                .data_i(RES[i]),
                
                
                .data_o(RES_delay[i])
                
            );

            assign C_input[i+1] = RES_delay[i];

            if (DSP_REG_LEVEL == 1) begin
            
                always @ (posedge clock_i)
                    C_input_1_delay[i+1] = RES_delay[i];
            
            end else if (DSP_REG_LEVEL == 2 || DSP_REG_LEVEL == 3) begin
                
                always @ (posedge clock_i) begin
                
                    if ((i == PE_NB-1) ? C_input_delay_en_i[0] : C_input_delay_en_i[i+1])
                        C_input_1_delay[i+1] <= RES_delay[i];
                    else
                        C_input_1_delay[i+1] <= C_input_1_delay[i+1];
                        
                end
                    
            end
            
            if (DSP_REG_LEVEL == 3) begin
                            
                always @ (posedge clock_i) begin
                
                    if ((i == PE_NB-1) ? C_input_delay_en_i[0] : C_input_delay_en_i[i+1])
                        C_input_2_delay[i+1] <= C_input_1_delay[i+1];
                    else
                        C_input_2_delay[i+1] <= C_input_2_delay[i+1];
                
                end
                
            end
                
            
    
            PE_NOCASC #(.ABREG(ABREG), .MREG(MREG), .CREG(CREG), .FIRST((i == 0) ? 1 : 0)) PE_NOCASC_inst (
                .clock_i(clock_i),
                
                .a_reg_en_i(a_reg_en_i[i]),
                
                .m_reg_en_i(m_reg_en_i[i]),
                
                .mux_A_sel_i(mux_A_sel_i[i]),
                .mux_B_sel_i(mux_B_sel_i[i]),
                
                // for the first PE in folded configuration, mux_C_sel_i, CREG_en_i and OPMODE_i 
                //take different values than for other PEs to accomodate the fact that it cannot use the PCIN cascade signal.
                
                .mux_C_sel_i(mux_C_sel_i[i]),
                
                .CREG_en_i(CREG_en_i[i]),
                
                .OPMODE_i(OPMODE_i[i]),
                
                .RES_delay_en_i(RES_delay_en_i[i]),
                
                
                .p_prime_0_i(p_prime_0[i]),
                
                .a_i(a_i[i*17+:17]),
                
                .b_i(b[i]),
                .p_i(p[i]),
                
                .C_i(C_input[i]),
                .C_input_1_delay_i(C_input_1_delay[i]),
                .C_input_2_delay_i(C_input_2_delay[i]),
                
                .p_prime_0_o(p_prime_0[i+1]),
                
                .RES_o(RES[i])
                
            );
           
        end
    endgenerate
    
    
endmodule
