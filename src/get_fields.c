#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TESS_FILE "tesselation.dat"
#define EXP_TIME 180.0
#define INTERVAL 7200.0
#define ITERATIONS 3
#define OBS_CODE 1
#define MIN_GAL_LAT 15.0
#define MAX_EXCLUDES 10000
#define REPEAT_CODE_ADD 20000
#define REPEAT_OFFSET (2.5*0.1666) /*2.5 times column spacing of QUEST array */ 

int check_excludes(int i1,int i2,int *exclude_list,int n_excludes);
int init_excludes(char *input_file,int *exclude_list);
extern double fabs();

/****************************************/
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
    int n_exclude,exclude_list[MAX_EXCLUDES];
    int repeat_flag=0; /* set to 1 to repeat each pair of fields with offset */

    if(argc!=11){
        fprintf(stderr,"syntax: get_fields ra1 ra2 d1 d2 exptime interval iterations obs_code excluded_list offset_flag\n");
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
    sscanf(argv[10],"%d", &repeat_flag);

    input=fopen(TESS_FILE,"r");
    if(input==NULL){
        fprintf(stderr,"can't open file %s for reading\n",TESS_FILE);
        exit(-1);
    }

    n_exclude=init_excludes(argv[9],exclude_list);
    if(n_exclude<0){
        fprintf(stderr,"unable to initialize exclude list\n");
        exit(-1);
    }

    epoch=2000.0;
    while(fgets(string,1024,input)!=NULL){
      if(strstr(string,"#")==NULL){
         sscanf(string,"%d %d %lf %lf %lf %lf",&i1,&i2,&ra1,&dec1,&ra2,&dec2);
	 f_ra=ra1;
         f_dec=dec1;
         galact(f_ra,f_dec,epoch,&gal_lon,&gal_lat);
         

         if(fabs(gal_lat)>MIN_GAL_LAT&&check_excludes(i1,i2,exclude_list,n_exclude)==0){
           if(r_h>=r_l&&ra1>r_l&&ra1<r_h&&dec1>d_l&&dec2<d_h){
             fprintf(stdout,"%12.6f %12.6f Y %6.1f %6.1f %d %d # %d\n",ra1,dec1,exp_time,exp_interval,exp_iterations,obs_code,i1);
             fprintf(stdout,"%12.6f %12.6f Y %6.1f %6.1f %d %d # %d\n",ra2,dec2,exp_time,exp_interval,exp_iterations,obs_code,i2);
             if(repeat_flag!= 0 ){
               fprintf(stdout,"%12.6f %12.6f Y %6.1f %6.1f %d %d # %d %s\n",ra1,dec1+REPEAT_OFFSET,exp_time,exp_interval,exp_iterations,obs_code,i1+REPEAT_CODE_ADD,"offset");
               fprintf(stdout,"%12.6f %12.6f Y %6.1f %6.1f %d %d # %d %s \n",ra2,dec2+REPEAT_OFFSET,exp_time,exp_interval,exp_iterations,obs_code,i2+REPEAT_CODE_ADD,"offset");
             }
           }
           else if(r_h<r_l&&(ra1>r_l||ra1<r_h)&&dec1>d_l&&dec2<d_h){
             fprintf(stdout,"%12.6f %12.6f Y %6.1f %6.1f %d %d # %d\n",ra1,dec1,exp_time,exp_interval,exp_iterations,obs_code,i1);
             fprintf(stdout,"%12.6f %12.6f Y %6.1f %6.1f %d %d # %d\n",ra2,dec2,exp_time,exp_interval,exp_iterations,obs_code,i2);
             if(repeat_flag != 0 ){
               fprintf(stdout,"%12.6f %12.6f Y %6.1f %6.1f %d %d # %d %s\n",ra1,dec1+REPEAT_OFFSET,exp_time,exp_interval,exp_iterations,obs_code,i1+REPEAT_CODE_ADD,"offset");
               fprintf(stdout,"%12.6f %12.6f Y %6.1f %6.1f %d %d # %d %s\n",ra2,dec2+REPEAT_OFFSET,exp_time,exp_interval,exp_iterations,obs_code,i2+REPEAT_CODE_ADD,"offset");
             }
           }
         }
      }
    }

    fclose(input);
    exit(0);
}
/******************************************************/
int init_excludes(char *input_file,int *exclude_list)
{
    int n,field_id;
    FILE *input;
    char string[1024],s[256];

    input=fopen(input_file,"r");
    if(input==NULL){
        fprintf(stderr,"can't open file %s for input\n",input_file);
        return(-1);
    }

    n=0;
    while(fgets(string,1024,input)!=NULL){
         sscanf(string,"%s %s %s %s %s %s %s %s %d",s,s,s,s,s,s,s,s,&field_id);
         exclude_list[n++]=field_id;
    }

    fclose(input);

    return(n);

}
/******************************************************/
int check_excludes(int i1,int i2,int *exclude_list,int n_excludes)
{
    int i;
    for(i=0;i<n_excludes;i++){
       if(i1==exclude_list[i]||i2==exclude_list[i]){
            return(1);
       }
    }

    return(0);

}
/******************************************************/
  
