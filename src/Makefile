CC = cc
COPTS = 
LIBS = -lm -lc
PROGRAMS = get_fields julian skycalc get_moon_jd get_sne_fields

GET_FIELDS_OBJECTS = get_fields.o galactic.o

GET_SNE_FIELDS_OBJECTS = get_sne_fields.o galactic.o

JULIAN_OBJECTS = julian.o

SKYCALC_OBJECTS = skycalc.o

GET_MOON_JD_OBJECTS = get_moon_jd.o

.c.o: 
	$(CC) $(COPTS) -c $<

all: $(PROGRAMS)


get_fields: $(GET_FIELDS_OBJECTS)
	 $(CC) $(COPTS) -o get_fields $(GET_FIELDS_OBJECTS) $(LIBS)

get_sne_fields: $(GET_SNE_FIELDS_OBJECTS)
	 $(CC) $(COPTS) -o get_sne_fields $(GET_SNE_FIELDS_OBJECTS) $(LIBS)

julians: $(JULIAN_OBJECTS)
	 $(CC) $(COPTS) -o julian $(JULIAN_OBJECTS) $(LIBS)

skycalc: $(SKYCALC_OBJECTS)
	 $(CC) $(COPTS) -o skycalc $(SKYCALC_OBJECTS) $(LIBS)

get_moon_jd: $(GET_MOON_JD_OBJECTS)
	 $(CC) $(COPTS) -o get_moon_jd $(GET_MOON_JD_OBJECTS) $(LIBS)


clean: 
	rm -f $(PROGRAMS) *.o 

install:
	cp $(PROGRAMS) ../bin





