`timescale 1ns / 1ps

module axi_lite_ctrl_tb;

    // Parameters
    localparam DATA_WIDTH = 32;
    
    // Signals
    reg s_axi_aclk;
    reg s_axi_aresetn;
    reg s_axi_awvalid;
    reg [3:0] s_axi_awaddr;
    reg s_axi_wvalid;
    reg [DATA_WIDTH-1:0] s_axi_wdata;
    reg s_axi_arvalid;
    reg [3:0] s_axi_araddr;
    wire s_axi_awready;
    wire s_axi_wready;
    wire s_axi_arready;
    wire s_axi_rvalid;
    wire [DATA_WIDTH-1:0] s_axi_rdata;
    wire s_axi_bvalid;
    reg s_axi_rready;
    reg s_axi_bready;

    // Instantiate DUT
    axi_lite_ctrl #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .s_axi_aclk(s_axi_aclk),
        .s_axi_aresetn(s_axi_aresetn),
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
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rready(s_axi_rready),
        .s_axi_bready(s_axi_bready)
    );

    // Clock Generation
    always #5 s_axi_aclk = ~s_axi_aclk;

    // Stimulus
    initial begin
        s_axi_aclk = 0;
        s_axi_aresetn = 0;
        s_axi_awvalid = 0;
        s_axi_awaddr = 4'b0000;
        s_axi_wvalid = 0;
        s_axi_wdata = 32'b0;
        s_axi_arvalid = 0;
        s_axi_araddr = 4'b0000;
        s_axi_rready = 0;
        s_axi_bready = 0;

        // Reset
        #20;
        s_axi_aresetn = 1;

        // --- Write Operation to Mode Register
        @(posedge s_axi_aclk);
        s_axi_awvalid = 1;
        s_axi_awaddr = 4'h0;  // Mode register address
        s_axi_wvalid = 1;
        s_axi_wdata = 32'h02; // Mode value
        @(posedge s_axi_aclk);
        s_axi_awvalid = 0;
        s_axi_wvalid = 0;

        // --- Write Operation to Add_Value Register
        @(posedge s_axi_aclk);
        s_axi_awvalid = 1;
        s_axi_awaddr = 4'h4;  // Add_Value register address
        s_axi_wvalid = 1;
        s_axi_wdata = 32'h12345678; // New value
        @(posedge s_axi_aclk);
        s_axi_awvalid = 0;
        s_axi_wvalid = 0;

        // --- Read Operation for Mode Register
        @(posedge s_axi_aclk);
        s_axi_arvalid = 1;
        s_axi_araddr = 4'h0;  // Mode register address
        s_axi_rready = 1;
        @(posedge s_axi_aclk);
        s_axi_arvalid = 0;

        // --- Read Operation for Add_Value Register
        @(posedge s_axi_aclk);
        s_axi_arvalid = 1;
        s_axi_araddr = 4'h4;  // Add_Value register address
        @(posedge s_axi_aclk);
        s_axi_arvalid = 0;

        #20;
        $finish;
    end

    // Monitor Outputs
    always @(posedge s_axi_aclk) begin
        if (s_axi_rvalid) begin
            $display("Time %t: Read from address 0x%h, Data = 0x%h", $time, s_axi_araddr, s_axi_rdata);
        end
        if (s_axi_bvalid) begin
            $display("Time %t: Write response valid", $time);
        end
    end

endmodule

