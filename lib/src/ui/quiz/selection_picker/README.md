# selection_picker

A flutter plugin for creating a Picker selection and customize it.

![Example](https://gitlab01.copyleft.no/pixzelle/selection_picker/raw/master/example.png)

## How to use

```dart
    SelectionPicker(
            items: Utilities.getDays(),
            showSelectAll: true,
            textColor: Color(0xFF003A5D),
            selectAllTitle: Text("Select all",style: _styleTitleSelectAll),
            showTitle: true,
            title: Text("Week days",style: _styleTitle,),
            backgroundColorSelected: Colors.black12,
            onSelected: (items){
            //Items selected here 
            },
            aligment: Alignment.center,
          )

class Utilities {
  static List<SelectionItem> getDays() {
    List<SelectionItem> days = [];
    days.add(SelectionItem(name: "MO", isSelected: false, identifier: 1));
    days.add(SelectionItem(name: "TU", isSelected: false, identifier: 2));
    days.add(SelectionItem(name: "WE", isSelected: false, identifier: 3));
    days.add(SelectionItem(name: "TH", isSelected: false, identifier: 4));
    days.add(SelectionItem(name: "FR", isSelected: false, identifier: 5));
    days.add(SelectionItem(name: "SA", isSelected: false, identifier: 6));
    days.add(SelectionItem(name: "SU", isSelected: false, identifier: 7));
    return days;
  }
}

```