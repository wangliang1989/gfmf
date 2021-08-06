program fastsum
use sacio
use module_weight
implicit none
character(len=1024) :: arg
character(len=:) ,allocatable :: file
integer :: grnnum, npts, strikei, dipi, rakei, num, step
integer :: i, j, flag, paranum, best_strike, best_dip, best_rake
real, allocatable, dimension(:) :: data
real, allocatable, dimension(:,:) :: x, norm, weight, z
real :: threshold, time, az, strike, dip, rake, b, delta, sigma, th, mad, best_time, best_cc
type(sachead) :: head

paranum = 3
grnnum = command_argument_count() - paranum

call get_command_argument(1, arg)
read(arg,*) threshold

call get_command_argument(2, arg)
read(arg,*) step

call get_command_argument(3, arg)
read(arg,*) num

call get_command_argument(paranum + 1, arg)
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
if ((norm(1, 7) == -12345) .or. (norm(1, 0) == -12345)) then
    write(0,*) file, " az is ", norm(1,7)
end if
deallocate(file)
deallocate(data)

i = paranum + 2
do while (i <= command_argument_count())
    call get_command_argument(i, arg)
    file = trim(arg)
    call sacio_readsac(file, head, data, flag)
    if (flag /= 0) then
        write(0,*)"can not open file", file
    end if
    forall(j = 1 : npts)
        x(i - paranum, j) = data(j)
    end forall
    norm(i - paranum, 0) = head%user0
    norm(i - paranum, 1) = head%user1
    norm(i - paranum, 2) = head%user2
    norm(i - paranum, 3) = head%user3
    norm(i - paranum, 4) = head%user4
    norm(i - paranum, 5) = head%user5
    norm(i - paranum, 6) = head%user6
    norm(i - paranum, 7) = head%az
    if ((norm(i - paranum, 7) == -12345) .or. (norm(i - paranum, 0) == -12345)) then
        write(0,*) file, " az is ", norm(i - paranum,7)
    end if
    deallocate(data)
    deallocate(file)
    i = i + 1
end do
do strikei = 0, 360, step
    strike = strikei
    do dipi = 0, 90, step
        dip = dipi
        do rakei = -90, 90, step
            rake = rakei
            if (strikei == 360) cycle
            if ((dipi == 0) .or. ((dipi == 90) .and. ((rakei == 90) .or. (rakei == -90)))) cycle
            if ((strikei >= 180) .and. (dipi == 90)) cycle
            if ((strikei >= 180) .and. (rakei == 90)) cycle
            if ((strikei >= 180) .and. (rakei == -90)) cycle
            do i = 1, grnnum
                az = norm(i,7)
                call sub_weight(norm(i,0), norm(i,1), norm(i,2), norm(i,3), norm(i,4), norm(i,5), norm(i,6), &
                    & strike, dip, rake, az, weight(1,i))
                weight(1,i) = weight(1,i) / num
            end do
            z = matmul(weight, x)
            if (threshold > 0) then
                !计算MAD，默认平均数为0，sigma是MAD的1.4826倍
                sigma = 0
                do i = 1, npts
                    sigma = sigma + z(1, i) * z(1, i)
                end do
                sigma = sqrt(sigma / npts)
                mad = sigma / 1.4826
                th = mad * threshold
            end if
            !get the mad
            do j = 1, npts
                if ((z(1, j) >= th) .and. (threshold > 0)) then
                    time = (j - 1) * delta + b
                    write(*,100) strikei, dipi, rakei, time, z(1,j), mad, th
                end if
                if ((z(1, j) > best_cc) .and. (threshold == 0)) then
                    best_strike = strikei
                    best_dip = dipi
                    best_rake = rakei
                    best_time = (j - 1) * delta + b
                    best_cc = z(1, j)
                end if
            end do
        end do
    end do
end do
if (threshold == 0) then
    write(*,100) best_strike, best_dip, best_rake, best_time, best_cc, 0.0, 0.0
end if
100 format(3I10, F15.2, 3ES25.10)
end program fastsum
