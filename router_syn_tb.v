module router_syn_tb();
	reg clk,rstn,empty_0,empty_1,empty_2,full_0,full_1,full_2,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2;
	reg [1:0]data_in;
	wire soft_reset_0,soft_reset_1,soft_reset_2,fifo_full;
	wire [2:0] write_enb;
	wire vld_out_0,vld_out_1,vld_out_2;
	
	router_syn DUT(clk,rstn,data_in,write_enb_reg,detect_add,vld_out_0,vld_out_1,vld_out_2,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);
//-------------------------------------- 	intialize the clock, reser, write enable values.
	task initialize;
		begin
			clk=1'b0;
			rstn=1'b1;
			write_enb_reg=1'b0;
		end
	endtask
//-------------------------------------- 	for clk generation
	always #5 clk=~clk;
//-------------------------------------- 	task for reset
	task reset;
		begin
			@(negedge clk) rstn=1'b0;
			@(negedge clk) rstn=1'b1;
		end
	endtask
//-------------------------------------- 	
	task detect(input d1);
		begin
			@(negedge clk) detect_add=d1;
		end
	endtask
//-------------------------------------- task for empty	
	task empty_status(input e0,e1,e2);
		begin
			{empty_0,empty_1,empty_2}={e0,e1,e2};
		end
	endtask
//-------------------------------------- 	task for full
	task full_status(input f0,f1,f2);
		begin
			{full_0,full_1,full_2}={f0,f1,f2};
		end
	endtask
//-------------------------------------- task for read

	task read(input r0,r1,r2);
		begin
			{read_enb_0,read_enb_1,read_enb_2}={r0,r1,r2};
		end
	endtask
//-------------------------------------- task for 1 clock cycle delay
	task delay;
		begin
			@(negedge clk);
		end
	endtask
//-------------------------------------- 	stimulus generation
	initial
		begin
			initialize;        //start
			reset;
			detect(1'b1);        // detect the address
			data_in=2'b10;
			write_enb_reg=1'b1;      // for write enables
			full_status(0,0,0);		 // full status of the fifos
			empty_status(1,1,0);		 //empty status of the fifos
			read(0,0,0);				// read enable values 
			#500 $finish;
		end
endmodule 