using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using Microsoft.SharePoint.WebControls;
using Microsoft.SharePoint;
using System.Collections.Generic;
using System.Web;
using System.IO;
using System.Linq;
using Indra.SGD.CustomControls.Fields;

namespace Indra.SGD.CustomControls.Autocomplete.LookupField
{
    /// <summary>
    /// This class represents the field editor of Autocomplete Lookup field
    /// </summary>
    public partial class AutocompleteLookupFieldEditor : UserControl, IFieldEditor
    {
        protected AutocompleteLookupField autocompleLookupField;
        private IFieldEditor lookupEditor;

        /// <summary>
        /// Handles the Load event of the Page control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="System.EventArgs"/> instance containing the event data.</param>
        protected void Page_Load(object sender, EventArgs e)
        {

            EnsureChildControls();
        }

        /// <summary>
        /// Initializes the field property editor when the page loads.
        /// </summary>
        /// <param name="field">An object that instantiates a custom field (column) class that derives from the <see cref="T:Microsoft.SharePoint.SPField"/> class.</param>
        public void InitializeWithField(SPField field)
        {
            EnsureChildControls();
            lookupEditor.InitializeWithField(field);
            if (field == null || Page.IsPostBack) return;
            autocompleLookupField = field as AutocompleteLookupField;
            filterTextBox.Text = autocompleLookupField.GetFieldAttribute("Filter");

            var lookupField = field as SPFieldLookup;
            if (lookupField == null) return;
        }

        /// <summary>
        /// Called by the ASP.NET page framework to notify server controls that use composition-based implementation to create any child controls they contain in preparation for posting back or rendering.
        /// </summary>
        protected override void CreateChildControls()
        {
            base.CreateChildControls();

            lookupEditor = lookupFieldEditor as IFieldEditor;
        }

        /// <summary>
        /// Validates and saves the changes the user has made in the field property editor control.
        /// </summary>
        /// <param name="field">The field (column) whose properties are being saved.</param>
        /// <param name="isNewField">true to indicate that the field is being created; false to indicate that an existing field is being modified.</param>
        public void OnSaveChange(SPField field, bool isNewField)
        {
            EnsureChildControls();

            lookupEditor.OnSaveChange(field, isNewField);
            autocompleLookupField = field as AutocompleteLookupField;
            autocompleLookupField.SetFieldAttribute("Filter", filterTextBox.Text);
        }

        /// <summary>
        /// Gets a value that indicates whether the field property editor should be in a special section on the page.
        /// </summary>
        /// <returns>true if the editor should be in its own section; otherwise, false. </returns>
        public bool DisplayAsNewSection
        {
            get
            {
                EnsureChildControls();

                return lookupEditor.DisplayAsNewSection;
            }
        }
    }
}
