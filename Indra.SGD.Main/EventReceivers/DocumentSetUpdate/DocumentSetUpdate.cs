using System;
using System.Security.Permissions;
using Microsoft.SharePoint;
using Microsoft.SharePoint.Utilities;
using Microsoft.SharePoint.Workflow;
using System.Configuration;
using System.Collections.Generic;

namespace Indra.Projects.SGD.DocumentSetUpdate
{
    /// <summary>
    /// List Item Events
    /// </summary>
    public class DocumentSetUpdate : SPItemEventReceiver
    {
        /// <summary>
        /// Gets List of strings based on an array defined on App Settings
        /// </summary>
        /// <returns>List<string></string></returns>
        private List<String> GetContentTypeExceptionList()
        {
            List<string> result = new List<string>();
            if (ConfigurationManager.AppSettings["CTypesList"] != null)
                return new List<string>(ConfigurationManager.AppSettings["CTypesList"].Split(';'));

            return result;
        }

        /// <summary>
        /// An item has been added.
        /// </summary>
        public override void ItemAdded(SPItemEventProperties properties)
        {
            if (this.GetContentTypeExceptionList().Contains(properties.ListItem.ContentType.Name))
            {
  
            }
            base.ItemAdded(properties);
        }

        /// <summary>
        /// An item is being Added
        /// </summary>
        public override void ItemAdding(SPItemEventProperties properties)
        {
            base.ItemAdding(properties);
        }

        /// <summary>
        /// An item has been deleted
        /// </summary>
        public override void ItemDeleted(SPItemEventProperties properties)
        {
            base.ItemDeleted(properties);
        }

        /// <summary>
        /// An item is being deleted
        /// </summary>
        public override void ItemDeleting(SPItemEventProperties properties)
        {
            base.ItemDeleting(properties);
        }


    }
}