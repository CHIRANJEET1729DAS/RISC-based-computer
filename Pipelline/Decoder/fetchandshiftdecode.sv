module general_purpose_register(
    input wire clk,
    input wire write_enable,
    input wire reset,
    input wire [4:0] address,
    input wire [31:0] data,
    output reg [31:0] out_register
);
    reg [31:0] register;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            register <= 32'b0;
            out_register <= 32'b0;
        end else if (write_enable) begin
            register <= data;
            out_register <= register;
        end
    end
endmodule

module read_instructions(
    input wire clk,
    output reg [31:0] instruction_binary
);
    reg [31:0] instructions [0:4];
    integer scanned;
    initial begin
        scanned = 0;
        $readmemb("/home/chiranjeet/instructions.txt", instructions);
    end
    always @(posedge clk) begin
        if (scanned < 5) begin
            instruction_binary <= instructions[scanned];
	    $display("instruction  read");
	    $display("%b",instruction_binary);
            scanned = scanned + 1;
        end
    end
endmodule

module shift_to_general(
    input wire clk,
    input wire reset,
    input wire [31:0] instruction_binary_line,
    input wire [4:0] address,
    input wire write_enable,
    output reg [4:0] program_counter,
    output reg [31:0] out_reg
);
    wire [31:0] reg_out;
    general_purpose_register regfile (
        .clk(clk),
        .write_enable(write_enable),
        .reset(reset),
        .address(program_counter),
        .data(instruction_binary_line),
        .out_register(reg_out)  
    );
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            program_counter <= 0;
        end else begin
            program_counter <= address;
            program_counter <= program_counter + 1;
        end
    end
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            out_reg <= 32'b0;
        end else begin
            out_reg <= reg_out;
        end
    end
endmodule

module decode(
    input wire clk,
    input wire reset,
    input wire [31:0] instruction_binary_line,
    input wire write_enable,
    output reg [4:0] program_counter,
    output reg [31:0] out_reg
);
    wire [31:0] reg_out;  

   
    general_purpose_register regfile (
        .clk(clk),
        .write_enable(write_enable),
        .reset(reset),
        .address(program_counter),
        .data(instruction_binary_line),
        .out_register(reg_out)  
    );

    reg [31:0] ins_mem;
    reg [4:0] ins_value;
    reg [31:0] temp_out_reg;  

    always @(posedge clk) begin
        ins_mem <= reg_out;
        case (ins_mem[16:0])
            17'b10000000010101010: begin
                program_counter <= ins_mem[31:27];
                ins_value <= ins_mem[26:22];
                temp_out_reg = ins_value;  
            end
            17'b10000001101010101: begin
                program_counter <= ins_mem[31:27];
                temp_out_reg = ins_mem[26:22];  
            end
            17'b10000010011011011: begin
                program_counter <= ins_mem[31:27];
                ins_value <= 5'b0;
                temp_out_reg = ins_value;  
            end
            17'b10000011111111111: begin
                program_counter <= ins_mem[31:27];
                temp_out_reg = ins_mem[26:22];  
            end
            17'b10000100101101101: begin
                program_counter <= ins_mem[31:27];
                temp_out_reg = ins_mem[26:22];  
            end
            17'b10000101101111100: begin
                program_counter <= ins_mem[31:27];
                ins_value <= ins_mem[26:22] + ins_mem[21:17];
                temp_out_reg = ins_value;  
	    end
            17'b10001011010101010: begin
                program_counter <= ins_mem[31:27];
                ins_value <= ins_mem[26:22];
                temp_out_reg = reg_out[ins_value];  
            end
            default: begin
                temp_out_reg = reg_out;  
            end
        endcase 
        out_reg <= temp_out_reg;
	$display("Out_reg");
	$display("%b",out_reg);
    end
endmodule

module testbench;
    reg clk;
    reg reset;
    reg write_enable;
    reg [4:0] address;
    wire [4:0] program_counter;
    wire [31:0] out_reg;
    wire [31:0] instruction_binary_line;

    read_instructions uut (.clk(clk), .instruction_binary(instruction_binary_line));
    general_purpose_register regfile (
        .clk(clk), .write_enable(write_enable), .reset(reset),
        .address(program_counter), .data(instruction_binary_line), .out_register(out_reg)
    );
    shift_to_general uuto (
        .clk(clk), .reset(reset), .instruction_binary_line(instruction_binary_line),
        .write_enable(write_enable), .address(address), .program_counter(program_counter)
    );
    decode uurt (
        .clk(clk), .reset(reset), .instruction_binary_line(instruction_binary_line),
        .write_enable(write_enable), .program_counter(program_counter), .out_reg(out_reg)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        write_enable = 0;
        #10;
        reset = 0;
        write_enable = 1;
        address = 5'h11;
        #100;
        $stop;
    end
endmodule
