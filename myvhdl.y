%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SIGNALS 1000
char* entity_name=NULL;
char* signals[MAX_SIGNALS];
char* signals_types[MAX_SIGNALS];
int num_signals = 0;
int num_errors = 0;
void yyerror (const char* s);
extern int yylex();
extern int yylineno;
int is_signal_inserted(const char *sig);
void insert_signal(char *str, char *type);
int is_same_type(char *sig1, char* sig2);
void inc_error(char * error_msg);

%}

%union {char * id;}
%start program
%token <id> IDENTIFIER
%token ENTITY
%token IS
%token END
%token ARCHITECTURE
%token OF
%token SIGNAL
%token BEG
%token ASSIGN
%token ':'
%token ';'

%%

program 	: entity_part arch_part  {;}
;


entity_part	: ENTITY IDENTIFIER IS END ';'
    	  	{
			entity_name = $2;
			//printf("Entity : %s\n",$2);
		}
;

arch_part	: ARCHITECTURE IDENTIFIER OF IDENTIFIER IS sig_part BEG assign_part END ';'
  		 {
			if(strcmp(entity_name,$4)!=0){
				char msg[256];
				snprintf(msg,sizeof(msg), "Architecture entity name (%s) does not match the declared entity name (%s) in line number\n", $4,entity_name);
				inc_error(msg);
			}
		}
;

sig_part        : /*empty*/ {;}
	       	|SIGNAL IDENTIFIER ':' IDENTIFIER ';'	 
                {	
			if(!is_signal_inserted($2)){
				insert_signal($2,$4);
				//printf("Signals:\n  %s of type %s\n",$2,$4);
			}else{
				char msg[256];
                                snprintf(msg,sizeof(msg),"Signal name '%s' duplicated in line %d\n", $2, yylineno);
                                inc_error(msg);

			}
		}

                | sig_part SIGNAL IDENTIFIER ':' IDENTIFIER ';'
                {
			if(!is_signal_inserted($3)){
                               	insert_signal($3,$5);
				//printf("  %s of type %s\n",$3,$5);
                        }else{
				char msg[256];
                                snprintf(msg,sizeof(msg),"Signal name '%s' duplicated in line %d\n", $3, yylineno);
                                inc_error(msg);

			}
		} ;
assign_part	:/*empty*/	{;}
	    	|IDENTIFIER ASSIGN IDENTIFIER ';'
		{
			if(!is_signal_inserted($1)){
				char msg[256];
                                snprintf(msg,sizeof(msg),"UNKNOWN signal \'%s\' in line %d \n",$1, yylineno);
                                inc_error(msg);


			}
			else if(!is_signal_inserted($3)){
				char msg[256];
                                snprintf(msg,sizeof(msg),"UNKNOWN signal \'%s\' in line %d \n",$3, yylineno);
                                inc_error(msg);

			}else if(!is_same_type($1,$3)){
				char msg[256];
                                snprintf(msg,sizeof(msg),"signals not of the same type in line %d\n",yylineno);
                                inc_error(msg);
			}

			//printf("Assignments:\n  %s <= %s\n",$1,$3);
		}
		| assign_part IDENTIFIER ASSIGN IDENTIFIER ';'
		{
			if(!is_signal_inserted($2)){
				char msg[256];
                                snprintf(msg,sizeof(msg),"UNKNOWN signal \'%s\' in line %d \n",$2, yylineno);
                                inc_error(msg);
			}
			else if(!is_signal_inserted($4)){
				char msg[256];
                                snprintf(msg,sizeof(msg),"UNKNOWN signal \'%s\' in line %d \n",$4, yylineno);
                                inc_error(msg);

			}else if(!is_same_type($2,$4)){
				char msg[256];
                                snprintf(msg,sizeof(msg),"signals not of the same type in line %d\n",yylineno);
                                inc_error(msg);


      			 }

			//printf("  %s <= %s\n",$2,$4);
		}
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
    return;
}

int main(){
	char *line = NULL;
    	size_t len = 0;
   	ssize_t read;

   
	while ((read = getline(&line, &len, stdin)) != -1) {
   		printf("%s", line);  // Print each line
	}

	free(line);

	// Rewind stdin to re-read it for parsing
	fseek(stdin, 0, SEEK_SET);  


	yyparse();
	if(num_errors==0){
		printf("Parsing Succesful\n");
	}
	printf("---------------------------------------\n");

return 0;
}

int is_signal_inserted(const char * sig){
	for(int i =0; i < num_signals; i++){
		if(strcmp(signals[i],sig) == 0 ){
			return 1; //string found
		}
	}
	return 0;	//string not found

}

void insert_signal(char *str, char *type){
	if(num_signals < MAX_SIGNALS){
		signals[num_signals] = str;
		signals_types[num_signals] =type;
		num_signals++;
	}else{
		printf("ERROR: Maximum number of signals reached (1000)\n");
	}

}

int is_same_type(char *sig1, char* sig2){
	char* type1;
	char* type2;
	int found1=0;
	int found2=0;
	for(int i=0;i< num_signals;i++){
		if(strcmp(sig1,signals[i])==0){
			type1=signals_types[i];
			found1=1;
		}
		if(strcmp(sig2,signals[i])==0){
			type2=signals_types[i];
			found2=1;
		}
		if(found1==1 && found2==1)
			break;

	}
	if(found1==1 && found2==1 && strcmp(type1,type2)==0){
		return 1;
	}
	return 0;
	
}

void inc_error(char * error_msg){
	num_errors++;
	yyerror(error_msg);
}
