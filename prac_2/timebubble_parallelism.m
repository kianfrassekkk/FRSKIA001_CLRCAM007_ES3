function t_user = timebubble_parallelism(size)

X=rand(size, size);

tic
spmd
    myStart = (spmdIndex - 1) * size/spmdSize + 1
    myEnd = myStart + size/spmdSize - 1
    for i = myStart:myEnd
        X(:,i) = BubbleSort(X(:,i));
    end
end
t_user = toc();

display("Time tacken by the parallelism bubble sort function was " + t_user );

return;
end
