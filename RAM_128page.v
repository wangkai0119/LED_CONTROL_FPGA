`timescale 1ns/10ps

module RAM_128page(
	data,
	wraddress,
	wrclock,
	wren,
	rdaddress,
	rdclock,
	q);
 
	input	[7:0]  data;
	input	[12:0]  wraddress;
	input	  wrclock;
	input	  wren;
	
	input	[12:0]  rdaddress;
	input		rdclock;
	output	[7:0]  q;

/***************************************************/
wire	[8:0]wren_blk;
assign wren_blk[0] = wren & (wraddress[5:2]==4'h0);
assign wren_blk[1] = wren & (wraddress[5:2]==4'h1);
assign wren_blk[2] = wren & (wraddress[5:2]==4'h2);
assign wren_blk[3] = wren & (wraddress[5:2]==4'h3);
assign wren_blk[4] = wren & (wraddress[5:2]==4'h4);
assign wren_blk[5] = wren & (wraddress[5:2]==4'h5);
assign wren_blk[6] = wren & (wraddress[5:2]==4'h6);
assign wren_blk[7] = wren & (wraddress[5:2]==4'h7);
assign wren_blk[8] = wren & (wraddress[5:2]==4'h8);

wire	[8:0]  wraddress_blk;
assign wraddress_blk = {wraddress[12:6],wraddress[1:0]};

wire	[8:0]  rdaddress_blk;
assign rdaddress_blk = {rdaddress[12:6],rdaddress[1:0]};
wire		[7:0]  q_blk[0:8];
reg [7:0] q;
//wire [7:0] qdata;
	
/* generate
genvar i;
	for (i = 0; i < 9; i = i + 1) begin : i_dp4k
		dp4k_512x8b_1w1r i_dp4k(
			.data		(data),
			.rdaddress	(rdaddress_blk),
			.rdclock		(rdclock),			
			.wraddress	(wraddress_blk),
			.wrclock		(wrclock),
			.wren		(wren_blk[i]),			
			.q			(q_blk[i])
			);
	end
endgenerate */

u0_dp4k_512x8b_1w1r u0_dp4k(
			.data		(data),
			.rdaddress	(rdaddress_blk),
			.rdclock		(rdclock),			
			.wraddress	(wraddress_blk),
			.wrclock		(wrclock),
			.wren		(wren_blk[0]),			
			.q			(q_blk[0])
			);
			
u1_dp4k_512x8b_1w1r u1_dp4k(
			.data		(data),
			.rdaddress	(rdaddress_blk),
			.rdclock		(rdclock),			
			.wraddress	(wraddress_blk),
			.wrclock		(wrclock),
			.wren		(wren_blk[1]),			
			.q			(q_blk[1])
			);
			
u2_dp4k_512x8b_1w1r u2_dp4k(
			.data		(data),
			.rdaddress	(rdaddress_blk),
			.rdclock		(rdclock),			
			.wraddress	(wraddress_blk),
			.wrclock		(wrclock),
			.wren		(wren_blk[2]),			
			.q			(q_blk[2])
			);

u3_dp4k_512x8b_1w1r u3_dp4k(
			.data		(data),
			.rdaddress	(rdaddress_blk),
			.rdclock		(rdclock),			
			.wraddress	(wraddress_blk),
			.wrclock		(wrclock),
			.wren		(wren_blk[3]),			
			.q			(q_blk[3])
			);	

u4_dp4k_512x8b_1w1r u4_dp4k(
			.data		(data),
			.rdaddress	(rdaddress_blk),
			.rdclock		(rdclock),			
			.wraddress	(wraddress_blk),
			.wrclock		(wrclock),
			.wren		(wren_blk[4]),			
			.q			(q_blk[4])
			);	

u5_dp4k_512x8b_1w1r u5_dp4k(
			.data		(data),
			.rdaddress	(rdaddress_blk),
			.rdclock		(rdclock),			
			.wraddress	(wraddress_blk),
			.wrclock		(wrclock),
			.wren		(wren_blk[5]),			
			.q			(q_blk[5])
			);			

			
u6_dp4k_512x8b_1w1r u6_dp4k(
			.data		(data),
			.rdaddress	(rdaddress_blk),
			.rdclock		(rdclock),			
			.wraddress	(wraddress_blk),
			.wrclock		(wrclock),
			.wren		(wren_blk[6]),			
			.q			(q_blk[6])
			);
			
u7_dp4k_512x8b_1w1r u7_dp4k(
			.data		(data),
			.rdaddress	(rdaddress_blk),
			.rdclock		(rdclock),			
			.wraddress	(wraddress_blk),
			.wrclock		(wrclock),
			.wren		(wren_blk[7]),			
			.q			(q_blk[7])
			);			

u8_dp4k_512x8b_1w1r u8_dp4k(
			.data		(data),
			.rdaddress	(rdaddress_blk),
			.rdclock		(rdclock),			
			.wraddress	(wraddress_blk),
			.wrclock		(wrclock),
			.wren		(wren_blk[8]),			
			.q			(q_blk[8])
			);
	

// reg [3:0] raddr_tmp1, raddr_tmp2;		//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// always @(posedge rdclock) begin
	// raddr_tmp1 <= rdaddress[5:2];
	// raddr_tmp2 <= raddr_tmp1;
// end
	
// always @ (posedge rdclock) begin
always @ (*) begin
	// case (raddr_tmp2)
	case (rdaddress[5:2])  
		4'h0: q = q_blk[0] ;
		4'h1: q = q_blk[1] ;
		4'h2: q = q_blk[2] ;
		4'h3: q = q_blk[3] ;
		4'h4: q = q_blk[4] ;
		4'h5: q = q_blk[5] ;
		4'h6: q = q_blk[6] ;
		4'h7: q = q_blk[7] ;
		4'h8: q = q_blk[8] ;
		default: q = 8'hX ;
	endcase
end
	

endmodule
