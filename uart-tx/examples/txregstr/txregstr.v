//-----------------------------------------------------------------------------------------
//-- txstr: Uart_tx example 2
//-- Transmission of string
//-- The reset signal is connected to the dtr signal (in file txstr.pcf)
//-- Fot this example to work is necessary to open a serial terminal (gtkterm for example)
//-- and deactivate DTR. Every time a reset is done, a string appears on the terminal
//-- Fixed BAUDRATE: 115200
//-----------------------------------------------------------------------------------------
//-- (C) BQ. December 2015. Written by Juan Gonzalez (Obijuan)
//-- GPL license
//-----------------------------------------------------------------------------------------
`default_nettype none
`include "baudgen.vh"

//-- Top entity
module txstr #(
	parameter BAUDRATE = `B9600//`B115200
)(
	output wire tx,    //-- Serial data output
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


//-- Serial Unit instantation
uart_tx #(
	.BAUDRATE(BAUDRATE)  //-- Set the baudrate
) TX0 (
	.clk(clk),
	.rstn(1'b1),
	.data(data),
	.start(start),
	.tx(tx),
	.ready(ready)
);

//-- Connecting wires
wire ready;
wire start;
reg [7:0] data;

//-- Characters counter
//-- It only counts when the cena control signal is enabled
integer char_count;

reg [7:0] dataregs[0:127];

//--------------------- CONTROLLER

localparam INI = 0;
localparam TXCAR = 1;
localparam NEXTCAR = 2;
localparam STOP = 3;

//-- fsm state
reg [1:0] state;
reg [1:0] next_state;

//set initial values
initial begin
	//initial values
	state <= 0;
	next_state <= 0;
	char_count <= 0;
	start <= 0;
	
	{dataregs[0], dataregs[1], dataregs[2], dataregs[3], dataregs[4], dataregs[5], dataregs[6], dataregs[7], dataregs[8], dataregs[9], dataregs[10], dataregs[11], dataregs[12], dataregs[13], dataregs[14], dataregs[15]} <= {"R", "e", "g", "i", "s", "t", "e", "r", " ", "T", "e", "s", "t", "\0", "\r", "\n"};
end

//-- Control signal generation and next states
always @(posedge clk) begin

	data <= dataregs[char_count];

  case (state)
    //-- Initial state. Start the trasmission
    INI: begin
      start = 1;
      next_state = TXCAR;
    end

    //-- Wait until one car is transmitted
    TXCAR: begin
      if (ready) begin
        next_state = NEXTCAR;
      end
    end

    //-- Increment the character counter
    //-- Finish when it is the last character
    NEXTCAR: begin
      if (char_count == 15) begin
        next_state = STOP;
        char_count = 0;
        start = 0;
      end
      else begin
        next_state = INI;
        char_count = char_count + 1;
      end
    end

  endcase
  
  state <= next_state;
  
end

assign debugclk = clk;

endmodule
