program glibrms
use sacio
implicit none
character(len=1024) :: arg
character(len=:) ,allocatable :: file0, file1, file2
real,allocatable,dimension(:) :: data0, data1, data2
type(sachead) :: head0, head1, head2
integer :: flag
real :: norm0, norm1, norm2, norm3, norm4, norm5

call get_command_argument(1, arg)
file0 = trim(arg)
call sacio_readsac(file0, head0, data0, flag)

call get_command_argument(2, arg)
file1 = trim(arg)
call sacio_readsac(file1, head1, data1, flag)

call get_command_argument(3, arg)
file2 = trim(arg)
call sacio_readsac(file2, head2, data2, flag)

if (head0%npts /= head1%npts) then
    write(0,*) file0, "and", file1, "'s npts not equale"
end if
if (head1%npts /= head2%npts) then
    write(0,*) file0, "and", file1, "'s npts not equale"
end if
if (head0%npts /= head2%npts) then
    write(0,*) file0, "and", file1, "'s npts not equale"
end if

norm0 = sum(data0 * data0)
norm1 = sum(data1 * data1)
norm2 = sum(data2 * data2)
norm3 = sum(data0 * data1)
norm4 = sum(data0 * data2)
norm5 = sum(data1 * data2)

head0%user0 = norm0
head0%user1 = norm1
head0%user2 = norm2
head0%user3 = norm3
head0%user4 = norm4
head0%user5 = norm5

head1%user0 = norm0
head1%user1 = norm1
head1%user2 = norm2
head1%user3 = norm3
head1%user4 = norm4
head1%user5 = norm5

head2%user0 = norm0
head2%user1 = norm1
head2%user2 = norm2
head2%user3 = norm3
head2%user4 = norm4
head2%user5 = norm5

call sacio_writesac(file0, head0, data0, flag)
call sacio_writesac(file1, head1, data1, flag)
call sacio_writesac(file2, head2, data2, flag)
end program glibrms
