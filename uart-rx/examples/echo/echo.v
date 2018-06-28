//----------------------------------------------------------------------------
//-- echo.v: Uart-rx example 2
//-- All the received characters are echoed
//----------------------------------------------------------------------------
//-- (C) BQ. December 2015. Written by Juan Gonzalez (Obijuan)
//-- GPL license
//----------------------------------------------------------------------------
`default_nettype none

`include "baudgen.vh"

//-- Top design
module echo #(
	parameter BAUDRATE = `B9600//115200
)(
	//input wire clk,         //-- System clock
	input wire rx,          //-- Serial input
	output wire tx,          //-- Serial output
	output reg [3:0] leds,   //-- Red leds
	output wire debugclk
);

wire intclk1;
wire intclk2;
wire clk;

//internal oscillator as clock
SB_HFOSC OSCInst0 (
	.CLKHFEN(1'b1),
	.CLKHFPU(1'b1),
	.CLKHF(intclk1)
);

//2 devide-by-2 clock dividers to divide 
//frequency from 50MHz to 12.5MHz
always @(posedge intclk1) begin
	intclk2 <= ~intclk2;
end

always @(posedge intclk2) begin
	clk <= ~clk;
end

//-- Received character signal
wire rcv;

//-- Received data
wire [7:0] data;

//-- Reset signal
reg rstn = 0;

//-- Transmitter ready signal
wire ready;

//-- Initialization
//always @(posedge clk)
//  rstn <= 1;

//-- Turn on all the red leds
//assign leds = 4'hF;

//-- Show the 4 less significant bits in the leds
//always @(posedge clk)
//  leds = data[3:0];

//-- Receiver unit instantation
uart_rx #(.BAUDRATE(BAUDRATE)) RX0 
(
	.clk(clk),
	.rstn(1'b1),
	.rx(rx),
	.rcv(rcv),
	.data(data)
);

//-- Transmitter unit instantation
uart_tx #(.BAUDRATE(BAUDRATE)) TX0 
(
	.clk(clk),
	.rstn(1'b1),
	.start(rcv),
	.data(data-8'b1),
	.tx(tx),
	.ready(ready)
);

assign leds = data[3:0];
assign debugclk = clk;

endmodule
