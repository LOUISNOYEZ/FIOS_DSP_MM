`timescale 1ns / 1ps

// FIOS_control FSM provides control signals to the first PE.
// These control signals are delayed and circulated between PEs.

// States are named after the inputs available to be fed to DSP blocks.

// A counter is used to count the iteration of the inner loop of the FIOS multiplication.
// The FSM terminates once s iteration of the inner loop have occured.

module FIOS_control_1_CASC #(parameter s = 16,
                                  int CREG = 0) (
    input clock_i, reset_i,
    
    
    input start_i,
    
    
    output reg a_reg_en_o,
    
    output reg m_reg_en_o,
    
    output reg [1:0] mux_A_sel_o,
    output reg [1:0] mux_B_sel_o,
    output reg [1:0] mux_C_sel_o,
    
    output reg CREG_en_o,
    
    output reg [6:0] OPMODE_o,
    
    output reg RES_delay_en_o,


    output reg a_shift_o,

    output reg b_fetch_o,
    
    output reg p_fetch_o,
    
    output reg RES_push_o,
    
    output reg done_o
    
    );
    
    
    localparam [3:0] INIT          = 4'b0000,
                     A_B0          = 4'b0001,
                     RES_P_PRIME_0 = 4'b0010,
                     M_P0          = 4'b0011,
                     A_BJ          = 4'b0100,
                     RES_ACC       = 4'b0101,
                     M_PJ          = 4'b0110,
                     LAST_A_BJ     = 4'b0111,
                     LAST_RES_ACC  = 4'b1000,
                     LAST_M_PJ     = 4'b1001,
                     RES_SHIFT     = 4'b1010,
                     RES_KEEP      = 4'b1011;
    
    reg [3:0] current_state;
    reg [3:0] future_state;

    
    reg loop_counter_reset;
    reg loop_counter_en;
    reg [$clog2(s)-1:0] loop_counter;
    
    
    always @ (posedge clock_i) begin

        if (reset_i)
            current_state <= INIT;
        else
            current_state <= future_state;
    
    end
    
    
    always_comb begin
    
        case (current_state)
        
            INIT :          begin
                           
                                if (start_i)
                                    future_state = A_B0;
                                else
                                    future_state = INIT;
                           
                            end
            A_B0          : future_state = RES_P_PRIME_0;
            RES_P_PRIME_0 : future_state = M_P0;
            M_P0          : future_state = A_BJ;
            A_BJ          : future_state = RES_ACC;
            RES_ACC       : future_state = M_PJ;
            M_PJ          : begin
                       
                                if (loop_counter == s-2)
                                    future_state = LAST_A_BJ;
                                else
                                    future_state = A_BJ;
                       
                            end
            LAST_A_BJ     : future_state = LAST_RES_ACC;                            
            LAST_RES_ACC  : future_state = LAST_M_PJ;
            LAST_M_PJ     : future_state = RES_SHIFT;
            RES_SHIFT     : future_state = RES_KEEP;
            RES_KEEP      : future_state = INIT;
            default       : future_state = INIT;
        
        endcase
    
    end


    always_comb begin
    
        case(current_state)
            INIT          : begin
                           
                                a_reg_en_o = 1;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 0;
        
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b0010101;
                                
                                a_shift_o = 0;
                                
                                b_fetch_o = 0;
                                
                                p_fetch_o = 0;

                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 1;
                                
                                loop_counter_en = 0;
                           
                            end
            A_B0          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 1;
                                mux_B_sel_o = 1;
                                mux_C_sel_o = 1;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b0000101;
                               
                                a_shift_o = 1;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            RES_P_PRIME_0 : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 1;
        
                                mux_A_sel_o = 1;
                                mux_B_sel_o = 2;
                                mux_C_sel_o = 0;
        
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b0110101;
                               
                                a_shift_o = 0;
                                
                                b_fetch_o = 1;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            M_P0          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b1100101;
                                                              
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 1;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 1;
                           
                            end
            A_BJ          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b0110010;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 1;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            RES_ACC       : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 2;
                                mux_B_sel_o = 2;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b0100101;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            M_PJ          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b1100101;
                                                              
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 1;
                               
                                RES_push_o = 1;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 1;
                           
                            end
            LAST_A_BJ     : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 0;
        
                                OPMODE_o = 7'b0110010;
                                                              
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            LAST_RES_ACC          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 2;
                                mux_B_sel_o = 2;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 0;
        
                                OPMODE_o = 7'b0100101;
                                                              
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            LAST_M_PJ     : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 0;
        
                                OPMODE_o = 7'b1100000;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 1;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 1;
                           
                            end
            RES_SHIFT     : begin
                           
                                a_reg_en_o = 1;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 0;
        
                                OPMODE_o = 7'b0100000;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 1;
                                
                                done_o = 1;


                                loop_counter_reset = 1;
                                
                                loop_counter_en = 0;
                           
                            end
            RES_KEEP     : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 0;
        
                                OPMODE_o = 7'b0100000;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;


                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            default       : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 0;
        
                                OPMODE_o = 7'b0000000;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 1;
                                
                                loop_counter_en = 0;
                                
                            end
        endcase
    
    end


    always @ (posedge clock_i) begin

        if (loop_counter_reset)
            loop_counter <= 0;
        else if (loop_counter_en)
            loop_counter <= loop_counter + 1;
        else
            loop_counter <= loop_counter;
    
    end
    
    


endmodule
