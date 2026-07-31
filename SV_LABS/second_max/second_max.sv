module tb;
int arr[];
int arr_2[];
int max[$];
int second_max[$];
initial
begin
arr={45,34,67,87,78};
max=arr.max();
arr_2 = arr.find with(item < max[0]);
second_max=arr_2.max();
$display("Max: %0d, Second Max: %0d", max[0], second_max[0]);
end
endmodule
