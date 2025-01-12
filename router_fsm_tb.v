
module router_fsm_tb();
       //port declarations for tb
       reg [1:0]data_in;
       reg clk,rstn,pkt_valid,fifo_full,empty_0,empty_1,empty_2,
		     soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_pkt_valid;
		 wire write_enb_reg,detect_add,ld_state,lfd_state,full_state,rst_int_reg,busy,laf_state;
		 
		 //router_fsm_instantiation
		router_fsm DUT(data_in,clk,rstn,pkt_valid,parity_done,fifo_full,low_pkt_valid,soft_reset_0,soft_reset_1,soft_reset_2,empty_0,empty_1,empty_2,busy,detect_add,ld_state,laf_state,write_enb_reg,rst_int_reg,lfd_state);

		 
		 parameter cycle = 10;
		 //clk generation
		 always
		    begin
			    #(cycle/2) clk = 1'b0;
				 #(cycle/2) clk = 1'b1;
			 end
			 
		 //rstn task
		 task rst;
		    begin
			    @(negedge clk)
				     rstn = 1'b0;
				 @(negedge clk)
				     rstn = 1'b1;
			 end
		 endtask
		 
		 //task t1
		 task t1;
		     begin
			     @(negedge clk)
				  pkt_valid = 1'b1;
				  data_in = 2'b00;
				  empty_0 = 1'b1;
				  @(negedge clk)
				  @(negedge clk)
				  fifo_full = 1'b0;
				  pkt_valid = 1'b0;
				  @(negedge clk)
				  fifo_full = 1'b0;
			 end
		 endtask
		 
		 //task t2
		 /*task t2;
		     begin
			     @(negedge clk)
				  pkt_valid = 1'b1;
				  data_in = 2'b00;
				  empty_0 = 1'b1;
				  @(negedge clk)
				  @(negedge clk)
				  fifo_full = 1'b1;
				  @(negedge clk)
				  fifo_full = 1'b0;
				  @(negedge clk)
				  parity_done = 1'b0;
				  low_packet_valid = 1'b0;
				  @(negedge clk)
				  fifo_full = 1'b0;
			 end
		endtask*/
		
		initial 
		    begin
			    rst;
				 //@(negedge clk)
				 t1;
				 #300 $finish;
				 //@(negedge clk)
				 //t2;
			 end
		
endmodule
				 
				  
		 
		 
			  