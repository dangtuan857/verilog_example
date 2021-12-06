`timescale 1ns/1ps
module uart_tb();

    reg clk,reset;
    reg wr_uart, rd_uart;
    reg [7:0] w_data;
    wire [7:0] r_data;
    


    uart #(
        .DBIT(8),
        .SB_TICK(16),
        .DVSR(163),
        .DVSR_BIT(8),
        .FIFO_W(2)
    ) uart_tx
    (
        .clk    ( clk     ),
        .reset  ( reset   ),
        .rd_uart(),
        .wr_uart( wr_uart ),
        .rx     ( rx      ),
        .w_data ( w_data  ),
        .tx_full(  ),
        .rx_empty( ),
        .tx     ( tx      ),
        .r_data ( )
    );


    uart #(
        .DBIT(8),
        .SB_TICK(16),
        .DVSR(163),
        .DVSR_BIT(8),
        .FIFO_W(2)
    ) uart_rx
    (
        .clk    ( clk     ),
        .reset  ( reset   ),
        .rd_uart( rd_uart ),
        .wr_uart( ),
        .rx     ( tx      ),
        .w_data ( ),
        .tx_full(  ),
        .rx_empty( ),
        .tx     ( tx      ),
        .r_data ( r_data)
    );

    initial begin
        clk = 0;
        forever #1 clk = !clk;
    end 

    initial begin
        reset = 1'b1;
        rd_uart = 1'b1;
        wr_uart = 1'b0;
        w_data = 8'b10000001;

        #10;
        reset = 1'b0;
        wr_uart = 1'b1;
        
        #10;
        wr_uart = 1'b0;
        
    end

endmodule