{

  function createGroup(operator, children) {
  	return {
      type: 'group',
      operator,
      children
    }
  }
  
  function createNode(operator, column, value) {
    return {
      type: 'node',
      operator,
      column,
      value
    }
  }
  
  function createValue(type, value) {
    return {
      type,
      value,
    };
  }
  
  function createList(head, tail) {
    return [head].concat(tail.map(i => i[3]));
  }
  
}

Start
 = expr

expr
 = or_expr
 
or_expr
 = head:and_expr tail:(_ OR _ and_expr)* {
   if(tail.length === 0) return head;
   return createGroup('OR', [head].concat(tail.map(i => i[3])));
 	// return createBinaryExprChain(head, tail);
 }
 
and_expr
 = head:not_expr tail:(_ AND _ not_expr)* {
   if(tail.length === 0) return head;
   return createGroup('AND', [head].concat(tail.map(i => i[3])));
   // return createBinaryExprChain(head, tail);
 }
 
not_expr
  = comparison_expr

comparison_expr
  = left:primary _ rh:comparison_op? {
      if (rh === null) return left;
      else if (rh.type === 'arithmetic') {
        return createNode(rh.tail[0][1], left, rh.tail[0][3]);
        // return createBinaryExprChain(left, rh.tail);
      }
      // else return createBinaryExpr(rh.op, left, rh.right);
      else return createNode(rh.op, left, rh.right);
    }
    
primary
  = literal
  / column_ref
  / "(" _ e:expr _ ")" {
 	return { ...e, parentheses: true }
  }; 
 
literal
  = literal_string
  / literal_digits
  / literal_bool
  / literal_null
  / literal_datetime
 
literal_digits
  = literal_decimal
  / literal_numeric

literal_null
  = NULL {
    return { type: 'null', value: null };
  }

literal_bool
  = TRUE {
      return { type: 'bool', value: true };
    }
  / FALSE {
      return { type: 'bool', value: false };
    }

literal_string
  = ca:(QUOTE single_char* QUOTE) {
      return {
        type: 'string',
        value: ca[1].join('')
      };
    }

literal_datetime
  = type:("TIME" / "DATE" / "TIMESTAMP") __ ca:(QUOTE single_char* QUOTE) {
      return {
        type: type.toLowerCase(),
        value: ca[1].join('')
      };
    }

literal_numeric
  = n:NUMBER {
 	return { type: 'number', value: n };
  }
 
literal_decimal
  = d:DECIMAL {
    return { type: 'decimal', value: d };
  }

single_char
  = [^'"\\\0-\x1F\x7f]
  / escape_char
  
escape_char
  = "\\'"  { return "'";  }
  / '\\"'  { return '"';  }
  / "\\\\" { return "\\"; }
  / "\\/"  { return "/";  }
  / "\\b"  { return "\b"; }
  / "\\f"  { return "\f"; }
  / "\\n"  { return "\n"; }
  / "\\r"  { return "\r"; }
  / "\\t"  { return "\t"; }
  / "''"   { return "\'"; }
  
list
  = head:expr tail:(_ COMMA _ expr)* {
    return {
      type: "list",
      value: createList(head, tail)
    };
  }
    
column_ref
  = c:column_name
 
column_name
  = v:STRING_WITH_DO_NOTATION { return v.join(""); }

operator
  = comparison_op

comparison_op
  = arithmetic_comparison_op
  / like_comparison_op
  / between_camparison_op
  / in_comparison_op
 
arithmetic_comparison_op
  = l:(_ arithmetic_comparison_operator _ primary)+ {
    return { type: 'arithmetic', tail: l };
  }

like_comparison_op
  = op:like_op _ right:comparison_expr {
    return { op, right: right };
  }

in_comparison_op
  = op:in_op _ LPAREN _ l:list _ RPAREN {
    return { op, right: l };
  };
  
in_op
  = t:(NOT _ IN) { return t[0] + ' ' + t[2]; }
  / IN
  ;
 
like_op
  = t:(NOT _ LIKE) { return t[0] + ' ' + t[2]; }
  / LIKE
  ;

between_camparison_op
  = op:between_op _ begin:literal_digits _ AND _ end:literal_digits {
    return { op, right: { type: 'list', value: [begin, end] } };
  }
  ;
 
between_op
  = t:(NOT _ BETWEEN) { return t[0] + ' ' + t[2]; }
  / BETWEEN
  ;
 
arithmetic_comparison_operator
  = '>='
  / '<='
  / '<'
  / '>'
  / '<>'
  / '!='
  / '='
  ;
 
logical_op
  = '!'
  / NOT;
  
_ "Optional Whitespace" = __?;
__ "Mandatory Whitespace" = $(WHITESPACE+);
WHITESPACE = [ \t\n\r];
AND = "AND"i;
OR = "OR"i;
NOT = "NOT"i;
LIKE = "LIKE"i;
IN = "IN"i;
BETWEEN = "BETWEEN"i;
IS = "IS"i;
NULL = "NULL"i;
TRUE = "TRUE"i;
FALSE = "FALSE"i;
LPAREN = "(";
RPAREN = ")";
DOT = ".";
COMMA = ',';
DIGIT = [0-9];
DIGITS = x:DIGIT+ { return x.join(""); };
DIGITS_AND_DOT = x:[0-9+?\.0-9+]i+ { return x.join(""); };
DECIMAL "decimal" = x:DIGITS_AND_DOT { return parseFloat(x); };
INTEGER "integer" = x:DIGITS { return parseInt(x, 10); };
NUMBER "number" 
  = DIGITS
  / d:DIGIT
  / o:SIGN d:DECIMAL { return o + d; }
  / o:SIGN d:INTEGER { return o + d; }
  ;
STRING "string" = [a-z0-9_%]i+;
STRING_WITH_DO_NOTATION = [a-z0-9_%\.]i+;
VALUE = STRING_WITH_DO_NOTATION / STRING / INTEGER / DECIMAL / NUMBER;
SIGN = '-' / '+';
QUOTE = '"' / '\'';

