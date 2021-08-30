/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */

%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>
#include <vector>

// extern "C" int yylex();
/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep %option noyywrapg++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */
static int commentCaller;
static int stringCaller;

static std::vector<char> stringArray;

%}

%option noyywrap

/*
 * Define names for regular expressions here.
 */

DARROW          =>
CLASS           class
INHERITS        inherits

IF              if
THEN            then
ELSE            else
FI              fi

WHILE           while
LOOP            loop
POOL            pool

LET             let
IN              in

CASE            case
OF              of
ESAC            esac

NEW             new
ISVOID          isvoid
NOT             not

ASSIGN          <-
LE              <=

/* Others:
 * Integers
 * Identifiers
 * strings
 * comment 
 * whitespace
 */
%x COMMENT
%x STRING
%x STRING_ESCAPE

%%

 /*
  *  format string, \t\v\r\f\n.
  */
[ \t\v\r\f] {}

\n  { ++curr_lineno; }

 /*
  *  Invalid operator.
  */
[\[\]\'>] {
  cool_yylval.error_msg = yytext;
  return (ERROR);
}

 /*
  *  Nested comments
  */
"(*" {
  commentCaller = INITIAL;
  BEGIN(COMMENT);
}
<COMMENT><<EOF>> {
  BEGIN(commentCaller);
  cool_yylval.error_msg = "EOF in comment";
  return (ERROR);
}
<COMMENT>[^(\*\))] {
  if(yytext[0] == '\n') {
    ++curr_lineno;
  }
}
<COMMENT>"*)" {
  BEGIN(commentCaller);
}
"*)" {
  cool_yylval.error_msg = "Unmatched *)";
  return (ERROR);
}

 /* simple comments */
--.*$ {
  cout << "#single line comment.\n" << endl;
}

 /*
  *  The multiple-character operators.
  */
{DARROW}		{ return (DARROW); }

{ASSIGN}    { return (ASSIGN); }
{LE}        { return (LE); }

 /*
  * Keywords are cool_yylex case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */
{CLASS}     { return (CLASS); }
{INHERITS}  { return (INHERITS); }

{IF}        { return (IF); }
{THEN}      { return (THEN); }
{ELSE}      { return (ELSE); }
{FI}        { return (FI); }

{WHILE}     { return (WHILE); }
{LOOP}      { return (LOOP); }
{POOL}      { return (POOL); }

{LET}       { return (LET); }
{IN}        { return (IN); }

{CASE}      { return (CASE); }
{OF}        { return (OF); }
{ESAC}      { return (ESAC); }

{NEW}       { return (NEW); }
{ISVOID}    { return (ISVOID); }
{NOT}       { return (NOT); }


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */
\"  {
  stringCaller = INITIAL;
  stringArray.clear();
  BEGIN(STRING);
}

<STRING>[^\"\\]*\\  {
  stringArray.insert(stringArray.end(), yytext, yytext + yyleng - 1);
  BEGIN(STRING_ESCAPE);
}

<STRING>[^\"\\]*\"  {
  stringArray.insert(stringArray.end(), yytext, yytext + yyleng - 1);
  cool_yylval.symbol = stringtable.add_string(&stringArray[0], stringArray.size());
  BEGIN(stringCaller);
  return (STR_CONST);
}

<STRING>[^\"\\]*$ {
  stringArray.insert(stringArray.end(), yytext, yytext + yyleng);
  cool_yylval.error_msg = "Unterminated string constant.";
  BEGIN(stringCaller);
  ++curr_lineno;
  return (ERROR);
}

<STRING><<EOF>>  {
  cool_yylval.error_msg = "EOF in string constant";
  BEGIN(stringCaller);
  return (ERROR);
}

 /* string escape */
<STRING_ESCAPE>n {
  stringArray.push_back('\n');
  BEGIN(STRING);
}

<STRING_ESCAPE>b {
  stringArray.push_back('\b');
  BEGIN(STRING);
}

<STRING_ESCAPE>t {
  stringArray.push_back('\t');
  BEGIN(STRING);
}

<STRING_ESCAPE>f {
  stringArray.push_back('\f');
  BEGIN(STRING);
}

<STRING_ESCAPE>0  {
  cool_yylval.error_msg = "Strng contains null character";
  BEGIN(STRING);
  return (ERROR);
}

<STRING_ESCAPE>\n {
  stringArray.push_back('\n');
  ++curr_lineno;
  BEGIN(STRING);
}

<STRING_ESCAPE><<EOF>>  {
  cool_yylval.error_msg = "EOF in string constant";
  BEGIN(STRING);
  return (ERROR);
}

<STRING_ESCAPE>.  {
  stringArray.push_back(yytext[0]);
  BEGIN(STRING);
}

 /* BOOL CONSTANT */
 t[Rr][Uu][Ee]  {
   cool_yylval.boolean = true;
   return (BOOL_CONST);
 }

 f[Aa][Ll][Ss][Ee]  {
   cool_yylval.boolean = false;
   return (BOOL_CONST);
 }

 /* INT CONSTANT */
[0-9][0-9]* {
  cool_yylval.symbol = inttable.add_string(yytext, yyleng);
  return (INT_CONST);
}

 /* Type Identifier 
  * begin with a upper case letter 
  */
SELF_TYPE {
  cool_yylval.symbol = idtable.add_string("SELF_TYPE");
  return (TYPEID);
}

[A-Z_][A-Za-z0-9_]* {
  cool_yylval.symbol = idtable.add_string(yytext, yyleng);
  return (TYPEID);
}

 /* Object Identifier
  * begin with a lower case letter.
  */
self  {
  cool_yylval.symbol = idtable.add_string(yytext, yyleng);
  return (OBJECTID);
}
[a-z_][A-Za-z0-9_]* {
  cool_yylval.symbol = idtable.add_string(yytext, yyleng);
  return (OBJECTID);
}

 /* Others */
. {
  return yytext[0];
}

%%

/* test */