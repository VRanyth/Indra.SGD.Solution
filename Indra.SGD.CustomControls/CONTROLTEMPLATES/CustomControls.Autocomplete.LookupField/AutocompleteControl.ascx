<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AutocompleteControl.ascx.cs" Inherits="Indra.SGD.CustomControls.Autocomplete.LookupField.AutocompleteControl" %>
<style>
    .ui-autocomplete {
        max-height: 100px;
        overflow-y: auto;
        /* prevent horizontal scrollbar */
        overflow-x: hidden;
        /* add padding to account for vertical scrollbar */
        padding-right: 20px;
    }
    /* IE 6 doesn't support max-height
	 * we use height instead, but this forces the menu to always be this tall
	 */
    * html .ui-autocomplete {
        height: 100px;
    }

    .ui-autocomplete-loading {
        background: white url('/_layouts/15/Indra.SGD.CustomControls/Images/ui-anim_basic_16x16.gif') right center no-repeat;
    }
</style>

<script type="text/javascript">
    var availableIDs<%=autocomplete.ClientID%> = [];
    var listName<%=autocomplete.ClientID%> = "<%=LookupListName %>";
    var fieldName<%=autocomplete.ClientID%> = "<%=LookupFieldName %>";
    var isMultiLookup<%=autocomplete.ClientID%> = "<%=IsMultiLookup %>";
    var siteUrl = "<%=SiteUrl %>";
    function ExtractID<%=autocomplete.ClientID%>(selectedValue) {
        for (i = 0; i < availableIDs<%=autocomplete.ClientID%>.length; i++) {
            var valueId = availableIDs<%=autocomplete.ClientID%>[i];
            var leftBracketIndex = valueId.lastIndexOf("[")
            var value = valueId.substr(0, leftBracketIndex);
            if (selectedValue == value) {
                document.getElementById('<%=LookupIDs.ClientID%>').value += valueId + ";";
                break;
            }
        }
    }
    $(function () {

        function split(val) {
            return val.split(/;\s*/);
        }
        function extractLast(term) {
            return split(term).pop();
        }

        $("input#<%=autocomplete.ClientID%>")
			// don't navigate away from the field on tab when selecting an item
			.bind("keydown", function (event) {
			    if (event.keyCode === $.ui.keyCode.TAB &&
						$(this).data("autocomplete").menu.active) {
			        event.preventDefault();
			    }
			})
			.autocomplete({
			    source: function (request, response) {
			        var restServiceAddress = siteUrl + "/_vti_bin/ListData.svc/";
			        var term = extractLast(request.term);
			        var encodedTerm = encodeURIComponent(term);
			        if (encodedTerm.indexOf("'") >= 0) {
			            encodedTerm = encodedTerm.replace(/'/g, "''");
			        }
			        var requestUrl = restServiceAddress + listName<%=autocomplete.ClientID%> + "()" + "?$filter=startswith(" + fieldName<%=autocomplete.ClientID%> + ",'" + encodedTerm + "') <%=Filter%>&$select=" + fieldName<%=autocomplete.ClientID%> + ",Id";
			        $.ajax({
			            url: requestUrl,
			            dataType: "json",
			            dataFilter: function (data, type) {
			                return data.replace(/\\'/g, "'");
			            },
			            success: function (data) { 
			                response(jQuery.map(data.d.results, function (suggestion) {
			                    availableIDs<%=autocomplete.ClientID%>.push(suggestion[fieldName<%=autocomplete.ClientID%>] + "[" + suggestion.Id + "]");
			                    return suggestion[fieldName<%=autocomplete.ClientID%>];
			                }))
			            },
			            error: function (XMLHttpRequest, textStatus, errorThrown) {
			                alert(XMLHttpRequest.responseText);
			            }
			        });
			    },
			    search: function () {
			        // custom minLength
			        var term = extractLast(this.value);
			        if (term.length < 2) {
			            return false;
			        }
			    },
			    focus: function () {
			        // prevent value inserted on focus
			        return false;
			    },
			    select: function (event, ui) {
			        if (isMultiLookup<%=autocomplete.ClientID%>.toLowerCase() == "true") {
			            var terms = split(this.value);
			            // remove the current input
			            terms.pop();
			            // add the selected item
			            terms.push(ui.item.value);
			            ExtractID<%=autocomplete.ClientID%>(ui.item.value);
			            // add placeholder to get the comma-and-space at the end
			            terms.push("");
			            this.value = terms.join("; ");
			            return false;
                    }
                    else {
                        ExtractID<%=autocomplete.ClientID%>(ui.item.value);
			        }

			    }
			});
    });

</script>
<asp:TextBox ID="autocomplete" runat="server" CssClass="ms-long" />
<asp:HiddenField ID="LookupIDs" runat="server" Value="" />
<br />
