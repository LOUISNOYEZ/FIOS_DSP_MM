module DSP48E_NOCASC_3A #(parameter ABREG = 1,
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
    

    output [33:0] P_o 
    );


        wire [47:0] P;

DSP48E #( 

    .SIM_MODE("SAFE"),

    .ACASCREG(ABREG),
    .ALUMODEREG(1),
    .AREG(ABREG),
    .AUTORESET_PATTERN_DETECT("FALSE"), // Changed HHK
    .AUTORESET_PATTERN_DETECT_OPTINV("MATCH"),
    .A_INPUT("DIRECT"),
    .BCASCREG(ABREG),
    .BREG(ABREG),
    .B_INPUT("DIRECT"),
    .CARRYINREG(1),
    .CARRYINSELREG(1),
    .CREG(CREG),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(MREG),
    .MULTCARRYINREG(1),
    .OPMODEREG(1),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .SEL_ROUNDING_MASK("SEL_MASK"),
    .USE_MULT("MULT_S"), //Changed HHK

    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48"))

    DSP48E_inst (
    .ACOUT(), 
    .BCOUT(), 
    .CARRYCASCOUT(),
    .CARRYOUT(),
    .MULTSIGNOUT(),
    .OVERFLOW(),
    .P(P),
    .PATTERNBDETECT(),
    .PATTERNDETECT(),
    .PCOUT(PCOUT_o),
    .UNDERFLOW(),

    .A({{13{1'b0}}, A_i}),
    .ACIN(),
    .ALUMODE(4'b0),
    .B({1'b0, B_i}),
    .BCIN(),
    .C({{14{1'b0}},C_i}),
    .CARRYCASCIN(),
    .CARRYIN(0),
    .CARRYINSEL(0),
    .CEA1(1'b1),
    .CEA2(1'b1),
    .CEALUMODE(1'b1),
    .CEB1(1'b1),
    .CEB2(1'b1),
    .CEC(CREG_en_i),
    .CECARRYIN(1'b1),
    .CECTRL(1'b1),
    .CEM(1'b1),
    .CEMULTCARRYIN(1'b1),
    .CEP(1'b1),
    .CLK(clock_i),
    .MULTSIGNIN(1'b1),
    .OPMODE(OPMODE_i),
    .PCIN(PCIN_i),
    .RSTA(1'b0),
    .RSTALLCARRYIN(1'b0),
    .RSTALUMODE(1'b0),
    .RSTB(1'b0),
    .RSTC(1'b0),
    .RSTCTRL(1'b0),
    .RSTM(1'b0),  
    .RSTP(1'b0));
    
    assign P_o = P[33:0];
    
endmodule
