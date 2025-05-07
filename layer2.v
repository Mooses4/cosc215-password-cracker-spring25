module layer2(
    input clk,
    input goL3,               // Start signal
    input doneL1,             // Acknowledgment from Layer 1
    input goL1,               // Layer 1 ready to receive bit
    input [15:0] passcode,    // Passcode to send
    output reg rq8,           // Request line
    output reg Dout,          // Data out (1 bit at a time)
    output reg done           // Done sending flag
);

    reg [15:0] D;             // Shift register
    reg [3:0] count;          // Bit counter
    reg [2:0] state;

    parameter S0 = 3'd0,  // Wait for goL3
              S1 = 3'd1,  // Initialize (load passcode, reset counter, clear done)
              S2 = 3'd2,  // Wait for doneL1 (ready to send)
              S3 = 3'd3,  // Wait for goL1 (bit latch from Layer 1)
              S4 = 3'd4,  // Raise rq8, present D[15] on Dout
              S5 = 3'd5,  // Wait for doneL1 (ack), then shift and count++
              S6 = 3'd6,  // Check if all bits sent
              S7 = 3'd7;  // Done

    always @(posedge clk) begin
        case (state)
            S0: begin
                if (goL3)
                    state <= S1;
            end

            S1: begin
                D <= passcode;
                count <= 0;
                done <= 0;
                state <= S2;
            end

            S2: begin
                if (doneL1)
                    state <= S3;
            end

            S3: begin
                if (goL1)
                    state <= S4;
            end

            S4: begin
                Dout <= D[15];
                rq8 <= 1;
                state <= S5;
            end

            S5: begin
                if (doneL1) begin
                    rq8 <= 0;
                    D <= D << 1;
                    count <= count + 1;
                    state <= S6;
                end
            end

            S6: begin
                if (count == 4'd15)
                    state <= S7;
                else
                    state <= S2;
            end

            S7: begin
                done <= 1;
                // Optional: stay here or reset to S0 if you want to reuse
            end
        endcase
    end

    initial begin
        rq8 = 0;
        Dout = 0;
        done = 0;
        count = 0;
        D = 0;
        state = S0;
    end
endmodule
