`timescale 1ns / 1ps

module stream_master_tb;

  // Parameters
  localparam DATA_WIDTH = 32;
  localparam BYTES = DATA_WIDTH / 8;

  // DUT signals
  reg aclk;
  reg areset;
  reg [1:0] mode;
  reg [DATA_WIDTH-1:0] add_value;
  reg s_axis_tvalid;
  reg [DATA_WIDTH-1:0] s_axis_tdata;
  reg [BYTES-1:0] s_axis_tkeep;
  reg [BYTES-1:0] s_axis_tstrb;
  reg s_axis_tlast;
  wire m_axis_tvalid;
  wire [DATA_WIDTH-1:0] m_axis_tdata;
  wire [BYTES-1:0] m_axis_tkeep;
  wire [BYTES-1:0] m_axis_tstrb;
  wire m_axis_tlast;
  reg m_axis_tready;

  // Instantiate DUT
  axi_stream_fifo dut (
    .aclk(aclk),
    .areset(areset),
    .mode(mode),
    .add_value(add_value),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tkeep(s_axis_tkeep),
    .s_axis_tstrb(s_axis_tstrb),
    .s_axis_tlast(s_axis_tlast),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tkeep(m_axis_tkeep),
    .m_axis_tstrb(m_axis_tstrb),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tready(m_axis_tready)
  );

  // Clock generation
  always #5 aclk = ~aclk;

  // Stimulus
  initial begin
    aclk = 0;
    areset = 0;
    s_axis_tvalid = 0;
    s_axis_tdata = 0;
    s_axis_tkeep = 4'b1111;
    s_axis_tstrb = 4'b1111;
    s_axis_tlast = 0;
    m_axis_tready = 0;
    mode = 2'b00; // Initially pass-through
    add_value = 32'h00000001;

    // Reset
    #20;
    areset = 1;

    // --- Mode 00: Pass-through for 1st word
    @(posedge aclk);
    mode <= 2'b00; // Pass-through mode
    s_axis_tvalid <= 1;
    s_axis_tdata  <= 32'hDEADBEEF;
    s_axis_tlast  <= 0;

    @(posedge aclk);
    s_axis_tdata  <= 32'h12345678;
    s_axis_tlast  <= 1;

    // --- Mode 01: Byte Reversal for 2nd word
    @(posedge aclk);
    mode <= 2'b01; // Byte reversal mode
    s_axis_tvalid <= 1;
    s_axis_tdata  <= 32'hABCDEF01;
    s_axis_tlast  <= 0;

    @(posedge aclk);
    s_axis_tdata  <= 32'h0BADBEEF;
    s_axis_tlast  <= 1;

    // --- Mode 10: Add constant for 3rd word
    @(posedge aclk);
    mode <= 2'b10; // Add constant mode
    s_axis_tvalid <= 1;
    s_axis_tdata  <= 32'hFACEFEED;
    s_axis_tlast  <= 1;

    // Deassert valid after all words are processed
    @(posedge aclk);
    s_axis_tvalid <= 0;
    s_axis_tlast  <= 0;

    // Simulate downstream ready after delay (backpressure)
   
    m_axis_tready <= 1;
	 

    // Let output complete
    repeat (20) @(posedge aclk);

    $finish;
  end

  // Monitor output
  always @(posedge aclk) begin
    if (m_axis_tvalid && m_axis_tready) begin
      $display("Time %t: READ ->  dataout = %h, keep=%b, strb=%b, last=%b",
               $time, m_axis_tdata, m_axis_tkeep, m_axis_tstrb, m_axis_tlast);
    end
  end

endmodule
