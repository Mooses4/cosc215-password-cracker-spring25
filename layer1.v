module layer1(rq, ak, Din, Dout, En, Rd, clk);
    input ak, Din, En, clk;
    output reg rq, Dout, Rd;

    reg [2:0] state;

    always @(posedge clk) begin
        case (state)
            3'b000:
                if (En) state <= 3'b001;
                else    state <= 3'b000;

            3'b001: begin
                Dout <= Din;
                Rd <= 0;
                state <= 3'b010;
            end

            3'b010: begin
                rq <= 1;
                state <= 3'b011;
            end

            3'b011:
                if (ak) state <= 3'b100;
                else    state <= 3'b011;

            3'b100:
                if (ak) state <= 3'b100;
                else    state <= 3'b101;

            3'b101: begin
                rq <= 0;
                Rd <= 1;
                state <= 3'b000;
            end
        endcase
    end

    initial begin
        state <= 3'b000;
        rq <= 0;
        Dout <= 0;
        Rd <= 1;
    end
endmodule
