/* julian.c

   convert yyyymmddhhmmss to julian date
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

double julian(int y,int m, double d, int jclndr);

/*****************************************************************************/

main(int argc, char **argv)
{

   int yr,mon,dy,hr,mn,sc;
   double d,jd;
   char year_s[256];
   char mon_s[256];
   char day_s[256];
   char hour_s[256];
   char min_s[256];
   char sec_s[256];

   if(argc!=2){
      fprintf(stderr,"syntax: julian yyyymmddhhmmss\n");
      exit(-1);
   }

   strncpy(year_s,argv[1],4);   
   *(year_s+4)=0;

   strncpy(mon_s,argv[1]+4,2);   
   *(mon_s+2)=0;

   strncpy(day_s,argv[1]+6,2);   
   *(day_s+2)=0;

   strncpy(hour_s,argv[1]+8,2);   
   *(hour_s+2)=0;

   strncpy(min_s,argv[1]+10,2);   
   *(min_s+2)=0;

   strncpy(sec_s,argv[1]+12,2);   
   *(sec_s+2)=0;

/*
   fprintf(stderr,"%s %s %s %s %s %s\n",year_s,mon_s,day_s,hour_s,min_s,sec_s);
*/
   sscanf(year_s,"%d",&yr);
   sscanf(mon_s,"%d",&mon);
   sscanf(day_s,"%d",&dy);
   sscanf(hour_s,"%d",&hr);
   sscanf(min_s,"%d",&mn);
   sscanf(sec_s,"%d",&sc);

   d=dy+(hr/24.0)+(mn/(24.0*60.0))+(sc/(24.0*60.0*60.0));

   jd=julian(yr,mon,d,0);

   fprintf(stdout,"%12.6f\n",jd);

   exit(0);
}

/*****************************************************************************/

double julian(int y,int m, double d, int jclndr) 
{
	long int lcy,lcm,lpyr,n;
     	double  julian,jdy,jdm,lpdays;

      julian=0.0;

/*     Trap invalid months */

      if (m < 1 || m > 12) {
         printf("***JULIAN: Month outside the range 1 to 12\n");
      }

/*     Adjust 'internal' calendar to start in March so that leap days
      occur at end of year */

      else{
         if (m > 2) {
            lcy = y;
            lcm = m + 1;
	 }
         else{
            lcy = y - 1;
            lcm = m + 13;
         }

/*     If Gregorian calendar, adjust for missing leap days */

         if (jclndr==1) {
            lpdays = 0.0;
	 }
         else{
            lpyr = lcy;
            if (lpyr < 0) lpyr++;
	    lpdays=2;
	    n=lpyr/100; 
	    lpdays=lpdays-n;
	    n=lpyr/400;
	    lpdays=lpdays+n;
         }

/*     Accumulate Julian Date based on number of days per year and month */

         jdy = 365.25*lcy;
         if (lcy < 0.0) jdy = jdy - 0.75;
         jdm = 30.6001*(double)lcm;
	 n=jdy;
	 julian=julian+n;
	 n=jdm;
	 julian=julian+n;
         julian = julian + d + 1720994.5 + lpdays;
      }

      return(julian);
}

/*****************************************************************/
