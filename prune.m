% Remove end points from segments, n times
% laurie.jy@gmail.com
function pseg = prune(seg, ns)
    pseg = seg;
    for n=1:ns
       pseg = pseg & ~bwmorph(pseg,'endpoints');
    end
end