//
// Created by insane on 11.07.20.
//

#include "ModuleLoader.h"

ModuleLoader::ModuleLoader(const QString &directory)
{
    this->directory = directory;
    libraries = QList<QLibrary*>();
    widgets = QList<QPair<QWidget*, QString>*>();
}

ModuleLoader::~ModuleLoader()
{
    for(auto *lib : libraries) delete lib;
    for(auto *p : widgets) delete p;
}

QLibrary* ModuleLoader::load(const QString &name)
{
    auto *lib = new QLibrary(name.toStdString().c_str());
    if(lib->load()) {
        Logger::debug("ModuleLoader", "loaded '" + name + "'");
        return lib;
    } else {
        Logger::warning("ModuleLoader", "unable to load '" + name + "'");
        Logger::error("ModuleLoader", lib->errorString());
    }
    return nullptr;
}

void ModuleLoader::loadAll(){
    QDir dir(this->directory.toStdString().c_str());
    Logger::debug("ModuleLoader", "loading modules from: " + dir.absolutePath());
    for(const auto& f : dir.entryList(QStringList() << "*.so", QDir::Files))
        this->libraries.append(this->load(dir.absoluteFilePath(f)));

    for(QLibrary *lib : libraries)
        widgets.insert(ModuleLoader::getDefaultIndex(lib), new QPair<QWidget*, QString>(ModuleLoader::getWidget(lib), ModuleLoader::getName(lib)));
}

QList<QPair<QWidget*, QString>*> ModuleLoader::getWidgets() {
    return widgets;
}

QString ModuleLoader::getName(QLibrary *lib) {
    return executeReturn<char*>(lib, "getName");
}

QWidget *ModuleLoader::getWidget(QLibrary *lib) {
    return executeReturn<QWidget*>(lib, "create");
}

template<typename R>
R ModuleLoader::executeReturn(QLibrary *lib, const QString& functionName) {
    typedef R (*Function)();
    Function f = (Function) lib->resolve(functionName.toStdString().c_str());
    if(!f) qDebug() << lib->errorString();
    return f();
}

int ModuleLoader::getDefaultIndex(QLibrary *lib) {
    return executeReturn<int>(lib, "getDefaultIndex");
}

QList<QString> *ModuleLoader::getNames() {
    auto *r = new QList<QString>();
    for(auto p : widgets) r->append(p->second);
    return r;
}

QStringList ModuleLoader::getOptions(QLibrary *lib) {
    return executeReturn<QStringList>(lib, "getSettingsKeys");
}
