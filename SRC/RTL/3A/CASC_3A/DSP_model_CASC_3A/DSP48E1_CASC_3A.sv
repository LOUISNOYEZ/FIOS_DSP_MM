`timescale 1ns / 1ps


// This module is essentially a wrapper for the DSP48E2 arithmetic accelerator used in a Processing Element.
// The DSP multiplier is used as a 17x17 bits unsigned multiplier.
// Only the 34 least significant bits of DSP block output are non-zero During FIOS computation.
// The number of register levels on the multiplier path of the DSP Slice can be modified using the ABREG and MREG parameters.
// (PREG is always set to one).


module DSP48E1_CASC_3A #(parameter ABREG = 1,
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
    
    input [47:0] PCIN_i,


    output [33:0] P_o,
    
    output [47:0] PCOUT_o
    
    );


        wire [47:0] P;

    DSP48E1 #(
          .A_INPUT("DIRECT"),               // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
      .B_INPUT("DIRECT"),               // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
      .USE_DPORT("FALSE"),              // Select D port usage (TRUE or FALSE)
      .USE_MULT("MULTIPLY"),            // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
      .USE_SIMD("ONE48"),               // SIMD selection ("ONE48", "TWO24", "FOUR12")
      // Pattern Detector Attributes: Pattern Detection Configuration
      .AUTORESET_PATDET("NO_RESET"),    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
      .MASK(48'h3fffffffffff),          // 48-bit mask value for pattern detect (1=ignore)
      .PATTERN(48'h000000000000),       // 48-bit pattern match for pattern detect
      .SEL_MASK("MASK"),                // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
      .SEL_PATTERN("PATTERN"),          // Select pattern value ("PATTERN" or "C")
      .USE_PATTERN_DETECT("NO_PATDET"), // Enable pattern detect ("PATDET" or "NO_PATDET")
        .ACASCREG(ABREG),                  // Number of pipeline stages between A/ACIN and ACOUT (0-2)
        .ADREG(ABREG),                     // Pipeline stages for pre-adder (0-1)
        .ALUMODEREG(1),                    // Pipeline stages for ALUMODE (0-1)
        .AREG(ABREG),                      // Pipeline stages for A (0-2)
        .BCASCREG(ABREG),                  // Number of pipeline stages between B/BCIN and BCOUT (0-2)
        .BREG(ABREG),                      // Pipeline stages for B (0-2)
        .CARRYINREG(1),                    // Pipeline stages for CARRYIN (0-1)
        .CARRYINSELREG(1),                 // Pipeline stages for CARRYINSEL (0-1)
        .CREG(CREG),                          // Pipeline stages for C (0-1)
        .DREG(1),                          // Pipeline stages for D (0-1)
        .INMODEREG(1),                     // Pipeline stages for INMODE (0-1)
        .MREG(MREG),                       // Multiplier pipeline stages (0-1)
        .OPMODEREG(1),                     // Pipeline stages for OPMODE (0-1)
        .PREG(1)                           // Number of pipeline stages for P (0-1)
   )   
   DSP48E1_inst (
        .ACOUT(),              // 30-bit output: A port cascade
        .BCOUT(),              // 18-bit output: B cascade
        .CARRYCASCOUT(),       // 1-bit output: Cascade carry
        .MULTSIGNOUT(),        // 1-bit output: Multiplier sign cascade
        .PCOUT(PCOUT_o),              // 48-bit output: Cascade output
        // Control outputs: Control Inputs/Status Bits
        .OVERFLOW(),           // 1-bit output: Overflow in add/acc
        .PATTERNBDETECT(),     // 1-bit output: Pattern bar detect
        .PATTERNDETECT(),      // 1-bit output: Pattern detect
        .UNDERFLOW(),          // 1-bit output: Underflow in add/acc
        // Data outputs: Data Ports
        .CARRYOUT(),           // 4-bit output: Carry
        .P(P),                 // 48-bit output: Primary data
      // Cascade: 30-bit (each) input: Cascade Ports
        .ALUMODE(4'b0),        // 4-bit input: ALU control
        .CARRYINSEL(3'b0),     // 3-bit input: Carry select
        .CLK(clock_i),         // 1-bit input: Clock
        .INMODE(5'b00000),         // 5-bit input: INMODE control
        .OPMODE(OPMODE_i),     // 9-bit input: Operation mode
        // Cascade inputs: Cascade Ports
        .ACIN(),               // 30-bit input: A cascade data
        .BCIN(),               // 18-bit input: B cascade
        .CARRYCASCIN(),        // 1-bit input: Cascade carry
        .MULTSIGNIN(),         // 1-bit input: Multiplier sign cascade
        .PCIN(PCIN_i),               // 48-bit input: P cascade
      // Data: 30-bit (each) input: Data Ports
      .A({{13{1'b0}}, A_i}), // 30-bit input: A data
        .B({1'b0, B_i}),       // 18-bit input: B data
        .C({{14{1'b0}},C_i}),  // 48-bit input: C data
        .CARRYIN(1'b0),            // 1-bit input: Carry-in
        .D(25'b0),                  // 27-bit input: D data
        
      // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
        .CEA1(1'b1),           // 1-bit input: Clock enable for 1st stage AREG
        .CEA2(1'b1),           // 1-bit input: Clock enable for 2nd stage AREG
        .CEAD(1'b1),           // 1-bit input: Clock enable for ADREG
        .CEALUMODE(1'b1),      // 1-bit input: Clock enable for ALUMODE
        .CEB1(1'b1),           // 1-bit input: Clock enable for 1st stage BREG
        .CEB2(1'b1),           // 1-bit input: Clock enable for 2nd stage BREG
        .CEC(CREG_en_i),            // 1-bit input: Clock enable for CREG
        .CECARRYIN(1'b1),      // 1-bit input: Clock enable for CARRYINREG
        .CECTRL(1'b1),         // 1-bit input: Clock enable for OPMODEREG and CARRYINSELREG
        .CED(1'b1),            // 1-bit input: Clock enable for DREG
        .CEINMODE(1'b1),       // 1-bit input: Clock enable for INMODEREG
        .CEM(1'b1),            // 1-bit input: Clock enable for MREG
        .CEP(1'b1),            // 1-bit input: Clock enable for PREG
        .RSTA(1'b0),           // 1-bit input: Reset for AREG
        .RSTALLCARRYIN(1'b0),  // 1-bit input: Reset for CARRYINREG
        .RSTALUMODE(1'b0),     // 1-bit input: Reset for ALUMODEREG
        .RSTB(1'b0),           // 1-bit input: Reset for BREG
        .RSTC(1'b0),           // 1-bit input: Reset for CREG
        .RSTCTRL(1'b0),        // 1-bit input: Reset for OPMODEREG and CARRYINSELREG
        .RSTD(1'b0),           // 1-bit input: Reset for DREG and ADREG
        .RSTINMODE(1'b0),      // 1-bit input: Reset for INMODEREG
        .RSTM(1'b0),           // 1-bit input: Reset for MREG
        .RSTP(1'b0)         // 1-bit input: Reset for PREG
   );


    assign P_o = P[33:0];

endmodule
