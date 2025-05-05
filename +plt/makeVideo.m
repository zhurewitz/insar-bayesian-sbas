%% Make Interferogram Video

function makeVideo(filename,IlluminationImage,videoFilename,WRITE,CLIM,figureSize)

arguments
    filename 
    IlluminationImage= [];
    videoFilename= [];
    WRITE= false;
    CLIM= [-100 100];
    figureSize= [];
end

[GridLong,GridLat,Z]= d3.readXYZ(filename);
Size= [length(GridLat) length(GridLong)];

S= z2str(Z);

Page= zeros([Size,3]);

if ~isempty(figureSize)
    setFigureSize(figureSize(1),figureSize(2))
end
cla
h= imagesc(GridLong,GridLat,Page);
setOptions
daspect([1/cosd(GridLat(1)) 1 1])
clim(CLIM)
c= colorbar;
c.Label.String= "LOS Displacement (mm)";
colormap2('redblue')

CMAP= colormap2('redblue',100);
z= linspace(CLIM(1),CLIM(2),100);


if WRITE
    VIDEO= VideoWriter(videoFilename,"MPEG-4");
    open(VIDEO)
end

for k= 1:height(Z)
    Page= d3.readPage(filename,k);
    
    C2= plt.toColor2(Page,CMAP,z);
    C= plt.utils.addLayer(IlluminationImage,C2,.7);
    
    h.CData= C;
    title( strcat(string(k)," : ",S(k)) )
    drawnow
    
    if WRITE
        writeVideo(VIDEO,getframe(gcf))
    end
end

if WRITE
    close(VIDEO)
end

end



function S= z2str(Z)

if isvector(Z)
    if isdatetime(Z)
        S= string(Z,'yyyy/MM/dd');
    else
        S= string(Z);
    end
else
    if isdatetime(Z)
        S= join([string(Z(:,1),'yyyy/MM/dd'), repmat("--",height(Z),1), string(Z(:,2),'yyyy/MM/dd')]);
    else
        S= join([string(Z(:,1)), repmat("--",height(Z),1), string(Z(:,2))]);
    end
end

end

