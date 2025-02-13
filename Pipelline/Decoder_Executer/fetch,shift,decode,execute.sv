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
	 //   $display("register value from gpr register %b",register);
            out_register <= register;
	 //   $display("out register value from gpr register %b",out_register);
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
	//    $display("instruction  read %b", instruction_binary);
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

module register_call(input wire clk , input wire[4:0] call_register, output reg[31:0] risc_register);
    reg[31:0] register_collection[0:31]; //32 registers each with 32 bit width
    always @(posedge clk)begin  
      case (call_register)
	    5'b00001 : begin
		    risc_register <= register_collection[0];
	    end
            5'b00010 : begin
                    risc_register <= register_collection[1];
            end
	    5'b00011 : begin
                    risc_register <= register_collection[2];
            end
	    5'b00100 : begin
                    risc_register <= register_collection[3];
            end
	    5'b00101 : begin
                    risc_register <= register_collection[4];
            end
	    5'b00110 : begin
                    risc_register <= register_collection[5];
            end
	    5'b00111 : begin
		    risc_register <= register_collection[6];
	    end
            5'b01000 : begin
		    risc_register <= register_collection[7];
            end
	    5'b01001 : begin
		    risc_register <= register_collection[8];
	    end
	    5'b01010 : begin
		    risc_register <= register_collection[9];
	    end
	    5'b01011 : begin
                    risc_register <= register_collection[10];
            end
            5'b01100 : begin
		    risc_register <= register_collection[11];
	    end
	    5'b01101 : begin
		    risc_register <= register_collection[12];
	    end
	    5'b01110 : begin
		    risc_register <= register_collection[13];
	    end
	    5'b01111 : begin
		    risc_register <= register_collection[14];
	    end
	    5'b10000 : begin
		    risc_register <= register_collection[15];
	    end
	    5'b10001 : begin
		    risc_register <= register_collection[16];
	    end
            5'b10010 : begin
		    risc_register <= register_collection[17];
	    end
 	    5'b10011 : begin
		    risc_register <= register_collection[18];
	    end
	    5'b10100 : begin
		    risc_register <= register_collection[19];
	    end
	    5'b10101 : begin
		    risc_register <= register_collection[20];
	    end
	    5'b10110 : begin
		    risc_register <= register_collection[21];
	    end
	    5'b10111 : begin
		    risc_register <= register_collection[22];
	    end
	    5'b11000 : begin
		    risc_register <= register_collection[23];
	    end
	    5'b11001 : begin
		    risc_register <= register_collection[24];
	    end
            5'b11010 : begin
		    risc_register <= register_collection[25];
	    end
	    5'b11011 : begin
		    risc_register <= register_collection[26];
	    end
	    5'b11100 : begin
		    risc_register <= register_collection[27];
	    end
	    5'b11101 : begin
		    risc_register <= register_collection[28];
	    end
	    5'b11110 : begin
		    risc_register <= register_collection[29];
	    end
	    5'b11111 : begin
		    risc_register <= register_collection[30];
	    end
	    5'b11001 : begin
		    risc_register <= register_collection[31];
        end
     endcase
   end
endmodule

module decode(
    input wire clk,
    input wire reset,
    input wire [31:0] instruction_binary_line,
    input wire write_enable,
    output reg [4:0] program_counter,
    output reg [31:0] res_reg
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
    reg [4:0] ins_value_1;
    wire [31:0] temp_out_wire;
    reg [31:0] temp_out_reg; 
    wire [31:0] temp_fill_wire;
    wire [31:0] temp_fill_reg; 
    reg [4:0] register_called;
    reg [4:0]  register_to_fill;

    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
          temp_out_reg <= 32'b0;
          register_called <= 5'b0;
        end else begin
          register_called <= reg_out[31:27]; // Extracting bits properly
	  register_to_fill <= reg_out[26:22];
       end
    end

    register_call regr (
      .clk(clk),
      .call_register(register_called),
      .risc_register(temp_out_wire)
    );
    register_call regri (
      .clk(clk),
      .call_register(register_called),
      .risc_register(temp_fill_wire)
    );
    
    assign temp_out_wire = temp_out_reg;
    assign temp_fill_wire = temp_fill_reg;

    always @(posedge clk) begin
	ins_mem <= reg_out;
//	$display("ins_mem[31:15] = %b", ins_mem[31:17]);
	$display("ins_mem = %b" , ins_mem);
        case (ins_mem[31:15])
            17'b10000000010101010: begin  //instruction_type  :: instruction , register_to_be_copied_from , register_to_replace_value_in
                temp_out_reg <= temp_fill_reg;
       	    end
            17'b10000001101010101: begin  // instruction_type  :: instruction , null_reg , register_to_jump
	//	ins_value <= ins_mem[26:22];
                ins_mem  <= temp_out_reg;
            end
            17'b10000010011011011: begin  // instruction_type  :: instruction , null_reg , register_to_empty
		temp_out_reg <= 32'b0;
            end
            17'b10000011111111111: begin  //instruction_type  :: instruction , value , register_to_initialise
                ins_value <= ins_mem[26:22];
		temp_out_reg <= {27'b0,ins_value};
            end
            17'b10000101101111100: begin //instruction_type  :: instruction , register ,register 
		temp_out_reg <= temp_out_reg + temp_fill_reg;
            end       
            17'b10000101101111100: begin //instruction_type ::  instruction , value , register_to_initialise
                ins_value <= ins_mem[26:22] ;
		temp_out_reg <= {27'b0,ins_value};
	    end
            17'b10001011010101010: begin //instruction_type :: instruction , value , value 
                ins_value <= ins_mem[26:22];
                ins_value_1 <= ins_mem[21:17];
		
		if (ins_value >= ins_value_1) begin
                   temp_out_reg <= {27'b0,ins_value- ins_value_1};
		end
		else begin 
		   temp_out_reg <= {26'b0,ins_value- ins_value_1};
		end
	    end
            17'b10000111000000001: begin //instruction_type :: instruction,value,value
		ins_value <= ins_mem[26:22];
                ins_value_1 <= ins_mem[21:17];

		temp_out_reg <={27'b0,ins_value/ins_value_1};
            end
            17'b10001000101111011: begin //instruction_type :: instruction,value,value
		ins_value <= ins_mem[26:22];
                ins_value_1 <= ins_mem[21:17];

                temp_out_reg <=ins_value*ins_value_1;
            end
	    17'b10001001011110110: begin //instruction_type :: instruction,null,value
		ins_value <= ins_mem[26:22];
		temp_out_reg <= {27'b0,ins_value<<1};
	    end
	    17'b10001010101110111: begin //instruction_type :: instruction,null,value
		ins_value <= ins_mem[26:22];
                temp_out_reg <= {27'b0,ins_value>>1};
	    end
            default: begin
                temp_out_reg = reg_out;  
  //		$display("Used default case");
            end
        endcase 
        res_reg <= temp_out_reg;
	$display("result_reg");
	$display("%b",res_reg);
    end
endmodule



module testbench;
    reg clk;
    reg reset;
    reg write_enable;
    reg [4:0] address;
    wire [4:0] program_counter;
    wire [31:0] out_reg; 
    wire [31:0] res_reg;
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
        .write_enable(write_enable), .program_counter(program_counter), .res_reg(res_reg)
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
