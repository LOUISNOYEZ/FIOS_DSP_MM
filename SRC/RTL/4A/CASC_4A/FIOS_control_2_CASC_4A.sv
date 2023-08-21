`timescale 1ns / 1ps

// FIOS_control FSM provides control signals to the first PE.
// These control signals are delayed and circulated between PEs.

// States are named after the inputs available to be fed to DSP blocks.

// A counter is used to count the iteration of the inner loop of the FIOS multiplication.
// The FSM terminates once s iteration of the inner loop have occured.

module FIOS_control_2_CASC_4A #(parameter s = 16) (
    input clock_i, reset_i,
    
    input start_i,
    
    
    output reg a_reg_en_o,
    
    output reg m_reg_en_o,
    
    output reg [1:0] mux_A_sel_o,
    output reg [1:0] mux_B_sel_o,
    output reg [1:0] mux_C_sel_o,
    
    output reg CREG_en_o,
    
    output reg [8:0] OPMODE_o,
    
    output reg RES_delay_en_o,

    output reg C_input_delay_en_o,
    
    output reg a_shift_o,

    output reg b_fetch_o,
    
    output reg p_fetch_o,
    
    output reg RES_push_o,
    
    output reg done_o
    
    );
    
    
    localparam [3:0] INIT          = 4'b0000,
                     A_B0          = 4'b0001,
                     A_B1          = 4'b0010,
                     RES_P_PRIME_0 = 4'b0011,
                     A_B2          = 4'b0100,
                     M_P0          = 4'b0101,
                     M_P1          = 4'b0110,
                     M_P2          = 4'b0111,
                     A_B3          = 4'b1000,
                     M_P3          = 4'b1001,
                     A_BJ          = 4'b1010,
                     M_PJ          = 4'b1011,
                     LAST_M_PJ     = 4'b1100,
                     RES_SHIFT     = 4'b1101;
    
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
            A_B0          : future_state = A_B1;
            A_B1          : future_state = RES_P_PRIME_0;
            RES_P_PRIME_0 : future_state = A_B2;
            A_B2          : future_state = M_P0;
            M_P0          : future_state = M_P1;
            M_P1          : future_state = M_P2;
            M_P2          : future_state = A_B3;
            A_B3          : future_state = M_PJ;
            A_BJ          : future_state = M_PJ;
            M_PJ          : begin
                       
                                if (loop_counter == s-1)
                                    future_state = LAST_M_PJ;
                                else
                                    future_state = A_BJ;
                       
                            end
            LAST_M_PJ     : future_state = RES_SHIFT;
            RES_SHIFT     : future_state = INIT;
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
        
                                OPMODE_o = 9'b000000000;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = 0;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 1;
                                
                                p_fetch_o = 0;

                                RES_push_o = 0;
                               
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 1;
                                
                                loop_counter_en = 0;
                           
                            end
            A_B0          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 9'b000010101;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = 0;
                               
                                a_shift_o = 1;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            A_B1          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 1;
                                mux_B_sel_o = 1;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 0;
        
                                OPMODE_o = 9'b000010101;
                               
                                RES_delay_en_o = 1;
                                
                                C_input_delay_en_o = 0;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 1;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            RES_P_PRIME_0 : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 9'b000000101;
                               
                                RES_delay_en_o = 1;
                                
                                C_input_delay_en_o = 0;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            A_B2          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 1;
        
                                mux_A_sel_o = 1;
                                mux_B_sel_o = 2;
                                mux_C_sel_o = 1;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 9'b000010101;
                               
                                RES_delay_en_o = 1;
                                
                                C_input_delay_en_o = 0;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 1;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            M_P0          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 2;
                                mux_B_sel_o = 2;
                                mux_C_sel_o = 1;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 9'b110000101;
                               
                                RES_delay_en_o = 1;
                                
                                C_input_delay_en_o = 0;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 1;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 1;
                           
                            end
            M_P1          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 2;
                                mux_B_sel_o = 2;
                                mux_C_sel_o = 1;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 9'b111100101;
                               
                                RES_delay_en_o = 1;
                                
                                C_input_delay_en_o = 0;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 1;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 1;
                           
                            end
            M_P2          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 2;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 9'b111100101;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = 1;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 1;
                               
                                RES_push_o = 1;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 1;
                           
                            end
            A_B3          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 2;
                                mux_B_sel_o = 2;
                                mux_C_sel_o = 2;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 9'b111100101;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = 0;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 1;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 1;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            A_BJ          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 2;
                                mux_B_sel_o = 2;
                                mux_C_sel_o = 2;
                                
                                CREG_en_o = 0;
        
                                OPMODE_o = 9'b111100101;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = 0;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 1;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 1;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            M_PJ          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 2;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 9'b000100101;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = 1;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 1;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 1;
                           
                            end
            LAST_M_PJ     : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 9'b001100000;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = 0;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 1;
                                
                                done_o = 0;


                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            RES_SHIFT     : begin
                           
                                a_reg_en_o = 1;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 9'b000100000;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = 0;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 1;
                                
                                done_o = 1;


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
        
                                OPMODE_o = 0;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = 0;
                               
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
