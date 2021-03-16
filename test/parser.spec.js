const { parse } = require("./../dist/parser");

test("should parse simple query", () => {
  const sql = "column = value";
  const tree = {
    type: "node",
    operator: "=",
    column: "column",
    value: "value",
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test('should parse query with ">=" operator', () => {
  const operator = ">=";
  const sql = `column ${operator} value`;
  const tree = {
    type: "node",
    operator,
    column: "column",
    value: "value",
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test('should parse query with "<=" operator', () => {
  const operator = "<=";
  const sql = `column ${operator} value`;
  const tree = {
    type: "node",
    operator,
    column: "column",
    value: "value",
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test('should parse query with "<" operator', () => {
  const operator = "<";
  const sql = `column ${operator} value`;
  const tree = {
    type: "node",
    operator,
    column: "column",
    value: "value",
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test('should parse query with ">" operator', () => {
  const operator = ">";
  const sql = `column ${operator} value`;
  const tree = {
    type: "node",
    operator,
    column: "column",
    value: "value",
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test('should parse query with "<>" operator', () => {
  const operator = "<>";
  const sql = `column ${operator} value`;
  const tree = {
    type: "node",
    operator,
    column: "column",
    value: "value",
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test('should parse query with "!=" operator', () => {
  const operator = "!=";
  const sql = `column1 ${operator} value1`;
  const tree = {
    type: "node",
    operator,
    column: "column1",
    value: "value1",
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test('should parse query with "BETWEEN" operator', () => {
  const sql = "column BETWEEN 0 AND 100";
  const tree = {
    type: "node",
    operator: "BETWEEN",
    column: "column",
    value: [0, 100],
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test('should parse query with "NOT BETWEEN" operator', () => {
  const sql = "column NOT BETWEEN 0 AND 100";
  const tree = {
    type: "node",
    operator: "NOT BETWEEN",
    column: "column",
    value: [0, 100],
  };
  expect(parse(sql)).toStrictEqual(tree);
});

// console.log(parse("city IN ('London', 'Paris')"));

test('should parse query with "IN" operator', () => {
  const sql = "city IN ('London', 'Paris')";
  const tree = {
    type: "node",
    operator: "IN",
    column: "city",
    value: ["London", "Paris"],
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test('should parse query with "NOT IN" operator', () => {
  const sql = "city NOT IN ('London', 'Paris')";
  const tree = {
    type: "node",
    operator: "NOT IN",
    column: "city",
    value: ["London", "Paris"],
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test('should parse query with "LIKE" operator', () => {
  const sql = "city LIKE '%cow%'";
  const tree = {
    type: "node",
    operator: "LIKE",
    column: "city",
    value: "%cow%",
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test('should parse query with "NOT LIKE" operator', () => {
  const sql = "city NOT LIKE '%cow%'";
  const tree = {
    type: "node",
    operator: "NOT LIKE",
    column: "city",
    value: "%cow%",
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test("should parse query with dot notation in column name", () => {
  const sql = "column.sub.subsub = value";
  const tree = {
    type: "node",
    operator: "=",
    column: "column.sub.subsub",
    value: "value",
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test("should parse query with string as value (variant 1)", () => {
  const sql = 'column = "value"';
  const tree = {
    type: "node",
    operator: "=",
    column: "column",
    value: "value",
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test("should parse query with string as value (variant 2)", () => {
  const sql = "column = 'value'";
  const tree = {
    type: "node",
    operator: "=",
    column: "column",
    value: "value",
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test("should parse query with number as value", () => {
  const sql = "column = 1";
  const tree = {
    type: "node",
    operator: "=",
    column: "column",
    value: 1,
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test("should parse query with number with sign as value", () => {
  const sql = "column = -1";
  const tree = {
    type: "node",
    operator: "=",
    column: "column",
    value: -1,
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test("should parse query with decimal as value", () => {
  const sql = "pi = 3.14159";
  const tree = {
    type: "node",
    operator: "=",
    column: "pi",
    value: 3.14159,
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test("should parse query with decimal with sign as value", () => {
  const sql = "pi != -3.14159";
  const tree = {
    type: "node",
    operator: "!=",
    column: "pi",
    value: -3.14159,
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test('should parse "AND" operator', () => {
  const sql = "column1 = value1 AND column2 = value2";
  const tree = {
    type: "group",
    operator: "AND",
    children: [
      { type: "node", operator: "=", column: "column1", value: "value1" },
      { type: "node", operator: "=", column: "column2", value: "value2" },
    ],
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test('should parse "OR" operator', () => {
  const sql = "column1 = value1 OR column2 = value2";
  const tree = {
    type: "group",
    operator: "OR",
    children: [
      { type: "node", operator: "=", column: "column1", value: "value1" },
      { type: "node", operator: "=", column: "column2", value: "value2" },
    ],
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test('should parse "AND" and "OR" operator', () => {
  const sql = "column1 = value1 AND column2 = value2 OR column3 = value3";
  const tree = {
    type: "group",
    operator: "OR",
    children: [
      {
        type: "group",
        operator: "AND",
        children: [
          { type: "node", operator: "=", column: "column1", value: "value1" },
          { type: "node", operator: "=", column: "column2", value: "value2" },
        ],
      },
      { type: "node", operator: "=", column: "column3", value: "value3" },
    ],
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test('should parse "AND" and "OR" operator with parentheses', () => {
  const sql = "column1 = value1 AND (column2 = value2 OR column3 = value3)";
  const tree = {
    type: "group",
    operator: "AND",
    children: [
      { type: "node", operator: "=", column: "column1", value: "value1" },
      {
        type: "group",
        operator: "OR",
        children: [
          { type: "node", operator: "=", column: "column2", value: "value2" },
          { type: "node", operator: "=", column: "column3", value: "value3" },
        ],
        parentheses: true,
      },
    ],
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test("should parse with extra spaces", () => {
  const sql = "column                     = \r\n          value";
  const tree = {
    type: "node",
    operator: "=",
    column: "column",
    value: "value",
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test("should parse with dot in string value", () => {
  const sql = "column = value.some";
  const tree = {
    type: "node",
    operator: "=",
    column: "column",
    value: "value.some",
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test("should parse without spaces", () => {
  const sql = "column=value";
  const tree = {
    type: "node",
    operator: "=",
    column: "column",
    value: "value",
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test("should parse without spaces with quotes", () => {
  const sql = 'column="value"';
  const tree = {
    type: "node",
    operator: "=",
    column: "column",
    value: "value",
  };
  expect(parse(sql)).toStrictEqual(tree);
});

test("should fail parse with few value refs", () => {
  const sql = "column=value<>123";
  const tree = {
    type: "node",
    operator: "=",
    column: "column",
    value: "value",
  };
  expect(() => parse(sql)).toThrow();
});
