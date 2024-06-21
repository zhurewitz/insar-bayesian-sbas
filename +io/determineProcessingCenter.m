
function processingCenter= determineProcessingCenter(filelist)

I1= contains(filelist,'-GUNW-'+ wildcardPattern+ '.nc');
I2= contains(filelist,'S1'+ characterListPattern('AB')+ characterListPattern('AB')+'_') & ...
    ~contains(filelist,'.zip');

processingCenter= repmat("",size(filelist));

processingCenter(I1)= "ARIA";
processingCenter(I2)= "HYP3";

end


