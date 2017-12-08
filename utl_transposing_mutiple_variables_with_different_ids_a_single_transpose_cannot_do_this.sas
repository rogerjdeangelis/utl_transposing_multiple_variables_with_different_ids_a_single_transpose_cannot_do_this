Transposing mutiple variables with different ids - single transpose cannot do this

Original topic: Transposing/Moving Data

  Two Solutions

    1. Arts transpose
       http://www.sascommunity.org/mwiki/images/3/3c/Transpose.sas

       Arts profile
       https://communities.sas.com/t5/user/viewprofilepage/user-id/13711

    2. utl_gather and datastep
       for gather macro Alea Iacta
       https://github.com/clindocu/sas-macros-r-functions

INPUT
=====

  WORK.HAVE total obs=12
                                                       |         RULES
    CUSTOMER_    INVOICE_    CUSTOMER_                 |         =====
        ID          NUM        NAME       CHRG    AMT  |
                                                       |
       1121          1         Bank1      Fee1      1  |   Alea
       1121          1         Bank1      Fee2      2  |    CHRG1   CHRG2  CHRG3    AMT1  AMT2  AMT3
       1121          1         Bank1      Fee3      3  |     FEE1    FEE2   FEE3      1     2    3
                                                       |
       1122          2         Bank2      Fee4     12  |   Art changes the order but should not be an issue
       1122          2         Bank2      Fee5     15  |
       1122          2         Bank2      Fee7     15  |    CHRG1   CHRG2  CHRG3    AMT1  AMT2  AMT3
                                                       |     FEE2    FEE3   FEE1      2     3    1
       1123          3         Bank3      Fee1      1  |
       1123          3         Bank3      Fee3      2  |
       1123          3         Bank3      Fee5      3  |
                                                       |
       1124          4         Bank4      Fee3     12  |
       1124          4         Bank4      Fee5     15  |
       1124          4         Bank4      Fee7     15  |

PROCESS
========

   1. Arts

     %utl_transpose(data=have, out=want, by=Customer_ID, var=Chrg Amt, sort=YES)

   2. Alea Iacta

      %utl_gather(have,var,val,Customer_ID Invoice_num Customer_name,havxpo,valformat=$8.);

      data havpre(drop=cnt);
       retain cnt 0;
       do until (last.customer_id);
         set havxpo;
         array amts[9] amt1-amt9;
         array chgs[9] $5 chg1-chg9;
         by customer_id;
         if var='CHRG' then do;
              cnt=cnt+1;
             chgs[cnt]=val;
         end;
         else amts[cnt]=input(val,3.);
       end;
       output;
       cnt=0;
      run;quit;

OUTPUT
======

  Art
   WORK.WANT total obs=4

   CUSTOMER_
       ID       CHRG1    AMT1    CHRG2    AMT2    CHRG3    AMT3

      1121      Fee2       2     Fee3       3     Fee1       1
      1122      Fee7      15     Fee5      15     Fee4      12
      1123      Fee1       1     Fee5       3     Fee3       2
      1124      Fee7      15     Fee5      15     Fee3      12

 Alea

  WORK.HAVPRE total obs=4

  CUSTOMER_  INVOICE_  CUSTOMER_
      ID        NUM      NAME     CHG1  CHG2  CHG3... AMT1  AMT2  AMT3...

     1121        1       Bank1    Fee1  Fee2  Fee3      1     2     3
     1122        2       Bank2    Fee4  Fee5  Fee7     12    15    15
     1123        3       Bank3    Fee1  Fee3  Fee5      1     2     3
     1124        4       Bank4    Fee3  Fee5  Fee7     12    15    15

SAS Forum
https://communities.sas.com/t5/General-SAS-Programming/Transposing-Moving-Data/m-p/419625
*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

data have;
  input Customer_ID Invoice_num Customer_name$ Chrg$ Amt;
cards4;
1121 1 Bank1 Fee1 1
1121 1 Bank1 Fee2 2
1121 1 Bank1 Fee3 3
1122 2 Bank2 Fee4 12
1122 2 Bank2 Fee5 15
1122 2 Bank2 Fee7 15
1123 3 Bank3 Fee1 1
1123 3 Bank3 Fee3 2
1123 3 Bank3 Fee5 3
1124 4 Bank4 Fee3 12
1124 4 Bank4 Fee5 15
1124 4 Bank4 Fee7 15
;;;;
run;quit;

*   _         _
   / \   _ __| |_
  / _ \ | '__| __|
 / ___ \| |  | |_
/_/   \_\_|   \__|

;

%utl_transpose(data=have, out=want, by=Customer_ID, var=Chrg Amt, sort=YES)

*   _    _
   / \  | | ___  __ _
  / _ \ | |/ _ \/ _` |
 / ___ \| |  __/ (_| |
/_/   \_\_|\___|\__,_|

;


* gather does extreme normalization, target is just two variables var and val;
* this is actally very powerfull;
%utl_gather(have,var,val,Customer_ID Invoice_num Customer_name,havxpo,valformat=$8.);

data havpre(drop=cnt var val);
 retain cnt 0;
 do until (last.customer_id);
   set havxpo;
   array chgs[9] $5 chg1-chg9;
   array amts[9] $5 amt1-amt9;
   by customer_id;
   if var='CHRG' then do;
        cnt=cnt+1;
       chgs[cnt]=val;
   end;
   else amts[cnt]=input(val,3.);
 end;
 output;
 cnt=0;
run;quit;

/*
Utl gather output
Up to 40 obs WORK.HAVXPO total obs=24

       CUSTOMER_    INVOICE_    CUSTOMER_
Obs        ID          NUM        NAME       VAR     VAL

  1       1121          1         Bank1      CHRG    Fee1
  2       1121          1         Bank1      AMT     1
  3       1121          1         Bank1      CHRG    Fee2
  4       1121          1         Bank1      AMT     2
  5       1121          1         Bank1      CHRG    Fee3
  6       1121          1         Bank1      AMT     3
  7       1122          2         Bank2      CHRG    Fee4
  8       1122          2         Bank2      AMT     12
  9       1122          2         Bank2      CHRG    Fee5
 10       1122          2         Bank2      AMT     15
 11       1122          2         Bank2      CHRG    Fee7
 12       1122          2         Bank2      AMT     15
 13       1123          3         Bank3      CHRG    Fee1
 14       1123          3         Bank3      AMT     1
 15       1123          3         Bank3      CHRG    Fee3
 16       1123          3         Bank3      AMT     2
 17       1123          3         Bank3      CHRG    Fee5
 18       1123          3         Bank3      AMT     3
 19       1124          4         Bank4      CHRG    Fee3
 20       1124          4         Bank4      AMT     12
 21       1124          4         Bank4      CHRG    Fee5
 22       1124          4         Bank4      AMT     15
 23       1124          4         Bank4      CHRG    Fee7
 24       1124          4         Bank4      AMT     15
*/

