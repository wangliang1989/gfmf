module module_fastcor
use sacio
public :: sub_fastcor
public :: sub_norm

contains

subroutine sub_fastcor(x, y, norm, result, flag)
    implicit none
    real, allocatable, dimension(:), intent(in) :: x, y, norm
    real, allocatable, dimension(:), intent(out) :: result
    real, allocatable, dimension(:) :: cor
    integer, intent(inout) :: flag
    integer :: i, npts, nx, ny

    flag = 0
    nx = size(x)
    ny = size(y)
    npts = nx - ny + 1
    allocate(result(1 : npts))
    allocate(cor(1 : npts))
    forall(i=1:npts)
        cor(i) = sum(x(i:i+ny-1)*y(1:ny))
    end forall
    result = cor / norm
end subroutine sub_fastcor

subroutine sub_norm(norm, x, ny, npts)
    implicit none
    real, allocatable, dimension(:), intent(out) :: norm
    real, allocatable, dimension(:), intent(in) :: x
    real, allocatable, dimension(:) :: temp
    integer, intent(in) :: ny, npts
    integer :: i

    allocate(temp(1 : npts))
    temp = x * x
    allocate(norm(1 : npts))
    do i=1, npts
        norm(i) = sum(temp(i:i+ny-1))
        if (norm(i) == 0) then
            norm(i) = 1
        end if
    end do
    norm = sqrt(norm)
end subroutine sub_norm

end module module_fastcor
