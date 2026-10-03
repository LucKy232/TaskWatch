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

static func get_seven_segment_digit(digit: int, decimal_point: bool = false) -> int:
	if !seven_segment.has(str(digit)):
		return 0
	var bits: int = seven_segment[str(digit)]
	return (bits | 0b1000_0000) if decimal_point else bits

static func get_seven_segment_symbol(symbol: String, decimal_point: bool = false) -> int:
	if !seven_segment.has(symbol):
		return 0
	var bits: int = seven_segment[symbol]
	return (bits | 0b1000_0000) if decimal_point else bits


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

static func get_fourteen_segment_digit(digit: int, decimal_point: bool = false) -> int:
	if !fourteen_segment.has(str(digit)):
		return 0
	var bits: int = fourteen_segment[str(digit)]
	return (bits | 0b1000_0000_0000_000) if decimal_point else bits

static func get_fourteen_segment_symbol(symbol: String, decimal_point: bool = false) -> int:
	if !fourteen_segment.has(symbol):
		return 0
	var bits: int = fourteen_segment[symbol]
	return (bits | 0b1000_0000_0000_000) if decimal_point else bits
