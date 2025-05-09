// Description:
// This module implements an AXI-Stream processor with a configurable data width.
// It processes incoming AXI-Stream data in one of three modes:
// - Mode 0: Pass-through (no change)
// - Mode 1: Byte reversal (endian swap per byte)
// - Mode 2: Adds a constant value to the input data
//
// Internally, a small FIFO buffers the input data before sending it out.
// The output stream checks m_axis_tready before advancing the FIFO, ensuring proper AXI-Stream backpressure handling.



module axi_stream_fifo #(
    parameter DATA_WIDTH = 32,
	parameter BYTES = DATA_WIDTH/8
)(
    input wire aclk,
    input wire areset,
	
	// input coming from axi_lite_reg
    input wire [1:0] mode,
    input wire [DATA_WIDTH-1:0] add_value,

    // AXI-Stream Input
	
    input wire [DATA_WIDTH-1:0] s_axis_tdata,
    input wire					s_axis_tvalid,
    input wire [BYTES-1:0] 		s_axis_tkeep,
    input wire [BYTES-1:0] 		s_axis_tstrb,
    input wire					s_axis_tlast,


    // AXI-Stream Output
	
    output wire [DATA_WIDTH-1:0] 	m_axis_tdata,
    output wire 					m_axis_tvalid,
    output wire [BYTES-1:0]			m_axis_tkeep,
	output wire [BYTES-1:0]         m_axis_tstrb,
    output wire						m_axis_tlast,
	input wire 						m_axis_tready
);

	reg [DATA_WIDTH-1:0] mem_d [0:15];
	reg	[BYTES-1:0]		 mem_k [0:15];
    reg [BYTES-1:0]      mem_s [0:15];
	reg					 mem_l [0:15];
	
	reg [3:0] wr_ptr;
	reg [3:0] rd_ptr;
	reg [4:0] count;
	
	wire full;
	wire empty;
	
	assign full = (count == 5'd15 ) ? 1:0;
	assign empty = (count == 5'd0 ) ? 1:0;
	
	integer i;
	always @(posedge aclk) begin
		if (!areset) begin
			wr_ptr		<= 0;
			rd_ptr		<= 0;
			count		<= 0;
			
			for(i=0; i<16; i=i+1) begin
				mem_d[i] 	<= {DATA_WIDTH{1'b0}};
				mem_k[i]	<= 1'b0;
				mem_l[i]	<= 1'b0;
				mem_s[i]	<= 1'b0;
			end
			
		end else begin
			if (s_axis_tvalid && full == 1'b0) begin
				case (mode)
					2'b00: mem_d[wr_ptr] 	<= s_axis_tdata;
							
					2'b01: begin // Byte reversal
						if (DATA_WIDTH == 32) 
							mem_d[wr_ptr]	<= {s_axis_tdata[7:0], s_axis_tdata[15:8], s_axis_tdata[23:16], s_axis_tdata[31:24]};
						else 
							mem_d[wr_ptr]	<= {s_axis_tdata[7:0], s_axis_tdata[15:8], s_axis_tdata[23:16], s_axis_tdata[31:24],
											   s_axis_tdata[39:32], s_axis_tdata[47:40], s_axis_tdata[55:48], s_axis_tdata[63:56]};
					end
					2'b10: mem_d[wr_ptr]	<= s_axis_tdata + add_value;
						
					default: mem_d[wr_ptr]	<= s_axis_tdata;
				endcase
				
				wr_ptr			<= wr_ptr + 1;
				count			<= count +  1;
				
				mem_k[wr_ptr] 	<= s_axis_tkeep;
				mem_l[wr_ptr]	<= s_axis_tlast;
				mem_s[wr_ptr]	<= s_axis_tstrb;
				
			end 
			//	read data from the fifo
			else if (m_axis_tready == 1'b1 && empty == 1'b0) begin
				
				rd_ptr			<= rd_ptr + 1;
				count			<= count - 1;
			end
		end
	end
	
	assign m_axis_tdata = (m_axis_tvalid == 1'b1) ? mem_d[rd_ptr] : {DATA_WIDTH{1'b0}};
	assign m_axis_tkeep = (m_axis_tvalid == 1'b1) ? mem_k[rd_ptr] : 1'b0;
	assign m_axis_tstrb = (m_axis_tvalid == 1'b1) ? mem_s[rd_ptr] : 1'b0;
	assign m_axis_tlast = (m_axis_tvalid == 1'b1) ? mem_l[rd_ptr] : 1'b0;
	assign m_axis_tvalid = (count > 0 ) ? 1'b1 : 1'b0;
	
endmodule

	
		
