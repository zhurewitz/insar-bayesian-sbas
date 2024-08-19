%% KMZ.SUBTRACT
% Performs a subtraction operation on a pair of KMZ files

function p= subtract(kmzfile1,kmzfile2,outputFile,outputName)

arguments
    kmzfile1
    kmzfile2
    outputFile= [];
    outputName= [];
end

[px,py]= kmz.readPolygon(kmzfile1);
warning off
pshape1= polyshape(px,py);
warning on

[px,py]= kmz.readPolygon(kmzfile2);
warning off
pshape2= polyshape(px,py);
warning on

warning off
result= subtract(pshape1,pshape2);
warning on

if nargout > 0
    p= result;
end

if ~isempty(outputFile)
    kmz.writePolyshape(outputFile,result,outputName);
end

end

