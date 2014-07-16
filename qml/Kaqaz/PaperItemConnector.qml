import QtQuick 2.0

QtObject {
    id: connector

    property variant item

    property string title
    property string text

    property int modifyDate
    property int createDate
    property variant tags
    property variant attachments

    property string group
    property variant paperChilds
    property string paperParent

    property variant last_item

    onTitleChanged: if( item ) item.title = title
    onTextChanged: if( item ) item.text = text
    onModifyDateChanged: if( item ) item.modifyDate = modifyDate
    onCreateDateChanged: if( item ) item.createDate = createDate
    onTagsChanged: if( item ) item.tags = tags
    onAttachmentsChanged: if( item ) item.attachments = attachments
    onGroupChanged: if( item ) item.group = group
    onPaperChildsChanged: if( item ) item.paperChilds = paperChilds
    onPaperParentChanged: if( item ) item.paperParent = paperParent
    onItemChanged: refresh()
    Component.onCompleted: refresh()

    function refresh() {
        if( last_item ) {
            last_item.titleChanged.disconnect(connector._titleChanged)
            last_item.textChanged.disconnect(connector._textChanged)
            last_item.modifyDateChanged.disconnect(connector._modifyDateChanged)
            last_item.createDateChanged.disconnect(connector._createDateChanged)
            last_item.tagsChanged.disconnect(connector._tagsChanged)
            last_item.attachmentsChanged.disconnect(connector._attachmentsChanged)
            last_item.groupChanged.disconnect(connector._groupChanged)
            last_item.paperChildsChanged.disconnect(connector._paperChildsChanged)
            last_item.paperParentChanged.disconnect(connector._paperParentChanged)
        }

        if( item ) {
            item.titleChanged.connect(connector._titleChanged)
            item.textChanged.connect(connector._textChanged)
            item.modifyDateChanged.connect(connector._modifyDateChanged)
            item.createDateChanged.connect(connector._createDateChanged)
            item.tagsChanged.connect(connector._tagsChanged)
            item.attachmentsChanged.connect(connector._attachmentsChanged)
            item.groupChanged.connect(connector._groupChanged)
            item.paperChildsChanged.connect(connector._paperChildsChanged)
            item.paperParentChanged.connect(connector._paperParentChanged)
            last_item = item
        }

        last_item = item
    }

    function _titleChanged() {
        connector.title = item.title
    }
    function _textChanged() {
        connector.text = item.text
    }
    function _modifyDateChanged() {
        connector.modifyDate = item.modifyDate
    }
    function _createDateChanged() {
        connector.createDate = item.createDate
    }
    function _tagsChanged() {
        connector.tags = item.tags
    }
    function _attachmentsChanged() {
        connector.attachments = item.attachments
    }
    function _groupChanged() {
        connector.group = item.group
    }
    function _paperChildsChanged() {
        connector.paperChilds = item.paperChilds
    }
    function _paperParentChanged() {
        connector.paperParent = item.paperParent
    }
}
