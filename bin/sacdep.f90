program sacdep
use sacio
implicit none
character(len=1024) :: arg
character(len=:), allocatable :: file
integer :: i, flag
real, allocatable, dimension(:) :: data
real :: time, time0, dep, time1, mis
type(sachead) :: head

call get_command_argument(1, arg)
file = trim(arg)

call get_command_argument(2, arg)
read(arg,*) time

call sacio_readsac(file, head, data, flag)
if (flag /= 0) then
    write(0,*)"can not open file ", file
end if

dep = -12345
time1 = -12345
mis = head%e - head%b
do i = 1, head%npts
    time0 = (i - 1) * head%delta + head%b
    if (abs(time0 - time) < mis) then
        dep = data(i)
        time1 = time0
        mis = abs(time0 - time)
    end if
end do
write(*,*) dep, time1
end program sacdep
