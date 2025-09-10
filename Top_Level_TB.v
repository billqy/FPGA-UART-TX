`timescale 1ns/1ps

module tb_Top_Level;

    localparam CLK_PERIOD = 20; // 50 MHz -> 20 ns

    reg clk;
    reg reset;
    reg input_signal;
    wire tx;

    Top_Level uut (
        .clk(clk),
        .reset(reset),
        .input_signal(input_signal),
        .tx(tx)
    );

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        reset = 1;
        input_signal = 0;

        #(CLK_PERIOD*10); 
        reset = 0;

        forever begin
            #(5_000_000);
            input_signal = ~input_signal;
        end
    end

    initial begin
        #(50_000_000);
        $finish;
    end

endmodule
