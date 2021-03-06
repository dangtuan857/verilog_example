module uart 
#(  // Default setting: 
    // 19,200 baud, 8 data bits , 1 stop bit, 2**2 FIFO 
parameter   DBIT = 8,       // # data bits + parity bit 
            SB_TICK = 16,   // # ticks for stop bits , 
                            // 16/24/32 for 1/1.5/2 bits 
            DVSR = 163,     // baud rate divisor 
                            // DVSR = 50M/(16* baud rate) 
            DVSR_BIT = 8,   // # bits of DVSR = log2(DVSR)
            FIFO_W = 2      // # addr bits of FIFO 
                            // # words in FIFO=2**FIFO_W 
)
();

reg clk, reset;
wire wr_uart; 
wire [DBIT-1:0] w_data;
wire  tx; 

 
// signal declaration 
wire tick , tx_done_tick; 
wire tx_empty, tx_fifo_not_empty; 



assign tx_fifo_not_empty = !tx_empty;

//body 
mod_m_counter#(
    .M(DVSR), 
    .N(DVSR_BIT)) 
baud_gen_unit (
    .clk(clk) , 
    .reset(reset), 
    .q(), 
    .max_tick(tick)
    ) ;

uart_tx #( 
    .DBIT(DBIT), 
    .SB_TICK(SB_TICK) 
    ) 
uart_tx_unit( 
    .clk(clk), 
    .reset(reset), 
    .tx_start(tx_fifo_not_empty),
    .s_tick(tick), 
    .din(wr_uart), 
    .tx_done_tick(tx_done_tick), 
    .tx(tx) 
);

    initial begin
        clk = 0;
        forever #1 clk = !clk;
    end 

    initial begin
        reset = 1'b1;
        wr_uart = 1'b0;
        w_data = 8'b10000001;
        tx_empty = 1'b1;

        
        #20;
        reset = 1'b0;
        wr_uart = 1'b1;
        tx_empty = 1'b0;
        
        #20;
        wr_uart = 1'b0;
    end

endmodule