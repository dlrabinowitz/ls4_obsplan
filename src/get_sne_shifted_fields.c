/* read ra and dec range from command line. FInd fields in 
  tessellation.dat within this range. Print out "paired" fields
  togetherm, where the second in the pair is shifted in ra.

  For normal survey, the shift is as listed in tessellation.dat
  For sne shift, add 0.5 to the ra of the second field

  dlr 2009 sep 29
*/

#include <stdio.h>

#define ADD_HALF_DEG 1  /* use 0 for no additional shift */
#define TESS_FILE "tesselation.dat"
#define EXP_TIME 180.0
#define INTERVAL 7200.0
#define ITERATIONS 3
#define OBS_CODE 1

main(int argc, char **argv)
{
    double d_l,d_h,r_l,r_h;
    double ra1,ra2,dec1,dec2;
    int i1,i2;
    FILE *input;
    char string[1024];

    if(argc!=5){
        fprintf(stderr,"syntax: get_fields ra1 ra2 d1 d2\n");
        exit(-1);
    }

    sscanf(argv[1],"%lf", &r_l);
    sscanf(argv[2],"%lf", &r_h);
    sscanf(argv[3],"%lf", &d_l);
    sscanf(argv[4],"%lf", &d_h);

    input=fopen(TESS_FILE,"r");
    if(input==NULL){
        fprintf(stderr,"can't open file %s for reading\n",TESS_FILE);
        exit(-1);
    }


    while(fgets(string,1024,input)!=NULL){
      if(strstr(string,"#")==NULL){
         sscanf(string,"%d %d %lf %lf %lf %lf",&i1,&i2,&ra1,&dec1,&ra2,&dec2);
         if (ADD_HALF_DEG ) {
            ra2 = ra2 + (0.5/15.0);
            if(ra2>24.0)ra2=ra2-24.0;
            i2=i2+10000;
         }
         if(r_h>=r_l&&ra1>r_l&&ra1<r_h&&dec1>d_l&&dec2<d_h){
             fprintf(stdout,"%12.6f %12.6f Y %6.1f %6.1f %d %d # %d\n",ra1,dec1,EXP_TIME,INTERVAL,ITERATIONS,OBS_CODE,i1);
             fprintf(stdout,"%12.6f %12.6f Y %6.1f %6.1f %d %d # %d\n",ra2,dec2,EXP_TIME,INTERVAL,ITERATIONS,OBS_CODE,i2);
         }
         else if(r_h<r_l&&(ra1>r_l||ra1<r_h)&&dec1>d_l&&dec2<d_h){
             fprintf(stdout,"%12.6f %12.6f Y %6.1f %6.1f %d %d # %d\n",ra1,dec1,EXP_TIME,INTERVAL,ITERATIONS,OBS_CODE,i1);
             fprintf(stdout,"%12.6f %12.6f Y %6.1f %6.1f %d %d # %d\n",ra2,dec2,EXP_TIME,INTERVAL,ITERATIONS,OBS_CODE,i2);
         }
      }
    }

    fclose(input);
    exit(0);
}

   
