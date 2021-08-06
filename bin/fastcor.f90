program fastcor
use sacio
use module_fastcor
implicit none
character(len=1024) :: arg
character(len=:) ,allocatable :: file, out
integer :: i, flag, npts
real,allocatable,dimension(:) :: x, y, norm, result
real :: b, e
type(sachead) :: headx, heady, head

call get_command_argument(1, arg)
file = trim(arg)
call sacio_readsac(file, headx, x, flag)
deallocate(file)

call get_command_argument(2, arg)
file = trim(arg)
call sacio_readsac(file, heady, y, flag)
deallocate(file)

call get_command_argument(3, arg)
out = trim(arg)

if (headx%delta /= heady%delta) then
    flag = 1
    write(*,*) "sacio_Fortran: delta is not equal in -X file and -Y file"
end if
if (headx%npts < heady%npts) then
    flag = 1
    write(*,*) "sacio_Fortran: npts in -X file is smaller than -Y file"
end if

if (flag == 0) then
    npts = size(x)-size(y)+1
    call sacio_newhead(head, headx%delta, npts, headx%b - heady%e + (heady%npts - 1) * headx%delta)
    head%stlo = headx%stlo
    head%stla = headx%stla
    call sub_norm(norm, x, size(y), npts)

    call sub_fastcor(x, y, norm, result, flag)
    head%user0 = heady%user0
    head%user1 = heady%user1
    head%user2 = heady%user2
    head%user3 = heady%user3
    head%user4 = heady%user4
    head%user5 = heady%user5
    head%user6 = heady%user6
    call sacio_writesac(out, head, result, flag)
    deallocate(out)
    deallocate(y)
    deallocate(result)
end if

i = 5
do while (i <= command_argument_count())
    call get_command_argument(i-1, arg)
    file = trim(arg)
    call sacio_readsac(file, heady, y, flag)
    deallocate(file)
    call get_command_argument(i, arg)
    out = trim(arg)
    call sub_fastcor(x, y, norm, result, flag)
    head%user0 = heady%user0
    head%user1 = heady%user1
    head%user2 = heady%user2
    head%user3 = heady%user3
    head%user4 = heady%user4
    head%user5 = heady%user5
    head%user6 = heady%user6
    call sacio_writesac(out, head, result, flag)
    deallocate(out)
    deallocate(y)
    deallocate(result)
    i = i + 2
end do

write (*,*) head%b, head%e
end program fastcor
