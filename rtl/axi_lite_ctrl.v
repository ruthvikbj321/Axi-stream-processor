module axi_lite_ctrl #(
    parameter DATA_WIDTH = 32
)(
    input  wire                   s_axi_aclk,
    input  wire                   s_axi_aresetn,

    // AXI-Lite Write Address and Data
    input  wire                   s_axi_awvalid,
    input  wire [3:0]             s_axi_awaddr,
    input  wire                   s_axi_wvalid,
    input  wire [DATA_WIDTH-1:0]  s_axi_wdata,

    // AXI-Lite Read Address
    input  wire                   s_axi_arvalid,
    input  wire [3:0]             s_axi_araddr,

    // AXI-Lite Responses
    output reg                    s_axi_awready,
    output reg                    s_axi_wready,
    output reg                    s_axi_arready,
    output reg                    s_axi_rvalid,
    output reg [DATA_WIDTH-1:0]   s_axi_rdata,
    output wire                   s_axi_bvalid,
 

    // Internal control signals
    output reg [1:0]              mode,
    output reg [DATA_WIDTH-1:0]   add_value
);

assign s_axi_bvalid = s_axi_awvalid && s_axi_wvalid;

always @(posedge s_axi_aclk) begin
    if (!s_axi_aresetn) begin
        s_axi_awready <= 0;
        s_axi_wready  <= 0;
        s_axi_arready <= 0;
        s_axi_rvalid  <= 0;
        s_axi_rdata   <= 0;
        mode          <= 0;
        add_value     <= 0;
    end else begin
        // Write operations
        s_axi_awready <= s_axi_awvalid;
        s_axi_wready  <= s_axi_wvalid;

        if (s_axi_awvalid && s_axi_wvalid) begin
            case (s_axi_awaddr)
                4'h0: mode      <= s_axi_wdata[1:0];
                4'h4: add_value <= s_axi_wdata;
                default: ;
            endcase
        end

        // Read operations
        s_axi_arready <= s_axi_arvalid;

        if (s_axi_arvalid && s_axi_arready) begin
            case (s_axi_araddr)
                4'h0: s_axi_rdata <= {{(DATA_WIDTH-2){1'b0}}, mode};
                4'h4: s_axi_rdata <= add_value;
                default: s_axi_rdata <= {DATA_WIDTH{1'b1}}; // DEADBEEF replacement
            endcase
            s_axi_rvalid <= 1;
        end else begin
            s_axi_rvalid <= 0;
        end
    end
end

endmodule

