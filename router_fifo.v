
module router_fifo(rstn, clk, soft_reset, read_enb, write_enb, lfd_state, data_in, dout, full, empty);

//parameter width = 9, depth = 16;

input rstn, clk, soft_reset, read_enb, write_enb, lfd_state;
input [7:0] data_in;

output reg [7:0] dout;
output empty, full;

//---------------------------------------------------------
reg [8:0] mem[15:0];    
reg [4:0] rd_ptr; //= 5'b0;
reg [4:0] wr_ptr; //= 5'b0;
reg [6:0] count;
reg temp;
integer i;

//---------------------------------------------------------
assign full = ((wr_ptr[4] != rd_ptr[4]) && (wr_ptr[3:0] == rd_ptr[3:0])) ? 1'b1 : 1'b0;
assign empty = (wr_ptr[4:0] == rd_ptr[4:0]) ? 1'b1 : 1'b0;

//---------------------------------------------------------
always @(posedge clk) begin
  if (!rstn)
    temp <= 1'b0;
  else
    temp <= lfd_state;
end

//--------------------------------------------------------- counter
always @(posedge clk) begin
  if (!rstn)
    count <= 0;
  else if (soft_reset)
    count <= 0;
  else if (read_enb && ~empty)
	  begin
		 if (mem[rd_ptr[3:0]][8] == 1'b1)
			count <= mem[rd_ptr[3:0]][7:2] + 1'b1;
		 else
			count <= count - 1'b1;
	  end
	else count<=count;
end

//--------------------------------------------------------- pointer
always @(posedge clk) begin
  if (!rstn) 
	  begin
		 wr_ptr <= 0;
		 rd_ptr <= 0;
	  end 
  else 
		begin
		 if (write_enb && ~full)
			wr_ptr <= wr_ptr + 1'b1;
		 if (read_enb && ~empty)
			rd_ptr <= rd_ptr + 1'b1;
		end
end

//--------------------------------------------------------- read
always @(posedge clk) begin
  if (!rstn)
    dout <= 8'b0;
  else if (soft_reset)
    dout <= 8'hz;
  else if (read_enb && ~empty)
    dout <= mem[rd_ptr[3:0]][7:0];
  else
    dout <= 8'hz;
end

//--------------------------------------------------------- write 
always @(posedge clk) 
begin
  if (!rstn || soft_reset) 
	  begin
		 for (i = 0; i < 16; i = i + 1)
			mem[i] <= 8'b0;
	  end 
  else if (write_enb && ~full) 
	  begin
		
			{mem[wr_ptr[3:0]][8],mem[wr_ptr[3:0]][7:0]} <= {temp, data_in};
	  end
end

//---------------------------------------------------------
endmodule 