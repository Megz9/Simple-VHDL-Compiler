%{
#include "y.tab.h"
extern void inc_error(char * error_msg);
%}

%option caseless

%%

":"			{ return ':'; }
";"			{ return ';'; }
"<="			{ return ASSIGN; }
"OF"			{ return OF; }
"IS"			{ return IS; }
"entity"		{ return ENTITY; } 
"architecture"		{ return ARCHITECTURE; }
"signal" 		{ return SIGNAL; }
"begin" 		{ return BEG; }
"END"			{ return END; }
[a-zA-Z_][a-zA-Z_0-9]*  { yylval.id = strdup(yytext); return IDENTIFIER; }
[@!#$%^&*][a-zA-Z_0-9]+   {char msg[256]; snprintf(msg,sizeof(msg), "Identifier cannot start with special symbols: %s\n", yytext); inc_error(msg); }
[0-9]+[a-zA-Z_][a-zA-Z_0-9]*  {char msg[256]; snprintf(msg,sizeof(msg), "Identifier cannot start with a number: %s\n", yytext); inc_error(msg); }
[a-zA-Z_][a-zA-Z_0-9]*[@!#$%^&*]+[a-zA-Z_0-9]* {char msg[256]; snprintf(msg,sizeof(msg), "Identifier contains special characters: %s\n", yytext); inc_error(msg); }




[ \t]			{ ;} /*ignore spaces*/
[\n]			{yylineno++;}
.			{ printf("unexpected identifier: %s\n",yytext); }

%%

int yywrap()
{
	return 1;
}
