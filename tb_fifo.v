`timescale  1ns / 1ps
`include "fifo.v"
module tb_fifo;
    
    // fifo Parameters
    parameter PERIOD = 1;
    parameter B      = 8;
    
    // fifo Inputs
    reg   clk             ;
    reg   reset           ;
    reg   rd              ;
    reg   wr              ;
    reg   [B-1:0]  w_data  ;
    
    // fifo Outputs
    wire  empty;
    wire  full;
    wire  [B-1:0]  r_data;


fifo#(
    .B    (8),
    .W    (2)
)u_fifo(
    .clk    ( clk    ),
    .reset  ( reset  ),
    .rd     ( rd     ),
    .wr     ( wr     ),
    .w_data ( w_data ),
    .empty  ( empty  ),
    .full   ( full   ),
    .r_data  ( r_data  )
);

    
    initial
    begin
        forever #1  clk = ~clk;
    end
    
    
    initial
    begin
        clk    = 0 ;
        reset  = 1 ;
        rd     = 0 ;
        wr     = 0 ;
        w_data = 0 ;
        
        #1;
        reset = 0;
        wr = 1;
        w_data = 2;
        
        #2;
        w_data = 8;

        #2;
        w_data = 5;

        #2;
        w_data = 5;

        #2;
        w_data = 1;

        #2;
        w_data = 8;
        
        #1;
        rd = 1;

        #10;
        $finish;
    end
    
    initial
    begin
        $dumpfile("tb_fifo.vcb");
        $dumpvars(0,tb_fifo);
        $monitor("Time = %g ,full= %b,empty = %b,rd = %b, wr = %b , w_data = %b, r_data = %b \n",$time,full,empty,rd,wr,w_data,r_data);
    end

endmodule
