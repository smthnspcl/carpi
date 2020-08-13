//
// Created by insane on 13.08.20.
//

#ifndef CARPI_QML_SETTINGS_H
#define CARPI_QML_SETTINGS_H

#include "Music/MusicSettings.h"
#include "Video/VideoSettings.h"

class Settings {
public:
    static void registerTypes(){
        MusicSettings::registerType();
        VideoSettings::registerType();
    }
};

#endif //CARPI_QML_SETTINGS_H
