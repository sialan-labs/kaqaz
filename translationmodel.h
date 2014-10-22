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

#ifndef TRANSLATIONMODEL_H
#define TRANSLATIONMODEL_H

#include <QAbstractListModel>

class QDomElement;
class TranslationModelPrivate;
class TranslationModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString file READ file WRITE setFile NOTIFY fileChanged)
public:
    TranslationModel(QObject *parent = 0);
    ~TranslationModel();

    void setFile( const QString & path );
    QString file() const;

    QString id( const QModelIndex &index ) const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

public slots:
    void refresh();

signals:
    void fileChanged();

private:
    void parseFolderElement(const QDomElement &element);

private:
    TranslationModelPrivate *p;
};

#endif // TRANSLATIONMODEL_H
