
module top_module_router(clk,rstn,pkt_valid,read_enb_0,read_enb_1,read_enb_2,data_in,dout_0,dout_1,dout_2,vld_out_0,vld_out_1,vld_out_2,err,busy);
input clk,rstn,pkt_valid;
input read_enb_0,read_enb_1,read_enb_2;
input [7:0]data_in;
output [7:0]dout_0,dout_1,dout_2;
output vld_out_0,vld_out_1,vld_out_2,err,busy;

wire[2:0]write_enb;
wire[7:0]dout;


router_fsm FSM(data_in[1:0],clk,rstn,pkt_valid,parity_done,fifo_full,low_pkt_valid,soft_reset_0,soft_reset_1,soft_reset_2,empty_0,empty_1,empty_2,busy,detect_add,ld_state,laf_state,write_enb_reg,rst_int_reg,lfd_state,full_state);


router_register REGISTER(clk,rstn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,err,dout,data_in);


router_syn SYNCHRONIZER(clk,rstn,data_in[1:0],write_enb_reg,detect_add,vld_out_0,vld_out_1,vld_out_2,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);


router_fifo FIFO_0(rstn, clk, soft_reset_0, read_enb_0, write_enb[0], lfd_state, dout, dout_0, full_0, empty_0);

router_fifo FIFO_1(rstn, clk, soft_reset_1, read_enb_1, write_enb[1], lfd_state, dout, dout_1, full_1, empty_1);

router_fifo FIFO_2(rstn, clk, soft_reset_2, read_enb_2, write_enb[2], lfd_state, dout, dout_2, full_2, empty_2);


endmodule
