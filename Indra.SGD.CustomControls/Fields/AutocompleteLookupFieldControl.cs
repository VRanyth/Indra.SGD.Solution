using Indra.SGD.CustomControls.Autocomplete.LookupField;
using Microsoft.SharePoint;
using Microsoft.SharePoint.WebControls;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI.WebControls;

namespace Indra.SGD.CustomControls.Fields
{
    class AutocompleteLookupFieldControl : BaseFieldControl
    {
        /// <summary>
        /// Holds lookup values.
        /// </summary>
        protected TextBox lookupEditor;

        /// <summary>
        /// Stores the IDs of lookups
        /// </summary>
        protected HiddenField lookupIDs;

        /// <summary>
        /// The path of Autocomplete lookup ascx file.
        /// </summary>
        private const string autocompleteAscxPath = @"~/_CONTROLTEMPLATES/15/CustomControls.Autocomplete.LookupField/AutocompleteControl.ascx";

        /// <summary>
        /// Gets or sets the filter.
        /// </summary>
        /// <value>
        /// The filter.
        /// </value>
        public string Filter { get; set; }

        /// <summary>
        /// Collection to hold lookup values.
        /// </summary>
        SPFieldLookupValueCollection lookups = new SPFieldLookupValueCollection();

        /// <summary>
        /// Represents the method that handles the <see cref="E:System.Web.UI.Control.Load"/> event of a <see cref="T:Microsoft.SharePoint.WebControls.FieldMetadata"/> object.
        /// </summary>
        /// <param name="e">An <see cref="T:System.EventArgs"/> that contains the event data.</param>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            if (this.ControlMode == SPControlMode.New && this.Page.IsPostBack == false)
                this.SetFieldControlValue(null);
        }



        /// <summary>
        /// Initializes the lookups.
        /// </summary>
        private void InitializeLookups()
        {
            string[] lookupValues = this.lookupEditor.Text.Split(new char[] { ';' }, StringSplitOptions.RemoveEmptyEntries);
            string[] lookupHiddenValues = this.lookupIDs.Value.Split(new char[] { ';' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (string lookupValue in lookupValues)
            {
                foreach (string lookupHiddenValue in lookupHiddenValues)
                {
                    if (!string.IsNullOrEmpty(lookupHiddenValue.Trim()))
                    {
                        int leftBracketIndex = lookupHiddenValue.LastIndexOf("[");
                        string value = lookupHiddenValue.Substring(0, leftBracketIndex);
                        if (value.Trim().Equals(lookupValue.Trim()))
                        {
                            int rightBracketIndex = lookupHiddenValue.LastIndexOf("]");
                            string ID = lookupHiddenValue.Substring(leftBracketIndex + 1, rightBracketIndex - leftBracketIndex - 1);
                            lookups.Add(new SPFieldLookupValue(int.Parse(ID), string.Empty));
                            break;
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Gets or sets the value of the field in the UI.
        /// </summary>
        /// <returns>When overridden in a derived class, a <see cref="T:System.Object"/> that represents the value of the field in the UI. </returns>
        public override object Value
        {
            get
            {
                this.EnsureChildControls();
                AutocompleteLookupField lookupFieldPicker = (AutocompleteLookupField)this.Field;
                InitializeLookups();
                if (lookupFieldPicker.AllowMultipleValues)
                {
                    return lookups;
                }
                else
                {
                    if (lookups.Count > 0)
                    {
                        return lookups[0];
                    }
                    else
                    {
                        return null;
                    }
                }
            }

            set
            {
                this.EnsureChildControls();
                this.SetFieldControlValue(value);
            }
        }

        /// <summary>
        /// Creates any child controls necessary to render the field, such as a label control, link control, or text box control.
        /// </summary>
        protected override void CreateChildControls()
        {
            AutocompleteLookupField lookupFieldPicker = (AutocompleteLookupField)this.Field;

            using (SPWeb web = Web.Site.OpenWeb(lookupFieldPicker.LookupWebId))
            {
                SPList lookupList = web.Lists[new Guid(lookupFieldPicker.LookupList)];
                AutocompleteControl control = Page.LoadControl(autocompleteAscxPath) as AutocompleteControl;
                Controls.Add(control);
                this.lookupEditor = control.FindControl("autocomplete") as TextBox;
                this.lookupIDs = control.FindControl("LookupIDs") as HiddenField;
                string lookupListName = lookupList.Title;
                StringBuilder listBuilder = ValidateListOrFieldName(lookupListName);
                lookupListName = listBuilder.ToString();
                control.LookupListName = lookupListName;
                string internalFieldName = ((SPFieldLookup)(lookupFieldPicker)).LookupField;
                string lookupFieldName = lookupList.Fields.GetField(internalFieldName).Title;
                StringBuilder fieldBuilder = ValidateListOrFieldName(lookupFieldName);
                lookupFieldName = fieldBuilder.ToString();
                control.LookupFieldName = lookupFieldName;
                control.SiteUrl = web.Url;
                control.Filter = Filter ?? lookupFieldPicker.GetFieldAttribute("Filter");
                if (lookupFieldPicker.AllowMultipleValues)
                {
                    control.IsMultiLookup = true;
                }
                else
                {
                    control.IsMultiLookup = false;
                }
            }

            base.CreateChildControls();
        }

        /// <summary>
        /// Validates the given list or fieldname
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        private StringBuilder ValidateListOrFieldName(string name)
        {
            // Step 1. Get rid of all spaces. The first letter of each split word should be capital.
            // Step 2. all characters except letter/digit is to be considered as space.
            StringBuilder builder = new StringBuilder();
            bool isNonLetterOrDigit = false;
            int characterCount = 0;
            char[] title = name.ToCharArray();
            foreach (var character in title)
            {
                if (char.IsLetterOrDigit(character))
                {
                    if (isNonLetterOrDigit || characterCount == 0)
                    {
                        isNonLetterOrDigit = false;
                        builder.Append(character.ToString().ToUpper());
                    }
                    else
                    {
                        builder.Append(character.ToString());
                    }
                }
                else
                {
                    isNonLetterOrDigit = true;
                }
                characterCount++;
            }

            return builder;
        }

        /// <summary>
        /// Sets the field control value.
        /// </summary>
        /// <param name="value">The value.</param>
        private void SetFieldControlValue(object value)
        {
            this.lookupEditor.Text = string.Empty;
            AutocompleteLookupField lookupFieldPicker = (AutocompleteLookupField)this.Field;
            if (this.ControlMode == SPControlMode.New && lookupEditor.Text.Length == 0)
            {
                //string strValue = ParseDefaultValue(lookupFieldPicker.CustomDefaultValue);

                //if (strValue == null)
                return;

            }
            else
            {
                if (value == null || value.ToString() == "")
                    return;

                if (lookupFieldPicker.AllowMultipleValues)
                {
                    SPFieldLookupValueCollection lookupValues = value as SPFieldLookupValueCollection;
                    foreach (SPFieldLookupValue lookupValue in lookupValues)
                    {
                        string text = new SPFieldLookupValue(lookupValue.ToString()).LookupValue;
                        this.lookupEditor.Text += text + "; ";

                        int ID = new SPFieldLookupValue(lookupValue.ToString()).LookupId;

                        this.lookupIDs.Value += text + "[" + ID + "]" + "; ";
                    }
                }
                else
                {
                    SPFieldLookupValue lookupValue = value as SPFieldLookupValue;
                    this.lookupEditor.Text = lookupValue.LookupValue;
                    this.lookupIDs.Value = this.lookupEditor.Text + "[" + lookupValue.LookupId + "]";
                }
            }
        }

        /// <summary>
        /// Verifies that the value of <see cref="P:Microsoft.SharePoint.WebControls.BaseFieldControl.Value"/> meets all restrictions on field content such as length, format, and data type.
        /// </summary>
        public override void Validate()
        {
            if (base.ControlMode != SPControlMode.Display)
            {
                EnsureChildControls();

                base.Validate();

                object val = this.Value;
                if (base.IsValid == true && val == null)
                {
                    if (base.Field.Required)
                    {
                        IsValid = false;
                        ErrorMessage = SPResource.GetString("MissingRequiredField", new object[0]);
                    }
                }
            }
        }
    }
}
