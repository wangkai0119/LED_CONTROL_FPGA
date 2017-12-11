`timescale 1ns/1ns

`include "ledCtrl_define.v"
`include "i2cSlave_define.v" 

//`define QII
//`define iCE

module top_LEDs_ctrl (
	input	ext_rst_i,						//low-level reset
	input	clk_i,							//external clock
	input	scl_i,							//iic_sclk
	inout	sda_io,							//iic_sdata	
	output	busy_o,							//indicate_flag output 	
	output	[`LED_NUM-1:0]	led_pwm_o		//LED PWM output
);    
 
 /*
 `ifdef QII
 ******************
`endif
*/
 
//parameter

 
//reg
wire sysclk;
assign sysclk = clk_i;

wire rst_n;
wire busyFlag;
assign busy_o = busyFlag;

wire  reset_reg;
wire [7:0] timer_reg;

wire timer_int;
wire timer_on;

wire [5:0] load_cnt;
wire [7:0] pwm_parm;

wire sdaDebIn;
wire clearStartStopDet;

wire rstSerialI2c;
wire sclDly;
wire sdaDebOut;
wire [1:0] startStopDetState;

wire [7:0] iicDataIn;
wire [7:0] iicDataOut;
wire [7:0] regAddr;
wire [6:0] devAddr;
wire writeEn;

wire ramWren;
wire [7:0] ramData;
wire [12:0] wrRamAddr;
wire [12:0] rdRamAddr;

wire [`LED_NUM-1:0] led_pwm;

reg [`LED_NUM-1:0] led_pwm1;


//********************************************//
//pll4div u00_pll4div(
//	.inclk0(clk_i),
//	.c0(sysclk)
//);


sys_reset u0_sys_reset(
	.sysclk(sysclk),
	.ext_rst(ext_rst_i),
//	.ext_rst(1'b1),
	.reset_reg(reset_reg),
	.rst_n(rst_n)
);

i2cSlave_debounce u1_i2cSlave_debounce(
	.rst(rst_n),
	.clk(sysclk),
	.sda(sda_io),
	.scl(scl_i),
	.sdaDebIn(sdaDebIn),
	.clearStartStopDet(clearStartStopDet),  
	.rstSerialI2c(rstSerialI2c),
	.sclDly(sclDly),
	.sdaDebOut(sdaDebOut),
	.startStopDetState(startStopDetState)
);
 
serialInterface u2_serialInterface(
	.clearStartStopDet(clearStartStopDet), 
	.clk(sysclk),
	.rst(rstSerialI2c),
	.scl(sclDly),
	.sdaIn(sdaDebOut), 
	.sdaOut(sdaDebIn), 
	.startStopDetState(startStopDetState),
	.dataIn(iicDataOut),
	.dataOut(iicDataIn),
	.regAddr(regAddr), 
	.devAddr(devAddr), 
	.writeEn(writeEn)
);

main_state_ctrl u3_main_state_ctrl(
	.rst_n(rst_n),
	.clk(sysclk),
	.dev_addr(devAddr),
	.reg_addr(regAddr),
	.iicDataIn(iicDataIn),
	.writeEn(writeEn),
	.iicDataOut(iicDataOut),
	.ramData(ramData),
	.wrRamAddr(wrRamAddr),
	.rdRamAddr(rdRamAddr),	
	.ramWren(ramWren),
	.busyFlag(busyFlag),
	.rstReg(reset_reg),
	.pwm_parm(pwm_parm),
	.led_pwm_o(led_pwm_o)
); 

RAM_128page	u4_RAM_128page(
	.data(ramData),
	.wraddress(wrRamAddr),
	.wrclock(sysclk),
	.wren(ramWren),	
	.rdaddress(rdRamAddr),
	.rdclock(sysclk),
	.q(pwm_parm)
);

 
 endmodule