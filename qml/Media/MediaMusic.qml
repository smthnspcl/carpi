import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.folderlistmodel 2.15
import Qt.labs.settings 1.0
import Qt.labs.platform 1.1
import QtMultimedia 5.15
import QtQuick.Controls.Material 2.12

// todo folder browser for albums / music

Page {
    id: mediaMusic
    title: qsTr("Music")

    Component.onCompleted: {
        if(musicSettings.lastAlbum != "") loadAlbum(musicSettings.lastAlbum)
        if(musicSettings.lastSong != "") mediaPlayer.playlist.addItem(musicSettings.lastSong)
    }

    Settings {
        id: uiSettings
        category: "ui"
        property string theme: Material.Dark
        property int accent: Material.Purple
    }

    Settings {
        id: musicSettings
        category: "music"
        property string directory: StandardPaths.writableLocation(StandardPaths.MusicLocation)
        property int volume: 30
        property string lastSong: ""
        property string lastAlbum: ""

        Component.onCompleted: {
            console.log("Music")
            console.log(musicSettings.directory)
            console.log(musicSettings.volume)
            console.log(musicSettings.lastSong)
            console.log(musicSettings.lastAlbum)
        }
    }

    FolderListModel {
        id: albumModel
        showDirs: false
        showFiles: true
        nameFilters: ["*.mp3"]
    }

    function loadSong(f) {
        console.log("loading song: ", f)
        mediaPlaylist.addItem(f)
    }

    function loadAlbum(f){
        console.log("loading album: ", f)
        albumModel.folder = f
        for(var i=0; i<albumModel.count; i++) loadSong(albumModel.get(i, "fileUrl"))
    }

    function getAlbumCover(){ // todo load via qquickimageprovider & id3lib or via use a cpp mediaplayer and use qmediametadata and access coverartimage
        var m = mediaPlayer.metaData
        if(m.coverArtUrlLarge) return m.coverArtUrlLarge
        else if(m.coverArtUrlSmall) return m.coverArtUrlSmall
        else if(m.posterUrl) return m.posterUrl
        else if(m.coverArtImage) return m.coverArtImage
        return "qrc:///img/cover.png"
    }

    Playlist {
        id: mediaPlaylist
    }

    MediaPlayer {
        id: mediaPlayer
        playlist: mediaPlaylist
        volume: musicSettings.volume / 100
    }

    Label {
        id: lblArtist
        anchors.bottom: lblAlbum.top
        anchors.bottomMargin: 4
        anchors.left: parent.left
        anchors.leftMargin: 4
        text: mediaPlayer.metaData.albumArtist
    }

    Label {
        id: lblAlbum
        anchors.bottom: lblSong.top
        anchors.bottomMargin: 4
        anchors.left: parent.left
        anchors.leftMargin: 4
        text: mediaPlayer.metaData.albumTitle
    }

    Label {
        id: lblSong
        anchors.bottom: songProgress.top
        anchors.bottomMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 4
        text: mediaPlayer.metaData.title
    }

    Image {
        id: imgCover
        fillMode: Image.PreserveAspectFit
        anchors.left: btnLastSong.left
        anchors.right: btnPlayPause.right
        anchors.top: parent.top
        anchors.bottom: lblArtist.top
        anchors.bottomMargin: 16
        source: getAlbumCover()
    }

    Slider {
        id: songProgress
        anchors.left: btnLastSong.left
        anchors.bottom: btnPlayPause.top
        anchors.right: btnNextSong.right
        value: mediaPlayer.position
        to: mediaPlayer.duration

        onMoved: {
            mediaPlayer.seek(songProgress.position)
        }
    }

    Label {
        id: lblSongProgressSpacer
        text: "/"
        anchors.left: lblSongProgress.right
        anchors.bottom: lblSongProgress.bottom
        anchors.leftMargin: 4
    }

    Label {
        id: lblSongProgress
        text: "0:00"
        anchors.top: songProgress.top
        anchors.left: songProgress.right
        anchors.leftMargin: -(lblSongProgress.implicitWidth + lblSongProgressSpacer.implicitWidth + lblSongLength.implicitWidth)
    }

    Label {
        id: lblSongLength
        text: "10:00"
        anchors.left: lblSongProgressSpacer.right
        anchors.bottom: lblSongProgressSpacer.bottom
        anchors.leftMargin: 4
    }

    Slider {
        id: volume
        orientation: Qt.Vertical
        anchors.left: btnPlayPause.right
        anchors.rightMargin: 16
        anchors.top: parent.top
        anchors.topMargin: 32
        height: 300
        to: 100
        value: musicSettings.volume

        onMoved: {
            var cv = volume.value
            if(cv >= 90) lblVolumeMax.visible = false
            else lblVolumeMax.visible = true
            if(cv <= 10) lblVolumeMin.visible = false
            else lblVolumeMin.visible = true

            musicSettings.volume = volume.value
            mediaPlayer.volume = volume.value / 100
        }
    }

    Label {
        id: lblVolume
        anchors.bottom: volume.top
        anchors.left: volume.left
        text: "Volume"
    }

    function calculatePosition(v) {
        return v / 100 * volume.height
    }

    Label {
        id: lblVolumeCurrent
        anchors.left: volume.right
        anchors.bottom: volume.bottom
        text: volume.value | 0
        anchors.bottomMargin: calculatePosition(volume.value)
    }

    Label {
        id: lblVolumeMax
        anchors.left: volume.right
        anchors.top: volume.top
        text: "100"
    }

    Label {
        id: lblVolumeMin
        anchors.left: volume.right
        anchors.bottom: volume.bottom
        text: "0"
    }

    Button {
        id: btnLastSong
        text: "<<"
        width: 200
        height: 100
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        anchors.left: parent.left
        anchors.leftMargin: 4

        onClicked: {
            var p = mediaPlayer.playlist
            if(p.currentIndex >= 0) p.previous()
        }
    }

    Button {
        id: btnPlayPause
        text: ">"
        width: 200
        height: 100
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        anchors.left: btnLastSong.right
        anchors.leftMargin: 4

        onClicked: {
            if(mediaPlaylist.itemCount == 0) return;

            var s = mediaPlayer.playbackState
            if(s === MediaPlayer.PlayingState) {
                btnPlayPause.text = ">"
                mediaPlayer.pause()
            } else {
                btnPlayPause.text = "||"
                mediaPlayer.play()
            }
        }
    }

    Button {
        id: btnNextSong
        text: ">>"
        width: 200
        height: 100
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        anchors.left: btnPlayPause.right
        anchors.leftMargin: 4

        onClicked: {
            var p = mediaPlayer.playlist
            console.log("current index: ", p.currentIndex, "; itemCount: ", p.itemCount)
            if(p.currentIndex < p.itemCount) p.next()
        }
    }

    ListView {
        id: folderList
        anchors.left: btnNextSong.right
        anchors.leftMargin: 16
        anchors.top: parent.top
        anchors.topMargin: 4
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        anchors.right: parent.right
        anchors.rightMargin: 4

        FolderListModel {
            id: folderModel
            showDirs: true
            showFiles: false
            folder: musicSettings.directory
        }

        Component {
            id: fileDelegate

            Item {
                // width: parent.parent.implicitWidth
                width: 300
                height: 30

                Column {
                    Text {
                        font.pointSize: 14
                        text: fileName
                        color: "#ffffff"
                        // wrapMode: Text.WordWrap // todo newline or something
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: folderList.currentIndex = index
                }
            }
        }

        onCurrentItemChanged: {
            if(folderModel.isFolder(currentIndex)) loadAlbum(folderModel.get(currentIndex, "fileUrl"))
        }

        model: folderModel
        delegate: fileDelegate
        highlight: Rectangle {radius: 4; color: "black"}
    }
}
