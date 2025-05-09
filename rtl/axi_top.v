module top_module (
    input wire         aclk,
    input wire         aresetn,
    
    // AXI-Lite Control Signals
    input wire         s_axi_awvalid,
    input wire [3:0]   s_axi_awaddr,
    input wire         s_axi_wvalid,
    input wire [31:0]  s_axi_wdata,
    input wire         s_axi_arvalid,
    input wire [3:0]   s_axi_araddr,
    output wire        s_axi_awready,
    output wire        s_axi_wready,
    output wire        s_axi_arready,
    output wire        s_axi_rvalid,
    output wire [31:0] s_axi_rdata,
    output wire        s_axi_bvalid,

    // Signals from axi_stream_fifo module
    input wire [1:0]   mode,
    input wire [31:0]  add_value,
    input wire [31:0]  s_axis_tdata,
    input wire         s_axis_tvalid,
    input wire         s_axis_tlast,
    output wire [31:0] m_axis_tdata,
    output wire        m_axis_tvalid,
    output wire        m_axis_tlast
);

    // Instantiate AXI-Lite Controller
    axi_lite_ctrl axi_lite_inst (
        .s_axi_aclk(aclk),
        .s_axi_aresetn(aresetn),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_awready(s_axi_awready),
        .s_axi_wready(s_axi_wready),
        .s_axi_arready(s_axi_arready),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_bvalid(s_axi_bvalid)
    );

    // Instantiate AXI-Stream FIFO
    axi_stream_fifo #(
        .DATA_WIDTH(32)
    ) axi_fifo_inst (
        .aclk(aclk),
        .areset(aresetn),
        .mode(mode),
        .add_value(add_value),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tlast(s_axis_tlast),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tlast(m_axis_tlast)
    );

endmodule

