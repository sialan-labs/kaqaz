/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "translationmodel.h"

#include <QHash>
#include <QMap>
#include <QFile>
#include <QRegExp>
#include <QList>
#include <QStringList>
#include <QDomDocument>
#include <QDebug>

class TranslationModelPrivate
{
public:
    QMap<QString,QString> translations;
    QHash<QString, QHash<QString, QHash<quint32,QString> > > paths;

    QString filePath;
    QDomDocument dom;
};

TranslationModel::TranslationModel(QObject *parent) :
    QAbstractListModel(parent)
{
    p = new TranslationModelPrivate;
}

void TranslationModel::setFile(const QString &path)
{
    if( p->filePath == path )
        return;

    p->filePath = path;
    emit fileChanged();
    refresh();
}

QString TranslationModel::file() const
{
    return p->filePath;
}

QString TranslationModel::id(const QModelIndex &index) const
{
    int row = index.row();
    QMapIterator<QString,QString> i(p->translations);
    while( row >= 0 && i.hasNext() )
    {
        i.next();
        row--;
    }

    return i.key();
}

int TranslationModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return p->translations.count();
}

QVariant TranslationModel::data(const QModelIndex &index, int role) const
{
    const QString & key = id(index);
    QVariant res;
    switch( role )
    {
    case Qt::DisplayRole:
        res = key;
        break;
    }

    return res;
}

void TranslationModel::refresh()
{
    if( !QFile::exists(p->filePath) )
        return;

    QFile file(p->filePath);
    if( !file.open(QFile::ReadOnly) )
        return;

    QString errorStr;
    int errorLine;
    int errorColumn;

    if(!p->dom.setContent(&file, true, &errorStr, &errorLine, &errorColumn))
    {
        qDebug() << QString("Parse error at line %1, column %2:\n%3").arg(errorLine).arg(errorColumn).arg(errorStr);
        return;
    }

    QDomElement root = p->dom.documentElement();
    if(root.tagName() != "TS")
    {
        qDebug() << QString("The file is not an TS file.");
        return;
    }
    else
    if(root.hasAttribute("version") && root.attribute("version") < "2.0")
    {
        qDebug() << QString("The file has old version.");
        return;
    }

    QDomElement child = root.firstChildElement("context");
    while (!child.isNull())
    {
        parseFolderElement(child);
        child = child.nextSiblingElement("context");
    }
}

void TranslationModel::parseFolderElement(const QDomElement &element)
{
    const QString & name = element.firstChildElement("name").text();

    QDomElement child = element.firstChildElement();
    while (!child.isNull())
    {
        if (child.tagName() == "context")
        {
            parseFolderElement(child);
        }
        else
        if (child.tagName() == "message")
        {
            const QDomElement domLocation = child.firstChildElement("location");
            const QString & fileName = domLocation.attribute("filename");
            const QString & lineNumber = domLocation.attribute("line");

            const QString & originalText = child.firstChildElement("source").text();
            const QString & translatedText = child.firstChildElement("translation").text();

            p->paths[name][fileName][lineNumber.toUInt()] = originalText;
            p->translations[originalText] = translatedText;
        }

        child = child.nextSiblingElement();
    }
}

TranslationModel::~TranslationModel()
{
    delete p;
}
