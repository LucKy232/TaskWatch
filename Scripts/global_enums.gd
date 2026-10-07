class_name E
## Contains enums and constants

const ENTRY_SCENE: String = "uid://b3bhysdbxda66"
const DAY_SUMMARY_SCENE: String = "uid://c5okbpeec14hc"
const WEEK_SUMMARY_SCENE: String = "uid://ntsmuhtbjyk5"
const MONTH_SUMMARY_SCENE: String = "uid://28f2sjgj2lrd"

enum SideV {
	TOP,
	BOTTOM
}
enum SideH {
	LEFT,
	RIGHT
}
enum DisplayType {
	SEVEN_SEGMENT,
	FOURTEEN_SEGMENT,
	DOT_MATRIX_3x5,
	DOT_MATRIX_5x7,
	DOT_MATRIX_6x5,
	#DOT_MATRIX_27,
	#DOT_MATRIX_33,
}

const DisplayTypeNames: Dictionary[DisplayType, String] = {
	DisplayType.SEVEN_SEGMENT: "7 Seg",
	DisplayType.FOURTEEN_SEGMENT: "14 Seg",
	DisplayType.DOT_MATRIX_3x5: "Dot 3x5",
	DisplayType.DOT_MATRIX_5x7: "Dot 5x7",
	DisplayType.DOT_MATRIX_6x5: "Dot 6x5",
	#DisplayType.DOT_MATRIX_27: "Dot 27",
	#DisplayType.DOT_MATRIX_33: "Dot 33",
	}

const scale_dict: Dictionary[int, float] = {
	0:  0.12,   1:  0.15,   2:  0.20,
	3:  0.25,   4:  0.30,   5:  0.40,
	6:  0.50,   7:  0.75,   8:  1.00,
	9:  1.25,   10: 1.50,   11: 2.00,
	12: 2.50,   13: 3.00,
}
