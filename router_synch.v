
module router_syn(clk,rstn,data_in,write_enb_reg,detect_add,vld_out_0,vld_out_1,vld_out_2,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);

input clk,rstn,empty_0,empty_1,empty_2,full_0,full_1,full_2,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2;
input [1:0]data_in;
output reg soft_reset_0,soft_reset_1,soft_reset_2,fifo_full;
output reg [2:0] write_enb;
output vld_out_0,vld_out_1,vld_out_2;
reg [1:0]temp;
reg [4:0]count;  // as count moves from 2^0 --2^5   0-30.
//-------------------------------------- valid_out (if the fifo is not empty i.e some data is their
assign vld_out_0 = ~empty_0;
assign vld_out_1 = ~empty_1;
assign vld_out_2 = ~empty_2;
//-------------------------------------- for detection of the fifo address port using ,data_in,only when detect_add is 1
always@(posedge clk)
	begin
		if(!rstn)
			temp<=0;
		else if(detect_add)
			temp<=data_in;
		else
			temp<=temp;
	end
//-------------------------------------- fifo full , at any point of time , any of the fifo is full
always@(*)
	begin
		case(temp)
			2'b00 : fifo_full = full_0;
			2'b01 : fifo_full = full_1;
			2'b10 : fifo_full = full_2;
			default : fifo_full = 1'b0;
		endcase
	end
//-------------------------------------- to send write enable singles for the fifo
always@(*)
	begin
		if(write_enb_reg)
			begin
				case(temp)
					2'b00 : write_enb = 3'b001;
					2'b01 : write_enb = 3'b010;
					2'b10 : write_enb = 3'b100;
					default : write_enb = 3'b000;
				endcase
			end
		else
			write_enb = 3'b0;
	end
//-------------------------------------- for soft reset of the individual fifo
always@(posedge clk)
	begin
		if(!rstn)
			count<=5'b0;
		else if(vld_out_0)
			begin
				if(!read_enb_0)
					begin
						if(count==5'd29)
							begin
								soft_reset_0<=1'b1;
								count<=5'b0;
							end
						else
							begin
								soft_reset_0<=1'b0;
								count<=count+5'b1;
							end
					end
				else
					count<=5'b0;
			end
		else if(vld_out_1)
			begin
				if(!read_enb_1)
					begin
						if(count==5'd29)
							begin
								soft_reset_1<=1'b1;
								count<=5'b0;
							end
						else
								begin
								soft_reset_1<=1'b0;
								count<=count+5'b1;
							end
					end
				else
					count<=5'b0;
			end
		else if(vld_out_2)
			begin
				if(!read_enb_2)
					begin
						if(count==5'd29)
							begin
								soft_reset_2<=1'b1;
								count<=5'b0;
						end
						else
							begin
								soft_reset_2<=1'b0;
								count<=count+5'b1;
							end
					end
					else
					count<=5'b0;
			end
		else
				count<=5'b0;
	end
endmodule 