using Microsoft.SharePoint;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.SharePoint.WebControls;
using System.Reflection;


namespace Indra.SGD.CustomControls.Fields
{
    public class AutocompleteLookupField : SPFieldLookup
    {
        internal SPFieldCollection fields;

        //Point to a dummy js file.
        private const string JSLinkUrl = "~/_LAYOUTS/15/Indra.SGD.CustomControls/JS/dummy.js";
        /// <summary>
        /// Initializes a new instance of the <see cref="AutocompleteLookupField"/> class.
        /// </summary>
        /// <param name="fields">The fields.</param>
        /// <param name="fieldName">Name of the field.</param>
        public AutocompleteLookupField(SPFieldCollection fields, string fieldName)
            : base(fields, fieldName)
        {
            this.fields = fields;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="AutocompleteLookupField"/> class.
        /// </summary>
        /// <param name="fields">An <see cref="T:Microsoft.SharePoint.SPFieldCollection"/> object that represents the field collection.</param>
        /// <param name="typeName">A string that contains the name of the field type, which can be a string representation of an <see cref="T:Microsoft.SharePoint.SPFieldType"/> value.</param>
        /// <param name="displayName">A string that contains the display name of the field.</param>
        public AutocompleteLookupField(SPFieldCollection fields, string typeName, string displayName)
            : base(fields, typeName, displayName)
        {
            this.fields = fields;
        }

        /// <summary>
        /// Gets or sets the custom default value.
        /// </summary>
        /// <value>
        /// The custom default value.
        /// </value>
        public string CustomDefaultValue
        {
            get
            {
                object obj = this.GetFieldAttribute("CustomDefaultValue");
                if (obj == null)
                    return "";
                else
                    return obj.ToString();
            }
            set
            {
                if (value == null)
                    SetFieldAttribute("CustomDefaultValue", "");
                else
                    SetFieldAttribute("CustomDefaultValue", value.ToString());
            }
        }

        /// <summary>
        /// Gets or sets a Boolean value that specifies whether multiple values can be used in the lookup field.
        /// </summary>
        /// <returns>true to specify that multiple values can be used in the field; otherwise, false.</returns>
        public override bool AllowMultipleValues
        {
            get
            {
                return base.AllowMultipleValues;
            }
            set
            {
                base.AllowMultipleValues = value;
                if (value == true)
                    this.SetFieldAttribute("Type", "AutocompleteMultiLookup");
                else
                    this.SetFieldAttribute("Type", "AutocompleteLookup");
            }
        }

        /// <summary>
        /// Used for data serialization logic and for field validation logic that is specific to a custom field type to convert the field value object into a validated, serialized string.
        /// </summary>
        /// <param name="value">An object that represents the value object to convert.</param>
        /// <returns>
        /// A string that serializes the value object.
        /// </returns>
        public override string GetValidatedString(object value)
        {
            if (string.IsNullOrEmpty(value.ToString()) && this.Required)
            {
                throw new SPFieldValidationException(SPResource.GetString("MissingRequiredField", new object[0]));
            }

            return base.GetValidatedString(value);
        }

        /// <summary>
        /// Gets the control that is used to render the field.
        /// </summary>
        /// <returns>An <see cref="T:Microsoft.SharePoint.WebControls.BaseFieldControl"/> object that represents the rendering control.</returns>
        public override BaseFieldControl FieldRenderingControl
        {
            get
            {
                BaseFieldControl control = null;
                control = new AutocompleteLookupFieldControl();
                control.FieldName = this.InternalName;
                return control;
            }
        }

        /// <summary>
        /// Sets the field attribute.
        /// </summary>
        /// <param name="attribute">The attribute.</param>
        /// <param name="value">The value.</param>
        internal void SetFieldAttribute(string attribute, string value)
        {
            Type baseType = typeof(AutocompleteLookupField);
            MethodInfo mi = baseType.GetMethod("SetFieldAttributeValue", BindingFlags.Instance | BindingFlags.NonPublic);
            mi.Invoke(this, new object[] { attribute, value });
        }

        /// <summary>
        /// Gets the field attribute.
        /// </summary>
        /// <param name="attribute">The attribute.</param>
        /// <returns></returns>
        internal string GetFieldAttribute(string attribute)
        {
            Type baseType = typeof(AutocompleteLookupField);
            MethodInfo mi = baseType.GetMethod("GetFieldAttributeValue", BindingFlags.Instance | BindingFlags.NonPublic, null, new Type[] { typeof(String) }, null);
            object obj = mi.Invoke(this, new object[] { attribute });

            if (obj == null)
                return "";
            else
                return obj.ToString();
        }

        public override string JSLink
        {
            get
            {
                if (SPContext.Current.FormContext.FormMode != SPControlMode.Invalid)
                    return base.JSLink;
                else
                    return JSLinkUrl;
            }
            set
            {
                base.JSLink = value;
            }
        }
    }
}
