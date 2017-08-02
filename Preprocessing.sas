/*--to get data and time on report--*/
proc options option=date;
run;


/*--to define path of input files--*/
%let pathdm=/home/ameerkhoso470/workshop;
libname dm "&pathdm";

/*Import Procedure*/
data dm.profile_data;
/* to define length and type of variable; */
	length	
		age 8
		Job_Type $32
   		Qualification $32
   		years_in_edu 8
   		Marital_status $32
   		Job $32
   		Relationship_status $32
   		Race $32
   		Gender $32
   		Capital_gain 8
   		Capital_loss 8
   		Work_per_week 8
   		country $32
   		Salary $32;
/* to define file name and delimeter*/
	infile "&pathdm/DataSet_B.csv" dlm=',';
/* to define length and type of variable from input file*/
   	input	Age
   		Job_Type $
   		Qualification $
   		Years_in_Edu
   		Marital_status $
   		Job $
   		Relationship_status $
   		Race $
   		Gender $
   		Capital_gain 
   		Capital_loss 
   		Work_per_week 
   		country $
   		Salary $;
/* to define format of numeric fields */
   	format 	age 2.
   		Years_in_Edu 2.
   	   	Capital_gain 12.
   		Capital_loss 12.
   		Work_per_week 12.;
run;
    proc sql noprint;
	update dm.profile_data set Job_Type = 'unemployed' where Job_Type = '?';
	update dm.profile_data set Job = 'unemplyed' where Job = '?';
quit;
/*--Transformation and cleaning of raw data using Proc Format--*/
proc format;
	value age_tiers 
		low-21='Teenager'
		21<-31='Young' 
		31<-46='Mid_Age' 
		46<-66='Mature' 
		66<-high='Old';
run;

/*to assign format to attributes*/
data dm.profile_data;
	set dm.profile_data;
		format 
		age age_tiers.;
run;
/* Transform value ? into private and unemployed 
DATA Transformation;
SET dm.profile_data;
IF job_Type = '?' THEN job_Type = 'unemployed';
IF job = '?' THEN job = 'Unemployed';
run;

proc print data = transformation;
run;

/*--Proc Mean for Age--*/
title1 justify=r h=7pt "Report as of &currentdate &currenttime"  ;
title3 "Summarizing Properties of of Age";
proc means data=dm.profile_data n min max mean median var vardef=df q1 q3 qmethod=os;
var age;
run;


/* Plot the graph for Outliers. The variable can be changed as required*/
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=dm.profile_data;
	GETNAMES=YES;
RUN;
proc sgplot data= dm.profile_data;
vbox Capital_loss ;
run;
ods graphics off;
/*--Pie Chart for Age Category--*/
title3;
proc template;
	define statgraph WebOne.Pie;
		begingraph;
		entrytitle 'Distribution of AGE by Age Category' / textattrs=(size=14);
		entryfootnote halign=left 'Teenager=1-20 Years - Young=21-30 Years - Mid_Age=31-45 Years - Mature=46-65 Years - Old=66+ Yeras' / textattrs=(size=8);
		layout region;
		piechart category=age response=count / dataskin=crisp start=90 centerFirstSlice=1 datalabelcontent=all;
		endlayout;
		endgraph;
	end;
run;
ods graphics / reset imagemap;
proc sgrender template=WebOne.Pie data=dm.profile_data;
run;
ods graphics / reset;


/*--Pie Chart for Job Type--*/
title3;
proc template;
	define statgraph WebOne.Pie;
		begingraph;
		entrytitle 'Distribution of Job Type' / textattrs=(size=14);
		layout region;
		piechart category=job_type response=count / dataskin=crisp start=90 centerFirstSlice=1 datalabelcontent=all;
		endlayout;
		endgraph;
	end;
run;
ods graphics / reset imagemap;
proc sgrender template=WebOne.Pie data=dm.profile_data;
run;
ods graphics / reset;

/*--Means for Years in Education--*/
title3 "Summarizing Properties of Years in Education";
proc means data=dm.profile_data n min max mean median var vardef=df q1 q3 qmethod=os;
var years_in_edu;
run;
/* Corss tabulation analysis 
proc freq data=dm.profile_data order=freq;
   tables job*Years_in_Edu*Marital_status/ nocum
       plots=freqplot(twoway=stacked orient=horizontal);
run;

/*--Pie Chart for Qualification--*/
title3;
proc template;
	define statgraph WebOne.Pie;
		begingraph;
		entrytitle 'Distribution of Education Level' / textattrs=(size=14);
		layout region;
		piechart category=qualification response=count / dataskin=crisp start=90 centerFirstSlice=1 datalabelcontent=all;
		endlayout;
		endgraph;
	end;
run;
ods graphics / reset imagemap;
proc sgrender template=WebOne.Pie data=dm.profile_data;
run;
ods graphics / reset;

/*--Pie Chart for Marital Status--*/
title3;
proc template;
	define statgraph WebOne.Pie;
		begingraph;
		entrytitle 'Distribution of Marital Status' / textattrs=(size=14);
		layout region;
		piechart category=marital_status response=count / dataskin=crisp start=90 centerFirstSlice=1 datalabelcontent=all;
		endlayout;
		endgraph;
	end;
run;
ods graphics / reset imagemap;
proc sgrender template=WebOne.Pie data=dm.profile_data;
run;
ods graphics / reset;

/*--Bar Chart for Jobs--*/
title3 "Distribution of Jobs";
ods graphics / reset imagemap;
proc sgplot data=dm.profile_data where=(Job in ('Adm-clerical', 
		'Transport-moving', 'Prof-specialty' , 'Craft-repair', 'Other-service', 
		'Handlers-cleaners', 'Machine-op-inspct', 'Tech-support', 'Sales', 
		'Farming-fishing', 'Protective-serv', 'Priv-house-serv')));;
	vbar Job / fillattrs=(color=CX0f2cd3) datalabel fillType=gradient 
		dataskin=Sheen name='Bar';
	yaxis grid;
run;
ods graphics / reset;

/*--Bar Chart for Relationship Status--*/
title3 "Distribution of Relationship Status";
ods graphics / reset imagemap;
proc sgplot data=dm.profile_data where=(Relationship_status in ('Husband', 
		'Not-in-family'
, 'Other-relative', 'Own-child', 'Unmarried', 'Wife')));;
	vbar relationship_status / fillattrs=(color=CX0f2cd3) datalabel fillType=gradient 
		dataskin=Sheen name='Bar';
	yaxis grid;
run;
ods graphics / reset;

/*--Bar Chart for Race--*/
title3 "Distribution of Race";
ods graphics / reset imagemap;
proc sgplot data=dm.profile_data;
	vbar race / fillattrs=(color=CX0f2cd3) datalabel fillType=gradient 
		dataskin=Sheen name='Bar';
	yaxis grid;
run;
ods graphics / reset;

/*--Pie Chart for gender--*/
title3;
proc template;
	define statgraph WebOne.Pie;
		begingraph;
		entrytitle 'Distribution of Gender' / textattrs=(size=14);
		layout region;
		piechart category=gender response=count / dataskin=crisp start=90 centerFirstSlice=1 datalabelcontent=all;
		endlayout;
		endgraph;
	end;
run;
ods graphics / reset imagemap;
proc sgrender template=WebOne.Pie data=dm.profile_data;
run;
ods graphics / reset;

/*--Means for Capital Gain--*/
title3 "Summarizing Properties of Capital Gain";
proc means data=dm.profile_data n min max mean median var vardef=df q1 q3 qmethod=os;
var capital_gain;
run;

/*--Bar Chart for Capital Gain--*/
title3 "Distribution of Capital Gain";
ods graphics / reset imagemap;
proc sgplot data=dm.profile_data;
	vbar capital_gain / fillattrs=(color=CX0f2cd3) datalabel fillType=gradient 
		dataskin=Sheen name='Bar';
	yaxis grid;
run;
ods graphics / reset;
/*--Mean for Capital Loss--*/
title3 "Summarizing Properties of Capital Loss";
proc means data=dm.profile_data n min max mean median var vardef=df q1 q3 qmethod=os;
var capital_loss;
run;

/*--Bar Chart for Capital Loss--*/
title3 "Distribution of Capital Loss";
ods graphics / reset imagemap;
proc sgplot data=dm.profile_data;
	vbar capital_loss / fillattrs=(color=CX0f2cd3) datalabel fillType=gradient 
		dataskin=Sheen name='Bar';
	yaxis grid;
run;
ods graphics / reset;

/*--means for Works Per Week--*/
title3 "Summarizing Properties of Works Per Week";
proc means data=dm.profile_data n min max mean median var vardef=df q1 q3 qmethod=os;
var work_per_week;
run;

/*--Bar Chart for work Per Week--*/
title3 "Distribution of Works Per Week by type";
ods graphics / reset imagemap;
proc sgplot data=dm.profile_data;
	vbar work_per_week / fillattrs=(color=CX0f2cd3) datalabel fillType=gradient 
		dataskin=Sheen name='Bar';
	yaxis grid;
run;
ods graphics / reset;

/*--Pie chart of Nationality--*/
title3;
proc template;
	define statgraph WebOne.Pie;
		begingraph;
		entrytitle 'Distribution of Nationality' / textattrs=(size=14);
		layout region;
		piechart category=country response=count / dataskin=crisp start=90 centerFirstSlice=1 datalabelcontent=all;
		endlayout;
		endgraph;
	end;
run;
ods graphics / reset imagemap;
proc sgrender template=WebOne.Pie data=dm.profile_data;
run;
ods graphics / reset;

/*--Bar Chart for Country--*/
title3 "Distribution of Country";
ods graphics / reset imagemap;
proc sgplot data=dm.profile_data;
	vbar country / fillattrs=(color=CX0f2cd3) datalabel fillType=gradient 
		dataskin=Sheen name='Bar';
	yaxis grid;
run;
ods graphics / reset;


/*--Bar Chart for Salary--*/
title3 "Distribution of Salary";
ods graphics / reset imagemap;
proc sgplot data=dm.profile_data;
	vbar salary / fillattrs=(color=CX0f2cd3) datalabel fillType=gradient 
		dataskin=Sheen name='Bar';
	yaxis grid;
run;
ods graphics / reset;