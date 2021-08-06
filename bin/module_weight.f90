module module_weight
public :: sub_syngrn
public :: sub_weight

contains

subroutine sub_syngrn(z0, r0, z1, r1, t1, z2, r2, t2, stk0, dip0, rak0, az0)
    implicit none

    real, intent(in) :: stk0, dip0, rak0, az0
    real, intent(out) :: z0, r0, z1, r1, t1, z2, r2, t2
    real :: stk, dip, rak, az, sstk, sdip, srak, sstk2, sdip2, cstk, cdip, crak, cstk2, cdip2

    stk = stk0
    dip = dip0
    rak = rak0
    az = az0

    stk=(az-stk)*1.745329252e-2
    dip=dip*1.745329252e-2
    rak=rak*1.745329252e-2
    sstk=sin(stk)
    cstk=cos(stk)
    sdip=sin(dip)
    cdip=cos(dip)
    srak=sin(rak)
    crak=cos(rak)
    sstk2=2*sstk*cstk
    cstk2=cstk*cstk-sstk*sstk
    sdip2=2*sdip*cdip
    cdip2=cdip*cdip-sdip*sdip
    z0=0.5*srak*sdip2
    r0=z0
    z1=-sstk*srak*cdip2+cstk*crak*cdip
    r1=z1
    t1= cstk*srak*cdip2+sstk*crak*cdip
    z2=-sstk2*crak*sdip-0.5*cstk2*srak*sdip2
    r2=z2
    t2=cstk2*crak*sdip-0.5*sstk2*srak*sdip2
end subroutine sub_syngrn

subroutine sub_weight(user0, user1, user2, user3, user4, user5, grn, strike, dip, rake, az, weight)
    implicit none

    real, intent(in) :: user0, user1, user2, user3, user4, user5, grn, strike, dip, rake, az
    real, intent(out) :: weight
    real :: z0, r0, z1, r1, t1, z2, r2, t2, k0, k1, k2, k3, k4, k5, out

    call sub_syngrn(z0, r0, z1, r1, t1, z2, r2, t2, strike, dip, rake, az)

    if ((grn == 0) .or. (grn == 3) .or. (grn == 6)) then
        k0 = z0 * z0
        k1 = z1 * z1
        k2 = z2 * z2
        k3 = 2 * z0 * z1
        k4 = 2 * z0 * z2
        k5 = 2 * z1 * z2
        out = sqrt(k0 * user0 + k1 * user1 + k2 * user2 + k3 * user3 + k4 * user4 + k5 * user5)
    else if ((grn == 1) .or. (grn == 4) .or. (grn == 7)) then
        k0 = r0 * r0
        k1 = r1 * r1
        k2 = r2 * r2
        k3 = 2 * r0 * r1
        k4 = 2 * r0 * r2
        k5 = 2 * r1 * r2
        out = sqrt(k0 * user0 + k1 * user1 + k2 * user2 + k3 * user3 + k4 * user4 + k5 * user5)
    else if ((grn == 5) .or. (grn == 8)) then
        out = sqrt(t1 * t1 * user1 + t2 * t2 * user2 + 2 * t1 * t2 * user5)
    end if
    if (grn == 0) then
        weight = 1 / out * z0
    else if (grn == 3) then
        weight = 1 / out * z1
    else if (grn == 6) then
        weight = 1 / out * z2
    else if (grn == 1) then
        weight = 1 / out * r0
    else if (grn == 4) then
        weight = 1 / out * r1
    else if (grn == 7) then
        weight = 1 / out * r2
    else if (grn == 5) then
        weight = 1 / out * t1
    else if (grn == 8) then
        weight = 1 / out * t2
    end if

end subroutine sub_weight

end module module_weight
