__kernel void matrixMultiplication(__global int* matrixA_buffer, __global int* matrixB_buffer, __global int* output_buffer){
    int workItemNum = get_global_id(0); //Work item ID
    int workGroupNum = get_group_id(0); //Work group ID
	int localGroupID = get_local_id(0); //Work items ID within each work group
	int localSize = get_local_size(0); //Get the work number of items per group

    //Row <=> workGroupNum; Column <=> localGroupID
    //workItemNum <=> workGroup * localSize + localGroupID


    int cell = 0;
    for (int i = 0; i < localSize; i++) {
         cell = cell + *(matrixA_buffer + workGroupNum * localSize + i) * *(matrixB_buffer + localGroupID + i * localSize);
    }
    *(output_buffer + workItemNum) = cell;
}