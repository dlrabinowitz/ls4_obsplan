#include <stdio.h>

#define TESS_FILE "tesselation.dat"
#define EXP_TIME 180.0
#define INTERVAL 7200.0
#define ITERATIONS 3
#define OBS_CODE 1
#define MIN_GAL_LAT 15.0

main(int argc, char **argv)
{
    double d_l,d_h,r_l,r_h;
    double ra1,ra2,dec1,dec2;
    float f_ra,f_dec,gal_lon,gal_lat;
    double exp_time,exp_interval,epoch;
    int  exp_iterations, obs_code;
    int i1,i2;
    FILE *input;
    char string[1024];

    if(argc!=9){
        fprintf(stderr,"syntax: get_fields ra1 ra2 d1 d2 exptime interval iterations obs_code\n");
        exit(-1);
    }

    sscanf(argv[1],"%lf", &r_l);
    sscanf(argv[2],"%lf", &r_h);
    sscanf(argv[3],"%lf", &d_l);
    sscanf(argv[4],"%lf", &d_h);
    sscanf(argv[5],"%lf", &exp_time);
    sscanf(argv[6],"%lf", &exp_interval);
    sscanf(argv[7],"%d", &exp_iterations);
    sscanf(argv[8],"%d", &obs_code);

    input=fopen(TESS_FILE,"r");
    if(input==NULL){
        fprintf(stderr,"can't open file %s for reading\n",TESS_FILE);
        exit(-1);
    }

    epoch=2000.0;
    while(fgets(string,1024,input)!=NULL){
      if(strstr(string,"#")==NULL){
         sscanf(string,"%d %d %lf %lf %lf %lf",&i1,&i2,&ra1,&dec1,&ra2,&dec2);
	 f_ra=ra1;
         f_dec=dec1;
         galact(f_ra,f_dec,epoch,&gal_lon,&gal_lat);

         if(fabs(gal_lat)>MIN_GAL_LAT){
           if(r_h>=r_l&&ra1>r_l&&ra1<r_h&&dec1>d_l&&dec2<d_h){
             fprintf(stdout,"%12.6f %12.6f Y %6.1f %6.1f %d %d # %d\n",ra1,dec1,exp_time,exp_interval,exp_iterations,obs_code,i1);
             fprintf(stdout,"%12.6f %12.6f Y %6.1f %6.1f %d %d # %d\n",ra2,dec2,exp_time,exp_interval,exp_iterations,obs_code,i2);
           }
           else if(r_h<r_l&&(ra1>r_l||ra1<r_h)&&dec1>d_l&&dec2<d_h){
             fprintf(stdout,"%12.6f %12.6f Y %6.1f %6.1f %d %d # %d\n",ra1,dec1,exp_time,exp_interval,exp_iterations,obs_code,i1);
             fprintf(stdout,"%12.6f %12.6f Y %6.1f %6.1f %d %d # %d\n",ra2,dec2,exp_time,exp_interval,exp_iterations,obs_code,i2);
           }
         }
      }
    }

    fclose(input);
    exit(0);
}

   
