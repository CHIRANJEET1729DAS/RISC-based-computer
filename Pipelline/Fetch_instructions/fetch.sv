module read_instructions(input wire clk);
  reg [31:0] instructions [0:4]; 
  integer scanned;

  initial begin
    scanned = 0;  
    $readmemb("/home/chiranjeet/Text File.txt", instructions); 
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
  read_instructions uut(.clk(clk));
  always #5 clk = ~clk;

  initial begin
    clk = 0;
    #200; 
    $stop;
  end
endmodule

