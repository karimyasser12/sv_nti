module tb;
int arr[]={8,3,3,4,5,6,3,5,4,6,7,6,4,3,5,6};
int counter;
int current;
int arr_unq[$]=arr.unique();
initial 
begin
foreach(arr_unq[i])
	begin
	counter=0;
	foreach(arr[k])
	if(arr[k]==arr_unq[i])
	counter++;
if(counter>0)
$display("%0d appears %0d times",arr_unq[i],counter);
end
end
endmodule
