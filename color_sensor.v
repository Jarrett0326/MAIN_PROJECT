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
output [3:0]an, 
output a, b, c, d, e, f, g
    );
    reg [24:0] red;
    reg [24:0] green;
    reg [24:0] blue;
    reg [24:0] clear;
    reg prevFreq;
    reg [26:0] counter;
    reg [26:0] clkCount;
    reg [24:0] freqCount;
    reg [24:0] freq;
    reg [6:0] motor_temp;
    reg JC3_temp, JC4_temp, JC9_temp, JC10_temp, curr_pwm_r, curr_pwm_L;
    reg [3:0]sseg;
    reg [6:0]sseg_temp;
    reg [3:0] colState;
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
    assign select1 = 0;
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

    always@ (posedge clk)
    begin
    case(colState)
    0 : begin // red filter select
            clkCount <= clkCount + 1;
            if(clkCount == 12_500_000)
            begin 
                red <= freq;
                //red = red - 10000;
                clkCount <= 0;
                colState <= 1;
                select2 <= 0;
                select3 <= 1;
            end
        end
        
    1 : begin // blue filter select
            clkCount <= clkCount + 1;
            if(clkCount == 12_500_000)
            begin
                blue <= freq;
                clkCount <= 0;
                colState <= 2;
                select2 <= 1;
                select3 <= 1;
            end
        end
    2 : begin
            clkCount <= clkCount + 1;
            if(clkCount == 12_500_000)
            begin
                green <= freq;
                clkCount <= 0;
                colState <= 3;
                select2 <= 0;
                select3 <= 0;
            end
        end
    3: begin
        /*if( red > green && red > blue/*red > 2000 && green > 2000 && blue > 2000 && red != green && green != blue && blue != red)
        begin
            sseg_temp = 7'b0111111;
        end
        else 
        begin
            sseg_temp = 7'b0000000;
        end*/
        
            if(blue < green && red > blue && blue > 920) // green
            begin
                sseg_temp <= 7'b0000010;
            end
            else if(red < green && red < blue && red > 700)// red
            begin
               sseg_temp   = 7'b0101111;
            end
            else if(green > blue && red > blue && green > 1500)// blue
            begin
                sseg_temp <= 7'b0000011;
            end
            else
            begin
            sseg_temp <= 7'b0111111;
            end
            colState <= 0;
            select2 <= 0;
            select3 <= 0;
        end
    endcase
    end
    assign {g, f, e, d, c, b, a} = sseg_temp;
    endmodule