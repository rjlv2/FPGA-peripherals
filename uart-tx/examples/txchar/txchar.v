//-----------------------------------------------------------------------------------------
//-- txchar: Uart_tx example 1
//-- Continuous transmission of a character when the DTR signal is activated
//-- The reset signal is connected to the dtr signal (in file txchar.pcf)
//-- Fot this example to work is necessary to open a serial terminal (gtkterm for example)
//-- and deactivate DTR. A lot of "A" will be received on the terminal
//-- Fixed BAUDRATE: 115200
//-----------------------------------------------------------------------------------------
//-- (C) BQ. December 2015. Written by Juan Gonzalez (Obijuan)
//-- GPL license
//-----------------------------------------------------------------------------------------
`default_nettype none
`include "baudgen.vh"

//-- Top entity
module txchar (
          output wire tx,    //-- Serial data output
          output wire debugclk
);

//clock signal from internal oscillator
wire intclk;
wire clk1;
wire clk;

SB_HFOSC OSCInst0 (
	.CLKHFEN(1'b1),
	.CLKHFPU(1'b1),
	.CLKHF(intclk)
);

//clock dividers to convert clock signal
//from 50MHz to 12.5 MHz
initial begin
	clk1 <= 0;
	clk <= 0;
end

always @(posedge intclk) begin
	clk1 <= ~clk1;
end

always @(posedge clk1) begin
	clk <= ~clk;
end

//-- Serial Unit instantation
uart_tx #(
    .BAUDRATE(`B9600)//115200)  //-- Set the baudrate
  ) TX0 (
    .clk(clk),
    .rstn(1'b1),
    .data("!"),    //-- Fixed character to transmit (always the same)
    .start(1'b1),  //-- Start signal always set to 1
    .tx(tx)
);                 //-- Port ready not used

assign debugclk = clk; //clock for debugging

endmodule
