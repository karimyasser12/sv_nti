module tb;
int arr_ev[$];
int arr_odd[$];
int arr[]= '{9,7,4,6,2,8,6,5};
initial
begin
foreach(arr[i])
begin
    if(arr[i]%2==0)
    begin
    arr_ev.push_back(arr[i]);
    end
    else begin
    arr_odd.push_back(arr[i]);
    end
end
$display("queue even:%p",arr_ev);
$display("queue odd:%p",arr_odd);
end
endmodule
