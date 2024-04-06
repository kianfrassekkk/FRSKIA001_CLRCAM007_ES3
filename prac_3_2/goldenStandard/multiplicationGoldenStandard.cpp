
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

float matrix_multiply(int Size, int MATRIX_COUNT, bool displayMatrices) {
    clock_t start, end;  //Timers

    //MATRIX CREATION ALLOWING FOR DIFFERENT SIZES AND COUNTS
    int matrix_size = Size * Size;
    int* matrices = new int[MATRIX_COUNT * matrix_size];

    for (int m = 0; m < MATRIX_COUNT; m++) {
        createKnownSquareMatrix(Size, matrices + m * matrix_size, displayMatrices);
        if (displayMatrices) {
            cout << "Number of elements in matrix 1: " << matrix_size << "\n";
            cout << "Dimensions of matrix 1: " << Size << "x" << Size << "\n";
            cout << "Matrix 1 pointer: " << matrices + m * matrix_size << "\n";
        }
    }

    start = clock(); //start running clock
	
	int matrix_output[matrix_size], matrixA[matrix_size], cell;
    for (int c = 0; c < matrix_size; c++) matrixA[c] = matrices[c];

	//TODO: code your golden standard matrix multiplication here
    for (int m = 1; m < MATRIX_COUNT; m++) {
        for (int row = 0; row < Size; row++) {
            for (int col = 0; col < Size; col++) {
                cell = 0;
                for (int dot = 0; dot < Size; dot++) {
                    cell += matrixA[row * Size + dot] * matrices[m * matrix_size + col + dot * Size];
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

    delete[] matrices;
    end = clock();

	return ((float) end - (float) start)/CLOCKS_PER_SEC;
}

int main(void) {
#define averages 20
#define size_min 2
#define size_max 201
#define count_min 2
#define count_max 51
    int count_sizes[] = {5, 10, 20, 50, 100};

    float time;

    printf("<------------------------------------------------------->\n");
    printf("Run time for sizes between %d and %d\n\n", size_min, size_max);
    matrix_multiply(size_min, 2, false);
    for (int size = size_min; size < size_max; size++) {
        time = 0;
        for (int i = 0; i < averages; i++) {
            time += matrix_multiply(size, 2, false);
        }
        printf("%0.8f\n", time / averages);
    }

    for (int count_size : count_sizes) {
        printf("<------------------------------------------------------->\n");
        printf("\nRun time for count between %d and %d at size %d\n\n", count_min, count_max, count_size);
        matrix_multiply(count_size, count_min, false);
        for (int count = count_min; count < count_max; count++) {
            time = 0;
            for (int i = 0; i < averages; i++) {
                time += matrix_multiply(count_size, count, false);
            }
            printf("%0.8f\n", time / averages);
        }
    }


    printf("<------------------------------------------------------->\n");
    printf("\nRun time for count between %d and %d and size between %d and %d\n\n", count_min, count_max, size_min, size_max);
    for (int count = 5; count <= 100; count += 5) {
        matrix_multiply(10, count, false);
        for (int size = 5; size <= 200; size += 5) {
            printf("%0.6f;", matrix_multiply(size, count, false));
        }
        printf("|");
    }
}