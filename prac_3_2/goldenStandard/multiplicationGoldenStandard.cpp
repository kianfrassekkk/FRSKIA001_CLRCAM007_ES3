
//Author: Christopher Hill For the EEE4120F course at UCT

#include<stdio.h>
#include<iostream>

using namespace std;



//creates a square matrix of dimensions Size X Size, with the values being the column number
void createKnownSquareMatrix(int Size, int* squareMatrix, bool displayMatrices){

	
	for(int i = 0; i<Size; i++){
		
		for(int j = 0; j<Size; j++){
			squareMatrix[i*Size+j] = j + 1;
			if(displayMatrices){
				cout<<squareMatrix[i*Size+j]<<"\t";
			}
		}
		if(displayMatrices){
			cout<<"\n";
		}
	}
	

}


//creates a random square matrix of dimensions Size X Size, with values ranging from 1-100
void createRandomSquareMatrix(int Size, int* squareMatrix, bool displayMatrices){

	
	for(int i = 0; i<Size; i++){
		
		for(int j = 0; j<Size; j++){
			squareMatrix[i*Size+j] = rand() % 100 + 1;
			if(displayMatrices){
				cout<<squareMatrix[i*Size+j]<<"\t";
			}
		}
		if(displayMatrices){
			cout<<"\n";
		}
	}
	

}




int main(void){

    clock_t start, end;  //Timers

    //MATRIX CREATION ALLOWING FOR DIFFERENT SIZES AND COUNTS
    #define displayMatrices true
    #define Size 3
    int matrix_size = Size * Size;
    #define MATRIX_COUNT 3
    int matrices[MATRIX_COUNT][matrix_size];

    for (int m = 0; m < MATRIX_COUNT; m++) {
        createKnownSquareMatrix(Size, matrices[m], displayMatrices);
        cout << "Number of elements in matrix 1: " << matrix_size << "\n";
        cout << "Dimensions of matrix 1: " << Size << "x" << Size << "\n";
        cout << "Matrix 1 pointer: " << matrices[m] << "\n";
    }
	
	
	int matrix_output[matrix_size], matrixA[matrix_size], cell;
    for (int c = 0; c < matrix_size; c++) matrixA[c] = matrices[0][c];

	//TODO: code your golden standard matrix multiplication here
    for (int m = 1; m < MATRIX_COUNT; m++) {
        for (int row = 0; row < Size; row++) {
            for (int col = 0; col < Size; col++) {
                cell = 0;
                for (int dot = 0; dot < Size; dot++) {
                    cell += matrixA[row * Size + dot] * matrices[m][col + dot * Size];
                }
                matrix_output[row * Size + col] = cell;
            }
        }
        //rewrite matrix A with output so loop can re-iterate
        for (int c = 0; c < matrix_size; c++) matrixA[c] = matrix_output[c];
    }
		
	
	
	
	//This if statement will display the matrix in output	
	if(displayMatrices){
		printf("\nOutput in the output_buffer \n");
		for(int j=0; j<matrix_size; j++) {
			printf("%i\t" ,matrix_output[j]);
			if(j%Size == (Size-1)){
				printf("\n");
			}
		}
	}
	
	return 0;
}
