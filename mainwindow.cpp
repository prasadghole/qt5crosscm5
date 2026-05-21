#include "mainwindow.h"
#include <QMessageBox>

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent) {
    // Create a button centered in the window
    button = new QPushButton("Click Me!", this);
    button->setGeometry(320, 210, 160, 60);

    // Connect the button click to a popup message box
    connect(button, &QPushButton::clicked, this, [this]() {
        QMessageBox::information(this, "Success!", "Hello from your WSL Cross-Compiled App running on CM5!");
    });
}

MainWindow::~MainWindow() {
    // Qt handles memory cleanup for child widgets automatically
}