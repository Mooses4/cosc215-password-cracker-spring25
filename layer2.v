module layer2(
    input clk,
    input rd,                  // Guard ready signal
    input ak,                  // Acknowledgment from guard
    input En,                  // Enable signal
    input [15:0] passcode,     // Full 16-bit passcode
    output reg rq,             // Request signal
    output reg Dout,           // Data line
    output reg done            // Done sending passcode
);

    reg [15:0] D;              // Shift register holding passcode
    reg [3:0] count;           // 4-bit counter (0–15)
    reg [2:0] state;           // FSM state

    parameter IDLE = 3'b000,
              LOAD = 3'b001,
              SETBIT = 3'b010,
              RQHIGH = 3'b011,
              WAITAK1 = 3'b100,
              WAITAK0 = 3'b101,
              NEXTBIT = 3'b110;

    always @(posedge clk) begin
        case (state)
            IDLE: begin
                if (rd && En) begin
                    count <= 0;
                    state <= LOAD;
                    done <= 0;
                end
            end

            LOAD: begin
                D <= passcode;
                state <= SETBIT;
            end

            SETBIT: begin
                Dout <= D[15];    // MSB first
                done <= 0;
                rq <= 1;
                state <= RQHIGH;
            end

            RQHIGH: begin
                if (ak)
                    state <= WAITAK1;
            end

            WAITAK1: begin
                if (!ak)
                    state <= WAITAK0;
            end

            WAITAK0: begin
                rq <= 0;
                done <= 1;
                state <= NEXTBIT;
            end

            NEXTBIT: begin
                count <= count + 1;
                D <= D << 1;     // Shift to next MSB
                if (count == 15)
                    state <= IDLE;
                else
                    state <= SETBIT;
            end
        endcase
    end

    initial begin
        rq = 0;
        Dout = 0;
        done = 0;
        count = 0;
        state = IDLE;
    end
endmodule
