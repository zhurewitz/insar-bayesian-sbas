%% Stitch Angles

function [AZ,INC,LOOK,LX,LY,LZ]= stitchAngles(filelist,metaGrid)

Size= metaGrid.Size;

AZ= nan(Size);
LOOK= nan(Size);
INC= nan(Size);
LX= nan(Size);
LY= nan(Size);
LZ= nan(Size);

for i= 1:length(filelist)
    [metaLat,metaLong,incidenceAngle,lookAngle,azimuthAngle,...
        lookVectorX,lookVectorY,lookVectorZ]= io.aria.readLookVector(filelist(i));
    
    [~,iax,ibx]= intersect(round(metaGrid.Long/metaGrid.dL),round(metaLong/metaGrid.dL));
    [~,iay,iby]= intersect(round(metaGrid.Lat/metaGrid.dL),round(metaLat/metaGrid.dL));
    
    AZnew= nan(Size);
    LOOKnew= nan(Size);
    INCnew= nan(Size);
    LXnew= nan(Size);
    LYnew= nan(Size);
    LZnew= nan(Size);
    
    AZnew(iay,iax)= azimuthAngle(iby,ibx);
    LOOKnew(iay,iax)= lookAngle(iby,ibx);
    INCnew(iay,iax)= incidenceAngle(iby,ibx);
    LXnew(iay,iax)= lookVectorX(iby,ibx);
    LYnew(iay,iax)= lookVectorY(iby,ibx);
    LZnew(iay,iax)= lookVectorZ(iby,ibx);
    
    OVERLAP= ~isnan(AZ) & ~isnan(AZnew);
    
    AZ= conditionalSwap(AZ,AZnew,OVERLAP);
    LOOK= conditionalSwap(LOOK,LOOKnew,OVERLAP);
    INC= conditionalSwap(INC,INCnew,OVERLAP);
    LX= conditionalSwap(LX,LXnew,OVERLAP);
    LY= conditionalSwap(LY,LYnew,OVERLAP);
    LZ= conditionalSwap(LZ,LZnew,OVERLAP);
end

x= metaGrid.Long- mean(metaGrid.Long);
y= metaGrid.Lat- mean(metaGrid.Lat);

AZ= extrapolate(AZ,x,y);
LOOK= extrapolate(LOOK,x,y);
INC= extrapolate(INC,x,y);
LX= extrapolate(LX,x,y);
LY= extrapolate(LY,x,y);
LZ= extrapolate(LZ,x,y);

end



function Z= conditionalSwap(Z,Znew,OVERLAP)

offset= 0;
if any(OVERLAP,'all')
    offset= mean(Z(OVERLAP)- Znew(OVERLAP),'omitmissing');
end

% If there is a large offset, the metadata is broken somehow. Instead
% choose either the current or the new data to use going forward
if abs(offset) > .1
    if sum(~isnan(Z),'all') <= sum(~isnan(Znew),'all')
        Z= Znew;
    end
else
    Z(isnan(Z))= Znew(isnan(Z))+ offset;
end

end


function Z= extrapolate(Z,x,y)

p= utils.polyfit2D(x,y,Z,2);
Ztmp= utils.polyval2D(p,x,y);
Z(isnan(Z))= Ztmp(isnan(Z));

end


