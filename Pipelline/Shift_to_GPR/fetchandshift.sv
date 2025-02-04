module read_instructions(input wire clk,output reg[31:0] instruction_binary);
  reg [31:0] instructions [0:4];  
  integer scanned;

  initial begin
    scanned = 0;
    $readmemb("/home/chiranjeet/instructions.txt", instructions); 
  end

  always @(posedge clk) begin
    if (scanned < 5) begin
      $display("Instruction %0d: %b", scanned, instructions[scanned]);
      instruction_binary <= instructions[scanned];
      scanned = scanned + 1;
    end else begin
      $display("End of Instructions.");
    end
  end
endmodule
module shift_to_general(input wire clk, input wire reset , input wire[31:0] instruction_binary_line,input wire[31:0] address_to_place,output reg[31:0] address,output reg[31:0] program_counter); 
 reg [31:0] general_purpose_register [0:1023];
 always @(posedge clk)begin
   if (reset)begin
	   program_counter <= 32'b0;
   end
   else begin
	   program_counter <= address_to_place;
	   general_purpose_register[program_counter] <= instruction_binary_line;
	   $display("program counter at :: ");
	   $display(program_counter);
	   program_counter <= program_counter + 1;
   end
 end
endmodule 

module testbench;
  reg clk;
  reg reset;
  reg [31:0] address_to_place;
  wire [31:0] address;
  wire[31:0] program_counter;
  wire [31:0] instruction_binary;
  // Instantiate module
  read_instructions uut(.clk(clk),.instruction_binary(instruction_binary));
  shift_to_general uuto(.clk(clk),.reset(reset),.instruction_binary_line(instruction_binary),.address_to_place(address_to_place),.address(address),.program_counter(program_counter));
  // Clock generation,
  always #5 clk = ~clk;
  initial begin
    clk = 0;
    reset = 1;
    #10;
    reset = 0;
    address_to_place = 32'h11;
    #200; 
    $stop;
  end
endmodule

