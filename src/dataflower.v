module dataflower 
#(  parameter RAM_DATA_DEPTH = 16,
    parameter RAM_DATA_WIDTH = 128,
    parameter RAM_WORD_WIDTH = 8)
(
    input  wire        clk,
    input  wire        rst_n,
    input write_enable,
    input [ 1:0] ram_choice,
    input wire [$clog2(RAM_DATA_DEPTH) - 1:0] addr,
    input  wire [15:0] m_axis_tdata,
    input  wire        m_axis_tvalid,
    output reg         m_axis_tready,
    output  [31:0] val0,
    output  [31:0] val1,
    output  [31:0] val2,
    output  [31:0] val3
);
    
    reg [RAM_DATA_WIDTH-1:0] RAM_0 [0:RAM_DATA_DEPTH-1];
    reg [RAM_DATA_WIDTH-1:0] RAM_1 [0:RAM_DATA_DEPTH-1];
    reg [RAM_DATA_WIDTH-1:0] RAM_2 [0:RAM_DATA_DEPTH-1];
    reg [RAM_DATA_WIDTH-1:0] RAM_3 [0:RAM_DATA_DEPTH-1];
    
    reg [RAM_DATA_WIDTH-1:0] temp_data_out;
    reg [2:0] ram_counter = 0;
    
    
    reg [$clog2(RAM_WORD_WIDTH) - 1 :0] col;
    reg [$clog2(RAM_DATA_DEPTH) - 1 :0] row;
    
    reg read_enable;
    always @(posedge clk)
        read_enable <= !write_enable;
    reg [15:0] temp_storage;
    
    
    integer count;
    always @(posedge clk)
    begin
        if(!rst_n)
        begin
            m_axis_tready <= 0;
            col <= 0;
            row <= 0;
            ram_counter <= 0;
            count <=0;
        end
        else 
        begin
            
            m_axis_tready <= 1;
            
            if(m_axis_tvalid && m_axis_tready)
            begin
                col <= col + 1;
                if (col == 8-1)
                begin
                    row <= row + 1;
                    if (row == RAM_DATA_DEPTH - 1)
                    begin
                        ram_counter <= ram_counter + 1;
                        if (ram_counter == 3)
                        begin
                            ram_counter <= 3;
                            row <= RAM_DATA_DEPTH - 1;
                            col <= 8-1;   
                           m_axis_tready <= 0; 
                        end
                    end
                end 
                        
            end
    
        end
    
    end
    
    
    always @(posedge clk) 
    begin
        if (write_enable)
        begin
            case (ram_counter)
                2'd0: RAM_0[row][col*16 +: 16] <= m_axis_tdata;
                2'd1: RAM_1[row][col*16 +: 16] <= m_axis_tdata;
                2'd2: RAM_2[row][col*16 +: 16] <= m_axis_tdata;
                2'd3: RAM_3[row][col*16 +: 16] <= m_axis_tdata;
                default : temp_storage <= m_axis_tdata;
            endcase
        end
    end              
    
    assign val0 = temp_data_out[31:0];
    assign val1 = temp_data_out[63:32];
    assign val2 = temp_data_out[95:64];
    assign val3 = temp_data_out[127:96];
    
    always @(posedge clk)
    begin
        if (read_enable)
        begin
            case (ram_choice)
                2'd0: temp_data_out <= RAM_0[addr];
                2'd1: temp_data_out <= RAM_1[addr];
                2'd2: temp_data_out <= RAM_2[addr];
                2'd3: temp_data_out <= RAM_3[addr];
                default : temp_data_out <= RAM_1[addr];
            endcase
        end   
        
    end

endmodule 
 
