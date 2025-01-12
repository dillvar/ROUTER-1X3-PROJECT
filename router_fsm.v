
module router_fsm(data_in,clk,rstn,pkt_valid,parity_done,fifo_full,low_pkt_valid,soft_reset_0,soft_reset_1,soft_reset_2,empty_0,empty_1,empty_2,busy,detect_add,ld_state,laf_state,write_enb_reg,rst_int_reg,lfd_state,full_state);
input [1:0]data_in;
reg [1:0]temp;
input clk,rstn,pkt_valid,parity_done,fifo_full,low_pkt_valid;
input soft_reset_0,soft_reset_1,soft_reset_2;
input empty_0,empty_1,empty_2;

output wire detect_add,ld_state,laf_state,write_enb_reg,rst_int_reg,lfd_state,full_state;
output reg busy;
parameter decode_address=3'b000,
				load_first_data=3'b001,
				wait_till_empty=3'b010,
				load_data=3'b011,
				fifo_full_state=3'b100,
				load_parity=3'b101,
				check_parity_error=3'b110,
				load_after_full=3'b111;
reg [2:0]state,next_state;

always@(posedge clk)
begin
if(detect_add)  temp<=data_in;
end

always@(posedge clk)
begin
if (!rstn) state<=decode_address;
else if((soft_reset_0 && temp==2'b00) || (soft_reset_1 && temp==2'b01)||(soft_reset_2 && temp==2'b10))
state<=decode_address;
else state<=next_state;
end

always@(*)
begin
next_state<=decode_address;

case(state)
//---------------------------------- state 0 decode_address
3'b000:begin

if((pkt_valid && data_in==0 && empty_0)||(pkt_valid && data_in==1 && empty_1)||(pkt_valid && data_in==2 && empty_2))
next_state<=load_first_data;

else if((pkt_valid && data_in==0 && ~empty_0)||(pkt_valid && data_in==1 && ~empty_1)||(pkt_valid && data_in==2 && ~empty_2))
next_state<=wait_till_empty;

else
next_state<=decode_address;
end

//-------------------------------------------state 1 load_first_data
3'b001:begin
next_state<=load_data; end

//-------------------------------------------state 2 wait_till_empty
3'b010:begin
if((empty_0 && temp==2'b00)||(empty_1 && temp==2'b01)||(empty_2 && temp==2'b10))
next_state<=load_first_data;

else
next_state<=wait_till_empty; end

//-------------------------------------------state 3 load_data
3'b011:begin
if (fifo_full)
next_state<=fifo_full_state;

else if(!fifo_full && !pkt_valid)
next_state<=load_parity;

else
next_state<=load_data;

end
//-------------------------------------------state 4 fifo_full_state
3'b100:begin
next_state<=(fifo_full)?fifo_full_state:load_after_full;
end

//-------------------------------------------state 5 load_parity
3'b101:begin
next_state<=check_parity_error;end

//-------------------------------------------state 6 check_parity_error
3'b110:begin
next_state<=(fifo_full)?fifo_full_state:decode_address; end

//-------------------------------------------state 7 load_after_full
3'b111:begin
if (!parity_done && !low_pkt_valid)  
next_state<=load_data;

else if(!parity_done && low_pkt_valid)
next_state<=load_parity;

else if(parity_done)
next_state<=decode_address;
end

endcase
end

assign detect_add = (state==decode_address);
assign lfd_state = (state==load_first_data);
assign ld_state = (state==load_data);
assign laf_state = (state==load_after_full);
assign write_enb_reg = ((state==load_data)||(state==load_parity)||(state==load_after_full));
assign full_state=(state==fifo_full_state);
assign rst_int_reg = (low_pkt_valid==1'b0)?(state==check_parity_error):1'b0;

always@(state)begin
case(state)
3'b000,3'b011 : busy=1'b0;
default: busy=1'b1;
endcase end

endmodule 