`timescale 1ns / 1ps

// This module describes a simple parametric variable width delay line.

module delay_line #(parameter WIDTH = 17,
                              DELAY = 2) (
    input clock_i, reset_i, en_i,
    
    
    input [WIDTH-1:0] data_i,
    
    
    output [WIDTH-1:0] data_o
    
    );
    
    
    reg [WIDTH-1:0] data_dly [0:DELAY];
    
    
    assign data_dly[0] = data_i;
    
    genvar i;
    
    generate
        for(i = 1; i < DELAY+1; i++) begin
            
            always @ (posedge clock_i) begin
        
                if (reset_i)
                    data_dly[i] = 0;    
                else if (en_i)
                    data_dly[i] <= data_dly[i-1];
                else
                    data_dly[i] <= data_dly[i];
                    
            end
            
        end
    endgenerate

    
    assign data_o = data_dly[DELAY];

    
endmodule
