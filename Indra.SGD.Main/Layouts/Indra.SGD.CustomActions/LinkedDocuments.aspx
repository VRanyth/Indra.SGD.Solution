<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Import Namespace="Microsoft.SharePoint.ApplicationPages" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LinkedDocuments.aspx.cs" Inherits="Indra.SGD.Main.LinkedDocuments" DynamicMasterPageFile="~masterurl/default.master" %>

<asp:Content ID="PageHead" ContentPlaceHolderID="PlaceHolderAdditionalPageHead" runat="server">
</asp:Content>

<asp:Content ID="Main" ContentPlaceHolderID="PlaceHolderMain" runat="server">
    <script type="text/javascript">

        $(document).ready(function () {

            SGD.genericFuncs.sharepoint.executeOrDelay(["sp.js", "sp.search.js"], function () {

                SGD.LinkDocuments.getChildsByParentDocument(SGD.genericFuncs.queryString.getByName('id'), function (array) {

                    var queryText = "IsDocument:1 parentlink:Documentos";

                    console.log("ListItemId: " + SGD.genericFuncs.queryString.getByName('id'));

                    var clientContext = new SP.ClientContext(SP.PageContextInfo.get_siteAbsoluteUrl());
                    var query = new Microsoft.SharePoint.Client.Search.Query.KeywordQuery(clientContext);

                    $.each(array, function (index, value) {
                        queryText += " ListItemId:" + value.childDocument;
                    });
                    query.set_queryText(queryText);

                    var propertiesArray = ['Title', 'ListItemId', 'Author', 'Write', 'FileType', 'DocId'];
                    var properties = query.get_selectProperties();
                    for (var i = 0; i < propertiesArray.length; i++) {
                        properties.add(propertiesArray[i]);
                    }

                    var searchExecutor = new Microsoft.SharePoint.Client.Search.Query.SearchExecutor(clientContext);
                    var results = searchExecutor.executeQuery(query);
                    clientContext.executeQueryAsync(onQuerySuccess, onQueryFail);

                    function onQuerySuccess() {
                        if (results.m_value.ResultTables) {
                            $.each(results.m_value.ResultTables, function (index, table) {
                                if (table.TableType == "RelevantResults") {

                                    $.each(results.m_value.ResultTables[index].ResultRows, function () {

                                        var that = this;
                                        var date = new Date(this.Write);
                                        var entryId = '';

                                        $.each(SGD.LinkDocuments.related, function (index, value) {
                                            if (value.childDocument === parseInt(that.ListItemId))
                                                entryId = value.ListItemId;
                                        });
                                        
                                        $("#tableResults tbody").append(
                                            "<tr class='ms-alternating  ms-itmHoverEnabled ms-itmhover'>" +
                                              "<td class='ms-cellStyleNonEditable ms-vb-itmcbx ms-vb-imgFirstCell' tabindex='0'><div role='checkbox' class='s4-itm-cbx s4-itm-imgCbx' tabindex='-1' title='Doc1' aria-checked='false'><span class='s4-itm-imgCbx-inner'><span class='ms-selectitem-span'><img class='ms-selectitem-icon' alt='' src='/_layouts/15/images/spcommon.png?rev=23'></span></span></div></td>" +
                                              "<td class='ms-cellstyle ms-vb2'><img width='16' height='16' border='0' src='" + SGD.genericFuncs.layouts.getIconFileType(this.FileType) + "'/></td>" +
                                              "<td class='ms-cellstyle ms-vb2'>" + this.Title + "</td>" +
                                              "<td class='ms-cellstyle ms-vb2'>" + this.Author + "</td>" +
                                              "<td class='ms-cellstyle ms-vb2'>" + date.format("dd-MM-yyyy HH:mm") + "</td>" +
                                              "<td><input type='hidden' name='ListItemId' value='" + this.ListItemId + "'/></td>" +
                                              "<td><input type='hidden' name='entryId' value='" + entryId + "'/></td>" +
                                            "</tr>");
                                    });

                                    $("#tableResults tbody tr td.ms-vb-imgFirstCell").on('click', function (e) {
                                        $(this.parentElement).toggleClass('s4-itm-selected');

                                        if ($(this.parentElement).hasClass('s4-itm-selected')) {
                                            var id = $(this.parentNode.cells[this.parentNode.cells.length - 1]).find('input').val();
                                            console.log("You've selected ListItemId: " + id);
                                        }
                                        else {
                                            var id = $(this.parentNode.cells[this.parentNode.cells.length - 1]).find('input').val();
                                            console.log("You've unselected ListItemId: " + id);
                                        }
                                    });
                                }
                            });
                        }
                    }
                });


                SGD.LinkDocuments.Items = [];

                $("#tableResults tr th.ms-vb-imgFirstCell").on('click', function (e) {
                    var i = 0;
                    $.each($("#tableResults tbody tr"), function (index, value) {
                        if ($(value).hasClass("s4-itm-selected"))
                            i++;
                    });

                    if (i < $("#tableResults tbody tr").length)
                        $("#tableResults tbody tr").addClass('s4-itm-selected');

                    else
                        $("#tableResults tbody tr").removeClass('s4-itm-selected');
                    e.preventDefault();
                });

                $("#btnModalConfirm").on('click', function (e) {
                    $.each($("#tableResults tbody tr"), function (index, value) {
                        if ($(this).hasClass('s4-itm-selected')) {
                            SGD.LinkDocuments.ListItemIds.push($(value.cells[value.cells.length - 1]).find('input').val());
                        }
                    });

                    SP.UI.ModalDialog.commonModalDialogClose(SP.UI.DialogResult.OK, SGD.LinkDocuments.ListItemIds); return false;
                });

                function onQueryFail(args) {
                    alert('Query failed. Error:' + args.get_message());
                }
            });
        });

    </script>

    <div style="height: 480px;">
        <div class="modal-mainDiv-border">
            <div id="resultsDiv">
                <table width="100%" id="tableResults" border="0" cellspacing="0" dir="none" cellpadding="1" class="ms-listviewtable">
                    <thead>
                        <tr style="text-align: left;" valign="top" class="ms-viewheadertr ms-vhltr">
                            <th class='ms-vb2 ms-cellStyleNonEditable ms-vb-itmcbx ms-vb-imgFirstCell' style="border-right-width: 0px; width: 20px;">
                                <div role='checkbox' class='s4-itm-cbx s4-itm-imgCbx'>
                                    <span class='s4-itm-imgCbx-inner'><span class='ms-selectitem-span'>
                                        <img class='ms-selectitem-icon' alt='' src='/_layouts/15/images/spcommon.png?rev=23'></span></span>
                                </div>
                            </th>
                            <th class='ms-vb2'>
                                <img width='16' height='16' border='0' src='/_layouts/15/images/icgen.gif' /></th>
                            <th class="ms-vh2">Documento</th>
                            <th class="ms-vh2">Criado Por</th>
                            <th class="ms-vh2">Criado a</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
		 <div style="position: absolute; bottom: 30px; right: 30px;">
            <input id="btnModalConfirm" type="button" value="OK" class="ms-ButtonHeightWidth" />
        </div>
    </div>
</asp:Content>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PlaceHolderPageTitle" runat="server">
    Documentos Associados
</asp:Content>

<asp:Content ID="PageTitleInTitleArea" ContentPlaceHolderID="PlaceHolderPageTitleInTitleArea" runat="server">
    Página Documentos Associados
</asp:Content>
