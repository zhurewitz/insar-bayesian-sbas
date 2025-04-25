
function TF= isDateString(str)

Pat= (digitsPattern(4)+ "-"+ digitsPattern(2)+ "-" + digitsPattern(2)) | "NaT" | "";

TF= all(contains(str,Pat));

end

