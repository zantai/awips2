      SUBROUTINE INCM55(PO,JN,NU,XFACT,NQL,X,LQ1,LQN,CM,CML,CMR,STT,
     1 LTSTT,QL,LTQL,ST1,LTST1,HS,SLFI,NUMLAD,LAD,NQCM,NJUN,YQCM,NRCM1,
     2 NCM,NB,QUSJ,LTQUSJ,YQR,MRV,IORDR,K1,K2,K4,K7,K8,K9,K10)
C
C      THIS SUBROUTINE CALCULATES MANNING'S N IF ZERO VALUES ARE GIVEN

C
      COMMON/M3255/IOBS,KTERM,KPL,JNK,TEH
      COMMON/SS55/NCS,A,B,DB,R,DR,AT,BT,P,DP,ZH
      COMMON/FLP55/KFLP
      COMMON/NPC55/NP,NPST,NPEND
      COMMON/IONUM/IN,IPR,IPU
      COMMON/IDOS55/IDOS,IFCST

      INCLUDE 'common/fdbug'
      INCLUDE 'common/ofs55'
C
      DIMENSION PO(*),ST1(*),LTST1(*),STT(*),LTSTT(*),QL(*),LTQL(*)
      DIMENSION QUSJ(*),LTQUSJ(*),NQL(K1),X(K2,K1),MRV(K1),IORDR(K1)
      DIMENSION LQ1(K10,K1),LQN(K10,K1),NJUN(K1),YQR(K8)
      DIMENSION NRCM1(K1),NCM(K7,K1),NQCM(K1),NUMLAD(K1),LAD(K4,K1)
      DIMENSION YQCM(K8,K7,K1),CM(K8,K7,K1),CML(K8,K7,K1),CMR(K8,K7,K1)
      DIMENSION HS(K9,K2,K1),NB(K1),SLFI(K2,K1)
      CHARACTER*8 SNAME

C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_fldwav/RCS/incm55.f,v $
     . $',                                                             '
     .$Id: incm55.f,v 1.2 2000/12/19 15:51:59 dws Exp $
     . $' /
C    ===================================================================
C

      DATA SNAME/ 'INCM55  ' /
C
      CALL FPRBUG(SNAME,1,55,IBUG)

      IF(NP.GE.0) GO TO 500

C ... DETERMINE TOTAL INFLOW INTO SYSTEM FOR EACH TRIBUTARY
      DO 18 L=1,NU
        DO 16 M=1,JN
          J=IORDR(JN-M+1)
          LQJ=LTQUSJ(J)-1
          LS1=LTST1(J)-1
          QUSJ(LQJ+J)=ST1(LS1+J)
          DO 12 J1=1,JN
            LQJ1=LTQUSJ(J1)-1
            IF(MRV(J1).EQ.J) QUSJ(LQJ+J)=QUSJ(LQJ+J)+QUSJ(L+LQJ1)
   12     CONTINUE
          NQ=NQL(J)
          LKJ=LTQL(K)
          IF(NQ.GT.0) THEN
            DO 14 K=1,NQ
              KJ=LCAT21(K,J,NQL)
              LKJ=LTQL(KJ)-1
              IQQ=LQ1(K,J)
              LQQ=LQN(K,J)
              DX=1.
              IF(IDOS.LT.3) DX=ABS(X(LQQ,J)-X(IQQ,J))*XFACT
              QUSJ(L+LQJ)=QUSJ(L+LQJ)+QL(L+LKJ)*DX
   14       CONTINUE
          ENDIF
   16   CONTINUE
   18 CONTINUE

      DO 70 M=1,JN
      J=IORDR(JN-M+1)
      LS1=LTST1(J)-1
      NAT=NRCM1(J)
      NCML=IABS(NQCM(J))
      IF(NCML.EQ.0) NCML=NCS
      DO 65 LK=1,NAT
      IF(CM(2,LK,J).GT.0.001) GO TO 65
      I1=NCM(LK,J)
      IF(LK.LT.NAT) IND=NCM(LK+1,J)
      IF(LK.EQ.NAT) IND=NB(J)
      YQR(1)=0.
      IF(YQCM(1,LK,J).LT.0.0) YQR(1)=YQCM(1,LK,J)
      DO 102 KK=2,NCML
      YQR(KK)=0.5*(YQCM(KK-1,LK,J)+YQCM(KK,LK,J))
  102 CONTINUE
      DO 50 KK=1,NCML
      CSUM=0.
      LL=0
      DO 20 L=1,NU
      QUS=ST1(L+LS1)
      IF(JN.EQ.1) GO TO 4
      DO 2 J1=1,JN
        LQJ1=LTQUSJ(J1)-1
        IF(MRV(J1).EQ.J.AND.I1.GE.NJUN(J1)) QUS=QUS+QUSJ(L+LQJ1)
    2 CONTINUE
CC      IF(J.GT.1) GO TO 4
CC      DO 103 J1=2,JN
CC      NJN=NJUN(J1)
CC      IF(I1.GE.NJN) QUS=QUS+ST1(L,J1)
CC  103 CONTINUE
    4 IF(NQL(J).EQ.0) GO TO 6
      NQ=NQL(J)
      DO 5 I=1,NQ
        IJ=LCAT21(I,J,NQL)
        LIJ=LTQL(IJ)-1
        IQQ=LQ1(I,J)
        LQQ=LQN(I,J)
        IF(I1.GE.LQQ) THEN
          DX=1.
          IF(IDOS.LT.3) DX=ABS(X(LQQ+1,J)-X(IQQ,J))*XFACT
          QUS=QUS+QL(L+LIJ)*DX
        END IF
    5 CONTINUE
    6 II=LK
      IIJ=LCAT21(II,J,NGAGE)
      LIIJ=LTSTT(IIJ)-1
      LI1J=LTSTT(IIJ+1)-1
      IF(NQCM(J).LT.0) GO TO 7
      STA=0.5*(STT(L+LIIJ)+STT(L+LI1J))
      IF(KK.LT.NCML.AND.STA.GT.YQR(KK).AND.STA.LE.YQR(KK+1)) GO TO 8
      GO TO 20
    7 IF(QUS.GT.-10.0.AND.QUS.LT.10.0)GO TO 20
      IF(KK.LT.NCML.AND.QUS.GT.YQR(KK).AND.QUS.LE.YQR(KK+1)) GO TO 8
      GO TO 20
    8 DH=STT(L+LIIJ)-STT(L+LI1J)
      DXL=ABS(X(IND,J)-X(I1,J))*XFACT
      S=ABS(DH/DXL)
      NUML=NUMLAD(J)
      IF(NUML.EQ.0) GO TO 9
      DO 109 LLK=1,NUML
      LDD=IABS(LAD(LLK,J))
      IF(LDD.GE.I1.AND.LDD.LT.IND) S=0.5*(SLFI(I1,J)+SLFI(IND,J))
  109 CONTINUE
    9 SA=0.
      SB=0.
      DO 125 I=I1,IND
      DXX=ABS(X(I1,J)-X(I,J))*XFACT
      IF(I.EQ.I1) H=STT(L+LIIJ)
      IF(I.EQ.I1) GO TO 115
      IF(I.EQ.IND) H=STT(L+LI1J)
      IF(I.EQ.IND) GO TO 117
      H=STT(L+LIIJ)-DH*DXX/DXL
      GO TO 117
  115 CALL SECT55(PO(LCPR),PO(LOAS),PO(LOBS),HS,PO(LOASS),PO(LOBSS),
     . J,I,H,PO(LCHCAV),PO(LCIFCV),K1,K2,K9)
      AU=A
      BU=B
      GO TO 125
  117 CALL SECT55(PO(LCPR),PO(LOAS),PO(LOBS),HS,PO(LOASS),PO(LOBSS),
     . J,I,H,PO(LCHCAV),PO(LCIFCV),K1,K2,K9)
      DX=ABS(X(I,J)-X(I-1,J))*XFACT
      SA=SA+0.5*(AU+A)*DX
      SB=SB+0.5*(BU+B)*DX
      AU=A
      BU=B
  125 CONTINUE
      AAV=SA/DXL
      BAV=SB/DXL
      CN=1.486/ABS(QUS)*AAV*(AAV/BAV)**(2./3.)*SQRT(S)
      IF(CN.LT.0.003)CN=0.003
      IF(CN.GT.0.20)CN=0.20
      CSUM=CSUM+CN
      LL=LL+1
   20 CONTINUE
      IF(LL.EQ.0) CM(KK,LK,J)=0.020
      IF(LL.GT.0) CM(KK,LK,J)=CSUM/LL
      IF(IBUG.GE.1) WRITE(IODBUG,72)LL,CM(KK,LK,J)
   72 FORMAT(2X,3HLL=,I2,20X,F10.4)
   50 CONTINUE
      DO 52 L=1,NCML
      LL=L
      IF(CM(L,LK,J).GT.0.001) GO TO 54
   52 CONTINUE
   54 IF(LL.EQ.1) GO TO 58
      LL=LL-1
      DO 56 L=1,LL
   56 CM(L,LK,J)=CM(LL+1,LK,J)
   58 DO 60 L=1,NCML
      LL=L
      IF(CM(L,LK,J).LT.0.001) CM(L,LK,J)=CM(L-1,LK,J)
   60 CONTINUE
      IF(IBUG.GE.1) WRITE(IODBUG,73)LK,J
   73 FORMAT(5X,6H(CM(L,,I2,1H,,I1,11H),L=1,NCML))
      IF(IBUG.GE.1) WRITE(IODBUG,74)(CM(L,LK,J),L=1,NCML)
   74 FORMAT(12F10.4)
   65 CONTINUE
   70 CONTINUE
C  INTERPOLATE MANNING N CURVE FOR ALL INPUT CROSS SECTION REACHES
      DO 590 J=1,JN
      IF(KFLP.GE.1) NQCM(J)=0
C  KFLP>0, USE CONVEYANCE; IMPLY NQCM=0
C  NQCM=>0 MANNING N IS FCN OF H; <0 MANNING N IS FCN OF Q
      NQCMJ=NQCM(J)
      NCML=ABS(NQCMJ)
      IF(NCML.LE.0) NCML=NCS
      NRCM=NRCM1(J)
      DO 590 II=1,NRCM
      I=NRCM-II+1
      IS=NCM(I,J)
      DO 580 K=1,NCML
      CM(K,IS,J)=CM(K,I,J)
      IF(KFLP.EQ.1) THEN
        CML(K,IS,J)=CML(K,I,J)
        CMR(K,IS,J)=CMR(K,I,J)
      ENDIF
  580 YQCM(K,IS,J)=YQCM(K,I,J)
  590 CONTINUE
CC      DO 870 J=1,JN
CC      N=NB(J)
CC      NM=N-1
CC      IF(KFLP.GE.1) NQCM(J)=0
CC      NQCMJ=NQCM(J)
CC      NCML=ABS(NQCMJ)
CC      IF(NCML.EQ.0) NCML=NCS
CC      NRCM=NRCM1(J)
CC      DO 769 II=1,NRCM
CC      IIP1=II+1
CC      IS=NCM(II,J)
CC      IE=NCM(IIP1,J)
CC      IF(II.EQ.NRCM) IE=N
CC      NPT=IE-IS-1
CC      IF(NPT.LE.0) GO TO 761
CC      DO 760 I=1,NPT
CC      IPT=IS+I
CC      DO 760 K=1,NCML
CC  760 CM(K,IPT,J)=CM(K,IS,J)
CC  761 IF(NQCMJ.NE.0) GO TO 764
CCC  NQCM<>0, USE MANNING EQUATION, IMPLY KFLP=0
CC      IF(KFLP.EQ.0) GO TO 768
CC      IF(NPT.LE.0) GO TO 768
CC      DO 762 I=1,NPT
CC      IPT=IS+I
CC      DO 762 K=1,NCML
CC      CML(K,IPT,J)=CML(K,IS,J)
CC  762 CMR(K,IPT,J)=CMR(K,IS,J)
CC      GO TO 768
CC  764 IF(NPT.LE.0) GO TO 768
CC      DO 766 I=1,NPT
CC      IPT0=IS+I-1
CC      IPT=IPT0+1
CCCCC   IPT1=IPT+1
CC      HIPT0=0.0
CC      HIPT=0.0
CCC      IF(NQCMJ.GT.0) THEN
CCC        HIPT0=0.5*(HS(1,IPT0,J)+HS(1,IPT,J))
CCC        HIPT=0.5*(HS(1,IPT,J)+HS(1,IPT1,J))
CCC      ENDIF
CC      DO 766 K=1,NCML
CC  766 YQCM(K,IPT,J)=YQCM(K,IPT0,J)-HIPT0+HIPT
CC  768 CONTINUE
CC  769 CONTINUE
CC      IF(NRCM.EQ.N) GO TO 774
CC      HNM=0.0
CC      HN=0.0
CC      IF(NQCMJ.GT.0) THEN
CC        HNM=0.5*(HS(1,NM,J)+HS(1,N,J))
CC        HN=HS(1,N,J)
CC      ENDIF
CC      DO 772 K=1,NCML
CC  772 YQCM(K,N,J)=YQCM(K,NM,J)-HNM+HN
CC  774 IF (NQCMJ.NE.0) GO TO 778
CC      DO 775 I=1,NM
CC      IP1=I+1
CC      DO 775 K=1,NCS
CC  775 YQCM(K,I,J)=0.5*(HS(K,I,J)+HS(K,IP1,J))
CC      DO 776 K=1,NCS
CC  776 YQCM(K,N,J)=HS(K,N,J)
CC  778 CONTINUE
CC      IF(NCM(NRCM,J).EQ.N) GO TO 780
CC      DO 786 K=1,NCML
CC      CM(K,N,J)=CM(K,NM,J)
CC      IF(KFLP.EQ.0) GO TO 786
CC      CML(K,N,J)=CML(K,NM,J)
CC      CMR(K,N,J)=CMR(K,NM,J)
CC  786 CONTINUE
CCCC  780 IF(JNK.LT.9.OR.IBUG.EQ.0) GO TO 870
CC  780 IF(IBUG.EQ.0) GO TO 870
CC      WRITE(IODBUG,2090) J
CC 2090 FORMAT(/2X,'MANNING TABLE AT EACH SECTION REACH ON RIVER NO.',I3)
CC      DO 860 I=1,N
CC        WRITE(IODBUG,2091) I,J,(CM(K,I,J),K=1,NCML)
CC        IF(KFLP.NE.1) GO TO 849
CC        WRITE(IODBUG,2092) I,J,(CML(K,I,J),K=1,NCML)
CC        WRITE(IODBUG,2093) I,J,(CMR(K,I,J),K=1,NCML)
CC  849   IF(NQCMJ.LT.0) WRITE(IPR,2094) I,J,(YQCM(K,I,J),K=1,NCML)
CC        IF(NQCMJ.GE.0) WRITE(IPR,2095) I,J,(YQCM(K,I,J),K=1,NCML)
CC  860 CONTINUE
CC  870 CONTINUE
CCC      WRITE(IPR,11111)
CC11111 FORMAT(1X,'** EXIT INITCM **')
CC 2091 FORMAT(5X,'  CM(K,',I2,1H,,I2,')= ',10F10.4,(/19X,10F10.4))
CC 2092 FORMAT(5X,' CML(K,',I2,1H,,I2,')= ',10F10.4,(/19X,10F10.4))
CC 2093 FORMAT(5X,' CMR(K,',I2,1H,,I2,')= ',10F10.4,(/19X,10F10.4))
CC 2094 FORMAT(5X,'YQCM(K,',I2,1H,,I2,')= ',10F10.0,(/19X,10F10.0))
CC 2095 FORMAT(5X,'YQCM(K,',I2,1H,,I2,')= ',10F10.2,(/19X,10F10.2))
 500  RETURN
      END
