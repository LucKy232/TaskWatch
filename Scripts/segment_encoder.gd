class_name SegmentEncoder
## Returns an integer that toggles the segments in the shader, by bitwise operations

## --- 7 segment Display + Decimal Point ---
## 8bits - From left to right (starting from most significant digit 2^7)
## 1st DecimalPoint |  2nd Top          |  3rd Top-Right  |  4th Bottom-Right
## 5th Bottom       |  6th Bottom-Left  |  7th Top-Left   |  8th Middle
const seven_segment: Dictionary[String, int] = {
	"":  0b0000_0000, "-": 0b0000_0001, "0": 0b0111_1110,
	"1": 0b0011_0000, "2": 0b0110_1101, "3": 0b0111_1001,
	"4": 0b0011_0011, "5": 0b0101_1011, "6": 0b0101_1111,
	"7": 0b0111_0000, "8": 0b0111_1111, "9": 0b0111_1011,
	"A": 0b0111_0111, "B": 0b0111_1111, "C": 0b0100_1110,
	"D": 0b0111_1110, "E": 0b0100_1111, "F": 0b0100_0111,
}

static func get_seven_segment_digit(digit: int) -> int:
	if !seven_segment.has(str(digit)):
		return 0
	return seven_segment[str(digit)]

static func get_seven_segment_symbol(symbol: String) -> int:
	if !seven_segment.has(symbol):
		return 0
	return seven_segment[symbol]

static func add_seven_segment_decimal_point(bits: int) -> int:
	return bits | 0b1000_0000


## --- 14 segment Display + Decimal Point ---
## 15bits - From left to right (starting from most significant digit 2^14)
##  1st DecimalPoint    |  2nd Middle BottomRight |  3rd Middle Bottom  |  4th Middle BottomLeft
##  5th Middle TopRight |  6th Middle Top         |  7th Middle TopLeft |  8th Middle Right
##  9th Middle Left     | 10th Top Left           | 11th Bottom Left    | 12th Bottom
## 13th Bottom Right    | 14th Top Right          | 15th Top
const fourteen_segment: Dictionary[String, int] = {
	"":  0b0000_0000_0000_000, "-": 0b0000_0001_1000_000, "0": 0b0001_1000_0111_111,
	"1": 0b0000_1000_0000_110, "2": 0b0000_0001_1011_011, "3": 0b0000_0001_0001_111,
	"4": 0b0000_0001_1100_110, "5": 0b0000_0001_1101_101, "6": 0b0000_0001_1111_101,
	"7": 0b0010_1000_0000_001, "8": 0b0000_0001_1111_111, "9": 0b0000_0001_1100_111,
}

static func get_fourteen_segment_digit(digit: int) -> int:
	if !fourteen_segment.has(str(digit)):
		return 0
	return fourteen_segment[str(digit)]

static func get_fourteen_segment_symbol(symbol: String) -> int:
	if !fourteen_segment.has(symbol):
		return 0
	return fourteen_segment[symbol]

static func add_fourteen_segment_decimal_point(bits: int) -> int:
	return (bits | 0b1000_0000_0000_000)


## --- 3x5 Dot Matrix Display ---
const dot3x5: Dictionary[String, int] = {
	"":  0b000_000_000_000_000, "-": 0b000_000_111_000_000, "0": 0b111_101_101_101_111,
	"1": 0b001_011_001_001_001, "2": 0b111_001_111_100_111, "3": 0b111_001_011_001_111,
	"4": 0b001_011_101_111_001, "5": 0b111_100_111_001_111, "6": 0b110_100_111_101_111,
	"7": 0b111_001_010_100_100, "8": 0b111_101_111_101_111, "9": 0b111_101_111_001_011,
	":": 0b000_010_000_010_000,
}
# Diffrent 2, 3 & 8
const dot3x5_alt: Dictionary[String, int] = {
	"":  0b000_000_000_000_000, "-": 0b000_000_111_000_000, "0": 0b111_101_101_101_111,
	"1": 0b010_110_010_010_010, "2": 0b111_101_001_010_111, "3": 0b111_001_010_001_111,
	"4": 0b001_011_101_111_001, "5": 0b111_100_111_001_111, "6": 0b110_100_111_101_111,
	"7": 0b111_001_010_100_100, "8": 0b111_101_010_101_111, "9": 0b111_101_111_001_011,
	":": 0b000_010_000_010_000,
}

static func get_dot3x5_segment_digit(digit: int) -> int:
	if !dot3x5.has(str(digit)):
		return 0
	var bits: int = dot3x5[str(digit)]
	return bits

static func get_dot3x5_segment_symbol(symbol: String) -> int:
	if !dot3x5.has(symbol):
		return 0
	var bits: int = dot3x5[symbol]
	return bits


## --- 6x5 Dot Matrix Display ---
const dot6x5: Dictionary[String, int] = {
	"":  0b000000_000000_000000_000000_000000, "-": 0b000000_000000_000000_000000_000000, "0": 0b011110_100001_100001_100001_011110,
	"1": 0b000010_000110_000010_000010_000010, "2": 0b111110_000001_011110_100000_111111, "3": 0b111110_000001_011110_000001_111110,
	"4": 0b000110_001010_010010_111111_000010, "5": 0b111111_100000_111110_000001_111110, "6": 0b011111_100000_111110_100001_011110,
	"7": 0b111111_000010_000100_001000_010000, "8": 0b011110_100001_011110_100001_011110, "9": 0b011110_100001_011111_000001_011110,
}
# Alternative "7": 0b111111_000010_001100_010000_010000

static func get_dot6x5_segment_digit(digit: int) -> int:
	if !dot3x5.has(str(digit)):
		return 0
	var bits: int = dot6x5[str(digit)]
	return bits

static func get_dot6x5_segment_symbol(symbol: String) -> int:
	if !dot3x5.has(symbol):
		return 0
	var bits: int = dot6x5[symbol]
	return bits
