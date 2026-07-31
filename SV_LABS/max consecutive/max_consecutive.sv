module tb;
int counter=1;
int maximum=1;
int current;
int value;
int arr[]={5,6,3,3,3,3,4,5,2,1};
initial
begin
for(int i=0;i<arr.size()-1;i++)
begin
    current=arr[i];
    if(current==arr[i+1])
    begin
        counter++;
    end
    else
    begin
        counter=1;
    end
    if(counter>maximum)
    begin
    maximum=counter;
    value=arr[i];
    end
end
$display("max %0d value %0d " ,maximum ,value);
end
endmodule
