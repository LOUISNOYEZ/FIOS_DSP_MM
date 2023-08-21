`timescale 1ns / 1ps


module generic_DSP_CASC_4A #(parameter ABREG = 1,
                         MREG = 1,
                         CREG = 1,
               localparam DSP_REG_LEVEL = 1+ABREG+MREG) (
               
    input clock_i,


    // The CREG registered C input to the additioner of the DSP is enabled using the CREG_en_i signal.    
    input CREG_en_i,


    // DSP block operation are selected using the OPMODE signal.
    input [8:0] OPMODE_i,


    input [16:0] A_i,
    input [16:0] B_i,
    input [33:0] C_i,
    
    input [47:0] PCIN_i,


    output [33:0] P_o,
    
    output [47:0] PCOUT_o,
    
    );

    reg [8:0] OPMODE;
    
    always @ (posedge clock_i)
        OPMODE <= OPMODE_i;

    reg [29:0] A;
    reg [17:0] B;
    reg [47:0] M;
    reg [47:0] C;
    reg [47:0] P;

    generate
        if (ABREG == 1) begin
        
            always @ (posedge clock_i) begin
                A <= {{13{1'b0}}, A_i};
                B <= {1'b0, B_i};
            end
            
        end else begin
        
            assign A = A_i;
            assign B = B_i;
            
        end
    endgenerate
    
    generate
        if (MREG == 1) begin
        
            always @ (posedge clock_i) begin
                M <= A*B;
            end
            
        end else begin
        
            assign M = A*B;
            
        end
    endgenerate
    
    generate
        if (CREG == 1) begin
            
            always @ (posedge clock_i) begin
                if (CREG_en_i)
                    C <= C_i;
                else
                    C <= C;
            end
                
        end else begin
        
            assign C = C_i;
            
        end
    endgenerate
    
    reg [47:0] XY, Z, W;
    
    always_comb begin
        case (OPMODE[8:7])
            2'b00 : W <= 0;
            2'b11 : W <= C;
            default : W <= 0;
        endcase
    end
    
    always_comb begin
        case (OPMODE[3:0])
            4'b0000 : XY <= 0;
            4'b0101 : XY <= M;
            default : XY <= 0;
        endcase
    end
    
    always_comb begin
        case (OPMODE[6:4])
            3'b000 : Z <= 0;
            3'b110 : Z <= P >> 17;
            3'b010 : Z <= P;
            3'b001 : Z <= PCIN_i;
            default : Z <= 0;
        endcase
    end

    always @ (posedge clock_i)
        P <= XY + Z + W;


    assign P_o = P[33:0];
    
    assign PCOUT_o = P;

endmodule
