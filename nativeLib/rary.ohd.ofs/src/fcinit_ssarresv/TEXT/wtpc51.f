C  MODULE WTPC51
C.......................................................................
C
C@PROCESS LVL(77)
C
      SUBROUTINE WTPC51(PO,CO,WK,NRES,VERSNO,OKSTOR)
C
C  DESC TRANSFERS PARAMETER INFORMAATION FROM A WORK ARRAY INTO THE PO
C  DESC AND CO ARRAYS FOR THE RESERVOIR OPERATION.
C....................................................................
C
C  WTPC51 TRANSFERS PARAMETER INFORMATION INUT FOR THE RESERVOIR
C  OPERATION FROM A TEMPORARY ARRAY INTO THE PO AND CO ARRAYS. PARAMETER
C  INPUT FOR THE RESERVOIR OPERATION IS IN A BLOCK STRUCTURE AND, HENCE,
C  THE TEMPORARY WORK ARRAY IS SO STRUCTURED. INFORMATION HAS BEEN PUT
C  INTO THE WORK ARRAY BY THREE PRECEEDING ROUTINES:
C
C   1) INFL51 - INFLOW PARAMETER, TIME-SERIES AND CARRYOVER INFORMATION
C   2) SAR51 - PARAMETERS, TIME-SERIES AND CRRYOVER INFORMATION FOR THE
C               RESERVOIR WITHOUT BACKWATER EFFECT
C   3) SAB51 - PARAMETERS, TIME-SERIES AND CRRYOVER INFORMATION FOR THE
C               RESERVOIR WITH BACKWATER EFFECT
C
C  NOTE : THIS ROUTINE SHOULD NOT BE ENTERED UNLESS THE THREE INPUT
C         ROUTINES HAVE ENDED NORMALLY AND THERE IS ENOUGH SPACE AVAIL-
C         ABLE IN BOTH THE CO AND PO ARRAYS.
C
C
C  WK(1)-WK(5) FIVE WORD FOR TITLE
C  WK(6) =1, FOR METRIC UNITS; =0, FOR ENGLISH UNITS.
C  WK(7) START LOCATION FOR INFL51 INPUT DATA, =4
C  WK(8) START LOCATION FOR DOWNSTREAM RESERVOIR INPUT DATA
C  WK(9) START LOCATION FOR UPSTREAM RESERVOIR/STATION INPUT DATA
C  WK(10) START LOCATION FOR INFLOW TIME SERIES
C  WK(11) TOTAL NUMBER OF VALUES FOR INFLOW TIME SERIES (5 PER TS)
C  WK(12) START LOCATION FOR INFLOW CARRYOVER
C  WK(13) TOTAL NUMBER OF VALUES FOR INFLOW CARRYOVER
C  XWK=WK(8) OR WK(9)
C  XWK+1 START LOCATION FOR SAR OR SAB PARAMETER
C  XWK+2 TOTAL NUMBER OF VALUES FOR SAR OR SAB PARAMETER
C  XWK+3 START LOCATION FOR SAR OR SAB TIME SERIES
C  XWK+4 TOTAL NUMBER OF VALUES FOR SAR OR SAB TIME SERIES (5 PER TS)
C  XWK+5 START LOCATION FOR SAR OR SAB CARRYOVER
C  XWK+6 TOTAL NUMBER OF VALUES FOR SAR OR SAB CARRYOVER
C  XWK+7 & XWK+7 FOR RESERVOIR REGULATION CODE, RESERVED FOR FUTURE
C
C..............................................................
C  ARGUMENT LIST DESCRIPTION
C
C    PO     - PORTION OF THE P ARRAY GIVEN TO THIS OPERATION (IN/OUT)
C    CO     - PORTION OF THE C ARRAY GIVEN TO THIS OPERATION (IN/OUT)
C    WK   - TEMPORARY WORK ARRAY WHERE ALL INFORMATION WAS STORED
C             IN THE INPUT ROUTINES. (INPUT)
C    VERSNO - VERSION NUMBER OF THIS OOPERATION (INPUT)
C    IBUG   - DEBUG FLAG =1,ON; =0,OFF (INPUT)
C    OKSTOR - LOGICAL FLAG FOR NORAML EXECUTION (OUTPUT)
C
C......................................................................
C
C  DESCRIPTION OF PO ARRAY STRUCTURE IS PRESENTED IN CHAPTER
C  VIII.3.3.SSARRESV OF THE NWSRFS USER'S MANUAL.
C.......................................................................
C
C  THE WORK ARRAY IS STRUCTURED IN THE FOLLOWING WAY:
C
C   POSITION       VARIABLE       DESCRIPTION
C   --------       --------       -----------
C       7          LWINF         POSITION IN WORK ARRAY OF START
C                                OF INFLOW INFO.
C       8          LWSAR         POSITION IN WORK ARRAY OF START
C                                OF RESERVOIR WITHOUT BACKWATER
C       9          LWSAB         POSITION IN WORK ARRAY OF START
C                                OF RESERVOIR WITH BACKWATER
C
C   LWINF         LOCPW          POINTER TO START OF PARAMETER
C                                INFO FOR INFLOW SECTION
C   LWINF+2       LOCTSW         POINTER TO START OF TIME-SERIES
C                                INFO FOR INFLOW SECTION
C   LWINF+4       LOCCOW         POINTER TO START OF CARRYOVER
C                                INFO FOR INFLOW SECTION
C
C   LWSAR         LOCPW          POINTER TO START OF PARAMETER
C                                INFO FOR SAR SECTION
C   LWSAR+2       LOCTSW         POINTER TO START OF TIME-SERIES
C                                INFO FOR SAR SECTION
C   LWSAR+4       LOCCOW         POINTER TO START OF CARRYOVER
C                                INFO FOR SAR SECTION
C
C.......................................................................
C
C  KUANG HSU  - HRL - OCTOBER 1994
C................................................................
      DIMENSION PO(*),CO(*),WK(*)
      LOGICAL OKSTOR
C
C  COMMON BLOCKS.
      INCLUDE 'common/fdbug'
      INCLUDE 'common/fprog'
      INCLUDE 'common/ionum'
      INCLUDE 'common/comn51'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_ssarresv/RCS/wtpc51.f,v $
     . $',                                                             '
     .$Id: wtpc51.f,v 1.1 1996/03/21 14:44:43 page Exp $
     . $' /
C    ===================================================================
C
C
C  TRACE WRITTEN HERE
C
      IF (ITRACE.GE.3) WRITE(IODBUG,900)
  900 FORMAT(' *** ENTER WTPC51 ***')
C
C  INITIALIZE LOCAL COUNTERS
C
      OKSTOR = .TRUE.
C
C
C  SET LOCATIONS OF INFL, SAB AND SAR INFO IN THE WORK ARRAY
C
      LWINF = WK(7)
      LWSAR = WK(8)
      LWSAB = WK(9)
C
C  ESTABLISH THE NUMBER OF VALUES FOR:
C
C  NTINF   = NO. OF INFL TS INFO VALUES
C  NCINF   = NO. OF INFL CO INFO VALUES
C
C  NPSAB  = NO. OF SAB PARM VALUES
C  NTSAB  = NO. OF SAB TS INFO VALUES
C  NCSAB  = NO. OF SAB CO INFO VALUES
C
C  NPSAR  = NO. OF SAR PARM VALUES
C  NTSAR  = NO. OF SAR TS INFO VALUES
C  NCSAR  = NO. OF SAR CO INFO VALUES
C
      NTINF = 0
      NCINF = 0
      NPSAB = 0
      NTSAB = 0
      NCSAB = 0
      NPSAR = 0
      NTSAR = 0
      NCSAR = 0
C
      NTINF   = WK(LWINF+1)
      NCINF   = WK(LWINF+3)
C
C.......................................
C  FIRST EIGHT VALUES OF PO ARRAY CAN BE SET DIRECTLY FROM INFO HELD IN
C  WORK ARRAY
C
C  VERSION NUMBER OF OPERATION
      PO(1) = VERSNO
C
C  OPERATION NAME
C
      DO 10 I=1,5
   10 PO(I+1) = WK(I)
C
C  OPERATION TIME INTERVAL
C
      PO(7) = MINODT + 0.01
C
C  UNITS USED FOR PARAMETER DEFINITION
C
      PO(8) = WK(6)
C      PO(8) = 1.0
      PO(9) = NRES
C
      NPSAR  = WK(LWSAR+1)
      NTSAR  = WK(LWSAR+3)
      NCSAR  = WK(LWSAR+5)
C
C  SAR PARAMETER START LOCATION IN PO ARRAY
C
      PO(10) = 21.01
C
C  SAB PARAMETER START LOCATION IN PO ARRAY
C
      IF(LWSAB.EQ.0) GO TO 50
      NPSAB  = WK(LWSAB+1)
      NTSAB  = WK(LWSAB+3)
      NCSAB  = WK(LWSAB+5)
 50   CONTINUE
C
      LPO = PO(10)+NPSAR
      PO(11) = 0.
      IF(NPSAB.GT.0) THEN
        PO(11) = LPO
        LPO = LPO+NPSAB
      END IF
C
C  TIME-SERIES START LOCATION IN PO ARRAY
C
      PO(12) = LPO
C
C.....................................................
C  TRANSFER THE INFLOW TS AND CO VALUES TO THE PO AND CO ARRAYS
C
C.....................................
C  NOW TRANSFER THE INFLOW TIME-SERIES INFO TO THE PO ARRAY
C  THE FIRST WORD HERE INDICATES HOW MANY TIME-SERIES ARE TO BE
C  SCANNED FOR EXISTENCE (BLANK OR VALID ID'S)
C
      LOCTSW = WK(LWINF)
      LOCTSP = PO(12)
      PO(LOCTSP) = (NTINF+NTSAR+NTSAB)/5
      LOCTSP = LOCTSP + 1
      CALL UMEMOV(WK(LOCTSW),PO(LOCTSP),NTINF)
C
      LOCTSP = LOCTSP + NTINF
C......................................
C  FINALLY TRANSFER THE CARRYOVER VALUES TO THE CO ARRAY
C
      LOCCOW = WK(LWINF+2)
      LOCCOC = 1.01
      CALL UMEMOV(WK(LOCCOW),CO(LOCCOC),NCINF)
C
      LOCCOC = LOCCOC + NCINF
C
C..................................................
C  WE'RE NOW FINISHED WITH THE INFLOW INFORMATION FOR THE RESERVOIR
C  OPERATION.
C
C  NOW WE START ON THE SAR INFORMATION
C
C.....................................................
C  TRANSFER THE SAR PARM, TS AND CO VALUES TO THE PO AND CO ARRAYS
C
      LOCPW = WK(LWSAR)
      LOCPP = PO(10)
      CALL UMEMOV(WK(LOCPW),PO(LOCPP),NPSAR)
C
C.....................................
C  NOW TRANSFER THE SAR TIME-SERIES INFO TO THE PO ARRAY
C  THE FIRST WORD HERE INDICATES HOW MANY TIME-SERIES ARE TO BE
C  SCANNED FOR EXISTENCE (BLANK OR VALID ID'S)
C
      LOCTSW = WK(LWSAR+2)
      CALL UMEMOV(WK(LOCTSW),PO(LOCTSP),NTSAR)
C
      LOCTSP = LOCTSP + NTSAR
C......................................
C  FINALLY TRANSFER THE SAR CARRYOVER VALUES TO THE CO ARRAY
C
      LOCCOW = WK(LWSAR+4)
      CALL UMEMOV(WK(LOCCOW),CO(LOCCOC),NCSAR)
C
      LOCCOC = LOCCOC + NCSAR
C
C..................................................
C  WE'RE NOW FINISHED WITH THE SAR INFORMATION FOR THE RESERVOIR
C  OPERATION.
C
C  NOW WE START ON THE SAB INFORMATION
C
C
C.....................................................
C  TRANSFER THE SAB PARM, TS AND CO VALUES TO THE PO AND CO ARRAYS
C
      IF(LWSAB.LE.0) GO TO 300
      LOCPW = WK(LWSAB)
      LOCPP = PO(11)
      CALL UMEMOV(WK(LOCPW),PO(LOCPP),NPSAB)
C
C  STOR POINTER FOR BACKWATER TABLE
      LPP = PO(11)
      LPP = LPP+1
      NELST = PO(LPP)
C
C.....................................
C  NOW TRANSFER THE SAB TIME-SERIES INFO TO THE PO ARRAY
C  THE FIRST WORD HERE INDICATES HOW MANY TIME-SERIES ARE TO BE
C  SCANNED FOR EXISTENCE (BLANK OR VALID ID'S)
C
      LOCTSW = WK(LWSAB+2)
      CALL UMEMOV(WK(LOCTSW),PO(LOCTSP),NTSAB)
C
      LOCTSP = LOCTSP + NTSAB
C......................................
C  FINALLY TRANSFER THE SAB CARRYOVER VALUES TO THE CO ARRAY
C
      LOCCOW = WK(LWSAB+4)
      CALL UMEMOV(WK(LOCCOW),CO(LOCCOC),NCSAB)
C
      LOCCOC = LOCCOC + NCSAB
C
C..................................................
C  WE'RE NOW FINISHED WITH THE SAB INFORMATION FOR THE RESERVOIR
C  OPERATION.
C
 300  CONTINUE
C
C  STORE TOTAL NUMBER OF CARRYOVER VALUES IN PO(15)
      NCTOTL = NCINF+NCSAB+NCSAR
      PO(15) = NCTOTL
C      
      IF (IBUG.GE.1) WRITE(IODBUG,1695)
     & NTINF,NCINF,NPSAB,NTSAB,NCSAB,NPSAR,NTSAR,NCSAR
 1695 FORMAT(1X,5X,5HNTINF,5X,5HNCINF,5X,5HNPSAB,
     & 5X,5HNTSAB,5X,5HNCSAB,5X,5HNPSAR,5X,5HNTSAR,5X,5HNCSAR,
     & /1X,9I10)
      NTL= NTINF+NCINF+NPSAB+NTSAB+NCSAB+NPSAR+NTSAR+NCSAR+10
      PO(14) = NTL
      IF (IBUG.LT.2) GO TO 600
      WRITE(IODBUG,1600)
 1600 FORMAT(//,' *** PO ARRAY AFTER WTPC51 ***')
      DO 550 I=1,NTL,8
      IE = I+7
      WRITE(IODBUG,1605) I,IE
 1605 FORMAT(' *** POS. NOS. :',I4,' THRU ',I4)
      WRITE(IODBUG,1610) (PO(J),J=I,IE)
  550 CONTINUE
 1610 FORMAT(1X,8F10.2)
      WRITE(IODBUG,1601)
 1601 FORMAT(//,' *** CO ARRAY AFTER WTPC51 ***')
      NTCO = 1+NRES*4
      WRITE(IODBUG,1611) (CO(J),J=1,NTCO)
 1611 FORMAT(1X,5F12.2)
 600  CONTINUE
      IF (ITRACE.GE.3) WRITE(IODBUG,999)
  999 FORMAT('  *** EXIT WTPC51 ***')
      RETURN
      END
