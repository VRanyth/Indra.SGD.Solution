using System;
using System.Security.Permissions;
using Microsoft.SharePoint;
using Microsoft.SharePoint.Utilities;
using Microsoft.SharePoint.Workflow;

namespace Indra.SGD.Main.EventReceivers.RelatedDocumentRemoved
{
    /// <summary>
    /// List Item Events
    /// </summary>
    public class RelatedDocumentRemoved : SPItemEventReceiver
    {
        /// <summary>
        /// remove Document relations
        /// </summary>
        /// <param name="docId"></param>
        private void RemoveDocumentRelations(int docId)
        {
            
        }


        /// <summary>
        /// An item was deleted.
        /// </summary>
        public override void ItemDeleted(SPItemEventProperties properties)
        {
            base.ItemDeleted(properties);
        }


    }
}