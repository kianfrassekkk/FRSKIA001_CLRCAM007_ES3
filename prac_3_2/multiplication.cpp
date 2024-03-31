
//Author: Christopher Hill For the EEE4120F course at UCT
//Updated by: S. Winberg

#include <stdio.h>
#include <OpenCL/cl.h>
#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
#include <tuple>

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


int main(void)
{

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

	/* OpenCL structures you need to program*/
	cl_device_id device;
	cl_context context;
	cl_program program;
	cl_kernel kernel;
	cl_command_queue queue;

    //------------------------------------------------------------------------
    //STEP 1

	cl_uint platformCount; //keeps track of the number of platforms you have installed on your device
	cl_platform_id *platforms;
	// get platform count
	clGetPlatformIDs(5, NULL, &platformCount); //sets platformCount to the number of platforms

	// get all platforms
	platforms = (cl_platform_id*) malloc(sizeof(cl_platform_id) * platformCount);
	clGetPlatformIDs(platformCount, platforms, NULL); //saves a list of platforms in the platforms variable
    

	cl_platform_id platform = platforms[0]; //Select the platform you would like to use in this program (change index to do this). If you would like to see all available platforms run platform.cpp.
	
	
	//Outputs the information of the chosen platform
	char* Info = (char*)malloc(0x1000*sizeof(char));
	clGetPlatformInfo(platform, CL_PLATFORM_NAME      , 0x1000, Info, 0);
	printf("Name      : %s\n", Info);
	clGetPlatformInfo(platform, CL_PLATFORM_VENDOR    , 0x1000, Info, 0);
	printf("Vendor    : %s\n", Info);
	clGetPlatformInfo(platform, CL_PLATFORM_VERSION   , 0x1000, Info, 0);
	printf("Version   : %s\n", Info);
	clGetPlatformInfo(platform, CL_PLATFORM_PROFILE   , 0x1000, Info, 0);
	printf("Profile   : %s\n", Info);
	
	//------------------------------------------------------------------------
    //STEP 2

	cl_int err;
	
	/* Access a device */
	//The if statement checks to see if the chosen platform uses a GPU, if not it setups the device using the CPU
	err = clGetDeviceIDs(platform, CL_DEVICE_TYPE_GPU, 1, &device, NULL);
	if(err == CL_DEVICE_NOT_FOUND) {
		err = clGetDeviceIDs(platform, CL_DEVICE_TYPE_CPU, 1, &device, NULL);
        printf("CPU ");
	} else printf("GPU ");
	printf("Device ID = %i\n",err);

	//------------------------------------------------------------------------
    //STEP 3

	context = clCreateContext(NULL, 1, &device, NULL, NULL, NULL);

	//------------------------------------------------------------------------
    //STEP 4

	//read file in	
	FILE *program_handle;
	program_handle = fopen("OpenCL/Kernel.cl", "r");

	//get program size
	size_t program_size;//, log_size;
	fseek(program_handle, 0, SEEK_END);
	program_size = ftell(program_handle);
	rewind(program_handle);

	//sort buffer out
	char *program_buffer;//, *program_log;
	program_buffer = (char*)malloc(program_size + 1);
	program_buffer[program_size] = '\0';
	fread(program_buffer, sizeof(char), program_size, program_handle);
	fclose(program_handle);
   	
	//------------------------------------------------------------------------
	//STEP 5
	
	program = clCreateProgramWithSource(context, 1, (const char**)&program_buffer, &program_size, NULL); //this compiles the kernels code

	//------------------------------------------------------------------------
	//STEP 6
	
	cl_int err3= clBuildProgram(program, 0, NULL, NULL, NULL, NULL);
	printf("program ID = %i\n", err3);
	
	//------------------------------------------------------------------------
	//STEP 7

	//TODO: select the kernel you are running
    kernel = clCreateKernel(program, "matrixMultiplication", &err);

	//------------------------------------------------------------------------
	//STEP 8

	queue = clCreateCommandQueue(context, device, 0, NULL);

	//------------------------------------------------------------------------

	//STEP 9
    size_t global_size = Size*Size; //total number of work items
    size_t local_size = Size; //Size of each work group
    cl_int num_groups = global_size/local_size; //number of work groups needed

    cl_mem matrixA_buffer, matrixB_buffer, output_buffer;

    int matrix_output[matrix_size], matrixA[matrix_size];
    for (int c = 0; c < matrix_size; c++) matrixA[c] = matrices[0][c];

    for (int m = 1; m < MATRIX_COUNT; m++) {
        //TODO: create matrixA_buffer, matrixB_buffer and output_buffer, with clCreateBuffer()
        matrixA_buffer = clCreateBuffer(context,
                                               CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
                                               matrix_size * sizeof(int),
                                               &matrixA,
                                               &err);

        matrixB_buffer = clCreateBuffer(context,
                                               CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
                                               matrix_size * sizeof(int),
                                               &matrices[m],
                                               &err);

        output_buffer = clCreateBuffer(context,
                                              CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR,
                                              matrix_size * sizeof(int),
                                              &matrix_output,
                                              &err);

        //------------------------------------------------------------------------
        //STEP 10

        //TODO: create the arguments for the kernel. Note you can create a local buffer only on the GPU as follows: clSetKernelArg(kernel, argNum, size, NULL);
        clSetKernelArg(kernel, 0, sizeof(cl_mem), &matrixA_buffer);
        clSetKernelArg(kernel, 1, sizeof(cl_mem), &matrixB_buffer);
        clSetKernelArg(kernel, 2, sizeof(cl_mem), &output_buffer);

        //------------------------------------------------------------------------
        //STEP 11

        cl_int err4 = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &global_size, &local_size, 0, NULL, NULL);

        printf("\nKernel check: %i \n", err4);

        //------------------------------------------------------------------------
        //STEP 12

        err = clEnqueueReadBuffer(queue, output_buffer, CL_TRUE, 0, sizeof(matrix_output), matrix_output, 0, NULL,
                                  NULL);

        //This command stops the program here until everything in the queue has been run
        clFinish(queue);

        //------------------------------------------------------------------------
        //STEP 13
        //rewrite matrix A with output so loop can re-iterate
        for (int c = 0; c < matrix_size; c++) matrixA[c] = matrix_output[c];
    }

    //------------------------------------------------------------------------
    //STEP 17

	if(displayMatrices){
		printf("\nOutput in the output_buffer \n");
		for(int j=0; j < matrix_size; j++) {
			printf("%i\t", matrix_output[j]);
			if(j%Size == (Size-1)){
				printf("\n");
			}
		}
	}
	
	
	//------------------------------------------------------------------------
    //STEP 18

	clReleaseKernel(kernel);
	clReleaseMemObject(output_buffer);
	clReleaseMemObject(matrixA_buffer);
	clReleaseMemObject(matrixB_buffer);
	clReleaseCommandQueue(queue);
	clReleaseProgram(program);
	clReleaseContext(context);

	return 0;
}
