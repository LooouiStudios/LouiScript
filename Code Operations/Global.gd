extends Node

var current_line = 0
@onready var main = get_node("/root/main")

var TOKEN_PATTERNS = {
	"DEFINE_VARIABLE": [TOKEN_VARIABLE, TOKEN_VALUE_TYPE, TOKEN_EQUALS, "VALUE", TOKEN_END],
	"DEFINE_VARIABLE_WITH_FUNCTION_CALL+_INPUT": [TOKEN_VARIABLE, TOKEN_VALUE_TYPE, TOKEN_EQUALS, TOKEN_CALL_FUNCTION, TOKEN_LPAREN, "VALUE", TOKEN_RPAREN, TOKEN_END],
	"DEFINE_VARIABLE_WITH_FUNCTION_CALL+_INPUT_2": [TOKEN_VARIABLE, TOKEN_VALUE_TYPE, TOKEN_EQUALS, TOKEN_CALL_FUNCTION, TOKEN_LPAREN, "VALUE", TOKEN_COMMA, "VALUE", TOKEN_RPAREN, TOKEN_END],
	"DEFINE_VARIABLE_OPERATORS": [TOKEN_VARIABLE, TOKEN_VALUE_TYPE, TOKEN_EQUALS, "VALUE", "OPERATOR", "VALUE"],
	
	"FUNCTION_CALL_+_INPUT": [TOKEN_CALL_FUNCTION, TOKEN_LPAREN, "VALUE", TOKEN_RPAREN, TOKEN_END],
	"FUNCTION_CALL_+_INPUT_2": [TOKEN_CALL_FUNCTION, TOKEN_LPAREN, "VALUE", TOKEN_COMMA, "VALUE", TOKEN_RPAREN, TOKEN_END],
	
	"IF_STATEMENT": [TOKEN_IF, "VALUE", "IF_OPERATOR", "VALUE", TOKEN_END],
	"ELSE_IF_STATEMENT": [TOKEN_ELSE, TOKEN_IF, "VALUE", "IF_OPERATOR", "VALUE", TOKEN_END],
	"ELSE_STATEMENT": [TOKEN_ELSE, TOKEN_END],
	"WHILE_STATEMENT": [TOKEN_WHILE, "VALUE", "IF_OPERATOR", "VALUE", TOKEN_END]
}

# Constants
const DIGITS = "0123456789"
const ALPHABET = "abcdefghijklmnopqrstuvwxyzæøå_"
const VALUE_TYPES = ["int", "float", "string", "bool", "variable"]
const KEYWORDS = [
	"true", 
	"false",
	]

const IN_BUILT_FUNCTIONS = [
	"print",
	"printc",
	"input",
	
	"make_int",
	"make_float",
	"make_string",
	"get_type",
	"len",
	
	"add",
	"subtract",
	"multiply",
	"divide",
	
	"random_int",
	
	"create_window",
]

var CUSTOM_FUNCTIONS = []
var DEFINED_VARIABLE = []

# Token Types

# Value types
const TOKEN_INT = "INT" # 0
const TOKEN_FLOAT = "FLOAT" # 0.0
const TOKEN_BOOL = "BOOL" # true
const TOKEN_STRING = "STRING" # "Hello, world!"
const TOKEN_VALUE_TYPE = "VALUE_TYPE" # (float, int, string, bool)

# If Value types
@onready var IF_VALUES = [TOKEN_EQUAL_TO, TOKEN_NOT_EQUAL_TO, TOKEN_BIGGER_THAN, TOKEN_LESS_THAN]
const TOKEN_EQUAL_TO = "EQUAL_TO" # ==
const TOKEN_NOT_EQUAL_TO = "NOT_EQUAL_TO" # !=
const TOKEN_BIGGER_THAN = "BIGGER_THAN" # <
const TOKEN_BIGGER_OR_EQUAL_TO = "BIGGER_EQUAL" # <=
const TOKEN_LESS_THAN = "LESS_THAN" # >
const TOKEN_LESS_OR_EQUAL_TO = "LESS_EQUAL" # >=

# Math operators
const TOKEN_PLUS = "PLUS" # +
const TOKEN_MINUS = "MINUS" # -
const TOKEN_MULTIPLY = "MULTIPLY" # *
const TOKEN_DIVIDE = "DIVIDE" # /
const TOKEN_EQUALS = "EQUALS" # = 
const TOKEN_COMMA = "COMMA" # , 

# Parentheses
const TOKEN_LPAREN = "LPAREN" # (
const TOKEN_RPAREN = "RPAREN" # )

# Variables
const TOKEN_VARIABLE = "DEFINE_VARIABLE" # @some_variable,
const TOKEN_DEFINED_VARIABLE = "VARIABLE" # some_variable

# Functions
const TOKEN_DEFINE_FUNCTION = "DEFINE_FUNCTION" #
const TOKEN_CALL_FUNCTION = "CALL_FUNCTION" #

# Other
const TOKEN_IF = "IF" # if
const TOKEN_ELSE = "ELSE" # else
const TOKEN_WHILE = "WHILE"# while

const TOKEN_END = "LINE_END" # nothing, just the end of the line.
