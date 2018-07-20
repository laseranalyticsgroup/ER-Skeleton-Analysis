function output = unpadarray(input, paddingSize)
% Does exactly the opposite of padarray.
%
% Only works for DIRECTION: "both" (which is the default behaviour of padarray.)
% Feel free to improve the functionality to make useage more like padarray. 
%
% Marcus Fantham
% 2016
s = paddingSize;

if ndims(input) == 2
    output = input(1+s(1):end-s(1),1+s(2):end-s(2));
elseif ndims(input) == 3
    output = input(1+s(1):end-s(1),1+s(2):end-s(2),:);
else 
    output = input(1+s(1):end-s(1),1+s(2):end-s(2),:,:);
    warning('Dimensionality of input is not 2 or 3. Edit unpadarray if necessary');
end