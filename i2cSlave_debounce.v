`timescale 1ns/1ns
`include "i2cSlave_define.v"

module i2cSlave_debounce (
  rst,
  clk,
  sda,
  scl,
  sdaDebIn,
  clearStartStopDet,  
  rstSerialI2c,
  sclDly,
  sdaDebOut,
  startStopDetState
); 

input clk;
input rst;
inout sda;
input scl;
input sdaDebIn;
input clearStartStopDet;

output rstSerialI2c;
output sclDly;
output sdaDebOut;
output [1:0] startStopDetState;


// local wires and regs
reg sdaDeb;
reg sclDeb;
reg [`DEB_I2C_LEN-1:0] sdaPipe;
reg [`DEB_I2C_LEN-1:0] sclPipe;

reg [`SCL_DEL_LEN-1:0] sclDelayed;
reg [`SDA_DEL_LEN-1:0] sdaDelayed;
reg [1:0] startStopDetState;
reg [1:0] rstPipe;
wire rstSyncToClk;
reg startEdgeDet;


assign sclDly = sclDelayed[`SCL_DEL_LEN-1];
assign sdaDebOut = sdaDeb;

assign sda = (sdaDebIn == 1'b0) ? 1'b0 : 1'bz;
assign sdaIn = sda;


assign rstSyncToClk = ~rst;

assign rstSerialI2c = rstSyncToClk | startEdgeDet;


// debounce sda and scl
always @(posedge clk) begin
  if (rstSyncToClk == 1'b1) begin
    sdaDeb <= 1'b1;
    sclDeb <= 1'b1;
  end
  else begin
      sclDeb <= scl;
      sdaDeb <= sdaIn;
  end
end


// delay scl and sda
// sclDelayed is used as a delayed sampling clock
// sdaDelayed is only used for start stop detection
// Because sda hold time from scl falling is 0nS
// sda must be delayed with respect to scl to avoid incorrect
// detection of start/stop at scl falling edge. 
always @(posedge clk) begin
  if (rstSyncToClk == 1'b1) begin
    sclDelayed <= {`SCL_DEL_LEN{1'b1}};
    sdaDelayed <= {`SDA_DEL_LEN{1'b1}};
  end
  else begin
    sclDelayed <= {sclDelayed[`SCL_DEL_LEN-2:0], sclDeb};
    sdaDelayed <= {sdaDelayed[`SDA_DEL_LEN-2:0], sdaDeb};
  end
end

// start stop detection
always @(posedge clk) begin
  if (rstSyncToClk == 1'b1) begin
    startStopDetState <= `NULL_DET;
    startEdgeDet <= 1'b0;
  end
  else begin
    if (sclDeb == 1'b1 && sdaDelayed[`SDA_DEL_LEN-2] == 1'b0 && sdaDelayed[`SDA_DEL_LEN-1] == 1'b1)
      startEdgeDet <= 1'b1;
    else
      startEdgeDet <= 1'b0;
    if (clearStartStopDet == 1'b1)
      startStopDetState <= `NULL_DET;
    else if (sclDeb == 1'b1) begin
      if (sdaDelayed[`SDA_DEL_LEN-2] == 1'b1 && sdaDelayed[`SDA_DEL_LEN-1] == 1'b0) 
        startStopDetState <= `STOP_DET;
      else if (sdaDelayed[`SDA_DEL_LEN-2] == 1'b0 && sdaDelayed[`SDA_DEL_LEN-1] == 1'b1)
        startStopDetState <= `START_DET;
    end
  end
end


endmodule