module Layer3(
  input wire clk,
  input wire reset,
  input wire RD,
  input wire doneL2,
  output reg [7:0] PW,
  output reg [7:0] Dout,
  output reg goL2
);

  // naming states based on each thing
  wire [2:0] state0 = 3'd0;  // PW = 0
  wire [2:0] state1 = 3'd1;  // first RD check
  wire [2:0] state2 = 3'd2;  // Dout = PW
  wire [2:0] state3 = 3'd3;  // goL2 = 1
  wire [2:0] state4 = 3'd4;  // doneL2 check
  wire [2:0] state5 = 3'd5;  // second RD check
  wire [2:0] state6 = 3'd6;  // PW = PW + 1
  
  reg [2:0] state, next_state;
  
  // state register
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= state0;
      PW <= 0;
    end 
    else begin
      state <= next_state;
      
      // increment state
      if (state == state6)
        PW <= PW + 1;
    end
  end
  
  // state traversal
  always @(*) begin
    next_state = state;  // remain in current state
    
    case (state)
      state0: begin  // PW = 0
        next_state = state1;  // always go to first RD check
      end
      
      state1: begin  // 1st RD check
        if (RD == 1)
          next_state = state2;  // if RD=1 go to Dout=PW
        else
          next_state = state1;  // if RD=0 stay in the state
      end
      
      state2: begin  // Dout = PW
        next_state = state3;  // go to L2
      end
      
      state3: begin  // set goL2 = 1
        next_state = state4;  // go to doneL2
      end
      
      state4: begin  // Check doneL2
        if (doneL2 == 1)
          next_state = state5;  // if doneL2=1 go to second RD check
        else
          next_state = state4;  // if doneL2=0 stay in the state
      end
      
      state5: begin  // 2nd RD check
        if (RD == 1)
          next_state = state6;  // if RD=1, go to PW=PW+1
        else
          next_state = state1;  // if RD=0, go back to first RD check
      end
      
      state6: begin  // PW=PW+1
        next_state = state1;  // go back to first RD check
      end

    endcase
  end
  
  always @(*) begin
    // output defualt
    Dout = 0;
    goL2 = 0;
    
    case (state)
      state2: begin  // Dout state
        Dout = PW;
      end
      
      state3, state4: begin  // goL2 and doneL2 states
        goL2 = 1;
      end
    endcase
  end

endmodule