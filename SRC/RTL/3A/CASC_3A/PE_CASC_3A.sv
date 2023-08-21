`timescale 1ns / 1ps


module PE_CASC_3A #(parameter  int   ABREG = 1,
                       int   MREG = 1,
                       int   FIRST = 0,
            localparam int   DSP_REG_LEVEL = 1+ABREG+MREG,
            localparam int   FEEDBACK_DELAY = (DSP_REG_LEVEL == 1) ? 1 :
                                              (DSP_REG_LEVEL == 2) ? 1 :
                                              (DSP_REG_LEVEL == 3) ? 2 : 1) (

    input         clock_i,
        
    input         a_reg_en_i,
    
    input         m_reg_en_i,
    
    input  [1:0]  mux_A_sel_i,
    input  [1:0]  mux_B_sel_i, 
    input  [1:0] mux_C_sel_i,
    
    input         CREG_en_i,
    
    input  [6:0]  OPMODE_i,
    
    input         RES_delay_en_i,

    
    input  [16:0] p_prime_0_i,
    
    input  [16:0] a_i,
    
    input  [16:0] b_i,
    input  [16:0] p_i,
    

    input  [16:0] C_i,
    input  [16:0] C_input_1_delay_i,
    input  [16:0] C_input_2_delay_i,
    
    input [47:0] PCIN_i,
    input [16:0] PCIN_cancel_i,
        
    output [16:0] p_prime_0_o,
    
    output [16:0] RES_o,
    
    output [47:0] PCOUT_o,
    
    output [16:0] PCIN_cancel_o
    
    );


    // Signals CREG_en_i, mux_A_sel_i, mux_B_sel_i and mux_C_sel_i are registered for better performance.

    reg [1:0] mux_A_sel_reg;
    reg [1:0] mux_B_sel_reg;

    // An additional C input to the DSP block is used when DSP_REG_LEVEL = 3.
    reg [1:0] mux_C_sel_reg;
    
    reg RES_delay_en_reg;
    
    reg CREG_en_reg;
    
    reg a_reg_en_reg;
    
    reg m_reg_en_reg;
    
    always @ (posedge clock_i) begin

        mux_A_sel_reg <= mux_A_sel_i;
        mux_B_sel_reg <= mux_B_sel_i;
        mux_C_sel_reg <= mux_C_sel_i;
        RES_delay_en_reg <= (DSP_REG_LEVEL == 2 && FIRST != 1 && m_reg_en_i) ? 0 : RES_delay_en_i;
        CREG_en_reg <= (DSP_REG_LEVEL == 2 && FIRST != 1 && m_reg_en_i) ? 0 : CREG_en_i;
        a_reg_en_reg <= a_reg_en_i;
        m_reg_en_reg <= m_reg_en_i;
    
    end


    // Declaration of data signals
 
    reg [16:0] p_prime_0_reg;

    reg [16:0] a_reg;

    reg [16:0] m_reg;

    
    wire [33:0] RES;

    reg [33:0] RES_delay;    

    reg [16:0] C_reg;

    // Signals p_prime_0_i, a_i, b_i and p_i are registered for better performance.

    always @ (posedge clock_i)
        p_prime_0_reg <= p_prime_0_i;


    always @ (posedge clock_i) begin
    
        if (a_reg_en_reg)
            a_reg <= a_i;
        else
            a_reg <= a_reg;
    
    end

    always @ (posedge clock_i) begin
    
        if (m_reg_en_reg)
            m_reg <= RES[16:0];
        else
            m_reg <= m_reg;
    
    end
    

    // Declaration and multiplexing of DSP data input signals.

    reg [16:0] DSP_A_input;
    reg [16:0] DSP_B_input;
    reg [33:0] DSP_C_input;

    reg [16:0] RES_reg;
    
    always @ (posedge clock_i) begin

        RES_reg <= RES[16:0];
    
    end

    always_comb begin
    
        case (mux_A_sel_reg)
            0       : DSP_A_input <= a_reg;
            1       : DSP_A_input <= RES[16:0];
            2       : DSP_A_input <= m_reg;
            default : DSP_A_input <= 0;
        endcase
    
    end
    
    always_comb begin
    
        case (mux_B_sel_reg)
            0       : DSP_B_input <= b_i;
            1       : DSP_B_input <= p_prime_0_reg;
            2       : DSP_B_input <= p_i;
            default : DSP_B_input <= 0;
        endcase
    
    end
    
    
    // An additional delayed C input is used when DSP_REG_LEVEL = 3.

    generate
    
        always_comb begin
        
            case ((DSP_REG_LEVEL == 2 && FIRST != 1 && m_reg_en_i == 1) ? 1 :mux_C_sel_reg)
                0       : DSP_C_input <= C_i;
                1       : DSP_C_input <= RES_delay;
                2       : DSP_C_input <= C_input_1_delay_i;
                3       : DSP_C_input <= (DSP_REG_LEVEL == 3) ? C_input_2_delay_i : 0;
                default : DSP_C_input <= 0;
            endcase
            
        end
        
    endgenerate
    
    
        DSP48E1_CASC_3A #(.ABREG(ABREG), .MREG(MREG), .CREG(1)) DSP48E1_CASC_3A_inst (

        .clock_i   (clock_i),
        

        .CREG_en_i (CREG_en_reg),

        .OPMODE_i  (OPMODE_i),
        
        .A_i       (DSP_A_input),
        .B_i       (DSP_B_input),
        .C_i       (DSP_C_input),
        
        .PCIN_i(PCIN_i),
        
        
        
        .P_o       (RES),
        .PCOUT_o(PCOUT_o)
        
    );
    
    
    // DSP output delay logic used to capture partial results
    // fed to the C input of the DSP block at a later cycle.
    // Only DSP_REG_LEVEL 2 and 3 require additional logic.
    //The CREG register inside the DSP block is sufficient for DSP_REG_LEVEL 1. 

    reg [16:0] PCIN_cancel_reg;

    generate
        
        if (FIRST != 1) begin
        
            if (DSP_REG_LEVEL == 3) begin
            
                always @ (posedge clock_i) begin
                    if (m_reg_en_reg)
                        PCIN_cancel_reg <= 0;
                    else
                        PCIN_cancel_reg <= PCIN_cancel_i;
                end
                    
            end else begin
            
                always @ (posedge clock_i)
                    PCIN_cancel_reg <= PCIN_cancel_i;
            
            end
            
        end
        
        if(DSP_REG_LEVEL == 2) begin
        
            always @ (posedge clock_i)
                    PCIN_cancel_reg <= PCIN_cancel_i;
    
            reg m_reg_en_reg_delay;
            
            always @ (posedge clock_i)
                m_reg_en_reg_delay <= m_reg_en_reg;
                
            reg [34:0] RES_delay_prime;
            
            always @ (posedge clock_i) begin
                if (RES_delay_en_reg)
                    RES_delay_prime <= {RES[33:17]-PCIN_cancel_reg, RES[16:0]};
                else
                    RES_delay_prime <= RES_delay_prime;
            end
                
            assign RES_delay = m_reg_en_reg_delay ? {RES[33:17]-PCIN_cancel_reg, RES[16:0]} : RES_delay_prime;
            
        end else begin
        
            delay_line #(.WIDTH(34), .DELAY(FEEDBACK_DELAY-1)) RES_delay_inst (
                .clock_i(clock_i), .reset_i(1'b0), .en_i((DSP_REG_LEVEL == 1) ? 1'b1 : RES_delay_en_reg),
                
                .data_i((FIRST == 1) ? RES : {RES[33:17]-PCIN_cancel_reg, RES[16:0]}),
                
                .data_o(RES_delay)
                
            );
        
        end
    endgenerate

    
    // Outputs and the p_prime_0 value are propagated to the next PE in the chain.

    assign p_prime_0_o = p_prime_0_reg;

    assign RES_o = RES[16:0];
    
    assign PCIN_cancel_o = RES[33:17];
    
    
endmodule
