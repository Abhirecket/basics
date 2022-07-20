module top( clk, rst, buf_in, buf_out, wr_en, rd_en, buf_empty, buf_full, fifo_counter );

input                 rst, clk, wr_en, rd_en;   
input [31:0]           buf_in;                   
output[7:0]           buf_out;                  
output                buf_empty, buf_full;      
output[3:0]           fifo_counter;             

reg[7:0]              buf_out;
reg                   buf_empty, buf_full;
wire[4:0]              fifo_counter; 
reg[4:0]              rd_ptr, wr_ptr;           
reg[7:0]              buf_mem[31 : 0];   
//FULL,EMPTY CONDITION
always @(fifo_counter)
begin
   buf_empty = (fifo_counter==0);
   buf_full = (fifo_counter>27);

end
//COUNTER UPDATE
assign fifo_counter = wr_ptr - rd_ptr ;
/*
always @(posedge clk or posedge rst)
begin
   if( rst ) 
       fifo_counter <= 0;

   else if( (!buf_full && wr_en) && ( !buf_empty && rd_en ) ) //read write at same time , counter value remains same
       fifo_counter <= fifo_counter;

   else if( !buf_full && wr_en )
       fifo_counter <= fifo_counter + 4; //8*4=32 input is of 32-bit so counter inc by 4

   else if( !buf_empty && rd_en )
       fifo_counter <= fifo_counter - 1; //output is of 8-bit so counter dec by 1
   else
      fifo_counter <= fifo_counter;
end
*/
//READING 8-bit DATA
always @( posedge clk or posedge rst)
begin
   if( rst )
      buf_out <= 0;
   else
   begin
      if( rd_en && !buf_empty )
         buf_out <= buf_mem[rd_ptr];

      else
         buf_out <= buf_out;

   end
end
//WRITTING 32-bit DATA
always @(posedge clk)
begin

   if( wr_en && !buf_full )
      {buf_mem[ wr_ptr +3],buf_mem[ wr_ptr +2],buf_mem[ wr_ptr +1],buf_mem[ wr_ptr ]} <= buf_in;
end
//POINTER UPDATE
always@(posedge clk or posedge rst)
begin
   if( rst )
   begin
      wr_ptr <= 0;
      rd_ptr <= 0;
   end
   else
   begin
      if( !buf_full && wr_en )    wr_ptr <= wr_ptr + 4; //8*4=32 input is of 32-bit so increment of 4
          else  wr_ptr <= wr_ptr;

      if( !buf_empty && rd_en )   rd_ptr <= rd_ptr + 1; //output is of 8-bit so increment of 1
      else rd_ptr <= rd_ptr;
   end

end
endmodule
