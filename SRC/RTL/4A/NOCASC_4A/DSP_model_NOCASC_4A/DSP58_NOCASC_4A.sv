module DSP58_NOCASC_4A #(parameter ABREG = 1,
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


    output [33:0] P_o
    
    );


    wire [47:0] P;

DSP58 #(
      // Feature Control Attributes: Data Path Selection
      .AMULTSEL("A"),                    // Selects A input to multiplier (A, AD)
      .A_INPUT("DIRECT"),                // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
      .BMULTSEL("B"),                    // Selects B input to multiplier (AD, B)
      .B_INPUT("DIRECT"),                // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
      .DSP_MODE("INT24"),                // Configures DSP to a particular mode of operation. Set to INT24 for
                                         // legacy mode.
      .PREADDINSEL("A"),                 // Selects input to pre-adder (A, B)
      .RND(58'h000000000000000),         // Rounding Constant
      .USE_MULT("MULTIPLY"),             // Select multiplier usage (DYNAMIC, MULTIPLY, NONE)
      .USE_SIMD("ONE58"),                // SIMD selection (FOUR12, ONE58, TWO24)
      .USE_WIDEXOR("FALSE"),             // Use the Wide XOR function (FALSE, TRUE)
      .XORSIMD("XOR24_34_58_116"),       // Mode of operation for the Wide XOR (XOR12_22, XOR24_34_58_116)
      // Register Control Attributes: Pipeline Register Configuration
      .ACASCREG(1),                      // Number of pipeline stages between A/ACIN and ACOUT (0-2)
      .ADREG(ABREG),                         // Pipeline stages for pre-adder (0-1)
      .ALUMODEREG(1),                    // Pipeline stages for ALUMODE (0-1)
      .AREG(ABREG),                          // Pipeline stages for A (0-2)
      .BCASCREG(1),                      // Number of pipeline stages between B/BCIN and BCOUT (0-2)
      .BREG(ABREG),                          // Pipeline stages for B (0-2)
      .CARRYINREG(1),                    // Pipeline stages for CARRYIN (0-1)
      .CARRYINSELREG(1),                 // Pipeline stages for CARRYINSEL (0-1)
      .CREG(CREG),                          // Pipeline stages for C (0-1)
      .DREG(1),                          // Pipeline stages for D (0-1)
      .INMODEREG(1),                     // Pipeline stages for INMODE (0-1)
      .MREG(MREG),                          // Multiplier pipeline stages (0-1)
      .OPMODEREG(1),                     // Pipeline stages for OPMODE (0-1)
      .PREG(1),                          // Number of pipeline stages for P (0-1)
      .RESET_MODE("SYNC")                // Selection of synchronous or asynchronous reset. (ASYNC, SYNC).
   )
   DSP58_inst (
      // Cascade outputs: Cascade Ports
      .ACOUT(),                   // 34-bit output: A port cascade
      .BCOUT(),                   // 24-bit output: B cascade
      .CARRYCASCOUT(),     // 1-bit output: Cascade carry
      .MULTSIGNOUT(),       // 1-bit output: Multiplier sign cascade
      .PCOUT(),                   // 58-bit output: Cascade output
      // Control outputs: Control Inputs/Status Bits
      .OVERFLOW(),             // 1-bit output: Overflow in add/acc
      .PATTERNBDETECT(), // 1-bit output: Pattern bar detect
      .PATTERNDETECT(),   // 1-bit output: Pattern detect
      .UNDERFLOW(),           // 1-bit output: Underflow in add/acc
      // Data outputs: Data Ports
      .CARRYOUT(),             // 4-bit output: Carry
      .P(P),                           // 58-bit output: Primary data
      .XOROUT(),                 // 8-bit output: XOR data
      // Cascade inputs: Cascade Ports
      .ACIN(),                     // 34-bit input: A cascade data
      .BCIN(),                     // 24-bit input: B cascade
      .CARRYCASCIN(),       // 1-bit input: Cascade carry
      .MULTSIGNIN(),         // 1-bit input: Multiplier sign cascade
      .PCIN(),                     // 58-bit input: P cascade
      // Control inputs: Control Inputs/Status Bits
      .ALUMODE(4'b0),               // 4-bit input: ALU control
      .CARRYINSEL(3'b0),         // 3-bit input: Carry select
      .CLK(clock_i),                       // 1-bit input: Clock
      .INMODE(5'b0),                 // 5-bit input: INMODE control
      .NEGATE(0),                 // 3-bit input: Negates the input of the multiplier
      .OPMODE(OPMODE_i),                 // 9-bit input: Operation mode
      // Data inputs: Data Ports
      .A({{17{1'b0}},A_i}),                           // 34-bit input: A data
      .B({{7{1'b0}},B_i}),                           // 24-bit input: B data
      .C({{10{1'b0}},C_i}),                           // 58-bit input: C data
      .CARRYIN(0),               // 1-bit input: Carry-in
      .D(),                           // 27-bit input: D data
      // Reset/Clock Enable inputs: Reset/Clock Enable Inputs
      .ASYNC_RST(1'b0),           // 1-bit input: Asynchronous reset for all registers.
      .CEA1(1'b1),                     // 1-bit input: Clock enable for 1st stage AREG
      .CEA2(1'b1),                     // 1-bit input: Clock enable for 2nd stage AREG
      .CEAD(1'b1),                     // 1-bit input: Clock enable for ADREG
      .CEALUMODE(1'b1),           // 1-bit input: Clock enable for ALUMODE
      .CEB1(1'b1),                     // 1-bit input: Clock enable for 1st stage BREG
      .CEB2(1'b1),                     // 1-bit input: Clock enable for 2nd stage BREG
      .CEC(CREG_en_i),                       // 1-bit input: Clock enable for CREG
      .CECARRYIN(1'b1),           // 1-bit input: Clock enable for CARRYINREG
      .CECTRL(1'b1),                 // 1-bit input: Clock enable for OPMODEREG and CARRYINSELREG
      .CED(1'b1),                       // 1-bit input: Clock enable for DREG
      .CEINMODE(1'b1),             // 1-bit input: Clock enable for INMODEREG
      .CEM(1'b1),                       // 1-bit input: Clock enable for MREG
      .CEP(1'b1),                       // 1-bit input: Clock enable for PREG
      .RSTA(1'b0),                     // 1-bit input: Reset for AREG
      .RSTALLCARRYIN(1'b0),   // 1-bit input: Reset for CARRYINREG
      .RSTALUMODE(1'b0),         // 1-bit input: Reset for ALUMODEREG
      .RSTB(1'b0),                     // 1-bit input: Reset for BREG
      .RSTC(1'b0),                     // 1-bit input: Reset for CREG
      .RSTCTRL(1'b0),               // 1-bit input: Reset for OPMODEREG and CARRYINSELREG
      .RSTD(1'b0),                     // 1-bit input: Reset for DREG and ADREG
      .RSTINMODE(1'b0),           // 1-bit input: Reset for INMODE register
      .RSTM(1'b0),                     // 1-bit input: Reset for MREG
      .RSTP(1'b0)                      // 1-bit input: Reset for PREG
   );
   
   assign P_o = P[33:0];
   
endmodule
