C MEMBER HDFUNC
C  (from old member HCLDFUNC)
C-----------------------------------------------------------------------
C
C                             LAST UPDATE: 04/05/95.13:55:24 BY $WC20SV
C
C @PROCESS LVL(77)
C
      SUBROUTINE HDFUNC (IGL,ISTAT)
C
C
C          ROUTINE:  HDFUNC
C
C             VERSION:  1.0.0
C
C                DATE: 7-28-81
C
C              AUTHOR:  SONJA R SIEGEL
C                       DATA SCIENCES INC
C
C***********************************************************************
C
C          DESCRIPTION:
C
C    THIS ROUTINE WILL PROCESS THE DEFINE FUNCTION COMMAND, BOTH
C    GLOBAL AND LOCAL.  IT WILL READ CARDS UNTIL ANOTHER COMMAND
C    IS FOUND.
C
C***********************************************************************
C
C          ARGUMENT LIST:
C
C         NAME    TYPE  I/O   DIM   DESCRIPTION
C
C          IGL      I     I    1     GLOBAL/LOCAL FLAG 1=LOC, -1=GLOB
C          ISTAT    I     O    1     STATUS 0=OK
C                                           1=ERROR
C
C***********************************************************************
C
C          COMMON:
C
      INCLUDE 'uio'
      INCLUDE 'udebug'
      INCLUDE 'udatas'
      INCLUDE 'ufreei'
      INCLUDE 'hclcommon/hcomnd'
      INCLUDE 'hclcommon/hwords'
      INCLUDE 'hclcommon/hcntrl'
C
C***********************************************************************
C
C          DIMENSION AND TYPE DECLARATIONS:
C
      DIMENSION NAME(2),ITNAME(2),ITBUF(512),IFNREC(128),IDFREC(512)
      DIMENSION IRIGHT(2),LEFT(2)
      DIMENSION IGTRAY(40)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/db_hclrw/RCS/hdfunc.f,v $
     . $',                                                             '
     .$Id: hdfunc.f,v 1.1 1995/09/17 18:42:02 dws Exp $
     . $' /
C    ===================================================================
C
C
C***********************************************************************
C
C          DATA:
C
C
C
C
      ITMAX=512
      IFMAX=128
      IDMAX=512
      MAXGT=40
C
C  READ FIRST CARD FROM SAVED CARD FILE
C
      NNCARD=1
      CALL HCARDR (NNCARD,ISTAT)
      IF (ISTAT.NE.0) GO TO 380
C
C CHECK NAME AND PASSWORD
C
      ISTAT=0
      IFIELD=3
      IF (IFIELD.LE.NFIELD) GO TO 20
C
      CALL ULINE (LP,2)
      WRITE (LP,10)
10    FORMAT ('0**ERROR** MISSING FUNCTION NAME')
      ISTAT=1
      GO TO 50
20    CONTINUE
      CALL HNMPSW (IFIELD,NAME,IPASS,ISTAT)
      CALL HCKPSW (IGL,IPASS,ISTAT)
      ITYPE=2
      CALL HFNDDF (NAME,IREC,ITYPE,IXREC)
      IF (IREC.NE.0) ISTAT=1
      IF (IREC.NE.0) THEN
         CALL ULINE (LP,2)
         WRITE (LP,30) NAME
         ENDIF
30    FORMAT ('0**ERROR** FUNCTION ',2A4,' ALREADY DEFINED.')
C
C
C SEI IF GLOBAL NAME MATCHES ANY _OCAL
C
      ISTA=0
      IF (IGL.GT.0) GO TO 40
      CALL HSRLDR (NAME,2,2,IREC,ISTA)
      IF (ISTA.NE.0) ISTAT=ISTA
40    CONTINUE
      IF (ISTAT.NE.0) GO TO 50
C
C NOW SET UP FUNCTION DEFINITION AND DEFAULT RECORD
C
      CALL UMEMST (0,IFNREC,16)
      CALL UMEMST (0,IDFREC,16)
C
C FILL IN FUNCTION INFORMATION
C
      IFNREC(1)=1
      NGT=0
C
C GLOBAL OR LOCAL
C
      IFNREC(3)=IGL*2
      CALL UMEMOV (NAME,IFNREC(4),2)
      NTECH=9
      ND=7
      IFNREC(6)=IPASS
C
C SET UP DEFAULT
C
      IDFREC(2)=1
      IDFREC(3)=5*IGL
      CALL UMEMOV (NAME,IDFREC(4),2)
      IDFREC(6)=IFNREC(3)
      IDFREC(7)=0
C
C NOW PARSE ANY TECHNIQUES
C
50    IF (NFIELD.LT.IFIELD) GO TO 210
      CALL HFEQLS (IFIELD,LEFT,IRIGHT,ISTRGT)
      IF (LEFT(1).EQ.LTECH) GO TO 70
      CALL ULINE (LP,2)
      WRITE (LP,60) IFIELD
      ISTAT=1
      GO TO 200
60    FORMAT ('0**ERROR** UNRECOGNIZED PARAMETER IN FIELD ',I2,'.')
C
C CHECK IF TECHNIQUE IS DEFINED
C LOOK FOR LEFT PAREN
C
70    N=IFSTOP(IFIELD)-ISTRGT+1
      CALL HFLPRN (ISTRGT,IFSTOP(IFIELD),IFLPRN)
      IF (IFLPRN.EQ.0) GO TO 80
C
C FOUND LEFT PAREN
C MAKE SURE TECH NAME IS 8CHAR OR LESS
C
      N=IFLPRN-ISTRGT
80    IF (N.LE.8) GO TO 100
      CALL ULINE (LP,2)
      WRITE (LP,90) IFIELD
90    FORMAT ('0**ERROR** INVALID TECHNIQUE NAME IN FIELD ',I2,'.')
      GO TO 150
100   CALL UMEMST (IBLNK,ITNAME,2)
      CALL UPACK1 (IBUF(ISTRGT),ITNAME,N)
C
C SEE IF TECH EXISTS
C
      ITYPE=IGL*3
      CALL HGTRCD (ITYPE,ITNAME,ITMAX,ITBUF,IERR)
      IF (IERR.NE.0) GO TO 150
C
C CHECK THAT GLOBAL FUNC USES GLOBAL TECH
C
      IF (IGL.GT.0.OR.ITYPE.LT.0) GO TO 120
      CALL ULINE (LP,2)
      WRITE (LP,110)
110   FORMAT ('0**ERROR** GLOBAL FUNCTION CANNOT USE LOCAL TECHNIQUE')
      GO TO 150
C
C IS THERE A DEFAULT
C
120   ITD=1
      IF (IFLPRN.EQ.0) GO TO 160
C
C YES
C
      IS=IFLPRN+1
      CALL HFRPRN (IS,IFSTOP(IFIELD),IFRPRN)
       IF (IFRPRN.NE.0) GO TO 140
      CALL ULINE (LP,2)
      WRITE (LP,130) IFIELD
130   FORMAT ('0**ERROR** UNBALANCED PARENTHESIS IN FIELD ',I2,'.')
      GO TO 150
C
C CHECK FOR Y N OR INTEGER
C
140   ITD=-1
      IF (IBUF(IS).EQ.LETN) ITD=0
      IF (IBUF(IS).EQ.LETY) ITD=1
      IF (ITD.GE.0) GO TO 160
C
C NOT Y OR N PERHAPS INTEGER?
C
      IERR=0
      CALL UINTFX (ITD,IS,IFRPRN-1,IERR)
      IF (IERR.EQ.0) GO TO 160
150   ISTAT=1
      GO TO 200
C
C ENTER TECHNIQUE INTO ARRAY
C
160   IF (ISTAT.NE.0) GO TO 200
      IFNREC(9)=IFNREC(9)+1
      IF (NTECH.GE.IFMAX) GO TO 360
      NTECH=NTECH+1
      IFNREC(NTECH)=ITBUF(2)
C
C IF TECH IS GLOBAL, SET TO NEG
C
      IF (ITBUF(3).GT.0) GO TO 190
      IFNREC(NTECH)=-IFNREC(NTECH)
C
C IF LOCAL DEF PUT INTO ARRAY FOR LATER STORAGE
C
      IF (IGL.LT.0) GO TO 190
      IF (NGT.LT.MAXGT) GO TO 180
      CALL ULINE (LP,2)
      WRITE (LP,170)
170   FORMAT ('0**ERROR** GLOBAL TECH REF ARRAY FULL')
      ISTAT=1
      GO TO 190
180   NGT=NGT+1
      IGTRAY(NGT)=IFNREC(NTECH)
C
C IS THERE DEFAULT VALUE
C
190   IDFREC(7)=IDFREC(7)+1
      IF (ND.GE.IDMAX) GO TO 360
      ND=ND+1
      IDFREC(ND)=IFNREC(NTECH)
      ND=ND+1
      IDFREC(ND)=ITD
C
C DO NEXT ON CARD
C
200   IF (IFIELD.LT.NFIELD) GO TO 220
C
C READ ANOTHER CARD LOOKING FOR CONTINUATION
C
210   NNCARD=NNCARD+1
      IF (NNCARD.GT.NCARD) GO TO 230
      CALL HCARDR (NNCARD,IERR)
      IF (IERR.NE.0) GO TO 380
      IFIELD=0
220   IFIELD=IFIELD+1
      CALL HFEQLS (IFIELD,LEFT,IRIGHT,ISTRGT)
      GO TO 70
C
C NO MORE TO DO
C WRAP IT UP
C
230   IF (ISTAT.NE.0) GO TO 300
C
C IF LOCAL, ENTER INTO LOCAL DEFINITION REFERENCE FILE
C
      IF (IGL.GT.0) CALL HPUTLD (2,NAME,NGT,IGTRAY,ISTAT)
      IF (ISTAT.NE.0) GO TO 300
C
C IF NO TECHNIQUES GO RIGHT TO FUNCTION
C
      IF (NTECH.EQ.9) GO TO 290
C
C ENTER LOCAL DEFAULT IF LOCAL FUNCTION
C
      IF (IGL.LT.0) GO TO 260
      IFNREC(7)=HCNTL(7,1)+1
      CALL HPTRCD (5,ND,IDFREC,ISTAT)
      IF (ISTAT.EQ.0) GO TO 290
240   CALL ULINE (LP,2)
      WRITE (LP,250) ISTAT
250   FORMAT ('0**ERROR** DEFAULT RECORD NOT ENTERED ISTAT=',I3)
      GO TO 300
C
C NOW GLOBAL FOR GLOBAL ONLY
C
260   CONTINUE
      IFNREC(8)=HCNTL(7,2)+1
      CALL HPTRCD (-5,ND,IDFREC,ISTAT)
      IF (ISTAT.NE.0) GO TO 240
C
C RESERVE LOCAL RECORDS
C
      IF (HCNTL(13,2)+IDFREC(1).LE.HCNTL(12,2)) GO TO 280
      CALL ULINE (LP,2)
      WRITE (LP,270)
270   FORMAT ('0**ERROR** LOCAL DEFAULT FOR GLOBAL DEFN FILE IS FULL.')
      GO TO 300
280   IFNREC(7)= (HCNTL(13,2)+1)
      HCNTL(13,2)=HCNTL(13,2)+IDFREC(1)
C
C NOW FUNCTION RECORD
290   CONTINUE
      CALL HGFNUM (IGL,IFNREC(2),ISTAT)
      IF (ISTAT.NE.0) GO TO 300
      CALL HPTRCD (IFNREC(3),NTECH,IFNREC,ISTAT)
      IF (ISTAT.EQ.0) GO TO 320
300   CALL ULINE (LP,2)
      WRITE (LP,310) NAME
310   FORMAT ('0**ERROR** FUNCTION ',2A4,' NOT ENTERED.')
C
      GO TO 380
320   CONTINUE
      IF (IGL.LT.0) GO TO 350
      CALL ULINE (LP,2)
      WRITE (LP,340) NAME,'LOCAL'
C
C PRINT THE FUNCTION
C
C UPDATE CNTRL COUNTER OF NUMBER OF FUNCTIONS AND UNLOCK RECORD
C
330   CONTINUE
      CALL HPFUNG (IFNREC)
      GO TO 380
340   FORMAT ('0**NOTE** FUNCTION ',2A4,' DEFINED AS ',A,'.')
350   CALL ULINE (LP,1)
      WRITE (LP,340) NAME,'GLOBAL'
      GO TO 330
360   CALL ULINE (LP,2)
      WRITE (LP,370)
370   FORMAT ('0**ERROR** TOO MANY TECHNIQUES IN FUNCTION.')
      GO TO 300
C
380   RETURN
C
      END
