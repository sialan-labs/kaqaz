#ifndef PAPERMANAGER_H
#define PAPERMANAGER_H

#include <QQuickItem>
#include <QStringList>

class Kaqaz;
class PaperManagerPrivate;
class PaperManager : public QQuickItem
{
    Q_PROPERTY(int root READ root WRITE setRoot NOTIFY rootChanged)
    Q_PROPERTY(int type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(QString keyword READ keyword WRITE setKeyword NOTIFY keywordChanged)
    Q_PROPERTY(QQuickItem *currentPaper READ currentPaper NOTIFY currentPaperChanged)
    Q_PROPERTY(QList<int> papers READ papers NOTIFY papersChanged)
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)
    Q_ENUMS(Type)

    Q_OBJECT
public:
    enum Type {
        Group,
        Date,
        Search,
        Clean
    };

    PaperManager(QQuickItem *parent = 0);
    ~PaperManager();

    void setRoot( int id );
    int root() const;

    void setType( int t );
    int type() const;

    void setKeyword( const QString & kw );
    QString keyword() const;

    QQuickItem *currentPaper() const;

    QList<int> papers() const;

    void setCurrentIndex( int idx );
    int currentIndex();

public slots:
    bool hideCurrentAttachments();

signals:
    void rootChanged();
    void typeChanged();
    void keywordChanged();
    void currentPaperChanged();
    void papersChanged();
    void currentIndexChanged();

private slots:
    QQuickItem *createPaper();
    Kaqaz *getKaqaz();

    void init_buffer();
    void reindexBuffer();
    void load_buffers();

    void paperClosed(const QVariant &var);
    void paperEntered(const QVariant &var);
    void paperSaved(int id);

    void deletePaper(const QVariant &var );

    void outMove(QVariant size );
    void outMoveFinished();

private:
    PaperManagerPrivate *p;
};

#endif // PAPERMANAGER_H
