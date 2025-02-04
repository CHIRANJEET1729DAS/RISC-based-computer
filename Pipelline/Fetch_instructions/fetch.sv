module read_instructions(input wire clk);
  reg [31:0] instructions [0:4];  // Array to store instructions (1024 words of 32-bit each)
  integer scanned;

  initial begin
    scanned = 0;  // Initialize scanned index
    $readmemb("/home/chiranjeet/Text File.txt", instructions); // Use a constant file path
  end

  always @(posedge clk) begin
    if (scanned < 5) begin
      $display("Instruction %0d: %b", scanned, instructions[scanned]);
      scanned = scanned + 1;
    end else begin
      $display("End of Instructions.");
    end
  end
endmodule

module testbench;
  reg clk;

  // Instantiate module
  read_instructions uut(.clk(clk));

  // Clock generation
  always #5 clk = ~clk;

  initial begin
    clk = 0;
    #200; // Run for 200 time units
    $stop;
  end
endmodule

