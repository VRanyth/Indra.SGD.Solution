var SGD = SGD || new Object();

SGD.LinkDocuments = {
    ListItemIds: new Array(),
    Id: 0,
    related: new Array(),
    item: new Object(),
    modalEditForm: function () {

        var ctx = SP.ClientContext.get_current();
        var web = ctx.get_web();
        var lists = web.get_lists();
        var items = SP.ListOperation.Selection.getSelectedItems(ctx);
        var listId = SP.ListOperation.Selection.getSelectedList();
        var list = lists.getById(listId);

        this.Id = items[0].id;

        this.item = list.getItemById(this.Id);

        ctx.load(this.item);

        ctx.executeQueryAsync(function () {

            SP.UI.ModalDialog.showModalDialog({
                url: SP.PageContextInfo.get_siteAbsoluteUrl() + "/_layouts/15/Indra.SGD.CustomActions/LinkDocuments.aspx?id=" + SGD.LinkDocuments.Id,
                allowMaximize: false,
                showClose: true,
                width: 800,
                height: 600,
                dialogReturnValueCallback: function (dialogResult, returnValue) {
                    if (dialogResult == SP.UI.DialogResult.OK) {
                        $.each(returnValue, function (index, value) {
                            SGD.LinkDocuments.create(SGD.LinkDocuments.Id, value);
                        });
                    }
                    else {
                        console.log('do nothing: close/cancel');
                    }
                }
            });
        }, function (sender, args) {
            console.log('Request failed. ' + args.get_message() + '\n' + args.get_stackTrace());
        });
    },
    create: function (parentId, childId) {

        var ctx = SP.ClientContext.get_current();
        var list = ctx.get_web().get_lists().getByTitle('LinkedDocuments');

        var itemCreateInfo = new SP.ListItemCreationInformation();
        var listItem = list.addItem(itemCreateInfo);

        listItem.set_item('ParentDocument', parentId);
        listItem.set_item('ChildDocument', childId);

        listItem.update();

        ctx.load(listItem);

        ctx.executeQueryAsync(
           function () {
               console.log('Item created: ' + listItem.get_id());
           },
           function onQueryFailed(sender, args) {
               console.log('Request failed. ' + args.get_message() + '\n' + args.get_stackTrace());
           }
       );
    },
    remove: function (id) {

        var ctx = SP.ClientContext.get_current();
        var list = ctx.get_web().get_lists().getByTitle('LinkedDocuments');

        this.listItem = list.getItemById(id);

        listItem.deleteObject();

        ctx.executeQueryAsync(
           function () {
               console.log('Item deleted: ' + id);
           },
           function (sender, args) {
               console.log('Request failed. ' + args.get_message() + '\n' + args.get_stackTrace());
           }
       );
    },
    getChildsByParentDocument: function (id, successFunc) {
        var that = this;
        var ctx = SP.ClientContext.get_current();
        var list = ctx.get_web().get_lists().getByTitle('LinkedDocuments');

        var camlQuery = new SP.CamlQuery();
        camlQuery.set_viewXml('<View><Query><Where><Eq><FieldRef Name="ParentDocument"/><Value Type="Number">' + id + '</Value></Eq></Where></Query><RowLimit>100</RowLimit></View>');

        that.listItems = list.getItems(camlQuery);

        ctx.load(that.listItems);

        ctx.executeQueryAsync(
            function () {
                SGD.LinkDocuments.related = new Array();
                var item = new Object();
                for (var i = 0; i < that.listItems.get_count() ; i++) {
                    item = new Object();
                    item.childDocument = that.listItems.get_item(i).get_item('ChildDocument');
                    item.ListItemId = that.listItems.get_item(i).get_id();
                    SGD.LinkDocuments.related.push(item);
                }
                successFunc(SGD.LinkDocuments.related);
            },
            function (sender, args) {
                console.log('Request failed. ' + args.get_message() + '\n' + args.get_stackTrace());
            }
        );
    }
},
SGD.LinkedDocuments = {
    Id: 0,
    modalEditForm: function () {

        var ctx = SP.ClientContext.get_current();
        var web = ctx.get_web();
        var lists = web.get_lists();
        var items = SP.ListOperation.Selection.getSelectedItems(ctx);
        var listId = SP.ListOperation.Selection.getSelectedList();
        var list = lists.getById(listId);

        this.Id = items[0].id;

        this.item = list.getItemById(this.Id);

        ctx.load(this.item);

        ctx.executeQueryAsync(function () {

            SP.UI.ModalDialog.showModalDialog({
                url: SP.PageContextInfo.get_siteAbsoluteUrl() + "/_layouts/15/Indra.SGD.CustomActions/LinkedDocuments.aspx?id=" + SGD.LinkedDocuments.Id,
                allowMaximize: false,
                showClose: true,
                width: 800,
                height: 600,
                dialogReturnValueCallback: function (dialogResult, returnValue) {
                    if (dialogResult == SP.UI.DialogResult.OK) {
                        $.each(returnValue, function (index, value) {
                            SGD.LinkDocuments.remove(value);
                        });
                    }
                    else {
                        console.log('do nothing: close/cancel');
                    }
                }
            });
        }, function (sender, args) {
            console.log('Request failed. ' + args.get_message() + '\n' + args.get_stackTrace());
        });
    }
}
SGD.genericFuncs = {
    layouts: {
        getIconFileType: function (fileType) {

            var layoutsUrl = "/_layouts/15/images/";

            switch (fileType) {
                case 'docx':
                    return layoutsUrl + "icdocx.png";
                case 'xlsx':
                    return layoutsUrl + "icxlsx.png";
                case 'pptx':
                    return layoutsUrl + "icpptx.png";
                case 'pdf':
                    return layoutsUrl + "icpdf.png";
                default:
                    return layoutsUrl + "icgen.png";
            }
        }
    },
    queryString: {
        getByName: function (name) {
            name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
            var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
                results = regex.exec(location.search);
            return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
        }
    },
    sharepoint: {
        executeOrDelay: function (sodScripts, onLoadAction) {
            if (SP.SOD.loadMultiple) {
                for (var x = 0; x < sodScripts.length; x++) {
                    //register any unregistered scripts
                    if (!_v_dictSod[sodScripts[x]]) {
                        SP.SOD.registerSod(sodScripts[x], '/_layouts/15/' + sodScripts[x]);
                    }
                }
                SP.SOD.loadMultiple(sodScripts, onLoadAction);
            } else
                ExecuteOrDelayUntilScriptLoaded(onLoadAction, sodScripts[0]);
        }
    }
}
