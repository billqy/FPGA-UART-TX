`timescale 1ns / 1ps

module tb_UART_TX;

    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] tx_data;
    wire tx;
    wire busy;

    // Clock period (20 ns = 50 MHz)
    localparam CLK_PERIOD = 20;

    // Instantiate VHDL UART_TX module
    UART_TX uut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .busy(busy)
    );

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        reset = 1;
        tx_start = 0;
        tx_data = 8'h00;

        #(CLK_PERIOD * 1000);
        reset = 0;

        #(CLK_PERIOD * 10);

        // Send first byte (0xA5)
        tx_data = 8'hA5;
        tx_start = 1;
        // pulse tx_start for 2 clock cycles to ensure it is sampled by DUT
        #(CLK_PERIOD * 2);
        tx_start = 0;

        // Wait for the UART to accept and finish the transmission
        wait (busy == 1'b1);   // transmission/request started
        wait (busy == 1'b0);   // transmission finished

        #(CLK_PERIOD * 100);

        // Send second byte (0x3C)
        tx_data = 8'h3C;
        tx_start = 1;
        #(CLK_PERIOD * 2);
        tx_start = 0;

        wait (busy == 1'b1);
        wait (busy == 1'b0);
        
        #(CLK_PERIOD * 100);

        // Send third byte (0x3C)
        tx_data = 8'h1D;
        tx_start = 1;
        #(CLK_PERIOD * 2);
        tx_start = 0;

        wait (busy == 1'b1);
        wait (busy == 1'b0);

        #(CLK_PERIOD * 500);
        $finish;
    end

    initial begin
        $monitor("reset=%b tx_start=%b tx_data=%h tx=%b busy=%b",
                  reset, tx_start, tx_data, tx, busy);
    end

endmodule
