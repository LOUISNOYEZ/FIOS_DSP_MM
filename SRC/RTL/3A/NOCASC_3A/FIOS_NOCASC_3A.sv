`timescale 1ns / 1ps

// This module contains the FIOS multiplier as well as its control logic.

module FIOS_NOCASC_3A #(parameter  string CONFIGURATION = "EXPAND",
                         int    LOOP_DELAY = 0,
                         int    ABREG = 1,
                         int    MREG = 1,
                         int    CREG = 1,
                         int    s = 8,
                         int COL_LENGTH = 168,
              localparam int   DSP_REG_LEVEL = ABREG+MREG+1,
              localparam int   PE_DELAY = (CREG ? 1 : 0) + ((DSP_REG_LEVEL == 1) ? 6 :
                                                            (DSP_REG_LEVEL == 2) ? 7 :
                                                            (DSP_REG_LEVEL == 3) ? 9 :
                                                            6),
                         int   PE_NB = (CONFIGURATION == "FOLD") ? ((3*s+2*DSP_REG_LEVEL+((DSP_REG_LEVEL == 3) ? 1 :0))/PE_DELAY+1) :
                                       s) (                            
    input clock_i, reset_i,
    
    input start_i,

    
    input [16:0] p_prime_0_i,
    
    input [PE_NB*17-1:0] a_i,
    
    input [16:0] b_i,
    input [16:0] p_i,
    
    
    output reg a_shift_o,   
    
    output reg b_fetch_o,
    output reg p_fetch_o,
    
    output reg RES_push_o,
    
    output reg done_o,
    

    output [16:0] RES_o

    );
    
    
    // GLOBAL signals
    reg a_reg_en [0:PE_NB-1];
    
    reg m_reg_en [0:PE_NB-1];
    
    reg [1:0] mux_A_sel [0:PE_NB-1];
    reg [1:0] mux_B_sel [0:PE_NB-1];
    reg [1:0] mux_C_sel [0:PE_NB-1];
    
    reg CREG_en [0:PE_NB-1];
    
    reg [6:0] OPMODE [0:PE_NB-1];
    
    reg RES_delay_en [0:PE_NB-1];
    
    reg a_shift [0:PE_NB-1];
    
    reg RES_push [0:PE_NB-1];
    
    reg done [0:PE_NB-1];


    reg FIOS_input_sel_reg;
        
        
    reg RES_push_reg;
    reg done_reg;
        
    reg start [0:PE_NB];
    
    wire b_fetch;
    wire p_fetch;
        
    reg C_input_delay_en [0:PE_NB-1];
        

    generate
        if (CONFIGURATION == "FOLD") begin
        
            // In the folded configuration, control signals are initially provided
            // by the FIOS_control FSM. Control signals are subsequently delayed and
            // circulated between the different processing elements, and fed back to the
            // first PE once it has completed its first iteration (when FIOS_input_sel_reg is set).
        
            always @ (posedge clock_i) begin

                if (reset_i || done_o)
                    FIOS_input_sel_reg <= 0;
                else if (done[0] && ~FIOS_input_sel_reg)
                    FIOS_input_sel_reg <= 1;
                else
                    FIOS_input_sel_reg <= FIOS_input_sel_reg;
            
            end
                            
            always_comb begin
            
                if (FIOS_input_sel_reg) begin
                                        
                    start[0] = start[PE_NB];
                    
                end else begin
                    
                    start[0] = start_i;
                    
                end
            
            end
            
            // In folded configuration, a counter is incremented
            // at every shift of the a input register. FIOS output
            // is available during the last iteration of the PE (s-1) % PE_NB .
            
            reg output_en_reg;
            
            reg [$clog2((s-1)/PE_NB+1)-1:0] a_shift_counter;
            
            always @ (posedge clock_i) begin
            
                if (reset_i || done_o)
                    a_shift_counter <= 0;
                else if (a_shift[PE_NB-1] && ~output_en_reg)
                    a_shift_counter <= a_shift_counter+1;
                else
                    a_shift_counter <= a_shift_counter;
            
            end

            
            always @ (posedge clock_i) begin
            
                if (reset_i || done_o)
                    output_en_reg <= 0;
                else if (a_shift_counter == (s-1)/PE_NB && a_shift[(s-1) % PE_NB] && ~output_en_reg)
                    output_en_reg <= 1;
                else
                    output_en_reg <= output_en_reg;
            
            end
            
            assign RES_push_o = output_en_reg ? RES_push_reg : 0;
            
            
            assign done_o = output_en_reg ? done_reg : 0;
            
        end else begin
        
            assign start[0] = start_i;
            
            assign RES_push_o = RES_push_reg;
            
            assign done_o = done_reg;
        
        end
    endgenerate        
    
    
    // The a register is shifted to provide
    // new a inputs to the PEs after they have
    // all captured input operands.
    always @ (posedge clock_i) begin

        a_shift_o <= a_shift[PE_NB-1];
        
        b_fetch_o <= b_fetch;
        p_fetch_o <= p_fetch;
        
        RES_push_reg <= RES_push[(s-1) % PE_NB];
        done_reg <= done[(s-1) % PE_NB];
                    
    end
    

    generate

        if (DSP_REG_LEVEL == 1) begin
        
            FIOS_control_1_NOCASC_3A #(.s(s), .CREG(CREG)) FIOS_control_1_NOCASC_3A_inst (
                .clock_i(clock_i), .reset_i(reset_i),
                
                .start_i(start[0]),
        
                
                .a_reg_en_o(a_reg_en[0]),
                
                .m_reg_en_o(m_reg_en[0]),
                
                .mux_A_sel_o(mux_A_sel[0]),
                .mux_B_sel_o(mux_B_sel[0]),
                .mux_C_sel_o(mux_C_sel[0]),
                
                .CREG_en_o(CREG_en[0]),
                
                .OPMODE_o(OPMODE[0]),
                
                .a_shift_o(a_shift[0]),
                
                .b_fetch_o(b_fetch),
                
                .p_fetch_o(p_fetch),
                
                .RES_push_o(RES_push[0]),
                
                .done_o(done[0]) 
        
            );
            
        end else if (DSP_REG_LEVEL == 2) begin
        
            FIOS_control_2_NOCASC_3A #(.s(s), .CREG(CREG)) FIOS_control_2_NOCASC_3A_inst (
                .clock_i(clock_i), .reset_i(reset_i),
                
                .start_i(start[0]),
        
                
                .a_reg_en_o(a_reg_en[0]),
                
                .m_reg_en_o(m_reg_en[0]),
                
                .mux_A_sel_o(mux_A_sel[0]),
                .mux_B_sel_o(mux_B_sel[0]),
                .mux_C_sel_o(mux_C_sel[0]),
                
                .CREG_en_o(CREG_en[0]),
                
                .OPMODE_o(OPMODE[0]),
                
                .RES_delay_en_o(RES_delay_en[0]),
                
                .C_input_delay_en_o(C_input_delay_en[0]),
                
                .a_shift_o(a_shift[0]),
                
                .b_fetch_o(b_fetch),
                
                .p_fetch_o(p_fetch),
                
                .RES_push_o(RES_push[0]),
                
                .done_o(done[0]) 
        
            );
        
        end else if (DSP_REG_LEVEL == 3) begin
        
            FIOS_control_3_NOCASC_3A #(.s(s), .CREG(CREG)) FIOS_control_3_NOCASC_3A_inst (
                .clock_i(clock_i), .reset_i(reset_i),
                
                .start_i(start[0]),
        
                
                .a_reg_en_o(a_reg_en[0]),
                
                .m_reg_en_o(m_reg_en[0]),
                
                .mux_A_sel_o(mux_A_sel[0]),
                .mux_B_sel_o(mux_B_sel[0]),
                .mux_C_sel_o(mux_C_sel[0]),
                
                .CREG_en_o(CREG_en[0]),
                
                .OPMODE_o(OPMODE[0]),
                
                .RES_delay_en_o(RES_delay_en[0]),
                
                .C_input_delay_en_o(C_input_delay_en[0]),
                
                .a_shift_o(a_shift[0]),
                
                .b_fetch_o(b_fetch),
                
                .p_fetch_o(p_fetch),
                
                .RES_push_o(RES_push[0]),
                
                .done_o(done[0]) 
        
            );
        
        end
    
    endgenerate
            
    genvar i;
    
    generate
    
        // Control signals are delayed to synchronize PE operations.
        
        for (i = 0; i < PE_NB; i++) begin
        
            if (i == PE_NB-1) begin
        
                delay_line #(.WIDTH(1), .DELAY(PE_DELAY+LOOP_DELAY)) start_dly_inst (
                    .clock_i(clock_i), .reset_i(1'b0), .en_i(1'b1),
                    
                    .data_i(start[PE_NB-1]),
                    
                
                    .data_o(start[PE_NB])
                
                );

            end else begin
            
                delay_line #(.WIDTH(24), .DELAY((i == PE_NB-1) ? PE_DELAY+LOOP_DELAY : PE_DELAY)) control_dly_inst (
                    .clock_i(clock_i), .reset_i(1'b0), .en_i(1'b1),
                    
                    .data_i({a_reg_en[i],
                             m_reg_en[i],
                             mux_A_sel[i],
                             mux_B_sel[i],
                             mux_C_sel[i],
                             CREG_en[i],
                             OPMODE[i],
                             RES_delay_en[i],
                             C_input_delay_en[i],
                             a_shift[i],
                             RES_push[i],
                             start[i],
                             
                             done[i]}),
                    
                    
                    .data_o({a_reg_en[i+1],
                             m_reg_en[i+1],
                             mux_A_sel[i+1],
                             mux_B_sel[i+1],
                             mux_C_sel[i+1],
                             CREG_en[i+1],
                             OPMODE[i+1],
                             RES_delay_en[i+1],
                             C_input_delay_en[i+1],
                             a_shift[i+1],
                             RES_push[i+1],
                             start[i+1],
                             
                             done[i+1]})
            
                );
                
            end
            
        end
    endgenerate
    
    
    FIOS_MM_NOCASC_3A #(.CONFIGURATION(CONFIGURATION), .ABREG(ABREG), .MREG(MREG), .CREG(CREG), .s(s), .LOOP_DELAY(LOOP_DELAY)) FIOS_MM_NOCASC_3A_inst (
        
        .clock_i(clock_i),
        
        
        .a_reg_en_i(a_reg_en[0:PE_NB-1]),
        
        .m_reg_en_i(m_reg_en[0:PE_NB-1]),
  
        .mux_A_sel_i(mux_A_sel[0:PE_NB-1]),
        .mux_B_sel_i(mux_B_sel[0:PE_NB-1]),
        .mux_C_sel_i(mux_C_sel[0:PE_NB-1]),
        
        .CREG_en_i(CREG_en[0:PE_NB-1]),
        
        .OPMODE_i(OPMODE[0:PE_NB-1]),
        
        .RES_delay_en_i(RES_delay_en[0:PE_NB-1]),
        
        .C_input_delay_en_i(C_input_delay_en[0:PE_NB-1]),
        
        .FIOS_input_sel_i(FIOS_input_sel_reg),
        
        .p_prime_0_i(p_prime_0_i),
        
        .a_i(a_i),
    
        .b_i(b_i),
        .p_i(p_i),
        
        
        .RES_o(RES_o)
    
    );
    
        
endmodule
