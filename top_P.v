module IPS_sensor(
    input ips_r, ips_L, clk,
    (* clock_buffer_type = "none" *)input obs_det,     
    output RMF,RMB,LMF,LMB, LM_pwm,RM_pwm,   
    output [3:0]an, 
    output a, b, c, d, e, f, g
    );
    
    reg[22:0] counter_r;
    reg[22:0] counter_L;
    reg[22:0] pulsewidth_r;
    reg[22:0] pulsewidth_L;
    reg RM_pwm_temp;
    reg LM_pwm_temp;
    
    reg [6:0]sseg_temp;
    
    reg [6:0] motor_temp;
    reg RMF_temp, RMB_temp, LMF_temp, LMB_temp;
    reg [6:0] state_temp;
    reg [6:0] obs_state;
    reg [6:0] pwm_state;
    reg state_two;
    reg obs_var, temp_var0, temp_var1, temp_var2, state_var, obs_count;
    reg [2:0] temp_var;
    initial begin
    obs_var = 0;
    state_var = 0;
    temp_var = 0;
    obs_count = 0;
    end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
always@(posedge clk)
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
    
always@(posedge clk)
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
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
 


     
always@(*)
begin   
    case(state_temp)
    4'd0: // normal state
    begin
    
    if(obs_count == 0)
    begin
        if(obs_det == 0)
        begin
            obs_count = 1;
            obs_var = 1;
        end
    end
        
        if(obs_var == 1)
        begin
        state_var = 1;
        end
        
        /*if(temp_var1 == 1)
        begin
        sseg_temp = 7'b1000000;
        end
        else 
        sseg_temp = 7'b0000000;*/
        
        if(obs_var == 0)
        begin
        state_var = 0;
        end
        if(temp_var == 0)
        begin
        temp_var = 0;
        sseg_temp <= 7'b1010101;
        end
        if(temp_var == 1)
        begin
        //temp_var = 1
        sseg_temp <= 7'b0000000;
        end
        if(temp_var == 2)
        begin
        //temp_var = 2;
        sseg_temp <= 7'b0101111;
        end
        if(temp_var == 3)
        begin
        //temp_var = 3;
        sseg_temp <= 7'b0000011;
        end
        if(temp_var == 0 && state_var == 0)
        begin
        sseg_temp <= 7'b0000010;
        end
        /*if( temp_var == 4)
        begin
        //temp_var = 4;
        sseg_temp <= 7'b0000010;
        end*/
        if(obs_var == 1)
        begin
        obs_var = 1;
        end
        
        if(obs_var == 1 && temp_var == 0 && ips_r == 1)
        begin
        motor_temp <= 4'd4;
        pwm_state <= 4'd4;
        //sseg_temp <= 7'b0000000;
        //temp_var <= 1;
        end
        else if( ips_r == 0 &&  obs_var == 1 && temp_var == 0)
        begin
            temp_var <= 1;
            motor_temp <= 4'd2;
            pwm_state <= 4'd4;
            //sseg_temp <= 7'b0101111;
        end
        else if(temp_var == 1 && ips_L == 0 && obs_var == 1)
        begin
            //temp_var0 <= 0;
            temp_var <= 2;
            motor_temp <= 4'd2;
            pwm_state <= 4'd4;
            //sseg_temp <= 7'b0000011;
        end
        else if(temp_var == 2 &&  ips_L == 1 && obs_var == 1)
        begin
           // temp_var1 <= 0;
            temp_var <= 3;
            motor_temp <= 4'd2;
            pwm_state <= 4'd4;
            //sseg_temp <= 7'b0000010;
        end
        else if(temp_var == 3 && ips_L == 0 && obs_var == 1)
        begin
            temp_var <= 0;
            //state_temp = 0;
            obs_var <= 0;
            state_var <= 0;
            //sseg_temp <= 7'b0111111;
        end
        
           if(ips_L == 0 && ips_r == 0 && state_var == 0)
                begin
                    //pulsewidth_L = 1333333;
                    //pulsewidth_r = 1333333;
                    pwm_state <= 4'd1;
                    motor_temp <= 4'd0;
                    //sseg_temp = 7'b0101010;
                end 
          else if(ips_L == 0 && state_var == 0)
                begin
                    //pulsewidth_L = 1333333;
                    //pulsewidth_r = 1333333;
                    pwm_state <= 4'd1;
                    motor_temp <= 4'd1;
                    //sseg_temp = 7'b0101010;
                end
          else if(ips_r == 0 && state_var == 0)
                begin
                   // pulsewidth_L = 1333333;
                   // pulsewidth_r = 1333333;
                    pwm_state <= 4'd1;
                    motor_temp <= 4'd2;
                    //sseg_temp = 7'b0101010;
                end
          else if(state_var == 0)
                begin
                    //pulsewidth_L = 1333333;
                    //pulsewidth_r = 1333333;
                    pwm_state <= 4'd1;
                    motor_temp <= 4'd0;
                    //sseg_temp = 7'b0101010;
                end
        end
        
    endcase
    
end


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
     
     always@(*)
    begin
        case(pwm_state)
        4'd0: // 100% Duty cycle
         begin
             pulsewidth_L = 1666667;
             pulsewidth_r = 1666667;
         end
        4'd1: // 80% duty cycle
         begin
            pulsewidth_L = 1333333;
            pulsewidth_r = 1333333;
         end
        4'd2: // 50& duty cycle
         begin
            pulsewidth_L = 833334;
            pulsewidth_r = 833334;
         end
        4'd3: // 30% duty cycle
         begin
            pulsewidth_L = 500000;
            pulsewidth_r = 500000;
         end
        4'd4:
         begin
            pulsewidth_L = 333333;
            pulsewidth_r = 333333;            
         end
        4'd5:
        begin
            pulsewidth_L = 500000; // right turn
            pulsewidth_r = 333333;
        end       
        endcase
    end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    assign an = 4'b0111;
    
    assign RM_pwm = RM_pwm_temp; //JC2
    assign LM_pwm = LM_pwm_temp; //JC8
    
    assign RMF = RMF_temp;
    assign RMB = RMB_temp;
    assign LMF = LMF_temp;
    assign LMB = LMB_temp;
    
    assign {g, f, e, d, c, b, a} = sseg_temp;
    
    
endmodule