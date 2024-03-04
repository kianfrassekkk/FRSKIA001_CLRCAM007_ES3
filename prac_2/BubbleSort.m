function Output_BubbleSort = BubbleSort(input_BubbleSort)
    for i = 1:length(input_BubbleSort)
        for j = length(input_BubbleSort):-1:i+1
            if input_BubbleSort(j) > input_BubbleSort(j-1)
                temp = input_BubbleSort(j);
                input_BubbleSort(j) = input_BubbleSort(j-1);
                input_BubbleSort(j-1) = temp;
            end 
        end
    end 
    Output_BubbleSort = input_BubbleSort;
    return;
end