using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using Microsoft.SharePoint.WebControls;

namespace Indra.SGD.CustomControls.Autocomplete.LookupField
{
    /// <summary>
    /// A class representing the Autocomplete lookup control
    /// </summary>
    public partial class AutocompleteControl : UserControl
    {
        /// <summary>
        /// The path of jquery.min.js
        /// </summary>
        private const string jqueryScript = "/_layouts/15/Indra.SGD.CustomControls/JS/jquery.min.js";

        /// <summary>
        /// The path of jquery-ui.min.js
        /// </summary>
        private const string jqueryUIScript = "/_layouts/15/Indra.SGD.CustomControls/JS/jquery-ui.min.js";

        /// <summary>
        /// The path of jjquery-ui.css
        /// </summary>
        private const string jqueryCss = "/_layouts/15/Indra.SGD.CustomControls/CSS/jquery-ui.css";

        /// <summary>
        /// Gets or sets the name of the lookup list.
        /// </summary>
        /// <value>
        /// The name of the lookup list.
        /// </value>
        public string LookupListName { get; set; }

        /// <summary>
        /// Gets or sets the name of the lookup field.
        /// </summary>
        /// <value>
        /// The name of the lookup field.
        /// </value>
        public string LookupFieldName { get; set; }

        /// <summary>
        /// Gets or sets the site URL.
        /// </summary>
        /// <value>
        /// The site URL.
        /// </value>
        public string SiteUrl { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this instance is multi lookup.
        /// </summary>
        /// <value>
        /// 	<c>true</c> if this instance is multi lookup; otherwise, <c>false</c>.
        /// </value>
        public bool IsMultiLookup { get; set; }

        /// <summary>
        /// Gets or sets the filter.
        /// </summary>
        /// <value>
        /// The filter.
        /// </value>
        public string Filter { get; set; }

        /// <summary>
        /// Handles the Load event of the Page control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="System.EventArgs"/> instance containing the event data.</param>
        protected void Page_Load(object sender, EventArgs e)
        {

            ScriptLink.Register(this.Page, jqueryScript, false);
            ScriptLink.Register(this.Page, jqueryUIScript, false);
            CssRegistration.Register(jqueryCss);
        }

        /// <summary>
        /// Outputs server control content to a provided <see cref="T:System.Web.UI.HtmlTextWriter"/> object.
        /// </summary>
        /// <param name="writer">The <see cref="T:System.Web.UI.HTmlTextWriter"/> object that receives the control content.</param>
        public override void RenderControl(HtmlTextWriter writer)
        {
            base.RenderControl(writer);
        }
    }
}
