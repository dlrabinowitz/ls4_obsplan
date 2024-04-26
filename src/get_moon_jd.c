/* get_moon_jd.c

   Read the moon_ephem_file and find the jd of the next new moon following the specified
   jd 

   DLR 2010 12 17
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>


main(int argc, char **argv)
{
    FILE *input;
    double jd0, jd, jd_prev,illum,illum_prev;
    double ra, dec, ra_prev, dec_prev;
    char string[1024],s[256],day[256],day_prev[256];

    if(argc!=3){
        fprintf(stderr,"syntax: get_moon_jd jd_star moon_ephem\n");
        exit(-1);
    }

    sscanf(argv[1],"%lf",&jd0);

    input=fopen(argv[2],"r");
    if(input==NULL){
        fprintf(stderr,"can't open file %s for input\n",argv[2]);
        exit(-1);
    }

    /* read input until jd >= jd0 */

    jd=0;
    jd_prev = 0;
    illum_prev=0;
    ra_prev=0;
    dec_prev=0;
    *day_prev=0;
    while(fgets(string,1024,input)!=NULL&&jd<jd0){
        if(strstr(string,"#")==NULL){
            illum_prev=illum;
            jd_prev=jd;
	    ra_prev=ra;
            dec_prev=dec;
	    strcpy(day_prev,day);
            sscanf(string,"%s %s %lf %lf %lf %s %lf",
		day,s,&jd,&ra,&dec,s,&illum);
        }
    }


    if(jd<jd0){
          fprintf(stderr,"get_moon_jd: end of moon ephem reached 1\n");
          fclose(input);
          exit(-1);
    }

    /* if moon illumination is increasing with time, keep reading
       until it reached a maximum */

    if(illum>=illum_prev){

       while(fgets(string,1024,input)!=NULL&&illum>=illum_prev){
          if(strstr(string,"#")==NULL){
            illum_prev=illum;
            jd_prev=jd;
	    ra_prev=ra;
            dec_prev=dec;
	    strcpy(day_prev,day);
            sscanf(string,"%s %s %lf %lf %lf %s %lf",
		day,s,&jd,&ra,&dec,s,&illum);
          }
       }

       if(illum>=illum_prev){
          fprintf(stderr,"get_moon_jd: end of moon ephem reached 2\n");
          fprintf(stdout,"%7.0f %7.3f %7.3f %7.3f %s\n",
		jd_prev,ra_prev,dec_prev,illum_prev,day_prev);

          fclose(input);
          exit(-1);
       }

    }

    /* now keep reading until moon illumination reaches a minimum */


    while(fgets(string,1024,input)!=NULL&&illum<illum_prev){
          if(strstr(string,"#")==NULL){
            illum_prev=illum;
            jd_prev=jd;
	    ra_prev=ra;
            dec_prev=dec;
	    strcpy(day_prev,day);
            sscanf(string,"%s %s %lf %lf %lf %s %lf",
		day,s,&jd,&ra,&dec,s,&illum);
          }
    }

    if(illum<illum_prev){
          fprintf(stderr,"get_moon_jd: end of moon ephem reached 3\n");
          fclose(input);
          exit(-1);
    }

    fprintf(stdout,"%7.0f %7.3f %7.3f %7.3f %s\n",
		jd_prev,ra_prev,dec_prev,illum_prev,day_prev);

    fclose(input);
    exit(0);
}


 
