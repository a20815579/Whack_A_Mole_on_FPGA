`define TimeExpire 32'd50000000
`define TimeExpire_2 32'd11300000
`define Time2 32'd50000
`define TimeExpire_KEY 25'b00010000000000000000000000

module matrixKeyboard_drive(
  input            i_clk,
  input            i_rst_n,
  input      [3:0] row,
  output reg [3:0] col,
  output reg [3:0] keyboard_val    
);

reg [19:0] cnt;
 
always @ (posedge i_clk, negedge i_rst_n)
  if (!i_rst_n)
    cnt <= 0;
  else
    cnt <= cnt + 1'b1;
 
wire key_clk = cnt[19];
parameter NO_KEY_PRESSED = 6'b000_001;   
parameter SCAN_COL0      = 6'b000_010;
parameter SCAN_COL1      = 6'b000_100;
parameter SCAN_COL2      = 6'b001_000;
parameter SCAN_COL3      = 6'b010_000;
parameter KEY_PRESSED    = 6'b100_000;
 
reg [5:0] current_state, next_state;
 
always @ (posedge key_clk, negedge i_rst_n)
  if (!i_rst_n)
    current_state <= NO_KEY_PRESSED;
  else
    current_state <= next_state;
 

always@(*)
  case (current_state)
    NO_KEY_PRESSED :                    
        if (row != 4'hF)
          next_state = SCAN_COL0;
        else
          next_state = NO_KEY_PRESSED;
    SCAN_COL0 :                         
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL1;
    SCAN_COL1 :                         
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL2;    
    SCAN_COL2 :                         
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL3;
    SCAN_COL3 :
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED;
    KEY_PRESSED :
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED;                      
  endcase
 
reg       key_pressed_flag;
reg [3:0] col_val, row_val;

always @ (posedge key_clk, negedge i_rst_n)
  if (!i_rst_n)
  begin
    col              <= 4'h0;
    key_pressed_flag <=    0;
  end
  else
    case (next_state)
      NO_KEY_PRESSED :                  
      begin
        col              <= 4'h0;
        key_pressed_flag <=    0;       
      end
      SCAN_COL0 :                      
        col <= 4'b1110;
      SCAN_COL1 :
        col <= 4'b1101;
      SCAN_COL2 :
        col <= 4'b1011;
      SCAN_COL3 :
        col <= 4'b0111;
      KEY_PRESSED :
      begin
        col_val          <= col;
        row_val          <= row;
        key_pressed_flag <= 1;
      end
    endcase
	 
always @ (posedge key_clk, negedge i_rst_n)
  if (!i_rst_n)
    keyboard_val <= 4'h0;
  else
    if (key_pressed_flag)
      case ({col_val, row_val})
        8'b1110_1110 : keyboard_val <= 4'hf;
        8'b1110_1101 : keyboard_val <= 4'h7;
        8'b1110_1011 : keyboard_val <= 4'hb;
        8'b1110_0111 : keyboard_val <= 4'h3;
         
        8'b1101_1110 : keyboard_val <= 4'he;
        8'b1101_1101 : keyboard_val <= 4'h6;
        8'b1101_1011 : keyboard_val <= 4'ha;
        8'b1101_0111 : keyboard_val <= 4'h2;
         
        8'b1011_1110 : keyboard_val <= 4'hd;
        8'b1011_1101 : keyboard_val <= 4'h5;
        8'b1011_1011 : keyboard_val <= 4'h9;
        8'b1011_0111 : keyboard_val <= 4'h1;
         
        8'b0111_1110 : keyboard_val <= 4'hc; 
        8'b0111_1101 : keyboard_val <= 4'h4;
        8'b0111_1011 : keyboard_val <= 4'h8;
        8'b0111_0111 : keyboard_val <= 4'h0;        
      endcase
       
endmodule


module keypad(clk, rst, keypadRow, keypadCol,keypadBuf);

	input clk, rst;
	input [3:0]keypadCol;
	
	output [3:0]keypadRow;
	output reg [3:0]keypadBuf;
	
	reg [3:0]keypadRow;
	reg [24:0]keypadDelay;
	
	always@(posedge clk)
	begin
		if(!rst)
		begin
			keypadRow = 4'b1110;
			keypadBuf = 4'b0000;
			keypadDelay = 25'd0;
		end
		else
		begin
			if(keypadDelay == `TimeExpire_KEY)
			begin
				keypadDelay = 25'd0;
				case({keypadRow, keypadCol})
					8'b1110_1110 : keypadBuf = 4'h4;
					8'b1110_1101 : keypadBuf = 4'h7;
					8'b1110_1011 : keypadBuf = 4'h1;
					8'b1110_0111 : keypadBuf = 4'h0;
					8'b1101_1110 : keypadBuf = 4'h8;
					8'b1101_1101 : keypadBuf = 4'h6;
					8'b1101_1011 : keypadBuf = 4'h2;
					8'b1101_0111 : keypadBuf = 4'h9;
					8'b1011_1110 : keypadBuf = 4'ha;
					8'b1011_1101 : keypadBuf = 4'h5;
					8'b1011_1011 : keypadBuf = 4'h3;
					8'b1011_0111 : keypadBuf = 4'hb;
					8'b0111_1110 : keypadBuf = 4'hc;
					8'b0111_1101 : keypadBuf = 4'hd;
					8'b0111_1011 : keypadBuf = 4'he;
					8'b0111_0111 : keypadBuf = 4'hf;
					default     : keypadBuf = keypadBuf;
				endcase
				case(keypadRow)
					4'b1110 : keypadRow = 4'b1101;
					4'b1101 : keypadRow = 4'b1011;
					4'b1011 : keypadRow = 4'b0111;
					4'b0111 : keypadRow = 4'b1110;
					default: keypadRow = 4'b1110;
				endcase
			end
			else
				keypadDelay = keypadDelay + 1'b1;
		end
	end
	
endmodule 

module SevenSegment(in,out);

input [3:0]in;
output reg[6:0]out;

always@(*)
begin
	case(in)
		4'h0: out = 7'b1_00_0_00_0;
		4'h1: out = 7'b1_11_1_00_1;
		4'h2: out = 7'b0_10_0_10_0;
		4'h3: out = 7'b0_11_0_00_0;
		4'h4: out = 7'b0_01_1_00_1;
		4'h5: out = 7'b0_01_0_01_0;
		4'h6: out = 7'b0_00_0_01_0;
		4'h7: out = 7'b1_11_1_00_0;
		4'h8: out = 7'b0_00_0_00_0;
		4'h9: out = 7'b0_01_0_00_0;
		4'ha: out = 7'b0_00_1_00_0;
		4'hb: out = 7'b0_00_0_01_1;
		4'hc: out = 7'b1_00_0_11_0;
		4'hd: out = 7'b0_10_0_00_1;
		4'he: out = 7'b0_00_0_11_0;
		4'hf: out = 7'b0_00_1_11_0;
	endcase
end

endmodule

module hit_gopher(
	input[15:0] state,
	input hit_value,
	output reg[15:0] out_state
);

always@(*) begin
	if(state == hit_value)
		out_state = 16'd0;
	else
		out_state = state;
end

endmodule

module random_gen_state(clk,reset,state);
input clk;
input reset;
output [3:0] state;

reg [3:0] state = 4'b0000;
reg [3:0] state1 = 4'b0010;
reg [3:0] state2 = 4'b0100;
reg [3:0] state3 = 4'b1000;

reg [31:0] count;
reg [31:0] count2;
reg clk2;
reg clk3;

always@(posedge clk)
begin
if(!reset)
	begin
		count = 32'd0;
		count2 = 32'd0;
		clk2 = 1'b0;
		clk3 = 1'b0;
	end
	else
	begin
		if(count == `TimeExpire)
		begin
			count = 32'd0;
			clk2 = ~clk2;
		end
		else
		begin
			count = count+32'd1;
		end
		
		if(count2 == `Time2)
		begin
			count2 = 32'd0;
			clk3 = ~clk3;
		end
		else
		begin
			count2 = count2+32'd1;
		end
	 end
end

always @( posedge clk2 or  negedge reset)
begin 
    if (!reset)
        state <= 4'b1111; 
    else
	 begin
	 case(state)
		4'd0: state <= 4'd7;
		4'd1: state <= 4'd4;
		4'd2: state <= 4'd5;
		4'd3: state <= 4'd2;
		4'd4: state <= 4'd11;
		4'd5: state <= 4'd6;
		4'd6: state <= 4'd8;
		4'd7: state <= 4'd15;
		4'd8: state <= 4'd12;
		4'd9: state <= 4'd10;
		4'd10: state <= 4'd14;
		4'd11: state <= 4'd9;
		4'd12: state <= 4'd13;
		4'd13: state <= 4'd1;
		4'd14: state <= 4'd0;
		4'd15: state <= 4'd3;
	 endcase
	 end
      
end 
endmodule

module dot_displayer(time1,time2,state,col,row);
input time1,time2;
output [7:0] row;
output [7:0] col;
input [3:0] state;

//reg [3:0] state = 4'b0000;
reg [7:0] col;
reg [7:0] row;

always@(*)
begin :matrix
   if (time2==4'd0 && time1==4'd0)
	   disable matrix;
	case(state)
	4'd0:begin
		  col=8'b11000000;row=8'b00111111;end
	4'd1:begin
		  col=8'b00110000;row=8'b00111111;end
	4'd2:begin
		  col=8'b00001100;row=8'b00111111;end
	4'd3:begin
		  col=8'b00000011;row=8'b00111111;end
	4'd4:begin
		  col=8'b11000000;row=8'b11001111;end		
	4'd5:begin
		  col=8'b00110000;row=8'b11001111;end		
	4'd6:begin
		  col=8'b00001100;row=8'b11001111;end		
	4'd7:begin
		  col=8'b00000011;row=8'b11001111;end		
	4'd8:begin
		  col=8'b11000000;row=8'b11110011;end		
	4'd9:begin
		  col=8'b00110000;row=8'b11110011;end		
	4'd10:begin
		  col=8'b00001100;row=8'b11110011;end		
	4'd11:begin
		  col=8'b00000011;row=8'b11110011;end		
	4'd12:begin
		  col=8'b11000000;row=8'b11111100;end		
	4'd13:begin
		  col=8'b00110000;row=8'b11111100;end		
	4'd14:begin
		  col=8'b00001100;row=8'b11111100;end		
	4'd15:begin
		  col=8'b00000011;row=8'b11111100;end		
	endcase
end

endmodule

module mux(
	input i0,
	input i1,
	input sel,
	output reg out
);

always@(i0, i1, sel) begin
	case(sel)
		1'b0: out = i0;
		1'b1: out = i1;
		default: out = out;
	endcase
end
endmodule

module div_clk(clk,out_clk);
input clk;
output out_clk;
reg out_clk;
reg[31:0] cnt;
always@(posedge clk)
begin
	if(cnt == `TimeExpire_2)
	begin
		cnt <= 32'd0;
		out_clk <= ~out_clk;
	end
	else
		cnt <= cnt + 32'd1;
end
endmodule



module gg(time1,time2,clk,row,col);

input time1,time2,clk;
output [7:0]col,row;

reg [3:0]tmp;
reg [3:0]tmp2;
reg [7:0]col;
reg [7:0]row;
reg [31:0]count;
reg [31:0]count2;
reg div_clk;
reg div_clk2;

initial begin
	count2<=32'd0;
   div_clk2<=1'b0;
   tmp2=4'd0;
end

always@(posedge clk)
begin
  if (time2== 4'd0 && time1 == 4'd0) begin
    if (count == `TimeExpire)
    begin
      count <= 32'd0;
      div_clk <= ~div_clk;
      tmp=tmp+1;
    end
    else
    begin
      count <= count + 32'd1;
    end
  end
end

always@(posedge clk)
begin
   if(count2==`Time2)
   begin
     tmp2 = tmp2+1;
     count2 <= 32'd0;
     div_clk2 <= ~div_clk2;
	  case(tmp2)
		3'b000:
		begin
		row=8'b11111110;
		col=8'b00000000<<tmp;
		end
		3'b001:
		begin
		row=8'b11111101;
		col=8'b00111000<<tmp;
		end
		3'b010:
		begin
		row=8'b11111011;
		col=8'b01000100<<tmp;
		end
		3'b011:
		begin
		row=8'b11110111;
		col=8'b01011110<<tmp;
		end
		3'b100:
		begin
		row=8'b11101111;
		col=8'b01000000<<tmp;
		end
		3'b101:
		begin
		row=8'b11011111;
		col=8'b01000000<<tmp;
		end
		3'b110:
		begin
		row=8'b10111111;
		col=8'b01000100<<tmp;
		end
		3'b111:
		begin
		row=8'b01111111;
		col=8'b00111000<<tmp;
		end
     endcase
   end
   else
     count2<=count2+32'd1;
end
endmodule

module whack_a_hole(
	input clk,
	input rst,
	input[3:0] keyboard_row,
	output[3:0] keyboard_col,
	//output[6:0] seven_0,
	//output[6:0] seven_1,
	output reg[7:0] row,
	output reg[7:0] col,
	output wire[6:0] score_out1,
	output wire[6:0] score_out2,
	output wire[6:0] time_out1,
	output wire[6:0] time_out2
);

wire[7:0] row_tmp;
wire[7:0] col_tmp;
wire[7:0] row_tmp2;
wire[7:0] col_tmp2;
reg[3:0] state;
reg[3:0] score1;
reg[3:0] score2;
wire[3:0] in_state;
wire clk_tmp;
wire[3:0] out_tmp;
reg [3:0] Time1;
reg [3:0] Time2;
//wire[6:0] score_out1;
//wire[6:0] score_out2;
assign time1 = Time1;
assign time2 = Time2;
reg count;

initial begin
	score1 = 4'b0000;
	score2 = 4'b0000;
	Time1 = 4'b0000;
	Time2 = 4'b0011;//30 seconds
end

div_clk div0(clk,clk_tmp);
//mux m1(clk,0,finish,clk_tmp);
random_gen_state random(clk,rst,in_state);
matrixKeyboard_drive keypad(clk,rst,keyboard_row,keyboard_col,out_tmp);
//SevenSegment displayer0(out_tmp,seven_0);
//SevenSegment displayer1(state,seven_1);

SevenSegment displayer0(score1,score_out1);
SevenSegment displayer1(score2,score_out2);
SevenSegment displayer4(Time1,time_out1);
SevenSegment displayer5(Time2,time_out2);

dot_displayer dot(time1,time2,state,col_tmp,row_tmp);

gg(time1,time2,clk,row_tmp2,col_tmp2);

always@(posedge clk_tmp) begin : main
	if(rst == 0) begin
	   score1 = 0;
		score2 = 0;
		Time1 = 4'd0;
		Time2 = 4'd3;
		count = 1'b0;
	end
	else begin
	   count = count + 1'b1;
		if (Time2 == 4'd0 && Time1 == 4'd0) begin
			Time2 = 4'd0;
			Time1 = 4'd0;
		end
		else begin
		  if (count == 1'b1) begin
	        Time1 = Time1 - 4'd1;
		     if (Time1 == 4'd15) begin
		        Time1 = 4'd9;
				  Time2 = Time2 - 4'd1;
			  end
		  end
		end
		score1 = score1;
		score2 = score2;
	   state = in_state;
	   if(state == out_tmp) begin
		   state = 4'b1111;
		   score1 = score1 + 4'd1;
		   if(score1 == 4'd10) begin
		      score1 = 4'b0000;
			   score2 = score2 + 4'd1;
		   end
	   end
	   else
		   state = in_state;
			end

end

always@(*) begin
	
	if (Time2 != 4'd0 || Time1 != 4'd0) begin
	   row = row_tmp;
	   col = col_tmp;
	end
	
	else if (Time2 == 4'd0 && Time1 == 4'd0) begin
	   row = row_tmp2;
	   col = col_tmp2;
	end
end

endmodule 
