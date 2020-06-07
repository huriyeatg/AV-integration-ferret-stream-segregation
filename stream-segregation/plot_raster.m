function hFig= plot_raster(data,colorCode)
% %plot_raster(data,colorCode) %%

temp = cell(1,size(data,1));
for k=1:size(data,1)
    temp{1,k}=find(data(k,:));
end

n=1 ; hold on
% plot each spikes
yyaxis left
for jj = 1:size(temp,2) 
    d=temp{1,jj};
    d=d'; %invert the matrix
    if ~isempty(d)
       plot(d,n,'.','color',colorCode,...
            'markerfacecolor', colorCode,...
            'markersize', 3);
    end
    n=n+1;
end

% add mean spikes per 20ms bin
yyaxis right
res = 20; % 20ms bin resolution
sLength = size(data,2);
temp = nan(1,sLength/res);
for k = 1:(sLength/res)
    temp (k) = mean(sum(data(:,((k-1)*res +1):(k*res)),2));
end
plot([1:(sLength/res)]*res,temp,'color',colorCode)
axis off
hFig = gca;
