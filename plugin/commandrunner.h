#pragma once
#include <QObject>
#include <QtQml/qqml.h>

class CommandRunner : public QObject {
    Q_OBJECT
    QML_ELEMENT
public:
    explicit CommandRunner(QObject *parent = nullptr);
    Q_INVOKABLE void exec(const QString &command);
signals:
    void done(const QString &command, int exitCode, const QString &output);
};
