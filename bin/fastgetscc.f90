program fastgetscc
use sacio
use module_weight
implicit none
character(len=1024) :: arg
character(len=:) ,allocatable :: file, scc
integer :: grnnum, npts, num
integer :: i, j, k, flag
real, allocatable, dimension(:) :: data
real, allocatable, dimension(:,:) :: x, norm, weight, z
real :: az, strike, dip, rake, b, delta
type(sachead) :: head

grnnum = command_argument_count() - 5!互相关格林函数数量

call get_command_argument(1, arg)
read(arg,*) strike

call get_command_argument(2, arg)
read(arg,*) dip

call get_command_argument(3, arg)
read(arg,*) rake

call get_command_argument(4, arg)
read(arg,*) num! 分量数

call get_command_argument(5, arg)
scc = trim(arg)

call get_command_argument(6, arg)
file = trim(arg)
call sacio_readsac(file, head, data, flag)
if (flag /= 0) then
    write(0,*)"can not open file ", file
end if

npts = head%npts
b = head%b
delta = head%delta
allocate(x(1 : grnnum, 1 : npts))
forall(i = 1 : npts)
    x(1,i) = data(i)
end forall
allocate(z(1 : 1, 1 : npts))! 叠加互相关波形
allocate(norm(1 : grnnum, 0 : 7))! 归一化参数
allocate(weight(1 : 1, 1 : grnnum))! 权重
norm(1,0) = head%user0
norm(1,1) = head%user1
norm(1,2) = head%user2
norm(1,3) = head%user3
norm(1,4) = head%user4
norm(1,5) = head%user5
norm(1,6) = head%user6
norm(1,7) = head%az
if ((norm(1,7) == -12345) .or. (norm(1,0) == -12345)) then
    write(0,*) file, " az is ", norm(1,7)
end if
deallocate(file)
deallocate(data)

i = 7
do while (i <= command_argument_count())
    k = i - 5
    call get_command_argument(i, arg)
    file = trim(arg)
    call sacio_readsac(file, head, data, flag)
    if (flag /= 0) then
        write(0,*)"can not open file", file
    end if
    forall(j = 1 : npts)
        x(k, j) = data(j)
    end forall
    norm(k, 0) = head%user0
    norm(k, 1) = head%user1
    norm(k, 2) = head%user2
    norm(k, 3) = head%user3
    norm(k, 4) = head%user4
    norm(k, 5) = head%user5
    norm(k, 6) = head%user6
    norm(k, 7) = head%az
    if ((norm(k, 7) == -12345) .or. (norm(k, 0) == -12345)) then
        write(0,*) file, " az is ", norm(k,7)
    end if
    deallocate(data)
    deallocate(file)
    i = i + 1
end do

do i = 1, grnnum
    az = norm(i,7)
    call sub_weight(norm(i,0), norm(i,1), norm(i,2), norm(i,3), norm(i,4), &
        norm(i,5), norm(i,6), strike, dip, rake, az, weight(1,i))
    weight(1,i) = weight(1,i) / num
end do
z = matmul(weight, x)
allocate(data(1 : npts))
forall(i = 1 : npts)
    data(i) = z(1, i)
end forall

head%depmax = maxval(data)
head%depmin = minval(data)
head%b = b
do j = 1, npts
    if (z(1, j) ==  head%depmax) then
        head%o = (j - 1) * delta + b
    end if
end do
call sacio_writesac(scc, head, data, flag)

end program fastgetscc
