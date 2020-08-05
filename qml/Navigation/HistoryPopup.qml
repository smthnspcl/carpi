import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: navigationHistoryPopup
    modal: true
    width: 400
    height: 600

    property PositionSource gpsSource

    property double latitude
    property double longitude

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    contentItem: Item {

    }
}
