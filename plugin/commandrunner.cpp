#include "commandrunner.h"
#include <QProcess>

CommandRunner::CommandRunner(QObject *parent) : QObject(parent) {}

void CommandRunner::exec(const QString &command) {
    auto *p = new QProcess(this);
    connect(p, &QProcess::finished, this, [this, p, command](int exitCode) {
        emit done(command, exitCode,
            QString::fromUtf8(p->readAllStandardOutput()).trimmed());
        p->deleteLater();
    });
    p->start("/bin/sh", {"-c", command});
}
