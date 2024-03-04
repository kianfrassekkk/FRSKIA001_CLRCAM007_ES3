function [t_user,t_inbulit ] = timetest(size)
    
    X=rand(size, size);
    Y=X

    tic
    for i = 1:size 
        X(:,i) = BubbleSort(X(:,i));
    end 
    t_user = toc();

    tic
    for i = 1:size 
        Y(:,i) = sort(Y(:,i));
    end 
    t_inbulit = toc();
    
    display("Time tacken by the bubble sort function was " + t_user + " s. Time tacken by the inbuilt sort function was: "+  t_inbulit +" s.")
   
    return;
end