
function T= toDate(str)

if all(str == "" | h5.isDateString(str))
    Pat= (digitsPattern(4)+ "-"+ digitsPattern(2)+ "-" + digitsPattern(2)) | "NaT" | "";
    
    T= datetime.empty;
    for i= 1:height(str)
        ttmp= datetime(extract(str(i,:),Pat),"Format","yyyy-MM-dd");
        T(i,1:length(ttmp))= ttmp;
    end
    
else
    T= [];
end

end

