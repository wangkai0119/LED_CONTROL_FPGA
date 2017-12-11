// ----------------------- ledCtrl_define.v --------------------

`define LED_NUM 36

// ----------------------- sys_reset.v --------------------------
`define POWERON_RST_LEN 4'b1111	//16 clock-cycle with 12MHz, ~~1.3us
`define EXT_RST_LEN 16'h8CA0	//12*1000*3ms, count with 12MHz 
`define REG_RST_LEN 6'hff		//16 clock-cycle with 12MHz, ~~1.3us	


// ----------------------- main_state_ctrl.v --------------------------
`define CTRL_REG_LEN 12
//`define BASE_TIMER_LEN 16'h2EE0	//12*1000*1ms, count with 12MHz 
`define BASE_TIMER_LEN 16'hEA60	//12*1000*5ms, count with 12MHz 

// ----------------------- led_pwm_drvier.v --------------------------
`define LED_WORK_FREQ 1000 // 1K hz
`define FREQ_COUNT 6'd47 // FREQ_COUNT=(12000000/256/LED_WORK_FREQ) 
`define FREQ_COUNT_BITWIDTH 6 

// BINARY ENCODED state machine: 
// State codes definitions:
`define IDLE 				11'b00000000001
`define GET_ADDR 			11'b00000000010
`define LOAD 				11'b00000000100
`define WAIT_TIMER 			11'b00000001000
`define LOOP_IN_PAGE 		11'b00000010000
`define LOOP_IN_PAGE_S 		11'b00000100000
`define LOOP_IN_PAGE_D 		11'b00001000000
`define LOOP_BTW_PAGE	 	11'b00010000000
`define LOOP_BTW_PAGE_S 	11'b00100000000
`define LOOP_BTW_PAGE_D 	11'b01000000000
`define END 				11'b10000000000