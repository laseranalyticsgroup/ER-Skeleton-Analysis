function [ img ] = AnalyzeSkeleton( ImgStack )
%SKELETONTOGRAPH AnalyzeSkeleton
%  Input - binary skeleton image
%  Output - img, struct of labeled images
%  Laurie Young 
%  Laser Analytics Group, University of Cambridge 2016
% laurie.jy@gmail.com
% edits by Marcus Fantham, Nov 2017

% Prune crudely
ImgStack = bwmorph(ImgStack, 'spur', 5);

minNumPixels = 30;
% Remove unconnected pixels
ConnectedComps = bwconncomp(ImgStack);
numPixels = cellfun(@numel,ConnectedComps.PixelIdxList);

%[cc, index] = max(numPixels);
indices = find(numPixels>minNumPixels);

ImgStackM = zeros(size(ImgStack));

for index = indices
    ImgStackM(ConnectedComps.PixelIdxList{index}) = 1;
end

% Extract branch points and segments
branchPointsImg = bwmorph(ImgStackM,'branchpoints');
endpointsImg = bwmorph(ImgStackM,'endpoints');
SegmentImg = ImgStackM - bwmorph(branchPointsImg,'dilate') > 0;
%imagesc(SegmentImg + endpointsImg + branchPointsImg*10)

% Remove spurs (segments connected to endpoints)
[row,col] = find(endpointsImg);
SegmentImgPrune = SegmentImg - bwselect(SegmentImg, col, row, 8);
%imagesc(SegmentImgPrune)

% Label branch points (nodes) and endpoints
[BranchPointsImgLabel, nBranchPoints] = bwlabel(branchPointsImg);
[EndPointsImgLabel, nEndPoints] = bwlabel(endpointsImg);

% Label segments
[SegmentImgLabel, nSegments] = bwlabel(SegmentImg);
%imagesc(SegmentImgLabel + EndPointsImgLabel + BranchPointsImgLabel*10)

% Prune
PrunedSegments = zeros(size(ImgStack));
PrunedEndpoints = zeros(size(ImgStack));
for l=1:max(SegmentImgLabel(:))
   seg = (SegmentImgLabel==l);
   seg_eps = bwmorph(seg,'endpoints');
   pruned_seg = prune(seg, 1);
   PrunedSegments = PrunedSegments | pruned_seg;
   PrunedEndpoints =  PrunedEndpoints | seg_eps;
end
PrunedSegmentsLabel = bwlabel(PrunedSegments);
EndpointsLabel = bwlabel(PrunedEndpoints+endpointsImg);

SegmentMask = EndpointsLabel > 0;
SegmentEndsLabel = SegmentImgLabel.*SegmentMask;

% assign output struct
img.SegmentImgLabel = SegmentImgLabel;

img.BranchPointsImgLabel = BranchPointsImgLabel;
img.EndPointsImgLabel = EndPointsImgLabel;
img.nSegments = nSegments;
img.BranchPointsImgLabel = BranchPointsImgLabel;
img.EndPointsImgLabel = EndPointsImgLabel;
    
end