%% Mean and Standard Deviation

function [Mean,STD]= L1meanSTD(filename,Mission,Track)

path= utils.getH5Path("L1",Mission,Track);
name= 'data';

primaryDate= h5.read(filename,path, 'primaryDate');
secondaryDate= h5.read(filename,path, 'secondaryDate');
temporalBaseline= reshape(years(secondaryDate- primaryDate),1,1,[]);

ChunkSize= h5.chunkSize(filename,path,name);
NChunks= h5.chunkCount(filename,path,name);

Size= h5.pageSize(filename,path,name);
Mean= nan(Size);
STD= nan(Size);

for j= 1:NChunks(1)
    for i= 1:NChunks(2)
        J= (j-1)*ChunkSize(1)+ (1:ChunkSize(1));
        I= (i-1)*ChunkSize(2)+ (1:ChunkSize(2));
        
        ChunkStack= 0.1*h5.readChunkStack(filename,path,name,j,i)./temporalBaseline; % cm/yr
        
        Mean(J,I)= mean(ChunkStack,3,'omitmissing');
        STD(J,I)= std(ChunkStack,[],3,'omitmissing');
    end
end

end
