module ALU(input logic [3:0]ALU_CTL, 
input logic [7:0]A, B, 
output logic [7:0]Z,FLAGS); 

logic [7:0] Z0,Z1,Z2,Z3;
logic [7:0] Z_temp;
logic COUT; //do i need this?

logic ADD_SUB_CTL, ROT_CTL, MULT_CTL, GATES_CTL;

assign ADD_SUB_CTL = ALU_CTL[0];
assign ROT_CTL = ALU_CTL[1];
assign MULT_CTL = ALU_CTL[2];
assign GATES_CTL = ALU_CTL[3];  

ADD_SUB mod1(A,B, ADD_SUB_CTL, Z0, COUT);

ROT mod2(A,B[2:0],ROT_CTL, Z1);

MULT mod3(A[3:0],B[3:0],Z2);

GATES mod4(A,B, GATES_CTL,Z3);

FLAGS mod5 (A,B,ALU_CTL,COUT,Z_temp,FLAGS);


always_comb 
begin 
casez(ALU_CTL)
4'b0000: Z = Z0;
4'b0010: Z = Z1;
4'b0100: Z = Z2;
4'b0011: Z = 8'b00000000;
4'b0110: Z = Z3;
default: Z = 8'b00000000;
endcase 
end 

endmodule


module ADD_SUB (input logic [7:0] A,B, 
					 input logic ADD_SUB_CTL, 
					 output logic [7:0] Z, 
					 output logic COUT); // can i do that?
					 
always_comb 
begin
if(ADD_SUB_CTL) 
{COUT,Z} = A - B; //subtraction with carry
else //addition
{COUT,Z} = A + B; //addition with carry
end 
endmodule




module ROT (input logic [7:0] A,
				input logic [2:0] B, //3 bit rotation 
				input logic ROT_CTL, 
				output logic [7:0] Z);
				
always_comb 
begin 
if (ROT_CTL) 
Z = A >> B | A << (8-B); //right rotate 
else // left rotate
Z = A << B | A >> (8-B); 
end 
endmodule 




module MULT (input logic [3:0] A,B, 
				 output logic [7:0] Z);
logic [7:0] temp_Z; //temp result to get the sum

always_comb
begin 
temp_Z = 8'b00000000; //set the result to 0
if (B[0]) temp_Z = temp_Z + {4'b0000, A}  // A shifted by 0
// checks if LSB is 1, if it is, it adds A to t_result and gives A four leading 
// zeros so there is no shift
if (B[1]) temp_Z = temp_Z + {3'b000,A,1'b0}; //A shifted by 1
//check if 2nd LSB is 1, adds A shifted by 1 bit to the left
//gives A three zeros at left, and one zero at right so A shifts by 1
if (B[2]) temp_Z = temp_Z + {2'b00, A, 2'b00};
// checks if third bit is 1, adds A by 2 bits to the left
// gives A two zeros to left and two zeros to right so A shifts by 2
if (B[3]) temp_Z = temp_Z + {1'b0, A, 3'b000}; //A shifted by 3
//checks if 4th bit is 1, adds A shifted by 3 bits to the left 
//gives A 1 zero to left and three zeros to the right, so A shifts by 3 
end 

assign Z = temp_Z; //output final result
endmodule






module GATES (input logic [7:0] A,B, 
				  input logic [1:0] GATES_CTL, 
				  output logic [7:0] Z);

always_comb 
begin 
case (GATES_CTL)
		2'b00: Z = A & B; //AND 
		2'b01: Z = A | B; //OR
		2'b10: Z = A ^ B; //XOR
		2'b11: Z = ~A;     //NOT
		default: Z = 8'b0;
		
endcase 
end 
endmodule

module FLAGS (input logic [7:0] Z, 
				  input logic [7:0] A, B,
				  input logic [3:0] ALU_CTL, 
				  input logic CIN, //where do i implement this?
				  output logic [7:0] FLAGS);
				  
always_comb
begin 

flags = 8'b0; //defaults all flags to 0

//ZERO FLAG
if (Z == 8'b00000000)
flags[2] = 1;


//NEGATIVE FLAG 
if (Z[7] == 1) //if the MSB is 1 then negative 
flags[3] = 1;

				
				
//OVERFLOW FLAG
		
if ((ALU_CTL == 4'b0000) || (ALU_CTL == 4'b0001)) //add or sub operations 
begin 
if ((A[7] == B[7]) && (Z[7] != A[7])) begin  
// A[7] and B[7] are MSB of both operands. checks if A and B have the same sign, 
//if it is true then both operands are either postive or both negative
//result[7] is MSB of the result, checks if the sign bit of the result is different from the sign bit of operand A
flags[0] = 1; //overflow flag is set
end 


//CARRY FLAG
if (ALU_CTL == 4'b0000) //add operation
begin 
if ((A+B + CIN) > 8'b11111111) //carry is set if the sum exceeds that many bits 
begin 
flags[1] = 1; //set carry flags 
end 


else if (ALU_CTL == 4'b0001) //sub operation
begin
if (A >= B + CIN) //no borrow occurs if A is greater than or equal to B
begin  
flags[1] = 1; 
end 




//MULT AND ROT FLAGS 

if (ALU_CTL == 4'b0101) //MULT
begin 
if (A[7:4] != 4'b0000 || B[7:4] != 4'b0000) //check for mult error, if upper 4 bits are non zero
begin 
flags[4] =1; 
Z= 8'b00000000; // for the result to zero
end 
end 

if (ALU_CTL == 4'b0110) //ROT
begin 
if (B[7:5] != 3'b000) //check if upper 5 bits of B are non zero
flags[5] = 1; 
Z = 8'b00000000;
end 




//LESS THAN / EQUAL TO FLAGS
if (A < B)
flags[6] = 1 ; 
else begin 
flags[6] = 0;
end 

if (A == B)
flags [7] =1; 
else begin 
flags[7] = 0;
end 
end 
endmodule

				
				
				
				
				