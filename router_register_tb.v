module router_register_tb();
	reg clk,rstn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,
			full_state,lfd_state;
	reg [7:0]data_in;
	wire parity_done,low_pkt_valid,err;
	wire [7:0]dout;
	integer i;
	
	router_register DUT(clk,rstn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,err,dout,data_in);

	
	
	always #5 clk=~clk;
	
	task packet_generation;
		reg [7:0]payload_data,header,parity;
		reg [5:0]payload_len;
		reg [1:0]addr;
		begin
			@(negedge clk)
			payload_len=6'd5;
			addr=2'b10;
			detect_add=1'b1;
			pkt_valid=1'b1;
			header={payload_len,addr};  /// creating the header 
			data_in=header;
			parity=8'b0^header; // parity
			@(negedge clk)
			detect_add=1'b0;
			lfd_state=1'b1;
			full_state=1'b0;
			fifo_full=1'b0;
			laf_state=1'b0;
			for(i=0;i<payload_len;i=i+1)   // payload input 
				begin
					@(negedge clk)
						lfd_state=1'b0;
						ld_state=1'b1;
						payload_data=i;
						data_in=payload_data;
						parity=parity^data_in;
						$display("parity %d= %d",i,parity);// calculated internal parity
				end
			@(negedge clk)
			pkt_valid=1'b0;     
			data_in=8'd18;                        // source parity
			@(negedge clk)
			ld_state=1'b0;
		end
	endtask
	
	task reset;
		begin
			@(negedge clk) rstn=1'b0;
			@(negedge clk) rstn=1'b1;
		end
	endtask
	
	task initialize;
		begin
			clk=1'b0;
			rstn=1'b1;
		end
	endtask
	
	initial
		begin
			initialize;
			reset;
			packet_generation;
			//#40 rst_int_reg=1'b0;
			#90 $finish;
		end
endmodule