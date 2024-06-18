
function str= dateString(Date)

INaT= ismissing(Date);

str= string(Date,'yyyy-MM-dd');
str(INaT)= "NaT";

end

