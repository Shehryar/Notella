@primaryFontName: AppleGothic;
@secondaryFontName: HelveticaNeue-Light;
@secondaryFontNameBold: HelveticaNeue;
@secondaryFontNameStrong: HelveticaNeue-Medium;
@inputFontName: HelveticaNeue;
@primaryFontColor: #555555;
@secondaryFontColor: #888888;
@primaryBackgroundColor: #E6E6E6;
@primaryBackgroundTintColor: #ECECEC;
@primaryBackgroundColorTop: #F3F3F3;
@primaryBackgroundColorBottom: #E6E6E6;
@primaryBackgroundColorBottomStrong: #DDDDDD;
@secondaryBackgroundColorTop: #FCFCFC;
@secondaryBackgroundColorBottom: #F9F9F9;
@primaryBorderColor: #A2A2A2;
@primaryBorderWidth: 1;
@buttonColor: #5d5d5d;


BarButton {
    
    background-tint-color: @buttonColor;
    border-width: @primaryBorderWidth;
    corner-radius: 7;
    font-name: @secondaryFontNameBold;
    font-color: @primaryFontColor;
    font-size: 13;
    text-shadow-color: clear;
}


LargeButton {
    height: 50;
    font-size: 20;
    corner-radius: 10;
}
SmallButton {
    height: 24;
    font-size: 14;
    corner-radius: 5;
}

Label {
    font-name: @secondaryFontName;
    font-size: 15;
    font-color: @primaryFontColor;
    text-auto-fit: True;
}
LargeLabel {
    font-size: 24;
}
SmallLabel {
    font-size: 15;
}
NavigationBar {
    font-name: @secondaryFontName;
    font-size: 20;
    font-color: @primaryFontColor;
    text-shadow-color: clear;
    background-color-top: @primaryBackgroundColorTop;
    background-color-bottom: @primaryBackgroundColorBottomStrong;


}

TableCell {
    background-color-top: @secondaryBackgroundColorTop;
    background-color-bottom: @secondaryBackgroundColorBottom;
    font-color: @primaryFontColor;
    font-name: @secondaryFontNameBold;
    font-size: 17;
}
TableCellDetail {
    font-name: @secondaryFontName;
    font-size: 14;
    font-color: @secondaryFontColor;
} 
TextField {
    font-name: @inputFontName;
    font-size: 14;
    font-color: @primaryFontColor;
    
}

LargeTextField {
    font-size: 18;
}
View {
    background-color: @primaryBackgroundColor;
    background-image: NUIViewBackground.png;
}