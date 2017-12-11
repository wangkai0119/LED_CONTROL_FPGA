`timescale 1ns/1ns

`include "ledCtrl_define.v"
`include "i2cSlave_define.v"

//// -- when PWM = 1, off -- //
//`define ledOff_All 36'hFFFFFFFFF 
//`define ledOn_All 36'h000000000
//`define ledOff 1'b1 
//`define ledOn 1'b0 

// -- when PWM = 0, off -- //
`define ledOff_All 36'h000000000
`define ledOn_All 36'hFFFFFFFFF 
`define ledOff 1'b0 
`define ledOn 1'b1  
 
module main_state_ctrl (
	rst_n,
	clk,
	dev_addr,
	reg_addr,
	iicDataIn, 
	writeEn,
	iicDataOut, 
	ramData,
	wrRamAddr,
	rdRamAddr,	
	ramWren,
	busyFlag,
	rstReg,  
	pwm_parm,
	led_pwm_o	
);     
 
input rst_n;
input clk;
input [6:0] dev_addr;
input [7:0] reg_addr;
input [7:0] iicDataIn;
input writeEn;
input [7:0] pwm_parm;

output [7:0] iicDataOut;
output [7:0] ramData;
output [12:0] wrRamAddr;
output [12:0] rdRamAddr;
output ramWren; 
output busyFlag;
output rstReg;
output	[`LED_NUM-1:0] led_pwm_o;	//LEDs PWM output

wire [`LED_NUM-1:0] led_pwm_tmp;

reg [7:0] iicDataOut;
reg busyFlag;
reg [5:0] load_cnt;
//reg [12:0] w_addr;
reg [12:0] r_addr;

reg [10:0]CurrState, NextState; 

reg delayEnaFlag;
reg	[24:0] powerOnDelayCnt;

//assign wrRamAddr = w_addr;
assign rdRamAddr = r_addr;
assign ramWren = (dev_addr[0] == 1'b1  && CurrState == `IDLE)? writeEn : 0; 


//--------------------------------------------------//
reg rstReg;						//00H
reg onOffReg;					//01H
//reg [7:0] busyReg;				//02H
wire [7:0] busyReg;				//02H
reg [7:0] pageNumReg;			//03H 
reg [7:0] timerReg;				//04H 
reg [7:0] initPageReg;			//05H
reg [7:0] endPageReg;			//06H
reg [7:0] pageLoopNumReg;		//07H
reg [7:0] stepLenReg;			//08H
reg loopDirReg;					//09H
reg [7:0] loopNumReg;			//0AH
reg [7:0] ledPositionReg;		//0BH
reg holdLastStatusReg;				//0CH
//--------------------------------------------------//



//**************************************************//
// --- I2C Read
always @(dev_addr, reg_addr) begin
	if(dev_addr[0] == 1'b0) begin
		case(reg_addr[3:0])
		4'h0: iicDataOut = rstReg? 8'hFF : 8'h00;
		4'h1: iicDataOut = onOffReg? 8'hFF : 8'h00;
		4'h2: iicDataOut = busyReg;
		4'h3: iicDataOut = pageNumReg;
		4'h4: iicDataOut = timerReg;
		4'h5: iicDataOut = initPageReg;
		4'h6: iicDataOut = endPageReg;
		4'h7: iicDataOut = pageLoopNumReg;
		4'h8: iicDataOut = stepLenReg;
		4'h9: iicDataOut = loopDirReg? 8'hFF : 8'h00;
		4'hA: iicDataOut = loopNumReg;
		4'hB: iicDataOut = ledPositionReg;
		4'hC: iicDataOut = holdLastStatusReg? 8'hFF : 8'h00;
		default: ;
		endcase
	end	
	else
		iicDataOut = 8'hFF;
end 

// --- I2C Write Contral Register --- //
			

always @(*) begin
	if(!rst_n) begin
		rstReg		 	= 1'b0;		//rstReg
		onOffReg	 	= 1'b1;		//onOffReg		
		pageNumReg	 	= 8'h00;		//pageNumReg		
		timerReg	 	= 8'h50;		//timerReg			
		initPageReg	 	= 8'h00;		//initPageReg		
		endPageReg	 	= 8'h00;		//endPageReg		
		pageLoopNumReg	= 8'h00;		//pageLoopNumReg	//FF	
		stepLenReg	 	= 8'h03;		//stepLenReg		//03 
		loopDirReg	 	= 1'b0;		//loopDirReg		
		loopNumReg	 	= 8'h05;		//loopNumReg		//FF 
		ledPositionReg 	= 8'h00;		//ledPositionReg   	 			
		holdLastStatusReg 	= 1'b1;		//holdLastStatusReg   	 			
	end
	else if(CurrState == `END) begin
		onOffReg = 1'b0;
	end 
	else if(writeEn == 1'b1 && dev_addr[0] == 1'b0) begin
		if(CurrState == `IDLE) begin	
			case(reg_addr[3:0])
			4'h0: rstReg 			= iicDataIn[0];
			4'h1:  onOffReg 		= iicDataIn[0];
			// 4'h2: ;
			4'h3: pageNumReg		= iicDataIn;		
			4'h4: timerReg 			= iicDataIn;		
			4'h5: initPageReg 		= iicDataIn;		
			4'h6: endPageReg 		= iicDataIn;		
			4'h7: pageLoopNumReg 	= iicDataIn;		
			4'h8: stepLenReg 		= iicDataIn;		
			4'h9: loopDirReg 		= iicDataIn[0];		
			4'hA: loopNumReg 		= iicDataIn;		
			4'hB: ledPositionReg 	= iicDataIn;
			4'hC: holdLastStatusReg 	= iicDataIn[0];
			default:;
			endcase	
		end
		else begin
			case(reg_addr[0])
			1'b0: rstReg 		= iicDataIn[0];
			1'b1: onOffReg 		= iicDataIn[0];
			default:;
			endcase	
		end
	end	
	else begin
		rstReg		 	= rstReg;			//rstReg
		onOffReg	 	= onOffReg;			//onOffReg		
		pageNumReg	 	= pageNumReg;		//pageNumReg		
		timerReg	 	= timerReg;			//timerReg			
		initPageReg	 	= initPageReg;		//initPageReg		
		endPageReg	 	= endPageReg;		//endPageReg		
		pageLoopNumReg	= pageLoopNumReg;	//pageLoopNumReg	//FF	
		stepLenReg	 	= stepLenReg;		//stepLenReg		//03 
		loopDirReg	 	= loopDirReg;		//loopDirReg		
		loopNumReg	 	= loopNumReg;		//loopNumReg		//FF 
		ledPositionReg 	= ledPositionReg;	//ledPositionReg
		holdLastStatusReg 	= holdLastStatusReg;		//holdLastStatusReg
	end		
end 

always @(rst_n, CurrState)begin
	if(!rst_n || CurrState == `IDLE) begin
		busyFlag = 1'b0;
	end
	else if(CurrState == `GET_ADDR) begin
		busyFlag = 1'b1;
	end
end
assign busyReg	= busyFlag ?  8'hFF : 8'h00;  
		
// --- I2C Write PWM Register ---- //
//always @(*) begin
//	if(!rst_n) begin
//		ramData = 8'h00;
//		w_addr = 13'h0000;
//	end
//	else if (writeEn == 1'b1 && dev_addr[0] == 1'b1 && CurrState == `IDLE) begin
//		ramData = iicDataIn;
//		w_addr[12:6] = pageNumReg;
////		if(reg_addr < 36) begin  
//		w_addr[5:0] = reg_addr[5:0];
////		end
//	end
//end

assign ramData = iicDataIn;
assign wrRamAddr[12:6] = pageNumReg;
assign wrRamAddr[5:0] = reg_addr[5:0];


//============================================================================================//

reg [7:0] loopCnt;				//loop-counter within page
//reg [5:0] inLoopCnt;			//counter in one loop

reg [7:0] pageLoopCnt;			//loop-counter between pages
reg [7:0] inPageLoopCnt;		//counter in one page-loop

reg [15:0] timerBaseCnt;
reg [7:0] timerNumCnt;
reg holdLastStatusFlag;

// Current State Logic (sequential)
always @ (posedge clk) begin
	if(!rst_n || onOffReg == 1'b0)
		CurrState <= `IDLE;
	else
		CurrState <= NextState;
end

always @ (*) begin
//	if(!rst_n)		
//		NextState = `IDLE; 
//	else begin	
		case(CurrState)
		`IDLE:	begin			
			if(onOffReg == 1'b1)
				NextState = `GET_ADDR;
			else
				NextState = `IDLE;
			end		
		`GET_ADDR:	begin
				NextState = `LOAD;
			end
		`LOAD:	begin
			if(load_cnt == `LED_NUM + 1)
				NextState = `WAIT_TIMER;
			else
				NextState = `LOAD;
			end
		`WAIT_TIMER: begin
			if(timerReg == 0)
				NextState = `WAIT_TIMER;	
			else if(timerReg == timerNumCnt)begin		
				if(holdLastStatusFlag == 1'b0)
					NextState = `LOOP_IN_PAGE;
				else
					NextState = `WAIT_TIMER;		//`GET_ADDR
				end
			else
				NextState = `WAIT_TIMER;
			end
		`LOOP_IN_PAGE: begin
				NextState = `LOOP_IN_PAGE_D;
			end	
		`LOOP_IN_PAGE_D: begin
			if(loopNumReg == 8'hFF)
				NextState = `GET_ADDR;
			else if(loopNumReg == 0 || loopNumReg == loopCnt)
				NextState = `LOOP_BTW_PAGE;
			else
				NextState = `GET_ADDR;
			end
		`LOOP_BTW_PAGE: begin
				NextState = `LOOP_BTW_PAGE_S;
			end
		`LOOP_BTW_PAGE_S: begin
				NextState = `LOOP_BTW_PAGE_D;
			end		
		`LOOP_BTW_PAGE_D: begin
			if(pageLoopNumReg == 8'hFF)
				NextState = `GET_ADDR;
			else if(pageLoopNumReg == 0 || pageLoopNumReg == pageLoopCnt)begin
				if(holdLastStatusFlag == 1'b0)begin
					NextState = `END; 
				end
				else begin
					NextState = `WAIT_TIMER;		//`GET_ADDR
				end
			end
			else
				NextState = `GET_ADDR;
			end
		`END: begin
				NextState = `IDLE;
			end	
		default : NextState = `IDLE;		
		endcase
//	end
end  

always @(*) begin
	if(!rst_n)
		holdLastStatusFlag = 1'b0;
	else if(CurrState == `IDLE)
		holdLastStatusFlag = 1'b0;
	else if((CurrState == `LOOP_BTW_PAGE_S) && (pageLoopNumReg == pageLoopCnt))begin
		if(holdLastStatusReg == 1'b0)
			holdLastStatusFlag = 1'b0;
		else
			holdLastStatusFlag = 1'b1;
	end
end
			
reg [6:0] inPageAddr;
reg [5:0] loadAddr;
reg [6:0] offsetAddr;

reg [7:0] rdLedRamAddr;
reg [7:0] wrLedRamAddr;
reg wrenLedRam;
reg [35:0] ledRamData;
reg [`FREQ_COUNT_BITWIDTH - 1:0] freq_cnt;	//bit width == FREQ_COUNT's width

integer i;

wire [5:0] initAddr;
assign initAddr = ledPositionReg ? (`LED_NUM - ledPositionReg) : 0; 	//if deseiring the 6th led(ledPositionReg = 6'h05) gets the 1st PWM parameter, the 1st led has to get the 31th PWM parameter.   

always @(*) begin
	inPageAddr = loadAddr[5:0] + load_cnt;
	r_addr[5:0] = inPageAddr <= `LED_NUM - 1 ?  inPageAddr: (inPageAddr - `LED_NUM);
	r_addr[12:6] = initPageReg + inPageLoopCnt;	
end


always @ (posedge clk) begin
	if(!rst_n) begin
		offsetAddr <= 7'h00;
		loadAddr <= 6'h00;
		loopCnt <= 0;
		inPageLoopCnt <= 0;
		pageLoopCnt <= 0;
		load_cnt <= 0;
		timerBaseCnt <= 0;
		timerNumCnt <= 0;
		wrLedRamAddr <= 8'h00;
		rdLedRamAddr <= 8'h00;
		wrenLedRam <= 1'b0;
		freq_cnt <= 0;
	end
	else begin
		case(CurrState)
		`IDLE: begin
			offsetAddr <= 7'h00;
			loadAddr <= 6'h00;
			loopCnt <= 0;
			inPageLoopCnt <= 0;
			pageLoopCnt <= 0;
			load_cnt <= 0;
			timerBaseCnt <= 0;
			timerNumCnt <= 0;
			wrLedRamAddr <= 8'h00;
			rdLedRamAddr <= 8'h00;
			wrenLedRam <= 1'b0;
			freq_cnt <= 0;
		end
		`GET_ADDR: begin
			offsetAddr <= offsetAddr;
			loadAddr <= loadAddr;
			loopCnt <= loopCnt;
			inPageLoopCnt <= inPageLoopCnt;
			pageLoopCnt <= pageLoopCnt;		
			load_cnt <= 0;
			timerBaseCnt <= 0;
			timerNumCnt <= 0;
			wrLedRamAddr <= 8'h00;
			rdLedRamAddr <= 8'h00;			
			wrenLedRam <= 1'b0;
			freq_cnt <= 0;
			if(loopDirReg == 1'b1) begin					//counterclockwise
				if(initAddr + offsetAddr > `LED_NUM - 1)
					loadAddr[5:0] <= initAddr + offsetAddr - `LED_NUM;
				else
					loadAddr[5:0] <= initAddr + offsetAddr;
			end		
			else begin										//clockwise
				if(initAddr < offsetAddr) 
					loadAddr[5:0] <= `LED_NUM + initAddr - offsetAddr;
				else
					loadAddr[5:0] <= initAddr - offsetAddr;
			end
		end	 	
		`LOAD: begin
			offsetAddr <= offsetAddr;
			loadAddr <= loadAddr;
			loopCnt <= loopCnt;
			inPageLoopCnt <= inPageLoopCnt;
			pageLoopCnt <= pageLoopCnt;	
			timerBaseCnt <= 0;
			timerNumCnt <= 0;
			wrenLedRam <= 1'b1;
			freq_cnt <= 0;
			rdLedRamAddr <= rdLedRamAddr + 1;
			wrLedRamAddr <= rdLedRamAddr;			
			if(wrLedRamAddr == 8'hFF) begin
				load_cnt <= load_cnt + 1;
			end
			else begin
				load_cnt <= load_cnt;
			end
		end
		`WAIT_TIMER: begin
			offsetAddr <= offsetAddr;
			loadAddr <= loadAddr;
			loopCnt <= loopCnt;
			inPageLoopCnt <= inPageLoopCnt;
			pageLoopCnt <= pageLoopCnt;
			load_cnt <= load_cnt;
			wrenLedRam <= 1'b0;
			wrLedRamAddr <= 8'h00;			
			if(freq_cnt == `FREQ_COUNT-1)  begin
				freq_cnt <= 0;
				rdLedRamAddr <= rdLedRamAddr + 1;
			end
			else begin
				freq_cnt <= freq_cnt + 1;
				rdLedRamAddr <= rdLedRamAddr;
			end
				
			if(timerBaseCnt == `BASE_TIMER_LEN) begin
				timerBaseCnt <= 0;
				timerNumCnt <= timerNumCnt + 1;
			end	
			else
				timerBaseCnt <= timerBaseCnt + 1;
		end		
		`LOOP_IN_PAGE: begin
			loadAddr <= loadAddr;
			inPageLoopCnt <= inPageLoopCnt;
			pageLoopCnt <= pageLoopCnt;
			load_cnt <= 0;
			timerBaseCnt <= 0;
			timerNumCnt <= 0;
			freq_cnt <= 0;
			wrLedRamAddr <= 8'h00;
			rdLedRamAddr <= 8'h00;					
			if(loopNumReg == 0) begin
				offsetAddr <= 0;
				loopCnt <= 0;
			end
			else begin
				if(offsetAddr + stepLenReg >= `LED_NUM) begin
					offsetAddr <= 0;					
					if(loopNumReg == 8'hFF)
						loopCnt <= 0;
					else
						loopCnt <= loopCnt + 1;
				end
				else
					offsetAddr <= offsetAddr + stepLenReg;	
			end
		end	
		`LOOP_IN_PAGE_D: begin
			loadAddr <= loadAddr;
			inPageLoopCnt <= inPageLoopCnt;
			pageLoopCnt <= pageLoopCnt;		
			load_cnt <= 0;
			timerBaseCnt <= 0;
			timerNumCnt <= 0;
			freq_cnt <= 0;
			wrLedRamAddr <= 8'h00;
			rdLedRamAddr <= 8'h00;
			offsetAddr <= offsetAddr;
			loopCnt <= loopCnt;			
		end
		`LOOP_BTW_PAGE: begin
			load_cnt <= 0;
			timerBaseCnt <= 0;
			timerNumCnt <= 0;
			offsetAddr <= 0;
			loopCnt <= 0;
			freq_cnt <= 0;
			wrLedRamAddr <= 8'h00;
			rdLedRamAddr <= 8'h00;
			inPageLoopCnt <= inPageLoopCnt;			
			if(pageLoopNumReg == 0 || initPageReg == endPageReg) begin
				pageLoopCnt <= 0;
			end
			else begin
				if(inPageLoopCnt == endPageReg - initPageReg) begin
					if(pageLoopNumReg == 8'hFF)
						pageLoopCnt <= 0;
					else
						pageLoopCnt <= pageLoopCnt + 1;
				end
				else
					pageLoopCnt <= pageLoopCnt;
			end
		end
		`LOOP_BTW_PAGE_S: begin
			load_cnt <= 0;
			timerBaseCnt <= 0;
			timerNumCnt <= 0;
			offsetAddr <= 0;
			loopCnt <= 0;
			freq_cnt <= 0;
			wrLedRamAddr <= 8'h00; 
			rdLedRamAddr <= 8'h00;
			inPageLoopCnt <= inPageLoopCnt;
			pageLoopCnt <= pageLoopCnt;
		end		
		`LOOP_BTW_PAGE_D: begin
			load_cnt <= 0;
			timerBaseCnt <= 0;
			timerNumCnt <= 0;
			offsetAddr <= 0;
			loopCnt <= 0;
			freq_cnt <= 0;
			wrLedRamAddr <= 8'h00; 
			rdLedRamAddr <= 8'h00;
			pageLoopCnt <= pageLoopCnt;
			if(pageLoopNumReg == 0 || initPageReg == endPageReg) 
				inPageLoopCnt <= 0;			
			else begin
				if(inPageLoopCnt == endPageReg - initPageReg) begin
					if(holdLastStatusFlag == 1'b0)
						inPageLoopCnt <= 0;
					else
						inPageLoopCnt <= inPageLoopCnt; 
				end
				else
					inPageLoopCnt <= inPageLoopCnt + 1;
			end			
		end
		default: begin 
			offsetAddr <= 7'h00;
			loadAddr <= 6'h00;
			loopCnt <= 0;
			inPageLoopCnt <= 0;
			pageLoopCnt <= 0;
			load_cnt <= 0;
			timerBaseCnt <= 0;
			timerNumCnt <= 0;
			freq_cnt <= 0;
			wrLedRamAddr <= 8'h00;
			rdLedRamAddr <= 8'h00;			
		end 
		endcase
	end
end			

always @(*) begin
	if(!rst_n || !busyFlag)
		ledRamData = `ledOff_All; 
	else begin
		for(i = 0; i < `LED_NUM; i = i + 1)begin
			if(i == load_cnt) begin
				if(wrLedRamAddr == 0)
					ledRamData[i] = `ledOff;
				else if(wrLedRamAddr <= pwm_parm) 
					ledRamData[i] = `ledOn;
				else
					ledRamData[i] = `ledOff;
			end
			else
				ledRamData[i] = led_pwm_tmp[i];
		end
	end
end 
	
ram256x36 u0_ram256x36(
	.clock(clk),
	.data(ledRamData),
	.rdaddress(rdLedRamAddr),
	.wraddress(wrLedRamAddr),
	.wren(wrenLedRam),
	.q(led_pwm_tmp)
	);

assign led_pwm_o = (CurrState == `WAIT_TIMER) ?	led_pwm_tmp : `ledOff_All; 
	

endmodule