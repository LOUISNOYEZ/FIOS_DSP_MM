`timescale 1ns / 1ps

// FIOS_control FSM provides control signals to the first PE.
// These control signals are delayed and circulated between PEs.

// States are named after the inputs available to be fed to DSP blocks.

// A counter is used to count the iteration of the inner loop of the FIOS multiplication.
// The FSM terminates once s iteration of the inner loop have occured.

module FIOS_control_2_NOCASC #(parameter s = 16,
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

    output reg C_input_delay_en_o,
    
    output reg a_shift_o,

    output reg b_fetch_o,
    
    output reg p_fetch_o,
    
    output reg RES_push_o,
    
    output reg done_o
    
    );
    
    
    localparam [4:0] INIT          = 5'b00000,
                     A_B0          = 5'b00001,
                     WAIT_0        = 5'b00010,
                     A_B1          = 5'b00011,
                     RES_P_PRIME_0 = 5'b00100,
                     M_P0          = 5'b00101,
                     ACC_SHIFT_0   = 5'b00110,
                     M_P1          = 5'b00111,
                     ACC_SHIFT_1   = 5'b01000,
                     A_B2          = 5'b01001,
                     M_P2          = 5'b01010,
                     ACC_SHIFT     = 5'b01011,
                     A_BJ          = 5'b01100,
                     M_PJ          = 5'b01101,
                     LAST_M_PJ     = 5'b01110,
                     RES_SHIFT     = 5'b01111,
                     RES_KEEP      = 5'b10000;
    
    reg [4:0] current_state;
    reg [4:0] future_state;

    
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
            A_B0          : future_state = WAIT_0;
            WAIT_0        : future_state = RES_P_PRIME_0;
            RES_P_PRIME_0 : future_state = A_B1;
            A_B1          : future_state = M_P0;
            M_P0          : future_state = ACC_SHIFT_0;
            ACC_SHIFT_0   : future_state = M_P1;
            M_P1          : future_state = ACC_SHIFT_1;
            ACC_SHIFT_1   : future_state = A_B2;
            A_B2          : future_state = M_P2;
            M_P2          : future_state = ACC_SHIFT;
            ACC_SHIFT     : future_state = A_BJ;
            A_BJ          : future_state = M_PJ;
            M_PJ          : begin
                       
                                if (loop_counter == s-1)
                                    future_state = LAST_M_PJ;
                                else
                                    future_state = ACC_SHIFT;
                       
                            end
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
        
                                OPMODE_o = 7'b0000000;
                               
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
                                
                                CREG_en_o = 0;
        
                                OPMODE_o = 7'b0110101;
                               
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
            WAIT_0        : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 1;
                                mux_B_sel_o = 1;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 0;
        
                                OPMODE_o = 7'b0000000;
                               
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
            RES_P_PRIME_0 : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b0000101;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = 0;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            A_B1          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 1;
        
                                mux_A_sel_o = 1;
                                mux_B_sel_o = 2;
                                mux_C_sel_o = (CREG ? 1 : 0);
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b0110101;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = 0;
                               
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
                                mux_C_sel_o = 1;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b0110101;
                               
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
            ACC_SHIFT_0   : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 2;
                                mux_B_sel_o = 2;
                                mux_C_sel_o = 1;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b1101100;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = 0;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            M_P1          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 2;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b0100101;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = (CREG) ? 2 : 0;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 1;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 1;
                           
                            end
            ACC_SHIFT_1   : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 2;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b1101100;
                               
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
            A_B2          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 2;
                                mux_B_sel_o = 2;
                                mux_C_sel_o = (CREG) ? 2 : 0;
                                
                                CREG_en_o = (CREG) ? 1 : 0;
        
                                OPMODE_o = 7'b0100101;
                               
                                RES_delay_en_o = (CREG) ? 1 : 0;
                                
                                C_input_delay_en_o = 0;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 1;
                                
                                p_fetch_o = 0;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 0;
                           
                            end
            M_P2          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = (CREG) ? 2 : 2;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b0100101;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = (CREG) ? 0 : 1;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 0;
                                
                                p_fetch_o = 1;
                               
                                RES_push_o = 0;
                                
                                done_o = 0;
                                
                                
                                loop_counter_reset = 0;
                                
                                loop_counter_en = 1;
                           
                            end
            ACC_SHIFT     : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 2;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b1101100;
                               
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
            A_BJ          : begin
                           
                                a_reg_en_o = 0;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 2;
                                mux_B_sel_o = 2;
                                mux_C_sel_o = 2;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b0100101;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = 2;
                               
                                a_shift_o = 0;
                               
                                b_fetch_o = 1;
                                
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
                                mux_C_sel_o = 2;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b0100101;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = (CREG) ? 0 : 1;
                               
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
        
                                OPMODE_o = 7'b1100000;
                               
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
        
                                OPMODE_o = 7'b0100000;
                               
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
            RES_KEEP     : begin
                           
                                a_reg_en_o = 1;
                           
                                m_reg_en_o = 0;
        
                                mux_A_sel_o = 0;
                                mux_B_sel_o = 0;
                                mux_C_sel_o = 0;
                                
                                CREG_en_o = 1;
        
                                OPMODE_o = 7'b0100000;
                               
                                RES_delay_en_o = 0;
                                
                                C_input_delay_en_o = 0;
                               
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
