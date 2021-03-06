`default_nettype none
module serv_regfile
  (
   input wire 	    i_clk,
   input wire 	    i_go,
   output reg 	    o_ready,
   input wire 	    i_rd_en,
   input wire [4:0] i_rd_addr,
   input wire 	    i_rd,
   input wire [4:0] i_rs1_addr,
   input wire [4:0] i_rs2_addr,
   input wire 	    i_rs_en,
   output wire 	    o_rs1,
   output wire 	    o_rs2);

   reg 		    t;
   always @(posedge i_clk) begin
     o_ready <= t;
     t <= i_go;
   end

   reg rd_r;

   reg [4:0] rcnt;
   reg [4:0] wcnt;
   reg 	     rs1;
   reg 	     rs2;
   reg 	     rs1_r;

   wire [1:0] wdata = {i_rd, rd_r};
   always @(posedge i_clk) begin
      rd_r <= i_rd;
      if (i_rs_en)
	wcnt <= wcnt + 1;

      if (i_go)
	rcnt <= 5'd0;
      else
	rcnt <= rcnt + 4'd1;
      if (rs1_en) begin
	 rs1 <= rdata[1];
      end else begin
	 rs2 <= rdata[1];
      end
      rs1_r <= rs1_tmp;
   end

   wire rs1_tmp = (rs1_en ? rdata[0] : rs1);

   assign o_rs1 = (|i_rs1_addr) & rs1_r;
   assign o_rs2 = (|i_rs2_addr) & (rs1_en ? rs2 : rdata[0]);

   wire [8:0] waddr = {i_rd_addr, wcnt[4:1]};
   wire wr_en = wcnt[0] & i_rd_en;

   wire [8:0] raddr = {!rs1_en ? i_rs1_addr : i_rs2_addr, rcnt[4:1]};
   wire rs1_en = rcnt[0];

   reg [1:0]  memory [0:511];
   reg [1:0]  rdata;

   always @(posedge i_clk) begin
      if (wr_en)
	memory[waddr] <= wdata;
      rdata <= memory[raddr];
   end
endmodule
