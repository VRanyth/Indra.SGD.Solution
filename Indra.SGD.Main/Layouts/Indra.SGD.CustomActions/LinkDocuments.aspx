<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Import Namespace="Microsoft.SharePoint.ApplicationPages" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LinkDocuments.aspx.cs" Inherits="Indra.SGD.Main.LinkDocuments" DynamicMasterPageFile="~masterurl/default.master" %>

<asp:Content ID="PageHead" ContentPlaceHolderID="PlaceHolderAdditionalPageHead" runat="server">
    <style type="text/css">
       
    </style>
</asp:Content>

<asp:Content ID="Main" ContentPlaceHolderID="PlaceHolderMain" runat="server">

    <script type="text/javascript">

        $(document).ready(function () {

            var watermark = 'Pesquisar Documentos';

            $('#customSearchBox').blur(function () {
                if ($(this).val().length == 0)
                    $(this).val(watermark).addClass('watermark');
            }).focus(function () {
                if ($(this).val() == watermark)
                    $(this).val('').removeClass('watermark');
            }).val(watermark).addClass('watermark');

            $("#resultsDiv").hide();

            $("#customInputAnchor").on('click', function (e) {

                $("#loading").attr("style", "display: inline-block; vertical-align: bottom;");

                SGD.genericFuncs.sharepoint.executeOrDelay(["sp.js", "sp.search.js"], function () {

                    console.log("ListItemId: " + SGD.genericFuncs.queryString.getByName('id'));

                    var clientContext = new SP.ClientContext(SP.PageContextInfo.get_siteAbsoluteUrl());

                    var query = new Microsoft.SharePoint.Client.Search.Query.KeywordQuery(clientContext);

                    query.set_queryText("IsDocument:1 parentlink:Documentos " + $("#customSearchBox").val());

                    var propertiesArray = ['Title', 'ListItemId', 'Author', 'Write', 'FileType', 'DocId'];

                    var properties = query.get_selectProperties();

                    for (var i = 0; i < propertiesArray.length; i++) {
                        properties.add(propertiesArray[i]);
                    }

                    var searchExecutor = new Microsoft.SharePoint.Client.Search.Query.SearchExecutor(clientContext);

                    var results = searchExecutor.executeQuery(query);

                    clientContext.executeQueryAsync(onQuerySuccess, onQueryFail);

                    function onQuerySuccess() {

                        $("#tableResults tbody").empty();

                        var showGrid = true;
                        if (results.m_value.ResultTables.length) {
                            if (!results.m_value.ResultTables[0].ResultRows.length) {
                                $("#resultsDiv").hide();
                                showGrid = false;
                            }
                        }

                        if (results.m_value.ResultTables) {
                            $.each(results.m_value.ResultTables, function (index, table) {
                                if (table.TableType == "RelevantResults") {

                                    SP.SOD.executeFunc('sp.js', 'SP.ClientContext', function () {

                                        SGD.LinkDocuments.getChildsByParentDocument(SGD.genericFuncs.queryString.getByName('id'), function (array) {

                                            $.each(results.m_value.ResultTables[index].ResultRows, function () {

                                                var date = new Date(this.Write);
                                                if (array.indexOf(parseInt(this.ListItemId)) == -1) {
                                                    if (SGD.genericFuncs.queryString.getByName('id') != this.ListItemId)
                                                        $("#tableResults tbody").append(
                                                            "<tr class='ms-alternating  ms-itmHoverEnabled ms-itmhover'>" +
                                                              "<td class='ms-cellStyleNonEditable ms-vb-itmcbx ms-vb-imgFirstCell' tabindex='0'><div role='checkbox' class='s4-itm-cbx s4-itm-imgCbx' tabindex='-1' title='Doc1' aria-checked='false'><span class='s4-itm-imgCbx-inner'><span class='ms-selectitem-span'><img class='ms-selectitem-icon' alt='' src='/_layouts/15/images/spcommon.png?rev=23'></span></span></div></td>" +
                                                              "<td class='ms-cellstyle ms-vb2'><img width='16' height='16' border='0' src='" + SGD.genericFuncs.layouts.getIconFileType(this.FileType) + "'/></td>" +
                                                              "<td class='ms-cellstyle ms-vb2'>" + this.Title + "</td>" +
                                                              "<td class='ms-cellstyle ms-vb2'>" + this.Author + "</td>" +
                                                              "<td class='ms-cellstyle ms-vb2'>" + date.format("dd-MM-yyyy HH:mm") + "</td>" +
                                                              "<td><input type='hidden' name='ListItemId' value='" + this.ListItemId + "'/></td>" +
                                                            "</tr>");
                                                }
                                            });

                                            $("#loading").attr("style", "display: none; vertical-align: bottom;");

                                            if ($("#tableResults tbody tr").length)
                                                $("#resultsDiv").show();

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
                                        })
                                    });
                                }
                            });
                        }
                    }

                    function onQueryFail(args) {
                        console.log('Query failed. Error:' + args.get_message());
                    }
                });
            });

            $("#customSearchBox").keyup(function (event) {
                if (event.keyCode == 13) {
                    $("#customInputAnchor").click();
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

            SGD.genericFuncs.sharepoint.executeOrDelay(["sp.js"], function () {
                var loaderSrc = SP.PageContextInfo.get_siteAbsoluteUrl() + "/Style%20Library/Indra/Images/loader.gif";
                $("#loader").attr("src", loaderSrc);
            });
        });

    </script>
    <div style="height: 480px;">
        <div class="modal-mainDiv-border">
            <div class="ms-srch-sb ms-srch-sb-border" style="margin-bottom: 20px;" id="ctl00_PlaceHolderSearchArea_SmallSearchInputBox1_csr_sboxdiv">
                <input id="customSearchBox" type="text" maxlength="2048" accesskey="S" title="Pesquisar Documentos" onkeydown="" onfocus="" onblur="" class="ms-textSmall ms-srch-sb-prompt ms-helperText">
                <div id="loading" style="display: none; vertical-align: bottom;">
                    <img id="loader" src="" alt="Loading" />
                </div>
                <a title="Procurar" class="ms-srch-sb-searchLink" id="customInputAnchor">
                    <img src="/_layouts/15/images/searchresultui.png?rev=23" class="ms-srch-sb-searchImg" id="searchImgCustom" alt="Procurar">
                </a>
            </div>
            <br>
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
    Associar Documentos
</asp:Content>

<asp:Content ID="PageTitleInTitleArea" ContentPlaceHolderID="PlaceHolderPageTitleInTitleArea" runat="server">
    Página Associar Documentos
</asp:Content>
