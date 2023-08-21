module DSP48_NOCASC_3A #(parameter ABREG = 1,
                         MREG = 1,
                         CREG = 1,
               localparam DSP_REG_LEVEL = 1+ABREG+MREG) (
               
    input clock_i,


    // The CREG registered C input to the additioner of the DSP is enabled using the CREG_en_i signal.    
    input CREG_en_i,


    // DSP block operation are selected using the OPMODE signal.
    input [6:0] OPMODE_i,


    input [16:0] A_i,
    input [16:0] B_i,
    input [33:0] C_i,
    

    output [33:0] P_o,
    
    );


        wire [47:0] P;

    DSP48 #(
    
    .AREG(ABREG),
    .BREG(ABREG),
    .B_INPUT("DIRECT"),
    .CARRYINREG(1),
    .CARRYINSELREG(1),
    .CREG(CREG),
    .LEGACY_MODE("MULT18X18S"),
    .MREG(MREG),
    .OPMODEREG(1),
    .PREG(1),
    .SUBTRACTREG(1))
    DSP48_inst(
    .BCOUT(), 
    .P(P), 
    .PCOUT(),

    .A({1'b0, A_i}),
    .B({1'b0, B_i}),
    .BCIN(),
    .C(C_i),
    .CARRYIN(),
    .CARRYINSEL(),
    .CEA(1'b1),
    .CEB(1'b1),
    .CEC(CREG_en_i),
    .CECARRYIN(1'b1),
    .CECINSUB(1'b1),
    .CECTRL(1'b1),
    .CEM(1'b1),
    .CEP(1'b1),
    .CLK(clock_i),
    .OPMODE(OPMODE_i),
    .PCIN(),
    .RSTA(1'b0),
    .RSTB(1'b0),
    .RSTC(1'b0),
    .RSTCARRYIN(1'b0),
    .RSTCTRL(1'b0),
    .RSTM(1'b0),
    .RSTP(1'b0),
    .SUBTRACT(),
    );

    assign P_o = P[33:0]

endmodule
