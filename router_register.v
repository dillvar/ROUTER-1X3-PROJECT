
module router_register(clk,rstn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,err,dout,data_in);
input clk,rstn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
input [7:0]data_in;
output reg parity_done,low_pkt_valid,err;
output reg [7:0]dout;

reg [7:0]header_byte,full_state_byte,internal_parity,packet_parity;

//------------------------------reset logic
/*always@(posedge clk)
begin
  if (!rstn)
  begin
    dout<=8'b0;
  end
end*/

//------------------------------PARITY DONE 
always@(posedge clk)
begin
  if (detect_add || ~rstn)												  parity_done<=1'b0;
  else if (ld_state==1 && fifo_full==0 && pkt_valid==0)        parity_done<=1'b1;
  else if(laf_state==1 && low_pkt_valid==1 && parity_done==0) parity_done<=1'b1;
  else parity_done<=parity_done;
end

//------------------------------low packet valid
always@(posedge clk)
begin
	if(rst_int_reg || ~rstn) low_pkt_valid<=0;
	else if (ld_state && ~pkt_valid) low_pkt_valid<=1;
end

//------------------------------ data input
always@(posedge clk)
begin
	if (~rstn) 
		begin
			header_byte<=8'b0;full_state_byte<=8'b0;packet_parity<=8'b0;
		end
	else if(detect_add && pkt_valid && data_in[1:0]!=2'b11)     //header byte
		header_byte<=data_in;
	else if (~pkt_valid && ld_state) 
		packet_parity<=data_in;												// packet_parity
	else if (fifo_full && ld_state) 
		full_state_byte<=data_in;												//full_state_byte
	else 
		begin
		header_byte<=header_byte;
		full_state_byte<=full_state_byte;
		packet_parity<=packet_parity;
		end
end

//---------------------calculating the internal parity
always@(posedge clk)
begin
	if (!rstn || detect_add)
		internal_parity<=8'b0;
	else if(lfd_state)
		internal_parity<=internal_parity^header_byte;
	else if(pkt_valid && ld_state && !full_state)
		internal_parity<=internal_parity^data_in;
	else
		internal_parity<=internal_parity;
end
//-------------------------------error_logic
always@(posedge clk)
begin
	if (!rstn) err<=0;
	else if(parity_done)
		err<=(internal_parity!=packet_parity)?1'b1:1'b0;
	else
		err<=err;
end
//------------------------------dout
always@(posedge clk)
begin
if (!rstn) dout<=0;
	else if (lfd_state)
		dout<=header_byte;
	else if(ld_state && !fifo_full)
		dout<=data_in;
	else if(laf_state)
		dout<=full_state_byte;
	else
		dout<=dout; end

endmodule 