`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2021 07:32:42 PM
// Design Name: 
// Module Name: color_sensor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module color_sensor(
input freqIn,
input clk,
output select0,
output select1,
output reg select2,
output reg select3,
output EO,
output JC3,
output JC4,
output JC9,
output JC10,
output [3:0]an, 
output pwm1,
output pwm2,
output a, b, c, d, e, f, g
    );
    reg [24:0] red;
    reg [24:0] green;
    reg [24:0] blue;
    reg [24:0] clear;
    reg prevFreq;
    reg [26:0]counter, counter_r, counter_L, pulsewidth_r; 
    reg [26:0]clkCount;
    reg [24:0] freqCount;
    reg [24:0] freq;
    reg [6:0] motor_temp;
    reg JC3_temp, JC4_temp, JC9_temp, JC10_temp, curr_pwm_r, curr_pwm_L;
    reg [3:0]sseg;
    reg [6:0]sseg_temp;
    reg [4:0] colState;
    initial begin
    red = 0;
    green = 0;
    blue = 0;
    clear = 0;
    counter = 0;
    freqCount = 0;
    clkCount = 0;
    freq = 0;
    colState = 0;
    select2 = 0;
    select3 = 0;
    //prevFreq = 0;
    end
       
    assign EO = 0;
    assign select0 = 1;
    assign select1 = 1;
    //assign select2 = 0;
    //assign select3 = 1;
    assign an = 4'b0111;
    
    always@ (posedge clk)
    begin
        counter <= counter + 1;    
        prevFreq <= freqIn;
    
        if(freqIn == 1 && prevFreq == 0)
        begin
            freqCount <= freqCount + 1;
        end    
        else if(counter == 12_500_000)
        begin
            freq <= freqCount << 3;
            freqCount <= 0;
            counter <= 0;
        end
    end
    /*
      always@(posedge clk)
    begin
        if(counter_r == 1666667)
            counter_r <= 0;
        else
            counter_r <= counter_r +1;
        if(counter_r < pulsewidth_r)
            curr_pwm_r  = 1;
        else
            curr_pwm_r = 0;  
    end
    */
    /*
    always@(posedge clk)
    begin
        if(counter_L == 1666667)
            counter_L <= 0;
        else
            counter_L <= counter_L +1;
        if(counter_L < pulsewidth_r)
            curr_pwm_L  = 1;
        else
            curr_pwm_L = 0;  
    end*/
    /*always@ (posedge clk)
    begin 
        clkCount <= clkCount + 1;
        
        if( clkCount == 12_500_000 ) // red filter select
        begin
            select2 <= 0;
            select3 <= 1;
            red <= freq;
        end
        else if( clkCount == 25_000_000 ) // blue filter select
        begin
            select2 <= 1;
            select3 <= 1;
            blue <= freq;
        end
        else if( clkCount == 37_500_000 ) // green filter
        begin
            select2 <= 1;
            select3 <= 0;
            green <= freq;
        end 
        else if( clkCount == 50_000_000 ) // clear filter select
        begin
            select2 <= 0;
            select3 <= 0;
            clear <= freq;
            clkCount <= 0;
            if((green > red && green > blue && green > clear))
            begin
            sseg_temp = 7'b0111111;
            end
            else 
            begin
            sseg_temp = 7'b0000000;
            end
            /*if(green > red && green > blue && green > clear)
            begin
                //motor_temp <= 4'd3;
                //sseg_temp <= 4'd1;
                sseg_temp   = 7'b0000010;
            end
            else if(red > green && red > blue && red > clear)
            begin
               // motor_temp = 4'd0;
               //sseg_temp <= 4'd0;
               sseg_temp   = 7'b0101111;
            end
            else if(blue > green && blue > red && blue > clear)
            begin
                //sseg_temp <= 4'd2;
                sseg_temp   = 7'b0000011;
            end
            else if(clear > green && clear > blue && clear > red)
            begin
                //motor_temp = motor_temp;
                //sseg_temp = 4'd3;
                sseg_temp   = 7'b1000110;
            end
            else
            begin
            sseg_temp = 7'b0111111;
            end
            clkCount <= 0;
        end
    end */ 
   /*
   always @(*)
    begin
    case(motor_temp)
        4'd0:
            begin
                JC3_temp  = 0;
                JC4_temp  = 0;
                JC9_temp  = 0;
                JC10_temp = 0;
            end
        
        4'd1: //turn right
            begin
                JC3_temp = 0;
                JC4_temp = 1;
                JC9_temp = 0;
                JC10_temp = 0;
            end
        4'd2: //turn left
            begin
                JC3_temp = 0;
                JC4_temp = 0;
                JC9_temp = 1;
                JC10_temp = 0;
            end 
        4'd3: //forward
            begin
                JC3_temp = 0;
                JC4_temp = 1;
                JC9_temp = 1;
                JC10_temp = 0;
            end 
        4'd4: //backwards
            begin
                JC3_temp = 1;
                JC4_temp = 0;
                JC9_temp = 0;
                JC10_temp = 1;
            end 
        default: //no moving
            begin
                JC3_temp  = 0;
                JC4_temp  = 0;
                JC9_temp  = 0;
                JC10_temp = 0;
            end
        endcase
    end
    /*always @ (*)
 begin
  case(sseg)
   4'd0  : sseg_temp   = 7'b0101111; //to display R 
   4'd1  : sseg_temp   = 7'b0000010; //to display G 
   4'd2  : sseg_temp   = 7'b1111100; //to display B
   4'd3  : sseg_temp   = 7'b1000110; //to display C
   default : sseg_temp = 7'b0111111; //to display -
  endcase
 end*/
    
    assign {g, f, e, d, c, b, a} = sseg_temp;
    
    always@ (posedge clk)
    begin
    case(colState)
    0 : begin // red filter select
            clkCount <= clkCount + 1;
            //sseg_temp   = 7'b0000010;
            if(clkCount == 12_500_000)
            begin 
                red <= freq;
                clkCount <= 0;
                colState <= 1;
                select2 = 0;
                select3 = 1;
            end
        end
        
    1 : begin // blue filter select
            clkCount <= clkCount + 1;
            if(clkCount == 12_500_000)
            begin
                blue <= freq;
                clkCount <= 0;
                colState <= 2;
                select2 = 1;
                select3 = 1;
            end
        end
    2 : begin
            clkCount <= clkCount + 1;
            if(clkCount == 12_500_000)
            begin
                green <= freq;
                clkCount <= 0;
                colState <= 3;
                select2 = 1;
                select3 = 0;
            end
        end
    3: begin
            clkCount <= clkCount + 1;
            if(clkCount == 12_500_000)
            begin
                clear <= freq;
                clkCount <= 0;
                colState <= 4;
                select2 = 0;
                select3 = 0;
            end
        end
    4: begin
        /*if( red > 25000 && green > 2000 && blue > 2000 &  clear > 2000 && red != green && green != blue && blue != clear && clear != red)
        begin
            sseg_temp = 7'b0111111;
        end
        else 
        begin
            sseg_temp = 7'b0000000;
        end
        */
        if(green > blue && green > red)
            begin
                sseg_temp   = 7'b0000010;
                //motor_temp = 4'd3;
                //pulsewidth_r = 1333333;
            end
            else if(red > green && red > blue) //&& red > clear)
            begin
               sseg_temp   = 7'b0101111;
               //motor_temp = 4'd0;
            end
            else if(blue > green && blue > red )//&& blue > red && blue > clear)
            begin
                sseg_temp   = 7'b0000011;
               // motor_temp = 4'd3;
               // pulsewidth_r = 833333;
                
            end
            /*else if(clear > green && clear > blue && clear > red)
            begin
                //motor_temp = motor_temp;
                //sseg_temp = 4'd3;
                sseg_temp   = 7'b1000110;
            end*/
            
            else
            begin
            sseg_temp = 7'b0111111;
            end
            colState <= 0;
        end
        
        
        
    //default : 
    
    endcase
    end
    
    assign pwm1 = curr_pwm_L;
    assign pwm2 = curr_pwm_r;   
    assign JC3 = JC3_temp;
    assign JC4 = JC4_temp;
    assign JC9 = JC9_temp;
    assign JC10 = JC10_temp; 
    
endmodule

