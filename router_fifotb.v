
module router_fifotb();
reg rstn, clk, soft_reset, read_enb, write_enb,lfd_state;
reg [7:0] data_in;

wire [7:0] dout;
wire empty, full;
integer k;

router_fifo DUT(rstn, clk, soft_reset, read_enb, write_enb, lfd_state, data_in, dout, full, empty);

always #5 clk=~clk;

task initialize;
		begin
			clk=1'b0;
			rstn=1'b1;
			{read_enb,write_enb}={2'b0};
		end
endtask
	
task reset;
	begin
		@(negedge clk) rstn=1'b0;
		@(negedge clk) rstn=1'b1;
	end
endtask
	
	task write(integer length);
		reg [7:0] payload_data,parity,header;
		reg [5:0] payload_len;
		reg [1:0] addr;
		begin
			@(negedge clk);
			payload_len=length;
			addr=2'b01;
			header={payload_len,addr};
			data_in=header;
			lfd_state=1'b1;
			write_enb=1'b1;
			for(k=0;k<payload_len;k=k+1)
				begin
					@(negedge clk);
					begin
					lfd_state=1'b0;
					payload_data=k;
					data_in=payload_data;
					end
				end
			@(negedge clk);
			//write_enb=1'b1;
			parity=3'b111;
			data_in=parity;
			
		end
		
	endtask
	
	initial
		begin
			initialize;
			reset;
			@(negedge clk) soft_reset=1'b1;
			@(negedge clk) soft_reset=1'b0;
			write(6'd14);
			#10;
			write_enb=1'b0;
			@(negedge clk) 
			//write_enb=1'b0;
			read_enb=1'b1;
			//$display();
		end 
	initial
		begin
			#450 $finish;
		end
endmodule 
