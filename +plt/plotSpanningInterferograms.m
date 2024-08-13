%% Plot Interferogram Network

function plotSpanningInterferograms(filelist)

warning off
metaTable= io.shortMetaData(filelist);
warning on


%% Calculate Spanning Interferograms

PrimaryDate= metaTable.PrimaryDate;
SecondaryDate= metaTable.SecondaryDate;

PostingDate= unique([PrimaryDate; SecondaryDate]);

DatePairs= unique([PrimaryDate SecondaryDate],"rows");

Nposting= length(PostingDate);
x= PostingDate(1:end-1)+ .5*diff(PostingDate);
N= Nposting-1;
y= zeros(N,1);
for i= 1:N
    y(i)= sum(DatePairs(:,1) <= x(i) & x(i) <= DatePairs(:,2));
end



%% Plot

cmap= [.5 0 0; .8 0 0; .8 .4 0 ; .5 .6 0; .2 .8 0];

plt.bar(x,y+1,min(y,4))
colormap(gca,cmap)
clim([0 4])
yticks(1:2:max(y)+1)
yticklabels(0:2:max(y))
grid on
box on
xlabel('Time Period')
xlim(PostingDate([1 end]))
ylim([0 max(y)+1])
ylabel('Spanning Interferograms')
% title('Interferogram Network Integrity','FontSize',18,'FontName','Times')

end