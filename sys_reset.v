`timescale 1ns/1ns

`include "ledCtrl_define.v"

module sys_reset (
	sysclk,				
	ext_rst,
	reset_reg,	
	rst_n	
);

input sysclk;				
input ext_rst;
input reset_reg;	
output	rst_n;

reg rst_n;

// poweron_rst, hold on '0' with POWERON_RST_LEN ticks; 
reg poweron_rst;
reg [3:0] poweron_cnt = 4'b0000; 

always @ (posedge sysclk) begin
	if(poweron_cnt == `POWERON_RST_LEN) begin
		poweron_rst <= 1'b1;
		poweron_cnt <= poweron_cnt;
	end
	else begin
		poweron_rst <= 1'b0;
		poweron_cnt <= poweron_cnt + 4'b0001;
	end
end


// ext_rst, hold on '0' with EXT_RST_LEN ticks;
reg [15:0] ext_rst_cnt ;

always @ (posedge sysclk) begin
	if(poweron_rst == 1'b0 || ext_rst == 1'b1) 
		ext_rst_cnt <= 16'h0000;
	else if(ext_rst == 1'b0) begin
		if(ext_rst_cnt == `EXT_RST_LEN) 
			ext_rst_cnt <= ext_rst_cnt;
		else
			ext_rst_cnt <= ext_rst_cnt + 16'h0001;
	end
end

// reg_rst, hold on '0' with RST_DET_LEN ticks;
reg [5:0] reg_rst_cnt ;

always @ (posedge sysclk) begin
	if(poweron_rst == 1'b0 || ext_rst_cnt == `EXT_RST_LEN || reset_reg == 1'b1) begin //
		rst_n <= 1'b0;
		reg_rst_cnt <= 6'h00;
	end
	else if(reg_rst_cnt == `REG_RST_LEN) begin
		rst_n <= 1'b1;
		reg_rst_cnt <= reg_rst_cnt;
	end
	else begin
		rst_n <= 1'b0;
		reg_rst_cnt <= reg_rst_cnt + 6'h01;	
	end
end

endmodule