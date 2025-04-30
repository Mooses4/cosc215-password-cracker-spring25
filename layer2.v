module layer2(
  input clk,
  input rd,             // Guard is ready
  input ak,             // Guard acknowledgment
  input [15:0] passcode,// 16-bit passcode to send
  input En,             // Enable sending
  output rq,            // Request signal to guard
  output Dout,          // Data line
  output done,          // Done sending flag
  output Rd             // To Layer 1 (read signal control)
);

  reg [4:0] bit_index;        // 0 to 15 (up to 16 bits)
  reg start;
  reg l1_en;
  reg l1_din;
  wire l1_rd;
  wire l1_rq;
  wire l1_dout;

  reg [2:0] state;

  assign rq = l1_rq;
  assign Dout = l1_dout;
  assign Rd = l1_rd;

  layer1 l1 (
      .rq(l1_rq),
      .ak(ak),
      .Din(l1_din),
      .Dout(l1_dout),
      .En(l1_en),
      .Rd(l1_rd),
      .clk(clk)
  );

  assign done = (state == 3'b011);

  always @(posedge clk) begin
      case (state)
          3'b000: begin
              bit_index <= 0;
              l1_en <= 0;
              start <= 0;
              if (rd && En)
                  state <= 3'b001;
          end

          3'b001: begin
              l1_din <= passcode[15 - bit_index]; // Big-endian: MSB first
              l1_en <= 1;
              state <= 3'b010;
          end

          3'b010: begin
              // Wait for Layer 1 to finish transmission
              if (l1_rd == 1) begin
                  l1_en <= 0;
                  if (bit_index == 15)
                      state <= 3'b011; // Done sending
                  else begin
                      bit_index <= bit_index + 1;
                      state <= 3'b001;
                  end
              end
          end

          3'b011: begin
              // Finished sending all bits
              if (!rd)
                  state <= 3'b000;
          end
      endcase
  end
endmodule
