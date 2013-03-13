module conversions

contains

    real(kind=dbl) function q2abs(spec_var,t,p,qv,qc,qi,qr,qs,qg,qh)

        use kinds
        use constants, only: r_d, r_v

        implicit none

        real(kind=dbl), intent(in) :: t,&
        p

        real(kind=dbl), intent(in) :: spec_var,& ! specific variable to convert
        qv,&
        qc,&
        qi,&
        qr,&
        qs,&
        qg

        real(kind=dbl), intent(in), optional :: qh

        if (present(qh)) then
            q2abs = spec_var*p/(r_d*(1._dbl+(r_v/r_d-1._dbl)*qv-qs-qc-qi-qr-qg-qh)*t)
        else
            q2abs = spec_var*p/(r_d*(1._dbl+(r_v/r_d-1._dbl)*qv-qs-qc-qi-qr-qg)*t)
        end if

    end function q2abs

    real(kind=dbl) function vapor2rh(temp_p,pres_p,hum_massmix)

        use kinds, only: dbl
        use constants, only: tpt, estpt, r_v, r_d, mmv, mmd,vapor_hc, sublim_hc

        implicit none
        !     XPABSM air pressure in Pa
        !     ZTEMP air temperature in K
        !     XRM water vapor mass mixing ratio kg/kg

        real, intent(in) :: temp_p,pres_p,hum_massmix

        REAL(kind=dbl) :: XCPV               ! Cpv (vapor)
        REAL(kind=dbl) :: XCL,XCI            ! Cl (liquid), Ci (ice)
        REAL(kind=dbl) :: XLMTT              ! Melting heat constant
        REAL(kind=dbl) :: XALPW,XBETAW,XGAMW ! Const saturation vapor pressure  (liquid)
        REAL(kind=dbl) :: XALPI,XBETAI,XGAMI ! Consts saturation vapor pressure  (solid ice)
        real(kind=dbl) :: ztemp,xrm,xpabsm,zwork31,zwork32

        zwork32 = 0._dbl
        !  print*, temp_p, pres_p, hum_massmix
        XCPV   = 4._dbl * r_v
        XCL    = 4.218d+3
        XCI    = 2.106d+3
        XLMTT  = sublim_hc - vapor_hc
        XGAMW  = (XCL - XCPV) / r_v
        XBETAW = (vapor_hc/r_v) + (XGAMW * tpt)
        XALPW  = LOG(sublim_hc) + (XBETAW /tpt) + (XGAMW *LOG(tpt))
        XGAMI  = (XCI - XCPV) / r_v
        XBETAI = (sublim_hc/r_v) + (XGAMI * tpt)
        XALPI  = LOG(estpt) + (XBETAI /tpt) + (XGAMI *LOG(tpt))

        ZTEMP=temp_p
        XRM=hum_massmix
        XPABSM=pres_p

        !     * humidit351 relative par rapport 340 l'eau liquide

        if (ZTEMP >= tpt) then
            ZWORK31=EXP(XALPW - XBETAW/ZTEMP - XGAMW*LOG(ZTEMP))
            ZWORK31=(mmv/mmd)*ZWORK31/(XPABSM-ZWORK31)
            ZWORK32=100._dbl*XRM/ZWORK31
        elseif (ZTEMP < tpt) then
            !     * humidit351 relative par rapport 340 la glace
            ZWORK31= EXP( XALPI - XBETAI/ZTEMP - XGAMI*LOG(ZTEMP) )
            ZWORK31=(mmv/mmd)*ZWORK31/(XPABSM-ZWORK31)
            ZWORK32=100._dbl*XRM/ZWORK31
        end if

        vapor2rh=ZWORK32

    end function vapor2rh
end module conversions
