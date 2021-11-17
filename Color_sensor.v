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
output RMF,RMB,LMF,LMB, LM_pwm,RM_pwm,  
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
    
    reg[22:0] counter_r;
    reg[22:0] counter_L;
    reg[22:0] pulsewidth_r;
    reg[22:0] pulsewidth_L;
    reg RM_pwm_temp;
    reg LM_pwm_temp;
    
    reg [6:0] motor_temp;
    reg RMF_temp, RMB_temp, LMF_temp, LMB_temp;
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
    
    always@(negedge clk)
    begin
        if(counter_r == 1666667)
            counter_r <= 0;
        else
            counter_r <= counter_r +1;
        if(counter_r < pulsewidth_r)
            RM_pwm_temp  = 1;
        else
            RM_pwm_temp = 0;  
    end
    
    always@(negedge clk)
    begin
        if(counter_L == 1666667)
            counter_L <= 0;
        else
            counter_L <= counter_L +1;
        if(counter_L < pulsewidth_L)
            LM_pwm_temp = 1;
        else
            LM_pwm_temp = 0;  
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
        
            if(blue < green && red > blue)
            begin
                sseg_temp <= 7'b0000011;
                pulsewidth_L <= 833334;
                pulsewidth_r <= 833334;
                motor_temp <= 4'd0;
            end
            else if(red < green && red < blue && red > 1800)// && red >= 10000)
            begin
                sseg_temp   <= 7'b0101111;
                motor_temp <= 4'd3;
            end
            else if(green < blue && green < red && green > 2500)
            begin
                sseg_temp <= 7'b0000010;
                pulsewidth_L <= 1666667;
                pulsewidth_r <= 1666667;
                motor_temp <= 4'd0;
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

    
    always@(*)
     begin 
        case(motor_temp)
            4'd0: // forwards
                begin
                    RMF_temp  =  1;
                    RMB_temp  =  0;
                    LMF_temp  =  1;
                    LMB_temp  =  0;
                end
            4'd1: // left turn
                begin
                    RMF_temp  =  1;
                    RMB_temp  =  0;
                    LMF_temp  =  0;
                    LMB_temp  =  1;
                end
           4'd2: // right turn
                begin
                    RMF_temp  =  0;
                    RMB_temp  =  1;
                    LMF_temp  =  1;
                    LMB_temp  =  0;
                end
          4'd3: // Stop
                begin
                    RMF_temp  =  0;
                    RMB_temp  =  0;
                    LMF_temp  =  0;
                    LMB_temp  =  0;
                end
          4'd4: // Backwards
                begin
                    RMF_temp  =  0;
                    RMB_temp  =  1;
                    LMF_temp  =  0;
                    LMB_temp  =  1;
                end
           default: // forwards
                begin
                    RMF_temp  =  1;
                    RMB_temp  =  0;
                    LMF_temp  =  1;
                    LMB_temp  =  0;
                end
        endcase
     end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    
    assign RM_pwm = RM_pwm_temp; //JC2
    assign LM_pwm = LM_pwm_temp; //JC8
    
    assign RMF = RMF_temp;
    assign RMB = RMB_temp;
    assign LMF = LMF_temp;
    assign LMB = LMB_temp;
    
endmodule   