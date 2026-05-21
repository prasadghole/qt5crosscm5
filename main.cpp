#include <QApplication>
#include "mainwindow.h"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    
    MainWindow window;
    window.resize(800, 480); // Standard resolution for many Pi displays
    window.setWindowTitle("Raspberry Pi CM5 Qt5 Cross-Compiled App");
    window.show();
    
    return app.exec();
}