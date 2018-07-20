% ER_NETWORK_ANALYSIS
%  Analyze ER network images
%  Laurie Young 2016, refactored by Marcus Fantham 2017
%  Laser Analytics Group, University of Cambridge 2017
%
% mjf74@cam.ac.uk

clearvars; clc;

%% Variables to be set
% Info
pixelsize = 32e-9; % 32nm
histBins = 60; % Number of histogram bins

% Option flags
do_graph = 0;
saveOutputStack = 1;
showFigures = 0;
saveHistograms = 1;
saveHistogramData = 1;
calculateSplineStatistics = 0;

%% Set up image stack
[filename, pathname] = uigetfile({'*.tif'}, 'Choose skeletonised stack');
disp(['Analysing ', filename, ' at ', pathname]);

%% Erase old files
if (saveOutputStack || saveHistograms || saveHistogramData)
    if exist([pathname, 'analysisOutput'], 'dir') == 7
        qResult = questdlg('Erase previous results?');
        switch qResult
            case 'Cancel'
                return;
            case 'Yes'
                rmdir([pathname, 'analysisOutput'], 's');
                mkdir([pathname, 'analysisOutput']);
            case 'No'
        end      
    else
        mkdir([pathname, 'analysisOutput']);
    end
end

%% Read binary skeleton image stack
FileNameStack = fullfile(pathname, filename);
info = imfinfo(FileNameStack);
padding = 2;

nFrames = size(info,1);
ImgStackT = zeros(info(1).Height, info(1).Width, nFrames);
for n=1:nFrames
    ImgStackT(:,:,n) = logical(imread(FileNameStack,n));
end

%% Analyse each frame
% nFrames = 1; % Uncomment this line to analyse just the first frame (for debugging)
h = waitbar(0, 'Analysing skeleton image'); % Waitbar doesn't work with parfor
outputStack = zeros(info(1).Height, info(1).Width, 3, nFrames);
for n=1:nFrames
    
    % Set up frame
    disp(['n=' int2str(n)])
    ImgSlice = squeeze(ImgStackT(:,:,n));
    ImgSlice = padarray(ImgSlice ,[padding padding],0);
    
    %% 1. Analyse Skeleton
    img = AnalyzeSkeleton(ImgSlice);
    % Make a pretty output image
    analysisOutput = zeros([size(img.BranchPointsImgLabel),3]);
    analysisOutput(:,:,1) = img.BranchPointsImgLabel;
    analysisOutput(:,:,2) = img.EndPointsImgLabel;
    analysisOutput(:,:,3) = img.SegmentImgLabel;
    
    outputImage = unpadarray(analysisOutput, [padding padding]);
    
    %% 2. Fit lines to segments
    disp('Reticulating splines');
    
    % Analyse each segment
    frameSegmentLengths = zeros(img.nSegments, 1);
    for s=1:img.nSegments
        [j, i] = find(img.SegmentImgLabel==s); 
        if(numel(i)>2) 
            % find end point of segment to use as start of contour
            [epy,epx] = find(bwmorph(img.SegmentImgLabel==s,'endpoints'));
            if isempty(epx)
                continue;
            end
            P = find(i==epx(1) & j==epy(1));
            [x,y] = points2contour(i,j,P,'ccw');
            xy = [x; y];
            
            % Get length of segment by geodesic distance transform
            frameSegmentLengths(s) = max(max(bwdistgeodesic(img.SegmentImgLabel==s,...
                                epx(1),epy(1),'quasi-euclidean')));
            
            if calculateSplineStatistics 
                % if all x's are equal, swap x and y 
                if(all(~diff(x)))
                    [x,y]=chckxywp(y,x);
                else
                    [x,y]=chckxywp(x,y);
                end

                % Interpolate spline through segment skeleton
                splfit(s) = cscvn(xy);
                [spline_points, t] = fnplt(splfit(s));

                % Smooth spline with Savitzky-Golay filter
                windowWidth = 35;
                polynomialOrder = 3;
                spline_points(1,:) = sgolayfilt(spline_points(1,:), polynomialOrder, windowWidth);
                spline_points(2,:) = sgolayfilt(spline_points(2,:), polynomialOrder, windowWidth);

                % Interpolate smoothed points... 
                splfit(s) = cscvn(spline_points);

                % Can pull out some statistics about spline now (could add more)
                segmentCentre = regionprops(img.SegmentImgLabel==s,'Centroid'); 
            end 
            % Update waitbar
            progress = ((n-1)+s/img.nSegments)/nFrames;
            waitbar(progress, h, ['Analysing frame ', num2str(n, '%d') ' of ' num2str(nFrames, '%d')]);
        end % End of segment analysis
        
    end % End of s: nSegments
    
    % NB Can't preallocate "segmentLength" because we don't know final length   
    segmentLength{n} = frameSegmentLengths;
    
    %% 3. Output stage  
    % Add image to output stack for saving
    if saveOutputStack
        outputStack(:,:,:,n) = outputImage;
    end
    
    % Show output image
    if showFigures
        figure(101);
        imshow(outputImage);
    end
    
    % Save figures
    if saveHistograms || showFigures
        outputFile = fullfile(pathname, 'analysisOutput', 'histogram-slice');
        figure(102);
        [histn, histx] = hist(frameSegmentLengths*pixelsize*1e6,60);
        bar(histx, histn, 'EdgeColor', 'none', 'FaceColor', [0.4 0.4 0.4], 'BarWidth', 0.9);
        xlabel('Segment Length (\mum)');
        ylabel('Counts');
        if saveHistograms
            savefig(gcf, [outputFile, num2str(n, '%02d'), '.fig']);
            saveas(gcf, [outputFile, num2str(n, '%02d'), '.png']);
        end
        if ~showFigures
            close gcf;
        end
    end
        
end % End of n: nFrames

%% Saving stage
if saveHistogramData
    disp('Saving histogram data');
    outputFile = fullfile(pathname, 'analysisOutput', 'segmentLengths.mat');
    save(outputFile, 'segmentLength');
end

if saveOutputStack
    disp('Saving image stack');
    for n = 1:nFrames
        outputFile = fullfile(pathname, 'analysisOutput', 'outputStack.tif');
        imwrite(outputStack(:,:,1:3,n), outputFile, 'WriteMode', 'Append');
    end
end
close(h);