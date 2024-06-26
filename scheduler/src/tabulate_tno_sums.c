/* tabulate_tno_sums.c

   read sums.all generated by read_sums.csh
   print tabulated values of number of observed fields:

   Region  Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
    1
    2
    3
    4

*/

#include <stdio.h>

typedef struct {
   int month;
   int count;
   int region;
} Entry;

#define MAX_ENTRIES 1000

main()
{
    Entry entry[MAX_ENTRIES],*e;
    char string[1024];
    int i,n,region,month,iteration,region_prev,total[12];
   
    n=0;
     while(fgets(string,1024,stdin)!=NULL){
       e=entry+n;
       sscanf(string,"%d %d %d %s",
         &(e->count),&(e->month),&(e->region));
        
       n++;
    }

    for(month=0;month<12;month++)total[month]=0;

    for(region=1;region<=4;region++){
         printf("%d   ", region);
         for(month=1;month<=12;month++){
             for(i=0;i<n;i++){
               if(entry[i].region==region&&entry[i].month==month){
                  printf("%4d   ",entry[i].count);
                  total[month-1]=total[month-1]+entry[i].count;
                  i=n;
               }
            }
         }
         printf("\n");
     }

    printf("tot:");
    for(month=0;month<12;month++){
       printf("%4d   ",total[month]);
    }
    printf("\n");


    exit(0);
}
