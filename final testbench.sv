module testbench();

logic clk; 
logic [3:0] ALU_CTL;
logic [7:0] A,B,Z, FLAGS, Z_ex, FLAGS_ex;
logic [70:0] vectornum, errors;
logic [35:0] testvectors [80:0];

ALU dut(ALU_CTL,A,B,Z,FLAGS);

always begin 
clk=1; #50; 
clk = 0; #50;
end 


initial 
begin 
$readmemh("testvector.tv", testvectors);
vectornum = 0; 
errors = 0;
end 

always@(posedge clk)
begin
#1; 
  
		{ALU_CTL,A,B,Z_ex, FLAGS_ex} = testvectors[vectornum];
     // A =  testvectors[vectornum][4];
     // B =  testvectors[vectornum][3];
     // ALU_CTRL =  testvectors[vectornum][2];
     // Z_ex =  testvectors[vectornum][1];
     // FLAGS_ex =  testvectors[vectornum][0];
    end

always @(negedge clk)
begin 
  if ((Z !== Z_ex)||(FLAGS !== FLAGS_ex))  begin
 $display(" Error in vector %d", vectornum);
				 errors = errors+1;		
end


 vectornum = vectornum + 1;	



  if (testvectors[vectornum][0] === 1'bx) begin
 $display("%d tests completed with %d errors", vectornum, errors);
 $stop;

  end
   end

endmodule




