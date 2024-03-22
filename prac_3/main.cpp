//
// Created by Cameron Clark on 2024/03/22.
//

#include <stdio.h>
#include <OpenCL/cl.h>
#include <OpenCL/cl_ext.h>
#include <OpenCL/cl_gl_ext.h>
#include <OpenCL/cl_platform.h>

int main() {

    using namespace std;

    /* OpenCL structures you need to program*/
	cl_device_id device;
    cl_context context;
    cl_program program;
    cl_kernel kernel;
    cl_command_queue queue;

    //------------------------------------------------------------------------

    cl_uint platformCount; //keeps track of the number of platforms you have installed on your device
    cl_platform_id *platforms;

    // get platform count
    clGetPlatformIDs(5, NULL, &platformCount); //sets platformCount to the number of platforms

    printf("Platform count: %d\n", platformCount);

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

    context = clCreateContext(NULL, 1, &device, NULL, NULL, NULL);

    //------------------------------------------------------------------------
//
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

    program = clCreateProgramWithSource(context, 1, (const char**)&program_buffer, &program_size, NULL); //this compiles the kernels code

    //------------------------------------------------------------------------

    cl_int err3 = clBuildProgram(program, 0, NULL, NULL, NULL, NULL);
    printf("program ID = %i\n", err3);

    //------------------------------------------------------------------------

    kernel = clCreateKernel(program, "hello_kernel", &err);

    //------------------------------------------------------------------------

    queue = clCreateCommandQueueWithPropertiesAPPLE(context, device, 0, NULL);

    //------------------------------------------------------------------------

    size_t global_size = 16; //total number of work items
    size_t local_size = 4; //Size of each work group
    cl_int num_groups = global_size/local_size; //number of work groups needed

    int argument1, argument2;
    int *output;
    output = (int *)malloc(global_size*local_size*sizeof(int));

    cl_mem argument1_buffer = clCreateBuffer(context,
                                      CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR, sizeof(int),
                                      &argument1, &err);
    cl_mem argument2_buffer = clCreateBuffer(context,
                                      CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR, sizeof(int),
                                      &argument2, &err);
    cl_mem output_buffer = clCreateBuffer(context,
                                   CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR,
                                   (global_size*local_size*sizeof(int)), output, &err);


    //------------------------------------------------------------------------

    clSetKernelArg(kernel, 0, sizeof(cl_mem), &argument1_buffer);
    clSetKernelArg(kernel, 1, sizeof(cl_mem), &argument2_buffer);
    clSetKernelArg(kernel, 2, sizeof(cl_mem), &output_buffer);

    //------------------------------------------------------------------------

	cl_int err4 = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &global_size, &local_size, 0, NULL, NULL);

	printf("\nKernel check: %i \n",err4);

    //------------------------------------------------------------------------

	err = clEnqueueReadBuffer(queue, output_buffer, CL_TRUE, 0, sizeof(output), output, 0, NULL, NULL);

//    This command stops the program here until everything in the queue has been run
	clFinish(queue);

    //------------------------------------------------------------------------

    printf("\nOutput in the output_buffer \n");
    for(int j=0; j<global_size; j++) {
        printf("element number:%i \t Output:%i \n",j ,output[j]);
    }

//    //------------------------------------------------------------------------
//
//    //***Step 14*** Deallocate resources
//	clReleaseKernel(kernel);
//	clReleaseMemObject(output_buffer);
//	clReleaseMemObject(argument1_buffer);
//	clReleaseMemObject(argument2_buffer);
//	clReleaseCommandQueue(queue);
//    clReleaseProgram(program);
//    clReleaseContext(context);

    return 0;
}
