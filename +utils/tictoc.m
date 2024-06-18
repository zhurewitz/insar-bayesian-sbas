%% TicToc
% Returns the current time in seconds relative to the start time from the
% 'tic' function

function t= tictoc

try
    t= toc;
catch
    tic
    t= toc;
end

end

