module top_tb();
reg [7:0]data_in;
	reg clk,rstn,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
	wire [7:0]dout_0,dout_1,dout_2;
	wire vld_out_0,vld_out_1,vld_out_2,err,busy;
	integer i;
	
top_module_router DUT(clk,rstn,pkt_valid,read_enb_0,read_enb_1,read_enb_2,data_in,dout_0,dout_1,dout_2,vld_out_0,vld_out_1,vld_out_2,err,busy);

	
	task initialize;
		begin
			clk=1'b0;
			rstn=1'b1;
			{read_enb_0,read_enb_1,read_enb_2}=3'b0;
		end
	endtask
	
	always #5 clk=~clk;
	
	task reset;
		begin
			@(negedge clk) rstn=1'b0;
			@(negedge clk) rstn=1'b1;
		end
	endtask
	
	task parity_generation;
		reg [7:0]header,payload_data,parity;
		reg [5:0]payload_len;
		reg [1:0]addr;
		begin
			parity=1'b0;
			wait(!busy)
			begin
				@(negedge clk)
				payload_len=6'd14;
				pkt_valid=1'b1;
				addr=2'b10;
				header={payload_len,addr};
				data_in=header;
				parity=8'b0^data_in;
				@(negedge clk);
				for(i=0;i<payload_len;i=i+1)
					begin
						wait(!busy)
						@(negedge clk)
						payload_data=$random;
						data_in=payload_data;
						parity=parity^data_in;
					end
				wait(!busy)
				@(negedge clk)
				pkt_valid=1'b0;
				data_in=parity;
			end
		end
	endtask
	
	initial
		begin
			initialize;
			reset;
			parity_generation;
			//repeat(30) @(negedge clk);
			@(negedge clk)read_enb_2=1'b1;
			#300 $finish;
		end
	
endmodule
