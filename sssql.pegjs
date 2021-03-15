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
  
  function recursiveJoin(a) {
  	return a.map((item, i, array) => {
      if(Array.isArray(item)) {
        return recursiveJoin(item);
      }
      return item;
    }).join("");
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
 }
 
and_expr
 = head:not_expr tail:(_ AND _ not_expr)* {
   if(tail.length === 0) return head;
   return createGroup('AND', [head].concat(tail.map(i => i[3])));
 }
 
not_expr
  = comparison_expr

comparison_expr
  = left:primary _ rh:comparison? {
      if (rh === null) return left;
      else if (rh.type === 'arithmetic') {
        return createNode(rh.tail[0][1], left, rh.tail[0][3]);
      }
      else return createNode(rh.op, left, rh.right);
    }
    
primary
  = literal
  / column_ref
  / "(" _ e:expr _ ")" {
 	return { ...e, parentheses: true }
  }; 
 
literal
  = literal_null
  / literal_bool
  / literal_datetime
  / literal_number
  / literal_string
  ;
 
literal_number
  = NUMBER

literal_null
  = NULL {
    return null;
  }

literal_bool
  = TRUE {
      return true;
    }
  / FALSE {
      return false;
    }

literal_string
  = ca:(QUOTE single_char* QUOTE) {
      return ca[1].join('');
    }

literal_datetime
  = type:("TIME" / "DATE" / "TIMESTAMP") __ ca:(QUOTE single_char* QUOTE) {
      return ca[1].join('');
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
    return createList(head, tail);
  }
    
column_ref
  = v:STRING

operator
  = comparison

comparison
  = arithmetic_comparison
  / like_comparison
  / between_camparison
  / in_comparison
 
arithmetic_comparison
  = l:(_ arithmetic_comparison_operator _ primary)+ {
    return { type: 'arithmetic', tail: l };
  }

like_comparison
  = op:like _ right:comparison_expr {
    return { op, right: right };
  }

in_comparison
  = op:in _ LPAREN _ l:list _ RPAREN {
    return { op, right: l };
  };

between_camparison
  = op:between _ begin:literal_number _ AND _ end:literal_number {
    return { op, right: [begin, end] };
  }
  ;

in
  = t:(NOT _ IN) { return t[0] + ' ' + t[2]; }
  / IN
  ;
 
like
  = t:(NOT _ LIKE) { return t[0] + ' ' + t[2]; }
  / LIKE
  ;
  
between
  = t:(NOT _ BETWEEN) { return t[0] + ' ' + t[2]; }
  / BETWEEN
  ;
 
arithmetic_comparison_operator
  = '<>'
  / '>='
  / '<='
  / '<'
  / '>'
  / '!='
  / '='
  ;
 
logical_operator
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
COMMA = ',';
NUMBER "Number" = x:([+-]?([0-9]*[.])?[0-9]+) { return parseFloat(recursiveJoin(x)) };
STRING "String" = s:([a-z0-9_%\.]i+) { return s.join(""); };
VALUE = STRING / NUMBER;
SIGN = '-' / '+';
QUOTE = '"' / '\'';

