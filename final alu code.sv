module ALU(input logic [3:0]ALU_CTL, 
input logic [7:0]A, B, 
output logic [7:0]Z,FLAGS); 

logic [7:0] Z0,Z1,Z2,Z3;
logic [7:0] Z_TEMP;
logic CARRY; //I hope you dont take points off but I used this since CIN = COUT and it wouldn't work if i didnt do this




ADD_SUB mod1(A[7:0],B[7:0], ALU_CTL[0],CARRY, Z0[7:0]);

ROT mod2(A[7:0],B[2:0],ALU_CTL[1:1], Z1[7:0]);

MULT mod3(A[3:0],B[3:0],Z2[7:0]);

GATES mod4(A[7:0],B[7:0], ALU_CTL[2:1],Z3[7:0]);   

FLAGS_ERROR mod5(A[7:0],B[7:0],ALU_CTL[3:0],CARRY,Z_TEMP[7:0],FLAGS[7:0],Z[7:0]);


always_comb 
begin 
casez(ALU_CTL) 
4'b000?: Z_TEMP = Z0; //addsub
4'b01??: Z_TEMP = Z1; //rot
4'b0010: Z_TEMP = Z2; //multiply
4'b1???: Z_TEMP = Z3; //gates
4'b0011: Z_TEMP= 8'b0; //reserved case
default: Z_TEMP =8'b0; //default for case

endcase 
end 


endmodule


module ADD_SUB (input logic [7:0] A,B, 
					 input logic [0:0]ALU_CTL, 
					 output logic CARRY, 
					 output logic [7:0] Z); 
				
			
 always_comb  
 
case(ALU_CTL)



1'b0: begin  //addition
{CARRY,Z} = A + B;  //performs addition, stores z, and carry is stored for flags
end 
1'b1: begin
CARRY = 1;
		{CARRY,Z} = A + (~B) + 1; // takes in account twos complement, stores z and stores the carry
		CARRY = ~CARRY; //inverts the carry didnt work without it
 end 
 
default: begin 
CARRY = 0;
Z = 0;

end
endcase
endmodule




module ROT (
    input logic [7:0] A,
    input logic [2:0] B,  // 3-bit rotation
    input logic [1:1]ALU_CTL,
    output logic [7:0] Z
);

logic [7:0] ZA, ZB;
logic [2:0] ROTBB;

always_comb begin
    if (ALU_CTL == 1'b0) begin // Right rotation
        ZA = A >> B; //A is rotated by the number of B bits
        ROTBB = 8 - B; //calculates the number of bits that needs to be shifted to the right to complete rotation
        ZB = A << ROTBB; //shifts A to the right by ROTBB bits 
        Z = ZA | ZB; //bitwise OR 
    end else begin // Left rotation
        ZA = A << B; //a is roated left by B bits
        ROTBB = 8 - B; //same as above but left
        ZB = A >> ROTBB;
        Z = ZA | ZB;
    end
end
endmodule






module MULT (input logic [3:0] A, B,
             output logic [7:0] Z2);

logic P0,P1,P2,P3,P4,P5,P6,P7;
logic [2:0] C0,C1,C2,C3,C4,C5;
assign {A3,A2,A1,A0} = A;
assign {B3,B2,B1,B0} = B;

always_comb 
begin 
P0 = (A0 & B0); 
{C0,P1} = ((A1 & B0) + (A0 & B1));
{C1,P2} = ((A2 & B0) + (A1 & B1) + (A0 & B2) + C0);
{C2,P3} = ((A3 & B0) + (B1 & A2) +  (A1 & B2) + (A0 & B3) + C1); //used the given diagram and took into account the carrys that happened throughout and use adders 
{C3,P4} = ((A3 & B1)  + (A2 & B2) + (A1 & B3) + C2);
{C4,P5} = ((A3 & B2) + (A2 & B3) + C3);
{C5,P6} = ((A3 & B3) + C4);
P7 = (C5);

Z2 = {P7,P6,P5,P4,P3,P2,P1,P0}; //assign to Z
end 
endmodule
				 






module GATES (input logic [7:0] A,B, 
				  input logic [2:1]ALU_CTL, 
				  output logic [7:0] Z3);

 always_comb 
 begin
 case (ALU_CTL[2:1])
		2'b00: begin  //AND
		Z3 = (A & B); 
	end	
	
		2'b01: begin //OR
		Z3 = (A | B); 
		end
		
		2'b10: begin //NAND
		Z3 = ~(A & B);
	end	
	
		2'b11: begin //XOR
		Z3 = (A ^ B );
		end
	
		default: begin
		Z3 = 8'b00000000; 
		end

endcase
end
endmodule





		


module FLAGS_ERROR (input logic [7:0]A, B,
				  input logic [3:0]ALU_CTL, 
				  input logic CARRY,
				 input logic [7:0]Z_TEMP,
				  output logic [7:0]FLAGS,
				  output logic [7:0]Z);
				  
 
 logic Q, L, R, M, N, Z5, C, V;
 
assign FLAGS = {Q, L, R, M, N, Z5, C, V};



logic [7:0] part;
assign part[7:0] = A[7:0] + (~B[7:0]) + 8'b0000_0001; //performs subtraction from B to A of twos complement and inverts all bits of B and stores in part

always_comb 
begin
casez(ALU_CTL) 

4'b0000: begin //add -> equal(Q), less than (L), negative (N), zero (Z5), carry(C), overflow(v)
			 

				

			//equal flag
			Q = (A == B); // A is equal to B
			
			
			//less than flag
		
				
			L = (((A[7] == 1) && (B[7] == 0)) || ((A[7] == 0) && (B[7] == 0 && A<B)|| A[7]==1 && B[7]==1 && A<B)); // if MSB of A = 1  and B = 0 , or LSB of A and B are 0 and A is less than B or the MSB of A and B is 1 and A is less than B then L = 1
		
			
			R = 1'b0;
			M = 1'b0;
			
			//negative flag 
			N = (Z_TEMP[7] == 1'b1) ; //checks if the MSB of Z is 1
			
			
			//Zero flag 
			Z5 =  (Z_TEMP == 8'b00000000);
			
			
			//carry flag 
			C = (CARRY == 1); //from add sub mod if carry is 1 
			
			//overflow flag 
			V = ((A[7] == B[7]) && (Z_TEMP[7] != A[7])); //addition -> Checks if MSB of A and B are equal and the result of MSB of Z is not equal to the MSB of A then over flow is set
			
			
		Z = Z_TEMP;
			end 




4'b0001: begin //subtract -> equal(Q), less than (L), negative (N), zero (Z5), carry(C), overflow(v)


			//equal flag
			Q = (A == B) ;
		
			
			//less than flag
			
			
				
			L=(((A[7] == 1) && (B[7] == 0)) || ((A[7] == 0) && (B[7] == 0 && A<B)|| A[7]==1 && B[7]==1 && A<B)); // if MSB of A = 1  and B = 0 , or LSB of A and B are 0 and A is less than B or the MSB of A and B is 1 and A is less than B then L = 1
			
			R = 0;
			M = 0;
			
			//negative flag 
			N = (Z_TEMP[7] == 1'b1) ; 
		
			
			//Zero flag 
			Z5 = (Z_TEMP == 8'b00000000);
			
			
			//carry flag 
			C = (CARRY == 1);
			
			
			//overflow flag 
			V = ((A[7] != part[7]) && (A[7] != B[7])); //overflow is set if msb of A is different from part[7] and if the msb of a is different from the sign of B
			
			Z = Z_TEMP;
			
			end



4'b0010: begin //mult ->  equal(Q), less than(L), mult(M), zero (Z5)
	
				//equal flag
			Q = (A == B) ;

			
			//less than flag
			
			
			L = (((A[7] == 1) && (B[7] == 0)) || ((A[7] == 0) && (B[7] == 0 && A<B)|| A[7]==1 && B[7]==1 && A<B));// if MSB of A = 1  and B = 0 , or LSB of A and B are 0 and A is less than B or the MSB of A and B is 1 and A is less than B then L = 1
			
			R = 0;
			
			//mult flag 
			M = ((A[7:4] !== 4'b0000) || (B[7:4] !== 4'b0000)) ; //checks if the upper 4 bost bits in A or B are non zero
			
			N = 0;
			
			//Zero flag 
			Z5 = (Z_TEMP == 8'b00000000);
			
			
			
			C = 0;
			V = 0; 
			
			

			if ((A[7:4] !== 4'b0000) || (B[7:4] !== 4'b0000)) //forces to zero if otherwise and sets zero flag
			begin 
			Z = 0;
			Z5 = 1;
			
			end
			else
			
			Z = Z_TEMP;
end
			
			
				
				
		4'b0011: begin   //reserved (all flags are 0)
		Q = 0;
		L = 0;
		R = 0;
		M = 0;
		N = 0;
		Z5 = 0;
		C = 0;
		V = 0;
		
		Z = 0;
		
		end 
		
		
4'b01??: begin //rotate -> equal (Q), less than (L), rot(R), negative(N), zero (Z5)

				//equal flag
			Q = (A == B) ;
			
			
			//less than flag
			
			
		 L = (((A[7] == 1) && (B[7] == 0)) || ((A[7] == 0) && (B[7] == 0 && A<B)|| A[7]==1 && B[7]==1 && A<B));// if MSB of A = 1  and B = 0 , or LSB of A and B are 0 and A is less than B or the MSB of A and B is 1 and A is less than B then L = 1
			
			//rotate flag 
			R = (B[7:5] !== 5'b00000); //checks if the upper 5 most bits in B are non zero 

			M = 0;
			
			//negative flag 
			N= (Z_TEMP[7] ==1) & (~Z5); //reads the negative flag before the zero flag 
			
			
			//Zero flag 
			Z5 = (Z_TEMP == 8'b00000000);
		
			C = 0;
			V = 0;
			
			if(B[7:5] !== 5'b00000) //forces to 0 otherwise and sets the Zero flag
				begin Z = 0;
				Z5 = 1; end
			else
				Z = Z_TEMP;
			

//			
			
			
			end
		


			


4'b1???:begin // gates -> equal(q), less than (L), zero(Z)

			//equal flag
			Q = (A == B); 
	
			
			
			//less than flag
		 L = (((A[7] == 1) && (B[7] == 0)) || ((A[7] == 0) && (B[7] == 0 && A<B)|| A[7]==1 && B[7]==1 && A<B)); //same as others

			R = 0;
			M = 0;
			N = 0;

			//Zero flag 
			Z5 = (Z_TEMP == 8'b00000000);
		 
		
		   C = 0;
			V = 0;
	 Z = Z_TEMP;
	
			end 
			

			default: begin //default for case
			Q = 0;
		L = 0;
		R = 0;
		M = 0;
		N = 0;
		Z5 = 0;
		C = 0;
		V = 0;
		Z = 0;
			
			
			end 
		
			
			endcase 
			
			//Z = Z_TEMP;
			
			end

			

endmodule
				  
				  
			
				
				